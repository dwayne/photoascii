#!/usr/bin/env ruby
#
# Convert photographs to ASCII.
#

require 'cgi'
require 'RMagick'

include Magick

photo = ImageList.new(ARGV.first)

# Step 1
# Convert pixels to their intensity values
# Also, figure out the number of rows and columns for the image
pixels = []
max_c = -1
max_r = -1
photo.each_pixel do |pixel, c, r|
  pixels << pixel.intensity
  max_c = [max_c, c].max
  max_r = [max_r, r].max
end

# Step 2
# We need to map the pixel values into the range of printable characters, so
# determine the smallest and highest intensities we're dealing with
max = pixels.max
min = pixels.min

# Step 3
# We will map:
#   min -> 32  (space)
#   max -> 126 (~)
# And interpolate everything else in-between
ascii = Array.new(max_r + 1) { Array.new(max_c + 1) }
photo.each_pixel do |pixel, c, r|
  if max == min
    code = 32
  else
    code = (94 * pixel.intensity + 32 * max - 126 * min) / (max - min)
  end

  ascii[r][c] = code.chr
end

# Step 4
# Display the darn thing
puts "<pre style=\"font-family: monospace; font-size: 5px\">"
(max_r + 1).times do |r|
  (max_c + 1).times do |c|
    print CGI.escapeHTML(ascii[r][c])
  end
  puts
end
puts "</pre>"
