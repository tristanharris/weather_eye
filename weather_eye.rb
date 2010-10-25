#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'weather_eye'

w = WeatherEye.new
puts w.current.inspect
puts

#w.each do |sample|
#  puts sample.inspect
#end

