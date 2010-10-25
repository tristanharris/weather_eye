class WeatherEye
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

