# frozen_string_literal: true

module Philiprehberger
  module ColorConvert
    class Error < StandardError; end

    # Raised when a color string cannot be parsed.
    class ParseError < Error; end

    # Parse a color string into a {Color} object.
    #
    # Supported formats:
    # - Hex: "#ff0000", "#f00", "ff0000", "f00"
    # - Hex with alpha: "#rrggbbaa" (8-digit)
    # - RGB: "rgb(255, 0, 0)"
    # - RGBA: "rgba(255, 0, 0, 0.5)"
    # - HSL: "hsl(0, 100%, 50%)"
    # - HSLA: "hsla(0, 100%, 50%, 0.5)"
    # - HSV: "hsv(0, 100%, 100%)"
    # - CMYK: "cmyk(0, 100%, 100%, 0)"
    # - CSS named colors: "red", "blue", "cornflowerblue"
    #
    # @param str [String] the color string to parse
    # @return [Color] the parsed color
    # @raise [ParseError] if the string cannot be parsed
    def self.parse(str)
      input = str.to_s.strip.downcase

      # Try named colors first
      return parse_hex(NAMED_COLORS[input]) if NAMED_COLORS.key?(input)

      # Hex format (3, 6, or 8 digits)
      return parse_hex(input) if input.match?(/\A#?[0-9a-f]{3,8}\z/)

      # RGBA format
      if (match = input.match(/\Argba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)\z/))
        return Color.new(match[1].to_i, match[2].to_i, match[3].to_i, alpha: match[4].to_f)
      end

      # RGB format
      if (match = input.match(/\Argb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\z/))
        return Color.new(match[1].to_i, match[2].to_i, match[3].to_i)
      end

      # HSLA format
      if (match = input.match(/\Ahsla\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)\s*\)\z/))
        return Color.from_hsl(match[1].to_f, match[2].to_f, match[3].to_f, alpha: match[4].to_f)
      end

      # HSL format
      if (match = input.match(/\Ahsl\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*\)\z/))
        return Color.from_hsl(match[1].to_f, match[2].to_f, match[3].to_f)
      end

      # HSV format
      if (match = input.match(/\Ahsv\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*\)\z/))
        return from_hsv(match[1].to_f, match[2].to_f, match[3].to_f)
      end

      # CMYK format
      if (match = input.match(/\Acmyk\(\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*\)\z/))
        return Color.from_cmyk(match[1].to_f, match[2].to_f, match[3].to_f, match[4].to_f)
      end

      raise ParseError, "Cannot parse color: #{str}"
    end

    # Return all CSS named colors as a hash of name => hex.
    #
    # @return [Hash{String => String}]
    def self.named_colors
      NAMED_COLORS
    end

    # Create a Color from HSV values.
    #
    # @param h [Numeric] hue (0-360)
    # @param s [Numeric] saturation (0-100)
    # @param v [Numeric] value/brightness (0-100)
    # @return [Color]
    def self.from_hsv(h, s, v)
      s /= 100.0
      v /= 100.0
      c = v * s
      x = c * (1 - (((h / 60.0) % 2) - 1).abs)
      m = v - c

      r, g, b = case (h / 60.0).floor % 6
                when 0 then [c, x, 0]
                when 1 then [x, c, 0]
                when 2 then [0, c, x]
                when 3 then [0, x, c]
                when 4 then [x, 0, c]
                else [c, 0, x]
                end

      Color.new(((r + m) * 255).round, ((g + m) * 255).round, ((b + m) * 255).round)
    end

    # @api private
    def self.parse_hex(str)
      hex = str.delete('#')

      case hex.length
      when 3
        r = hex[0] * 2
        g = hex[1] * 2
        b = hex[2] * 2
        Color.new(r.to_i(16), g.to_i(16), b.to_i(16))
      when 6
        r = hex[0..1]
        g = hex[2..3]
        b = hex[4..5]
        Color.new(r.to_i(16), g.to_i(16), b.to_i(16))
      when 8
        r = hex[0..1]
        g = hex[2..3]
        b = hex[4..5]
        a = hex[6..7].to_i(16) / 255.0
        Color.new(r.to_i(16), g.to_i(16), b.to_i(16), alpha: a.round(6))
      else
        raise ParseError, "Invalid hex color: #{str}"
      end
    end
    private_class_method :parse_hex
  end
end

require_relative 'color_convert/version'
require_relative 'color_convert/named_colors'
require_relative 'color_convert/color'
