#!/usr/bin/env ruby
#
# Convert photographs to ASCII.
#

require 'cgi'
require 'RMagick'

include Magick

class ASCIIPalette

  # The default sequence of ASCII characters were taken from
  # http://members.optusnet.com.au/astroblue/grey_scale.txt
  def initialize(ascii = "#@8%0o\";,'. ", bit_depth = 16)
    @ascii = ascii
    @max_intensity = (1<<16) - 1
  end

  def size
    @ascii.length
  end

  def to_ascii(value)
    index = value * (size - 1) / @max_intensity
    @ascii[index]
  end
end

palette = ASCIIPalette.new

photo = ImageList.new(ARGV.first)

nrows = photo.rows
ncols = photo.columns

# Step 1 - Convert to grayscale
# N.B. This step isn't necessarily needed and
# could be toggled using a config option
photo = photo.quantize(256, Magick::GRAYColorspace)

# Step 2 - Convert to ASCII
ascii = Array.new(nrows) { Array.new(ncols) }
photo.each_pixel do |pixel, c, r|
  ascii[r][c] = palette.to_ascii(pixel.intensity)
end

# Step 3 - Display the darn thing
puts "<pre style=\"font-family: monospace; font-size: 5px\">"
nrows.times do |r|
  ncols.times do |c|
    print CGI.escapeHTML(ascii[r][c])
  end
  puts
end
puts "</pre>"
