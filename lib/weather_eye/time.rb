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

