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

      # @return [Float] alpha component (0.0-1.0)
      attr_reader :alpha

      # @param r [Integer] red component (0-255)
      # @param g [Integer] green component (0-255)
      # @param b [Integer] blue component (0-255)
      # @param alpha [Float] alpha component (0.0-1.0, default 1.0)
      def initialize(r, g, b, alpha: 1.0)
        @r = clamp(r.round, 0, 255)
        @g = clamp(g.round, 0, 255)
        @b = clamp(b.round, 0, 255)
        @alpha = clamp(alpha.to_f, 0.0, 1.0)
      end

      # Convert to hex string.
      #
      # @return [String] hex color string (e.g., "#ff0000")
      def to_hex
        format('#%<r>02x%<g>02x%<b>02x', r: @r, g: @g, b: @b)
      end

      # Convert to RGB hash.
      #
      # @return [Hash] with :r, :g, :b keys (0-255)
      def to_rgb
        { r: @r, g: @g, b: @b }
      end

      # Convert to RGBA hash.
      #
      # @return [Hash] with :r, :g, :b (0-255) and :a (0.0-1.0) keys
      def to_rgba
        { r: @r, g: @g, b: @b, a: @alpha }
      end

      # Return the opacity (alpha) value.
      #
      # @return [Float] alpha value (0.0-1.0)
      def opacity
        @alpha
      end

      # Return a new Color with the given opacity.
      #
      # @param val [Float] new alpha value (0.0-1.0)
      # @return [Color] a new Color with the updated alpha
      def with_opacity(val)
        self.class.new(@r, @g, @b, alpha: val)
      end

      # @return [Boolean] true if the color is fully opaque (alpha == 1.0)
      def opaque?
        (@alpha - 1.0).abs < Float::EPSILON
      end

      # @return [Boolean] true if the color has any transparency (alpha < 1.0)
      def transparent?
        !opaque?
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

      # Convert to CMYK hash.
      #
      # @return [Hash] with :c, :m, :y, :k keys (0-100)
      def to_cmyk
        rf = @r / 255.0
        gf = @g / 255.0
        bf = @b / 255.0

        k = 1.0 - [rf, gf, bf].max

        if k >= 1.0
          return { c: 0.0, m: 0.0, y: 0.0, k: 100.0 }
        end

        c = (1.0 - rf - k) / (1.0 - k)
        m = (1.0 - gf - k) / (1.0 - k)
        y = (1.0 - bf - k) / (1.0 - k)

        { c: (c * 100).round(1), m: (m * 100).round(1), y: (y * 100).round(1), k: (k * 100).round(1) }
      end

      # Convert to CIELAB hash via XYZ (D65 illuminant).
      #
      # @return [Hash] with :l (0-100), :a (approx -128 to 127), :b (approx -128 to 127) keys
      def to_lab
        xyz = to_xyz
        x = xyz[:x] / 95.047
        y = xyz[:y] / 100.0
        z = xyz[:z] / 108.883

        x = lab_f(x)
        y = lab_f(y)
        z = lab_f(z)

        l = (116.0 * y) - 16.0
        a = 500.0 * (x - y)
        b = 200.0 * (y - z)

        { l: l.round(2), a: a.round(2), b: b.round(2) }
      end

      # Convert to CIE XYZ color space (D65 illuminant).
      #
      # @return [Hash] with :x, :y, :z keys
      def to_xyz
        rf = linearize_srgb(@r / 255.0) * 100.0
        gf = linearize_srgb(@g / 255.0) * 100.0
        bf = linearize_srgb(@b / 255.0) * 100.0

        x = (rf * 0.4124564) + (gf * 0.3575761) + (bf * 0.1804375)
        y = (rf * 0.2126729) + (gf * 0.7151522) + (bf * 0.0721750)
        z = (rf * 0.0193339) + (gf * 0.1191920) + (bf * 0.9503041)

        { x: x.round(4), y: y.round(4), z: z.round(4) }
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

      # Blend this color with another color.
      #
      # @param other [Color] the other color to blend with
      # @param weight [Float] blend weight (0.0 = all self, 1.0 = all other, 0.5 = equal mix)
      # @return [Color] the blended color
      def blend(other, weight: 0.5)
        w = clamp(weight.to_f, 0.0, 1.0)
        new_r = (@r * (1.0 - w)) + (other.r * w)
        new_g = (@g * (1.0 - w)) + (other.g * w)
        new_b = (@b * (1.0 - w)) + (other.b * w)
        self.class.new(new_r.round, new_g.round, new_b.round)
      end

      # Generate analogous colors (30 degrees apart on the color wheel).
      #
      # @return [Array<Color>] array of 3 colors: -30deg, self, +30deg
      def analogous
        hsl = to_hsl
        [
          self.class.from_hsl((hsl[:h] - 30) % 360, hsl[:s], hsl[:l]),
          self.class.new(@r, @g, @b),
          self.class.from_hsl((hsl[:h] + 30) % 360, hsl[:s], hsl[:l])
        ]
      end

      # Generate triadic colors (120 degrees apart on the color wheel).
      #
      # @return [Array<Color>] array of 3 colors
      def triadic
        hsl = to_hsl
        [
          self.class.new(@r, @g, @b),
          self.class.from_hsl((hsl[:h] + 120) % 360, hsl[:s], hsl[:l]),
          self.class.from_hsl((hsl[:h] + 240) % 360, hsl[:s], hsl[:l])
        ]
      end

      # Generate tetradic (rectangular) colors (90 degrees apart).
      #
      # @return [Array<Color>] array of 4 colors
      def tetradic
        hsl = to_hsl
        [
          self.class.new(@r, @g, @b),
          self.class.from_hsl((hsl[:h] + 90) % 360, hsl[:s], hsl[:l]),
          self.class.from_hsl((hsl[:h] + 180) % 360, hsl[:s], hsl[:l]),
          self.class.from_hsl((hsl[:h] + 270) % 360, hsl[:s], hsl[:l])
        ]
      end

      # Generate split-complementary colors (150 and 210 degrees from base).
      #
      # @return [Array<Color>] array of 3 colors
      def split_complementary
        hsl = to_hsl
        [
          self.class.new(@r, @g, @b),
          self.class.from_hsl((hsl[:h] + 150) % 360, hsl[:s], hsl[:l]),
          self.class.from_hsl((hsl[:h] + 210) % 360, hsl[:s], hsl[:l])
        ]
      end

      # Simulate color blindness.
      #
      # @param type [Symbol] one of :protanopia, :deuteranopia, :tritanopia
      # @return [Color] the simulated color
      # @raise [ArgumentError] if type is not recognized
      def simulate_color_blindness(type)
        matrix = COLOR_BLINDNESS_MATRICES[type]
        raise ArgumentError, "Unknown color blindness type: #{type}" unless matrix

        rf = @r / 255.0
        gf = @g / 255.0
        bf = @b / 255.0

        # Convert to linear RGB
        rl = linearize_srgb(rf)
        gl = linearize_srgb(gf)
        bl = linearize_srgb(bf)

        # Apply simulation matrix
        new_r = (matrix[0][0] * rl) + (matrix[0][1] * gl) + (matrix[0][2] * bl)
        new_g = (matrix[1][0] * rl) + (matrix[1][1] * gl) + (matrix[1][2] * bl)
        new_b = (matrix[2][0] * rl) + (matrix[2][1] * gl) + (matrix[2][2] * bl)

        # Convert back to sRGB
        new_r = delinearize_srgb(clamp(new_r, 0.0, 1.0))
        new_g = delinearize_srgb(clamp(new_g, 0.0, 1.0))
        new_b = delinearize_srgb(clamp(new_b, 0.0, 1.0))

        self.class.new((new_r * 255).round, (new_g * 255).round, (new_b * 255).round)
      end

      # Generate a gradient palette between this color and another.
      #
      # @param other [Color] the target color
      # @param steps [Integer] number of colors in the gradient (minimum 2)
      # @return [Array<Color>] array of colors forming a gradient
      def gradient(other, steps: 5)
        steps = [steps, 2].max
        (0...steps).map do |i|
          weight = i / (steps - 1).to_f
          blend(other, weight: weight)
        end
      end

      # Generate a monochromatic palette by varying lightness.
      #
      # @param steps [Integer] number of shades to generate (minimum 2)
      # @return [Array<Color>] array of colors from dark to light
      def monochromatic(steps: 5)
        steps = [steps, 2].max
        hsl = to_hsl
        step_size = 100.0 / (steps + 1)

        (1..steps).map do |i|
          self.class.from_hsl(hsl[:h], hsl[:s], step_size * i)
        end
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

      # Classify the color temperature based on HSL hue.
      #
      # @return [Symbol] :warm, :cool, or :neutral
      def temperature
        hue = to_hsl[:h]

        if hue <= 60 || hue >= 300
          :warm
        elsif hue.between?(120, 240)
          :cool
        else
          :neutral
        end
      end

      # @return [Boolean] true if the color temperature is warm
      def warm?
        temperature == :warm
      end

      # @return [Boolean] true if the color temperature is cool
      def cool?
        temperature == :cool
      end

      # @return [String]
      def to_s
        return to_hex if opaque?

        format('rgba(%d, %d, %d, %s)', @r, @g, @b, @alpha)
      end

      # @return [Boolean]
      def ==(other)
        other.is_a?(Color) && @r == other.r && @g == other.g && @b == other.b && @alpha == other.alpha
      end

      # Create a Color from HSL values.
      #
      # @param h [Numeric] hue (0-360)
      # @param s [Numeric] saturation (0-100)
      # @param l [Numeric] lightness (0-100)
      # @param alpha [Float] alpha component (0.0-1.0, default 1.0)
      # @return [Color]
      def self.from_hsl(h, s, l, alpha: 1.0)
        h /= 360.0
        s /= 100.0
        l /= 100.0

        if s.zero?
          val = (l * 255).round
          return new(val, val, val, alpha: alpha)
        end

        q = l < 0.5 ? l * (1 + s) : l + s - (l * s)
        p = (2 * l) - q

        r = hue_to_rgb(p, q, h + (1.0 / 3))
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - (1.0 / 3))

        new((r * 255).round, (g * 255).round, (b * 255).round, alpha: alpha)
      end

      # Create a Color from CMYK values.
      #
      # @param c [Numeric] cyan (0-100)
      # @param m [Numeric] magenta (0-100)
      # @param y [Numeric] yellow (0-100)
      # @param k [Numeric] key/black (0-100)
      # @return [Color]
      def self.from_cmyk(c, m, y, k)
        c /= 100.0
        m /= 100.0
        y /= 100.0
        k /= 100.0

        r = 255 * (1 - c) * (1 - k)
        g = 255 * (1 - m) * (1 - k)
        b = 255 * (1 - y) * (1 - k)

        new(r.round, g.round, b.round)
      end

      # Create a Color from CIELAB values (D65 illuminant).
      #
      # @param l [Numeric] lightness (0-100)
      # @param a [Numeric] green-red component (approx -128 to 127)
      # @param b [Numeric] blue-yellow component (approx -128 to 127)
      # @return [Color]
      def self.from_lab(l, a, b)
        # LAB to XYZ
        fy = (l + 16.0) / 116.0
        fx = (a / 500.0) + fy
        fz = fy - (b / 200.0)

        x = lab_f_inv(fx) * 95.047
        y = lab_f_inv(fy) * 100.0
        z = lab_f_inv(fz) * 108.883

        from_xyz(x, y, z)
      end

      # Create a Color from CIE XYZ values.
      #
      # @param x [Numeric] X component
      # @param y [Numeric] Y component
      # @param z [Numeric] Z component
      # @return [Color]
      def self.from_xyz(x, y, z)
        x /= 100.0
        y /= 100.0
        z /= 100.0

        r = (x * 3.2404542) + (y * -1.5371385) + (z * -0.4985314)
        g = (x * -0.9692660) + (y * 1.8760108) + (z * 0.0415560)
        b = (x * 0.0556434) + (y * -0.2040259) + (z * 1.0572252)

        r = delinearize_srgb_class(r)
        g = delinearize_srgb_class(g)
        b = delinearize_srgb_class(b)

        new(
          [[r * 255, 0].max, 255].min.round,
          [[g * 255, 0].max, 255].min.round,
          [[b * 255, 0].max, 255].min.round
        )
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

      # @api private
      def self.lab_f_inv(t)
        if t > 6.0 / 29
          t**3
        else
          3.0 * ((6.0 / 29)**2) * (t - (4.0 / 29))
        end
      end

      # @api private
      def self.delinearize_srgb_class(c)
        if c <= 0.0031308
          12.92 * c
        else
          (1.055 * (c**(1.0 / 2.4))) - 0.055
        end
      end

      # Color blindness simulation matrices (Brettel/Vienot method).
      COLOR_BLINDNESS_MATRICES = {
        protanopia: [
          [0.152286, 1.052583, -0.204868],
          [0.114503, 0.786281, 0.099216],
          [-0.003882, -0.048116, 1.051998]
        ],
        deuteranopia: [
          [0.367322, 0.860646, -0.227968],
          [0.280085, 0.672501, 0.047413],
          [-0.011820, 0.042940, 0.968881]
        ],
        tritanopia: [
          [1.255528, -0.076749, -0.178779],
          [-0.078411, 0.930809, 0.147602],
          [0.004733, 0.691367, 0.303900]
        ]
      }.freeze

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

      def linearize_srgb(channel)
        if channel <= 0.04045
          channel / 12.92
        else
          ((channel + 0.055) / 1.055)**2.4
        end
      end

      def delinearize_srgb(channel)
        if channel <= 0.0031308
          12.92 * channel
        else
          (1.055 * (channel**(1.0 / 2.4))) - 0.055
        end
      end

      def lab_f(t)
        if t > (6.0 / 29)**3
          t**(1.0 / 3)
        else
          (t / (3.0 * ((6.0 / 29)**2))) + (4.0 / 29)
        end
      end
    end
  end
end
