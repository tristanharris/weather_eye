#!/usr/bin/env ruby

#Try:
#w=WeatherEye.findAll[0]
#w.dev.usb_detach_kernel_driver_np 0,0
#out = ' '*60
#w.dev.usb_get_descriptor(1,0,out)
#w.dev.usb_get_descriptor(2,0,out)
#w.dev.usb_set_configuration(1)
#w.dev.usb_control_msg(0,0x0a,0x00,0,'',1000)
#
#w.dev.usb_control_msg(0x21,0x09,0x0200,0,[0xa1, 0, 0, 0x20, 0xa1, 0, 0, 0x20].pack('c*'),8)

require 'usb'

class HidData
	USBRQ_HID_GET_REPORT = 1
	USBRQ_HID_SET_REPORT = 9
	USB_HID_REPORT_TYPE_FEATURE = 3

	def initialize(dev_handle)
		@dev_handle = dev_handle
		@timeout = 5000
	end

	def dev
		@dev_handle
	end

	def readBlock(len, report_number=0)
		buffer = "\0" * len

		ret = @dev_handle.usb_control_msg(
			USB::USB_TYPE_CLASS | USB::USB_RECIP_DEVICE | USB::USB_ENDPOINT_IN,
			USBRQ_HID_GET_REPORT, 
			USB_HID_REPORT_TYPE_FEATURE << 8 | report_number,
			0, buffer, @timeout)

		if ret != len
			raise "read wrong number of bytes (#{ret} vs. #{len})"
		end

		return buffer
	end

	def writeBlockXX(buffer, report_number=0)
		len = buffer.length

		ret = @dev_handle.usb_control_msg(
			USB::USB_TYPE_CLASS | USB::USB_RECIP_DEVICE | USB::USB_ENDPOINT_OUT,
			USBRQ_HID_SET_REPORT, 
			USB_HID_REPORT_TYPE_FEATURE << 8 | report_number,
			0, buffer, @timeout)

		if ret != len
			raise "wrote wrong number of bytes (#{ret} vs. #{len})"
		end
	end
end

class WeatherEye < HidData
	VENDOR_ID = 0x1941
	PRODUCT_ID = 0x8021
	STATE_LEN = 8
	CONFIG_LEN = 128

	def initialize(dev_handle)
		super(dev_handle)
                #dev_handle.usb_detach_kernel_driver_np 0,0
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
          @dev_handle.usb_control_msg(0x21, 0x09, 0x0200, 0, cmd.pack('c*'), 10)
          buf = ' ' * 32
          @dev_handle.usb_bulk_read(1, buf, 10)
          buf
        end




	def _readState
		buffer = readBlock(STATE_LEN, 0)
		#puts "state = " + (buffer.unpack("C*").collect{|v| "%02x" % v}.join(" "))
		(accum, samps) = buffer.unpack('NN')
		@dn = accum.to_f / samps.to_f
		@temperature = @dn * @scale
	end

	def _readEeprom
		buffer = readBlock(CONFIG_LEN, 7)
		#puts "eeprom = " + buffer.unpack("C*").collect{|v| "%02x" % v}.join(" ")
		(@scale, @dev_id) = buffer.unpack('gN')
	end

	def _writeEeprom
		buffer = [@scale, @dev_id].pack("gN")
		buffer += "\0" * (CONFIG_LEN - buffer.length)
		writeBlock(buffer, 7)
	end

	def setMux(mux)
		buffer = [mux].pack('C')
		writeBlock(buffer, 1)
	end

	def calibration=(s)
		@scale = s
		_writeEeprom
	end

	def deviceID
		return @dev_id
	end

	def deviceID=(id)
		@dev_id = id
		_writeEeprom
	end

	def temperature(verbose=false)
		_readState
		if verbose
			puts "id=#{@dev_id} dn=#{"%.4f" % @dn} T=#{"%.4f" % @temperature}"
		end
		return @temperature
	end
end

