#!/usr/bin/env ruby
require_relative '../ImgStore'

puts "Encoding..."
ImgStore.encode(File.read("example.wav"), "example.png")
puts "Decoding..."
ImgStore.decode(File.read("example.png"), "recovered.wav")
