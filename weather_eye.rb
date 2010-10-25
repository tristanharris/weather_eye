#!/usr/bin/env ruby

#Try:
#w=WeatherEye::Usb.findAll[0]
#w.read(0x6810)

#out = ' '*60
#w.dev.usb_get_descriptor(1,0,out)
#w.dev.usb_get_descriptor(2,0,out)
#w.dev.usb_set_configuration(1)
#w.dev.usb_control_msg(0,0x0a,0x00,0,'',1000)
#
#w.dev.usb_control_msg(0x21,0x09,0x0200,0,[0xa1, 0, 0, 0x20, 0xa1, 0, 0, 0x20].pack('c*'),8)

require 'usb'
class Time
  # File activesupport/lib/active_support/core_ext/time/calculations.rb, line 73
  def change(options)
    ::Time.send(
      utc? ? :utc : :local,
      options[:year]  || year,
      options[:month] || month,
      options[:day]   || day,
      options[:hour]  || hour,
      options[:min]   || (options[:hour] ? 0 : min),
      options[:sec]   || ((options[:hour] || options[:min]) ? 0 : sec),
      options[:usec]  || ((options[:hour] || options[:min] || options[:sec]) ? 0 : usec)
    )
  end
end

class WeatherEye
  class Usb
    VENDOR_ID = 0x1941
    PRODUCT_ID = 0x8021
    DATA_LEN = 32
    USBRQ_HID_SET_REPORT = 9

    def initialize(dev_handle)
      @dev_handle = dev_handle
      @timeout = 1000
      begin
        @dev_handle.usb_detach_kernel_driver_np 0,0
        @dev_handle.usb_claim_interface 0
      rescue Errno::ENOENT
      end
    end

    def dev
      @dev_handle
    end

    def self.findAll
      usb_devs = USB.devices.select { |d|
        d.idVendor == VENDOR_ID &&
        d.idProduct == PRODUCT_ID
      }
      return usb_devs.collect { |dev|
        h = dev.open
        self.new(h)
      }
    end

    def read(addr)
      cmd = [0xa1, 0, 0, 0x20, 0xa1, 0, 0, 0x20]
      cmd[1] = addr >> 8 & 0xff
      cmd[2] = addr & 0xff
      cmd[5] = cmd[1]
      cmd[6] = cmd[2]
      @dev_handle.usb_control_msg(0x21, USBRQ_HID_SET_REPORT, 0x0200, 0, cmd.pack('c*'), @timeout)
      buf = ' ' * DATA_LEN
      @dev_handle.usb_bulk_read(1, buf, @timeout)
      buf
    end
  end

  class Sample
    ATTRS = [:time, :offset, :humidity_in, :temp_in, :humidity_out, :temp_out, :pressure,
             :wind_speed, :gust_speed, :direction, :rain]
    attr_reader *ATTRS

    WIND_TRANDUCER_FACTOR = 0.38
    RAIN_TRANDUCER_FACTOR = 0.3
    TEMP_FACTOR = 10.0
    PRESSURE_FACTOR = 10.0

    def self.from_raw(raw, time)
      raw = raw.split(//).map{|byte| byte[0]}
      data = {}
      data[:time] = time
      data[:offset] = raw[0] # minutes after last sample
      data[:humidity_in] = raw[1]
      data[:temp_in] = (raw[3] << 8) + raw[2]
      data[:humidity_out] = raw[4]
      data[:temp_out] = (raw[6] << 8) + raw[5]
      data[:pressure] = (raw[8] << 8) + raw[7]
      data[:wind_speed] = ((raw[11] & 0x0f) << 8) + raw[9]
      data[:gust_speed] = ((raw[11] & 0xf0) << 4) + raw[10]
      data[:direction] = raw[12]
      data[:rain] = ((raw[14] << 8) + raw[13])
      status = raw[15]

      data[:humidity_in] = nil if data[:humidity_in] == 0xff
      data[:temp_in] = nil if data[:temp_in] == 0xffff
      data[:humidity_out] = nil if data[:humidity_out] == 0xff
      data[:temp_out] = nil if data[:temp_out] == 0xffff
      data[:pressure] = nil if data[:pressure] == 0xffff
      data[:wind_speed] = nil if raw[9] == 0xff
      data[:gust_speed] = nil if raw[10] == 0xff
      data[:direction] = nil if data[:direction][7] > 0
      data[:rain] = nil if status[6] > 0
      raise 'rain overflow' if status[7] > 0

      data[:temp_in] = -(data[:temp_in] & 0x7fff) if data[:temp_in][15] > 0
      data[:temp_out] = -(data[:temp_out] & 0x7fff) if data[:temp_out][15] > 0

      data[:temp_in] /= TEMP_FACTOR
      data[:temp_out] /= TEMP_FACTOR
      data[:pressure] /= PRESSURE_FACTOR
      data[:wind_speed] *= WIND_TRANDUCER_FACTOR
      data[:gust_speed] *= WIND_TRANDUCER_FACTOR
      data[:rain] *= RAIN_TRANDUCER_FACTOR

      self.new(data)
    end

    def initialize(data)
      ATTRS.each do |a|
        instance_variable_set "@#{a}", data[a]
      end
    end

  end

  class Config
    attr :data

    def initialize(device)
      @device = device
      reload!
    end

    def reload!
      @data = []
      8.times do |i|
        @data += @device.read(i * 0x20).split(//).map{|b| b[0]}
      end
    end

    def bytes(addr, len=1)
      val = 0
      len.times do |i|
        val += @data[addr] << (i * 8)
        addr += 1
      end
      val
    end


    def sampling_interval
      bytes(0x10)
    end

    def data_sets
      bytes(0x1b, 2)
    end

    def data_start
      bytes(0x1e, 2)
    end

  end

  def initialize
    @device = Usb.findAll[0]
  end

  def current
    config = Config.new(@device)
    addr = config.data_start
    Sample.from_raw(@device.read(addr), Time.now)
  end

  def each
    config = Config.new(@device)
    addr = config.data_start
    config.data_sets
    sample = Sample.from_raw(@device.read(addr), Time.now.change(:sec => 0))
    config.data_sets.times do
      addr = (addr + 0x20) % 0x10000
      time = sample.time - (sample.offset * 60)
      sample = Sample.from_raw(@device.read(addr), time)
      yield sample
    end
  end
end

#w = WeatherEye.new
#puts w.current.inspect
#puts

#w.each do |sample|
#  puts sample.inspect
#end

