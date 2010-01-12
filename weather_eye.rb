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

module WeatherEye
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
end

