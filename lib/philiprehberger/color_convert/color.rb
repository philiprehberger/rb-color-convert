# frozen_string_literal: true

module Philiprehberger
  module ColorConvert
    # Represents a color with conversion, manipulation, and comparison methods.
    class Color
      # @return [Integer] red component (0-255)
      attr_reader :r

      # @return [Integer] green component (0-255)
      attr_reader :g

      # @return [Integer] blue component (0-255)
      attr_reader :b

      # @param r [Integer] red component (0-255)
      # @param g [Integer] green component (0-255)
      # @param b [Integer] blue component (0-255)
      def initialize(r, g, b)
        @r = clamp(r.round, 0, 255)
        @g = clamp(g.round, 0, 255)
        @b = clamp(b.round, 0, 255)
      end

      # Convert to hex string.
      #
      # @return [String] hex color string (e.g., "#ff0000")
      def to_hex
        format("#%<r>02x%<g>02x%<b>02x", r: @r, g: @g, b: @b)
      end

      # Convert to RGB hash.
      #
      # @return [Hash] with :r, :g, :b keys (0-255)
      def to_rgb
        { r: @r, g: @g, b: @b }
      end

      # Convert to HSL hash.
      #
      # @return [Hash] with :h (0-360), :s (0-100), :l (0-100) keys
      def to_hsl
        rf = @r / 255.0
        gf = @g / 255.0
        bf = @b / 255.0

        max = [rf, gf, bf].max
        min = [rf, gf, bf].min
        l = (max + min) / 2.0

        if max == min
          h = 0.0
          s = 0.0
        else
          d = max - min
          s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
          h = case max
              when rf then ((gf - bf) / d) + (gf < bf ? 6 : 0)
              when gf then ((bf - rf) / d) + 2
              else ((rf - gf) / d) + 4
              end
          h /= 6.0
        end

        { h: (h * 360).round(1), s: (s * 100).round(1), l: (l * 100).round(1) }
      end

      # Convert to HSV hash.
      #
      # @return [Hash] with :h (0-360), :s (0-100), :v (0-100) keys
      def to_hsv
        rf = @r / 255.0
        gf = @g / 255.0
        bf = @b / 255.0

        max = [rf, gf, bf].max
        min = [rf, gf, bf].min
        d = max - min

        v = max

        s = max.zero? ? 0.0 : d / max

        if max == min
          h = 0.0
        else
          h = case max
              when rf then ((gf - bf) / d) + (gf < bf ? 6 : 0)
              when gf then ((bf - rf) / d) + 2
              else ((rf - gf) / d) + 4
              end
          h /= 6.0
        end

        { h: (h * 360).round(1), s: (s * 100).round(1), v: (v * 100).round(1) }
      end

      # Lighten the color by a percentage.
      #
      # @param amount [Numeric] percentage to lighten (0-100)
      # @return [Color] a new lightened color
      def lighten(amount)
        hsl = to_hsl
        new_l = clamp(hsl[:l] + amount, 0, 100)
        self.class.from_hsl(hsl[:h], hsl[:s], new_l)
      end

      # Darken the color by a percentage.
      #
      # @param amount [Numeric] percentage to darken (0-100)
      # @return [Color] a new darkened color
      def darken(amount)
        lighten(-amount)
      end

      # Increase saturation by a percentage.
      #
      # @param amount [Numeric] percentage to increase saturation (0-100)
      # @return [Color] a new saturated color
      def saturate(amount)
        hsl = to_hsl
        new_s = clamp(hsl[:s] + amount, 0, 100)
        self.class.from_hsl(hsl[:h], new_s, hsl[:l])
      end

      # Decrease saturation by a percentage.
      #
      # @param amount [Numeric] percentage to decrease saturation (0-100)
      # @return [Color] a new desaturated color
      def desaturate(amount)
        saturate(-amount)
      end

      # Return the complementary color (180 degrees on the color wheel).
      #
      # @return [Color] the complement color
      def complement
        hsl = to_hsl
        new_h = (hsl[:h] + 180) % 360
        self.class.from_hsl(new_h, hsl[:s], hsl[:l])
      end

      # Calculate the WCAG contrast ratio between this color and another.
      #
      # @param other [Color] the other color
      # @return [Float] the contrast ratio (1.0 to 21.0)
      def contrast_ratio(other)
        l1 = relative_luminance
        l2 = other.relative_luminance
        lighter = [l1, l2].max
        darker = [l1, l2].min
        ((lighter + 0.05) / (darker + 0.05)).round(2)
      end

      # Calculate relative luminance per WCAG 2.0.
      #
      # @return [Float] luminance value (0.0 to 1.0)
      def relative_luminance
        rs = linearize(@r / 255.0)
        gs = linearize(@g / 255.0)
        bs = linearize(@b / 255.0)
        (0.2126 * rs) + (0.7152 * gs) + (0.0722 * bs)
      end

      # @return [String]
      def to_s
        to_hex
      end

      # @return [Boolean]
      def ==(other)
        other.is_a?(Color) && @r == other.r && @g == other.g && @b == other.b
      end

      # Create a Color from HSL values.
      #
      # @param h [Numeric] hue (0-360)
      # @param s [Numeric] saturation (0-100)
      # @param l [Numeric] lightness (0-100)
      # @return [Color]
      def self.from_hsl(h, s, l)
        h = h / 360.0
        s = s / 100.0
        l = l / 100.0

        if s.zero?
          val = (l * 255).round
          return new(val, val, val)
        end

        q = l < 0.5 ? l * (1 + s) : l + s - (l * s)
        p = (2 * l) - q

        r = hue_to_rgb(p, q, h + (1.0 / 3))
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - (1.0 / 3))

        new((r * 255).round, (g * 255).round, (b * 255).round)
      end

      # @api private
      def self.hue_to_rgb(p, q, t)
        t += 1 if t.negative?
        t -= 1 if t > 1
        return p + ((q - p) * 6 * t) if t < 1.0 / 6
        return q if t < 1.0 / 2
        return p + ((q - p) * ((2.0 / 3) - t) * 6) if t < 2.0 / 3

        p
      end

      private

      def clamp(value, min, max)
        [[value, min].max, max].min
      end

      def linearize(channel)
        if channel <= 0.03928
          channel / 12.92
        else
          ((channel + 0.055) / 1.055)**2.4
        end
      end
    end
  end
end
