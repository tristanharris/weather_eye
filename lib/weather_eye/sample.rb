  class WeatherEye::Sample
    ATTRS = [:time, :indoor_humidity, :indoor_temperature, :outdoor_humidity,
              :outdoor_temperature, :pressure, :wind_speed, :gust_speed, :wind_direction, :rainfall]
    attr_reader *ATTRS
    attr_reader :offset

    WIND_TRANDUCER_FACTOR = 0.38
    RAIN_TRANDUCER_FACTOR = 0.3
    TEMP_FACTOR = 10.0
    PRESSURE_FACTOR = 10.0

    def self.from_raw(raw, time)
      raw = raw.split(//).map{|byte| byte[0]}
      data = {}
      data[:time] = time
      data[:offset] = raw[0] # minutes after last sample
      data[:indoor_humidity] = raw[1]
      data[:indoor_temperature] = (raw[3] << 8) + raw[2]
      data[:outdoor_humidity] = raw[4]
      data[:outdoor_temperature] = (raw[6] << 8) + raw[5]
      data[:pressure] = (raw[8] << 8) + raw[7]
      data[:wind_speed] = ((raw[11] & 0x0f) << 8) + raw[9]
      data[:gust_speed] = ((raw[11] & 0xf0) << 4) + raw[10]
      data[:wind_direction] = raw[12]
      data[:rainfall] = ((raw[14] << 8) + raw[13])
      status = raw[15]

      data[:indoor_humidity] = nil if data[:indoor_humidity] == 0xff
      data[:indoor_temperature] = nil if data[:indoor_temperature] == 0xffff
      data[:outdoor_humidity] = nil if data[:outdoor_humidity] == 0xff
      data[:outdoor_temperature] = nil if data[:outdoor_temperature] == 0xffff
      data[:pressure] = nil if data[:pressure] == 0xffff
      data[:wind_speed] = nil if raw[9] == 0xff
      data[:gust_speed] = nil if raw[10] == 0xff
      data[:wind_direction] = nil if data[:wind_direction][7] > 0
      data[:rainfall] = nil if status[6] > 0
      raise 'rain overflow' if status[7] > 0

      data[:indoor_temperature] = -(data[:indoor_temperature] & 0x7fff) if data[:indoor_temperature][15] > 0
      data[:outdoor_temperature] = -(data[:outdoor_temperature] & 0x7fff) if data[:outdoor_temperature][15] > 0

      data[:indoor_temperature] /= TEMP_FACTOR
      data[:outdoor_temperature] /= TEMP_FACTOR
      data[:pressure] /= PRESSURE_FACTOR
      data[:wind_speed] *= WIND_TRANDUCER_FACTOR
      data[:gust_speed] *= WIND_TRANDUCER_FACTOR
      data[:rainfall] *= RAIN_TRANDUCER_FACTOR

      self.new(data)
    end

    def initialize(data)
      ATTRS.each do |a|
        instance_variable_set "@#{a}", data[a]
      end
      offset = data[:offset]
    end

    def to_h
      ATTRS.inject({}){|h, a| h[a] = instance_variable_get("@#{a}");h}
    end

    def md5
      Digest::MD5.hexdigest(data = ATTRS.map do |a|
        v = instance_variable_get("@#{a}")
        v = v.to_i if (v.is_a? Time)
        v.to_f.to_s
      end.join)
    end

  end


