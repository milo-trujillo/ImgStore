#!/usr/bin/env ruby

require 'benchmark'
require_relative '../ImgStore'

Kibibyte = 1024
Mebibyte = 1024 * Kibibyte

sizes = [100, Kibibyte, 10 * Kibibyte, Mebibyte, 5 * Mebibyte, 20 * Mebibyte]

puts "=== Testing encoding times ==="
Benchmark.bm(10) do |x|
	for size in sizes
		data = "X" * size
		x.report("#{size}:") { ImgStore.encode(data, "#{size}.png") }
	end
end

puts "=== Testing decoding times ==="
Benchmark.bm(10) do |x|
	for size in sizes
		data = File.read("#{size}.png")
		x.report("#{size}:") { ImgStore.decode(data, "#{size}.recovered") }
	end
end

# Now cleanup
for size in sizes
	for name in ["#{size}.png", "#{size}.recovered"]
		if( File.exists?(name) )
			File.unlink(name)
		end
	end
end
