#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'weather_eye'
require "net/http"
require 'digest'

 SECRET = ENV['WEATHER_SECRET'] || 'you need to set this'

w = WeatherEye.new
data = w.current
puts data.to_h.inspect
params = {}
data.to_h.each_pair{|k, v| params["data[#{k}]"] = v}
params[:md5] = Digest::MD5.hexdigest(data.md5 + SECRET)
x = Net::HTTP.post_form(URI.parse('http://localhost:9393/data'), params)
puts x.body
#w.back_to(Time.now - 50*60) do |sample|
#  puts sample.inspect
#end

#w.each do |sample|
#  puts sample.inspect
#end

