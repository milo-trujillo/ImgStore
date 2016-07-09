#!/usr/bin/env ruby

require 'chunky_png'

module ImgStore
	def ImgStore.encode(data, filename)
		# First, figure out how many pixels we need.
		# Remember that each pixel holds three bytes.
		pixelsNeeded = (data.size / 3)
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

		puts "Encoding image with size: #{size} (data is #{data.size} bytes)"
		white = ChunkyPNG::Color.rgb(255, 255, 255)
		image = ChunkyPNG::Image.new(size, size, white)
		bytes = data.bytes

		for y in (0 .. (size-1))
			for x in (0 .. (size-1))
				c = [bytes.shift, bytes.shift, bytes.shift]
				for i in (0 .. 2)
					if( c[i] == nil )
						c[i] = 255
					end
				end
				image[x,y] = ChunkyPNG::Color.rgb(c[0], c[1], c[2])
			end
		end

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
	end
end
