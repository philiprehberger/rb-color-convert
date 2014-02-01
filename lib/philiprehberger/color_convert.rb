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
    # - RGB: "rgb(255, 0, 0)"
    # - HSL: "hsl(0, 100%, 50%)"
    # - HSV: "hsv(0, 100%, 100%)"
    # - CSS named colors: "red", "blue", "cornflowerblue"
    #
    # @param str [String] the color string to parse
    # @return [Color] the parsed color
    # @raise [ParseError] if the string cannot be parsed
    def self.parse(str)
      input = str.to_s.strip.downcase

      # Try named colors first
      if NAMED_COLORS.key?(input)
        return parse_hex(NAMED_COLORS[input])
      end

      # Hex format
      if input.match?(/\A#?[0-9a-f]{3,8}\z/)
        return parse_hex(input)
      end

      # RGB format
      if (match = input.match(/\Argb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\z/))
        return Color.new(match[1].to_i, match[2].to_i, match[3].to_i)
      end

      # HSL format
      if (match = input.match(/\Ahsl\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*\)\z/))
        return Color.from_hsl(match[1].to_f, match[2].to_f, match[3].to_f)
      end

      # HSV format
      if (match = input.match(/\Ahsv\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*\)\z/))
        return from_hsv(match[1].to_f, match[2].to_f, match[3].to_f)
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
      hex = str.delete("#")

      case hex.length
      when 3
        r = hex[0] * 2
        g = hex[1] * 2
        b = hex[2] * 2
      when 6, 8
        r = hex[0..1]
        g = hex[2..3]
        b = hex[4..5]
      else
        raise ParseError, "Invalid hex color: #{str}"
      end

      Color.new(r.to_i(16), g.to_i(16), b.to_i(16))
    end
    private_class_method :parse_hex
  end
end

require_relative "color_convert/version"
require_relative "color_convert/named_colors"
require_relative "color_convert/color"
