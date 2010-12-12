#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'weather_eye'
require "net/http"
require 'digest'
require 'json'
require 'time'

 SECRET = ENV['WEATHER_SECRET'] || 'you need to set this'

w = WeatherEye.new
data = w.current

x = Net::HTTP.get(URI.parse('http://localhost:9393/last'))
start_time = Time.parse(JSON.parse(x)['latest_record'])

w.back_to(start_time) do |sample|
  puts '-----'+sample.inspect
  data=sample
  params = {}
  data.to_h.each_pair{|k, v| params["data[#{k}]"] = v}
  params[:md5] = Digest::MD5.hexdigest(data.md5 + SECRET)
  x = Net::HTTP.post_form(URI.parse('http://localhost:9393/data'), params)
  puts x.body
end

#w.each do |sample|
#  puts sample.inspect
#end

