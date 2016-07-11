#!/usr/bin/env ruby

begin
	require 'oily_png'
rescue LoadError
	require 'chunky_png'
	puts 'oily_png gem not installed. Using pure chunky_png. This might be slow!'
end

module ImgStore
	def ImgStore.encode(data, filename)
		# First, figure out how many pixels we need.
		# Remember that each pixel holds three bytes.
		bytes = data.bytes
		pixelsNeeded = (bytes.size / 3)
		if( pixelsNeeded % 1 == 0 )
			pixelsNeeded = pixelsNeeded.to_i
		else
			pixelsNeeded = pixelsNeeded.to_i + 1
		end

		# Find the smallest square large enough to hold our data
		size = 0
		root = Math.sqrt(pixelsNeeded)
		if( root % 1 == 0 )
			size = root.to_i
		else
			size = root.to_i + 1
		end

		puts "Encoding image with size: #{size} (data is #{bytes.size} bytes)"
		white = ChunkyPNG::Color.rgb(255, 255, 255)
		image = ChunkyPNG::Image.new(size, size, white)
		written = 0

		for y in (0 .. (size-1))
			for x in (0 .. (size-1))
				c = [bytes.shift, bytes.shift, bytes.shift]
				written += 3
				for i in (0 .. 2)
					if( c[i] == nil )
						c[i] = 255
						written -= 1
					end
				end
				image[x,y] = ChunkyPNG::Color.rgb(c[0], c[1], c[2])
			end
		end

		puts "Encoded #{written} bytes into #{filename}"
		image.save(filename, :fast_rgb) # Save as RGB, not RGBA
	end

	def ImgStore.decode(data, filename)
		image = ChunkyPNG::Image.from_blob(data)
		if( image.width != image.height )
			puts("WARNING: Image is not square (not created by this program)"+
				"but I'll try to decode it...")
		elsif( image.palette.opaque? == false )
			puts("ERROR: Image is RGBA, and is not supported!")
			return
		end

		bytes = []
		trailingNulls = 0
		read = 0
		
		for y in (0 .. (image.height-1))
			for x in (0 .. (image.width-1))
				c = image[x,y]
				channels = [ChunkyPNG::Color.r(c), 
					ChunkyPNG::Color.g(c),
					ChunkyPNG::Color.b(c)]
				for byte in channels
					if( byte == 255 )
						trailingNulls += 1
					else
						trailingNulls = 0
					end
					bytes.push(byte)
					read += 1
				end
			end
		end	

		if( trailingNulls != 0 )
			puts ("WARNING: #{filename} may have up to " +
				"#{trailingNulls} extra null bytes")
		end

		f = File.open(filename, "wb")
			for byte in bytes
				f.print(byte.chr)
			end
		f.close
		puts "Decoded #{read} bytes and saved to #{filename}"
	end
end
