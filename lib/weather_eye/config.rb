  class WeatherEye::Config
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

