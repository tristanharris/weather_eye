  class WeatherEye::Sample
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

    def to_h
      ATTRS.inject({}){|h, a| h[a] = instance_variable_get("@#{a}");h}
    end

  end


