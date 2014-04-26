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
    @max_intensity = (1<<bit_depth) - 1
  end

  def size
    @ascii.length
  end

  def to_ascii(value)
    index = value * (size - 1) / @max_intensity
    @ascii[index]
  end

  def to_index(ascii)
    @ascii.index(ascii)
  end
end

class ASCIIConverter

  attr_reader :nrows, :ncols, :palette

  def initialize(photo, palette = ASCIIPalette.new)
    @photo = photo

    @nrows = photo.rows
    @ncols = photo.columns

    @palette = palette
  end

  def convert(grayscale = true)
    photo = grayscale ? @photo.quantize(256, Magick::GRAYColorspace) : @photo

    ascii = Array.new(@nrows) { Array.new(ncols) }
    photo.each_pixel do |pixel, c, r|
      ascii[r][c] = @palette.to_ascii(pixel.intensity)
    end

    ascii
  end
end

class Renderer

  def initialize(ascii, palette, nrows, ncols)
    @ascii = ascii
    @palette = palette
    @nrows = nrows
    @ncols = ncols
  end

  def render
    [render_header, render_body, render_footer].join
  end

  protected

    def render_body
      body = []

      @nrows.times do |r|
        @ncols.times do |c|
          body << render_ascii(@ascii[r][c], r, c)
        end

        body << render_separator unless r+1 == @nrows
      end

      body.join
    end

    def render_separator
      "\n"
    end

    # Override these methods to define your renderer
    def render_header; end
    def render_footer; end
    def render_ascii(ascii, r, c); end
end

class TextRenderer < Renderer

  def render_ascii(ascii, r, c)
    ascii
  end
end

class HTMLRenderer < Renderer

  def render_header
    "<pre class=\"photoascii\">"
  end

  def render_ascii(ascii, r, c)
    position_class_name = "ascii-#{r}-#{c}"
    color_class_name = "ascii-#{@palette.to_index(ascii)}"

    "<span class=\"ascii #{position_class_name} #{color_class_name}\">#{CGI.escapeHTML(ascii)}</span>"
  end

  def render_footer
    "</pre>"
  end
end

class HTMLDocumentRenderer < HTMLRenderer

  def color_map=(map)
    @_color_map = map
  end

  def color_map
    # Default to a grayscale color scheme
    @_color_map ||= ['#000', '#111', '#222', '#333', '#666', '#777', '#888', '#999', '#aaa', '#ccc', '#eee', '#fff']
  end

  def render
    <<-HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">

    <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <!--[if IE]>
      <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <title>Photo ASCII</title>
    <style>
      .photoascii {
        font-family: monospace;
        font-size: 5px;
      }

      .ascii-0 {
        color: #{color_map[0]};
      }
      .ascii-1 {
        color: #{color_map[1]};
      }
      .ascii-2 {
        color: #{color_map[2]};
      }
      .ascii-3 {
        color: #{color_map[3]};
      }
      .ascii-4 {
        color: #{color_map[4]};
      }
      .ascii-5 {
        color: #{color_map[5]};
      }
      .ascii-6 {
        color: #{color_map[6]};
      }
      .ascii-7 {
        color: #{color_map[7]};
      }
      .ascii-8 {
        color: #{color_map[8]};
      }
      .ascii-9 {
        color: #{color_map[9]};
      }
      .ascii-10 {
        color: #{color_map[10]};
      }
      .ascii-11 {
        color: #{color_map[11]};
      }
    </style>
  </head>
  <body>
    #{super}
  </body>
</html>
    HTML
  end
end

photo = ImageList.new(ARGV.first)

converter = ASCIIConverter.new(photo)
ascii = converter.convert

puts HTMLDocumentRenderer.new(ascii, converter.palette, converter.nrows, converter.ncols).render
