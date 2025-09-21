# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::ColorConvert do
  it 'has a version number' do
    expect(Philiprehberger::ColorConvert::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses hex with hash' do
      color = described_class.parse('#ff0000')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses hex without hash' do
      color = described_class.parse('00ff00')
      expect(color.to_hex).to eq('#00ff00')
    end

    it 'parses short hex' do
      color = described_class.parse('#f00')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses RGB format' do
      color = described_class.parse('rgb(255, 128, 0)')
      expect(color.to_rgb).to eq({ r: 255, g: 128, b: 0 })
    end

    it 'parses HSL format' do
      color = described_class.parse('hsl(0, 100%, 50%)')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses HSV format' do
      color = described_class.parse('hsv(0, 100%, 100%)')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses CMYK format' do
      color = described_class.parse('cmyk(0, 100, 100, 0)')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses CMYK format with percent signs' do
      color = described_class.parse('cmyk(0%, 100%, 100%, 0%)')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses CSS named colors' do
      color = described_class.parse('red')
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'parses named colors case-insensitively' do
      color = described_class.parse('CornflowerBlue')
      expect(color.to_hex).to eq('#6495ed')
    end

    it 'raises ParseError for invalid input' do
      expect { described_class.parse('not-a-color') }.to raise_error(Philiprehberger::ColorConvert::ParseError)
    end

    it 'parses RGBA format' do
      color = described_class.parse('rgba(255, 0, 0, 0.5)')
      expect(color.to_rgb).to eq({ r: 255, g: 0, b: 0 })
      expect(color.alpha).to eq(0.5)
    end

    it 'parses HSLA format' do
      color = described_class.parse('hsla(0, 100%, 50%, 0.8)')
      expect(color.to_hex).to eq('#ff0000')
      expect(color.alpha).to eq(0.8)
    end

    it 'parses 8-digit hex with alpha' do
      color = described_class.parse('#ff0000ff')
      expect(color.to_hex).to eq('#ff0000')
      expect(color.alpha).to eq(1.0)
    end

    it 'parses 8-digit hex with partial alpha' do
      color = described_class.parse('#ff000080')
      expect(color.r).to eq(255)
      expect(color.alpha).to be_within(0.01).of(0.502)
    end
  end

  describe '.named_colors' do
    it 'returns a hash of 148 CSS colors' do
      colors = described_class.named_colors
      expect(colors).to be_a(Hash)
      expect(colors.size).to eq(148)
    end

    it 'contains common colors' do
      colors = described_class.named_colors
      expect(colors['red']).to eq('#ff0000')
      expect(colors['blue']).to eq('#0000ff')
      expect(colors['white']).to eq('#ffffff')
    end
  end
end

RSpec.describe Philiprehberger::ColorConvert::Color do
  subject(:red) { described_class.new(255, 0, 0) }

  describe '#to_hex' do
    it 'converts to hex string' do
      expect(red.to_hex).to eq('#ff0000')
    end

    it 'pads single-digit components' do
      color = described_class.new(0, 0, 0)
      expect(color.to_hex).to eq('#000000')
    end
  end

  describe '#to_rgb' do
    it 'returns RGB hash' do
      expect(red.to_rgb).to eq({ r: 255, g: 0, b: 0 })
    end
  end

  describe '#to_hsl' do
    it 'converts red to HSL' do
      hsl = red.to_hsl
      expect(hsl[:h]).to eq(0.0)
      expect(hsl[:s]).to eq(100.0)
      expect(hsl[:l]).to eq(50.0)
    end

    it 'converts white to HSL' do
      hsl = described_class.new(255, 255, 255).to_hsl
      expect(hsl[:h]).to eq(0.0)
      expect(hsl[:s]).to eq(0.0)
      expect(hsl[:l]).to eq(100.0)
    end

    it 'converts gray to HSL' do
      hsl = described_class.new(128, 128, 128).to_hsl
      expect(hsl[:s]).to eq(0.0)
    end
  end

  describe '#to_hsv' do
    it 'converts red to HSV' do
      hsv = red.to_hsv
      expect(hsv[:h]).to eq(0.0)
      expect(hsv[:s]).to eq(100.0)
      expect(hsv[:v]).to eq(100.0)
    end
  end

  describe '#to_cmyk' do
    it 'converts red to CMYK' do
      cmyk = red.to_cmyk
      expect(cmyk[:c]).to eq(0.0)
      expect(cmyk[:m]).to eq(100.0)
      expect(cmyk[:y]).to eq(100.0)
      expect(cmyk[:k]).to eq(0.0)
    end

    it 'converts white to CMYK' do
      cmyk = described_class.new(255, 255, 255).to_cmyk
      expect(cmyk[:c]).to eq(0.0)
      expect(cmyk[:m]).to eq(0.0)
      expect(cmyk[:y]).to eq(0.0)
      expect(cmyk[:k]).to eq(0.0)
    end

    it 'converts black to CMYK' do
      cmyk = described_class.new(0, 0, 0).to_cmyk
      expect(cmyk[:c]).to eq(0.0)
      expect(cmyk[:m]).to eq(0.0)
      expect(cmyk[:y]).to eq(0.0)
      expect(cmyk[:k]).to eq(100.0)
    end

    it 'converts a mid-range color to CMYK' do
      # Teal: rgb(0, 128, 128)
      cmyk = described_class.new(0, 128, 128).to_cmyk
      expect(cmyk[:c]).to eq(100.0)
      expect(cmyk[:m]).to eq(0.0)
      expect(cmyk[:y]).to eq(0.0)
      expect(cmyk[:k]).to be_within(0.5).of(49.8)
    end
  end

  describe '#to_lab' do
    it 'converts white to LAB' do
      lab = described_class.new(255, 255, 255).to_lab
      expect(lab[:l]).to eq(100.0)
      expect(lab[:a]).to be_within(0.1).of(0.0)
      expect(lab[:b]).to be_within(0.1).of(0.0)
    end

    it 'converts black to LAB' do
      lab = described_class.new(0, 0, 0).to_lab
      expect(lab[:l]).to eq(0.0)
      expect(lab[:a]).to eq(0.0)
      expect(lab[:b]).to eq(0.0)
    end

    it 'converts red to LAB with expected ranges' do
      lab = red.to_lab
      expect(lab[:l]).to be_within(1.0).of(53.23)
      expect(lab[:a]).to be_within(1.0).of(80.11)
      expect(lab[:b]).to be_within(1.0).of(67.22)
    end

    it 'converts blue to LAB with expected ranges' do
      lab = described_class.new(0, 0, 255).to_lab
      expect(lab[:l]).to be_within(1.0).of(32.30)
      expect(lab[:a]).to be_within(1.5).of(79.20)
      expect(lab[:b]).to be_within(1.5).of(-107.86)
    end
  end

  describe '#to_xyz' do
    it 'converts white to D65 reference' do
      xyz = described_class.new(255, 255, 255).to_xyz
      expect(xyz[:x]).to be_within(0.5).of(95.047)
      expect(xyz[:y]).to be_within(0.5).of(100.0)
      expect(xyz[:z]).to be_within(0.5).of(108.883)
    end

    it 'converts black to zero' do
      xyz = described_class.new(0, 0, 0).to_xyz
      expect(xyz[:x]).to eq(0.0)
      expect(xyz[:y]).to eq(0.0)
      expect(xyz[:z]).to eq(0.0)
    end
  end

  describe '.from_cmyk' do
    it 'converts CMYK to Color' do
      color = described_class.from_cmyk(0, 100, 100, 0)
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'converts full black CMYK' do
      color = described_class.from_cmyk(0, 0, 0, 100)
      expect(color.to_hex).to eq('#000000')
    end

    it 'converts zero CMYK to white' do
      color = described_class.from_cmyk(0, 0, 0, 0)
      expect(color.to_hex).to eq('#ffffff')
    end

    it 'round-trips through CMYK' do
      original = described_class.new(64, 128, 192)
      cmyk = original.to_cmyk
      restored = described_class.from_cmyk(cmyk[:c], cmyk[:m], cmyk[:y], cmyk[:k])
      expect(restored.r).to be_within(1).of(original.r)
      expect(restored.g).to be_within(1).of(original.g)
      expect(restored.b).to be_within(1).of(original.b)
    end
  end

  describe '.from_lab' do
    it 'converts LAB to Color for white' do
      color = described_class.from_lab(100, 0, 0)
      expect(color.r).to be_within(1).of(255)
      expect(color.g).to be_within(1).of(255)
      expect(color.b).to be_within(1).of(255)
    end

    it 'converts LAB to Color for black' do
      color = described_class.from_lab(0, 0, 0)
      expect(color.to_hex).to eq('#000000')
    end

    it 'round-trips through LAB' do
      original = described_class.new(128, 64, 192)
      lab = original.to_lab
      restored = described_class.from_lab(lab[:l], lab[:a], lab[:b])
      expect(restored.r).to be_within(2).of(original.r)
      expect(restored.g).to be_within(2).of(original.g)
      expect(restored.b).to be_within(2).of(original.b)
    end
  end

  describe '.from_xyz' do
    it 'converts D65 white reference back to white' do
      color = described_class.from_xyz(95.047, 100.0, 108.883)
      expect(color.r).to be_within(1).of(255)
      expect(color.g).to be_within(1).of(255)
      expect(color.b).to be_within(1).of(255)
    end
  end

  describe '#lighten' do
    it 'returns a lighter color' do
      lighter = red.lighten(20)
      expect(lighter.to_hsl[:l]).to be > red.to_hsl[:l]
    end

    it 'clamps at 100% lightness' do
      very_light = red.lighten(100)
      expect(very_light.to_hsl[:l]).to eq(100.0)
    end
  end

  describe '#darken' do
    it 'returns a darker color' do
      darker = red.darken(20)
      expect(darker.to_hsl[:l]).to be < red.to_hsl[:l]
    end

    it 'clamps at 0% lightness' do
      very_dark = red.darken(100)
      expect(very_dark.to_hsl[:l]).to eq(0.0)
    end
  end

  describe '#saturate' do
    it 'increases saturation' do
      gray_red = described_class.from_hsl(0, 50, 50)
      more_saturated = gray_red.saturate(25)
      expect(more_saturated.to_hsl[:s]).to be > 50
    end
  end

  describe '#desaturate' do
    it 'decreases saturation' do
      desaturated = red.desaturate(50)
      expect(desaturated.to_hsl[:s]).to be < 100
    end
  end

  describe '#complement' do
    it 'returns the complementary color' do
      complement = red.complement
      hsl = complement.to_hsl
      expect(hsl[:h]).to eq(180.0)
    end
  end

  describe '#blend' do
    it 'returns equal mix at default weight' do
      blue = described_class.new(0, 0, 255)
      blended = red.blend(blue)
      expect(blended.r).to eq(128)
      expect(blended.g).to eq(0)
      expect(blended.b).to eq(128)
    end

    it 'returns self at weight 0' do
      blue = described_class.new(0, 0, 255)
      blended = red.blend(blue, weight: 0.0)
      expect(blended).to eq(red)
    end

    it 'returns other at weight 1' do
      blue = described_class.new(0, 0, 255)
      blended = red.blend(blue, weight: 1.0)
      expect(blended).to eq(blue)
    end

    it 'supports custom weight' do
      white = described_class.new(255, 255, 255)
      black = described_class.new(0, 0, 0)
      blended = black.blend(white, weight: 0.25)
      expect(blended.r).to eq(64)
      expect(blended.g).to eq(64)
      expect(blended.b).to eq(64)
    end

    it 'clamps weight to valid range' do
      blue = described_class.new(0, 0, 255)
      blended = red.blend(blue, weight: 2.0)
      expect(blended).to eq(blue)
    end
  end

  describe '#analogous' do
    it 'returns an array of 3 colors' do
      colors = red.analogous
      expect(colors.size).to eq(3)
      expect(colors).to all(be_a(described_class))
    end

    it 'includes colors at -30 and +30 degrees' do
      colors = red.analogous
      expect(colors[0].to_hsl[:h]).to be_within(1).of(330.0)
      expect(colors[2].to_hsl[:h]).to be_within(1).of(30.0)
    end

    it 'preserves saturation and lightness' do
      colors = red.analogous
      hsl = red.to_hsl
      colors.each do |c|
        expect(c.to_hsl[:s]).to be_within(1).of(hsl[:s])
        expect(c.to_hsl[:l]).to be_within(1).of(hsl[:l])
      end
    end
  end

  describe '#triadic' do
    it 'returns an array of 3 colors' do
      colors = red.triadic
      expect(colors.size).to eq(3)
    end

    it 'includes colors at 120 and 240 degrees' do
      colors = red.triadic
      expect(colors[0]).to eq(red)
      expect(colors[1].to_hsl[:h]).to be_within(1).of(120.0)
      expect(colors[2].to_hsl[:h]).to be_within(1).of(240.0)
    end
  end

  describe '#tetradic' do
    it 'returns an array of 4 colors' do
      colors = red.tetradic
      expect(colors.size).to eq(4)
    end

    it 'includes colors at 90 degree intervals' do
      colors = red.tetradic
      expect(colors[0]).to eq(red)
      expect(colors[1].to_hsl[:h]).to be_within(1).of(90.0)
      expect(colors[2].to_hsl[:h]).to be_within(1).of(180.0)
      expect(colors[3].to_hsl[:h]).to be_within(1).of(270.0)
    end
  end

  describe '#split_complementary' do
    it 'returns an array of 3 colors' do
      colors = red.split_complementary
      expect(colors.size).to eq(3)
    end

    it 'includes colors at 150 and 210 degrees' do
      colors = red.split_complementary
      expect(colors[0]).to eq(red)
      expect(colors[1].to_hsl[:h]).to be_within(1).of(150.0)
      expect(colors[2].to_hsl[:h]).to be_within(1).of(210.0)
    end
  end

  describe '#simulate_color_blindness' do
    it 'simulates protanopia' do
      result = red.simulate_color_blindness(:protanopia)
      expect(result).to be_a(described_class)
      # Red should appear much less red in protanopia
      expect(result.r).to be < red.r
    end

    it 'simulates deuteranopia' do
      result = red.simulate_color_blindness(:deuteranopia)
      expect(result).to be_a(described_class)
      expect(result.r).to be < red.r
    end

    it 'simulates tritanopia' do
      result = red.simulate_color_blindness(:tritanopia)
      expect(result).to be_a(described_class)
      expect(result).to be_a(described_class)
    end

    it 'raises for unknown type' do
      expect { red.simulate_color_blindness(:unknown) }.to raise_error(ArgumentError)
    end

    it 'preserves gray colors' do
      gray = described_class.new(128, 128, 128)
      %i[protanopia deuteranopia tritanopia].each do |type|
        result = gray.simulate_color_blindness(type)
        expect(result.r).to be_within(5).of(128)
        expect(result.g).to be_within(5).of(128)
        expect(result.b).to be_within(5).of(128)
      end
    end

    it 'preserves white' do
      white = described_class.new(255, 255, 255)
      %i[protanopia deuteranopia tritanopia].each do |type|
        result = white.simulate_color_blindness(type)
        expect(result.r).to be_within(2).of(255)
        expect(result.g).to be_within(2).of(255)
        expect(result.b).to be_within(2).of(255)
      end
    end

    it 'preserves black' do
      black = described_class.new(0, 0, 0)
      %i[protanopia deuteranopia tritanopia].each do |type|
        result = black.simulate_color_blindness(type)
        expect(result.to_hex).to eq('#000000')
      end
    end
  end

  describe '#gradient' do
    it 'returns the correct number of steps' do
      blue = described_class.new(0, 0, 255)
      palette = red.gradient(blue, steps: 5)
      expect(palette.size).to eq(5)
    end

    it 'starts with self and ends with other' do
      blue = described_class.new(0, 0, 255)
      palette = red.gradient(blue, steps: 5)
      expect(palette.first).to eq(red)
      expect(palette.last).to eq(blue)
    end

    it 'produces a smooth transition' do
      white = described_class.new(255, 255, 255)
      black = described_class.new(0, 0, 0)
      palette = black.gradient(white, steps: 6)
      palette.each_cons(2) do |a, b|
        expect(b.r).to be >= a.r
        expect(b.g).to be >= a.g
        expect(b.b).to be >= a.b
      end
    end

    it 'enforces minimum of 2 steps' do
      blue = described_class.new(0, 0, 255)
      palette = red.gradient(blue, steps: 1)
      expect(palette.size).to eq(2)
    end

    it 'returns correct midpoint for 3 steps' do
      white = described_class.new(255, 255, 255)
      black = described_class.new(0, 0, 0)
      palette = black.gradient(white, steps: 3)
      expect(palette[1].r).to eq(128)
      expect(palette[1].g).to eq(128)
      expect(palette[1].b).to eq(128)
    end
  end

  describe '#monochromatic' do
    it 'returns the correct number of steps' do
      palette = red.monochromatic(steps: 5)
      expect(palette.size).to eq(5)
    end

    it 'returns colors with same hue' do
      palette = red.monochromatic(steps: 5)
      base_hue = red.to_hsl[:h]
      palette.each do |color|
        hsl = color.to_hsl
        # Achromatic colors may have h=0, which is fine for red (h=0)
        expect(hsl[:h]).to be_within(1).of(base_hue) unless hsl[:s].zero?
      end
    end

    it 'returns colors ordered from dark to light' do
      palette = red.monochromatic(steps: 5)
      lightness_values = palette.map { |c| c.to_hsl[:l] }
      expect(lightness_values).to eq(lightness_values.sort)
    end

    it 'enforces minimum of 2 steps' do
      palette = red.monochromatic(steps: 1)
      expect(palette.size).to eq(2)
    end
  end

  describe '#contrast_ratio' do
    it 'returns 21 for black vs white' do
      black = described_class.new(0, 0, 0)
      white = described_class.new(255, 255, 255)
      expect(black.contrast_ratio(white)).to eq(21.0)
    end

    it 'returns 1 for same color' do
      expect(red.contrast_ratio(red)).to eq(1.0)
    end

    it 'is symmetric' do
      blue = described_class.new(0, 0, 255)
      expect(red.contrast_ratio(blue)).to eq(blue.contrast_ratio(red))
    end
  end

  describe '#temperature' do
    it 'returns :warm for red (hue 0)' do
      expect(red.temperature).to eq(:warm)
    end

    it 'returns :warm for orange (hue ~30)' do
      color = described_class.from_hsl(30, 100, 50)
      expect(color.temperature).to eq(:warm)
    end

    it 'returns :warm for yellow (hue 60)' do
      color = described_class.from_hsl(60, 100, 50)
      expect(color.temperature).to eq(:warm)
    end

    it 'returns :warm for magenta (hue 300)' do
      color = described_class.from_hsl(300, 100, 50)
      expect(color.temperature).to eq(:warm)
    end

    it 'returns :warm for pink (hue 330)' do
      color = described_class.from_hsl(330, 100, 50)
      expect(color.temperature).to eq(:warm)
    end

    it 'returns :cool for cyan (hue 180)' do
      color = described_class.from_hsl(180, 100, 50)
      expect(color.temperature).to eq(:cool)
    end

    it 'returns :cool for blue (hue 240)' do
      color = described_class.new(0, 0, 255)
      expect(color.temperature).to eq(:cool)
    end

    it 'returns :cool for green (hue 120)' do
      color = described_class.from_hsl(120, 100, 50)
      expect(color.temperature).to eq(:cool)
    end

    it 'returns :neutral for chartreuse (hue ~90)' do
      color = described_class.from_hsl(90, 100, 50)
      expect(color.temperature).to eq(:neutral)
    end

    it 'returns :neutral for purple (hue ~270)' do
      color = described_class.from_hsl(270, 100, 50)
      expect(color.temperature).to eq(:neutral)
    end

    it 'returns :warm for achromatic colors (hue 0)' do
      gray = described_class.new(128, 128, 128)
      expect(gray.temperature).to eq(:warm)
    end
  end

  describe '#warm?' do
    it 'returns true for warm colors' do
      expect(red.warm?).to be true
    end

    it 'returns false for cool colors' do
      blue = described_class.new(0, 0, 255)
      expect(blue.warm?).to be false
    end

    it 'returns false for neutral colors' do
      color = described_class.from_hsl(90, 100, 50)
      expect(color.warm?).to be false
    end
  end

  describe '#cool?' do
    it 'returns true for cool colors' do
      blue = described_class.new(0, 0, 255)
      expect(blue.cool?).to be true
    end

    it 'returns false for warm colors' do
      expect(red.cool?).to be false
    end

    it 'returns false for neutral colors' do
      color = described_class.from_hsl(90, 100, 50)
      expect(color.cool?).to be false
    end
  end

  describe '#==' do
    it 'returns true for equal colors' do
      expect(described_class.new(255, 0, 0)).to eq(described_class.new(255, 0, 0))
    end

    it 'returns false for different colors' do
      expect(described_class.new(255, 0, 0)).not_to eq(described_class.new(0, 255, 0))
    end
  end

  describe '#to_s' do
    it 'returns hex string' do
      expect(red.to_s).to eq('#ff0000')
    end
  end

  describe '.from_hsl' do
    it 'converts HSL to Color' do
      color = described_class.from_hsl(0, 100, 50)
      expect(color.to_hex).to eq('#ff0000')
    end

    it 'handles achromatic colors' do
      gray = described_class.from_hsl(0, 0, 50)
      expect(gray.r).to eq(gray.g)
      expect(gray.g).to eq(gray.b)
    end
  end

  describe 'clamping' do
    it 'clamps values above 255' do
      color = described_class.new(300, 0, 0)
      expect(color.r).to eq(255)
    end

    it 'clamps values below 0' do
      color = described_class.new(-10, 0, 0)
      expect(color.r).to eq(0)
    end
  end

  describe 'alpha channel' do
    it 'defaults alpha to 1.0' do
      expect(red.alpha).to eq(1.0)
    end

    it 'accepts alpha keyword argument' do
      color = described_class.new(255, 0, 0, alpha: 0.5)
      expect(color.alpha).to eq(0.5)
    end

    it 'clamps alpha above 1.0' do
      color = described_class.new(255, 0, 0, alpha: 1.5)
      expect(color.alpha).to eq(1.0)
    end

    it 'clamps alpha below 0.0' do
      color = described_class.new(255, 0, 0, alpha: -0.1)
      expect(color.alpha).to eq(0.0)
    end

    describe '#to_rgba' do
      it 'returns RGBA hash with default alpha' do
        expect(red.to_rgba).to eq({ r: 255, g: 0, b: 0, a: 1.0 })
      end

      it 'returns RGBA hash with custom alpha' do
        color = described_class.new(255, 0, 0, alpha: 0.5)
        expect(color.to_rgba).to eq({ r: 255, g: 0, b: 0, a: 0.5 })
      end
    end

    describe '#opacity' do
      it 'returns the alpha value' do
        color = described_class.new(255, 0, 0, alpha: 0.75)
        expect(color.opacity).to eq(0.75)
      end
    end

    describe '#with_opacity' do
      it 'returns a new Color with updated alpha' do
        semi = red.with_opacity(0.3)
        expect(semi.alpha).to eq(0.3)
        expect(semi.r).to eq(255)
        expect(semi.g).to eq(0)
        expect(semi.b).to eq(0)
      end

      it 'does not mutate the original' do
        red.with_opacity(0.3)
        expect(red.alpha).to eq(1.0)
      end
    end

    describe '#opaque?' do
      it 'returns true when alpha is 1.0' do
        expect(red.opaque?).to be true
      end

      it 'returns false when alpha is less than 1.0' do
        color = described_class.new(255, 0, 0, alpha: 0.5)
        expect(color.opaque?).to be false
      end
    end

    describe '#transparent?' do
      it 'returns false when alpha is 1.0' do
        expect(red.transparent?).to be false
      end

      it 'returns true when alpha is less than 1.0' do
        color = described_class.new(255, 0, 0, alpha: 0.5)
        expect(color.transparent?).to be true
      end

      it 'returns true when alpha is 0.0' do
        color = described_class.new(255, 0, 0, alpha: 0.0)
        expect(color.transparent?).to be true
      end
    end

    describe '#to_s with alpha' do
      it 'returns hex string when fully opaque' do
        expect(red.to_s).to eq('#ff0000')
      end

      it 'returns rgba string when alpha is not 1.0' do
        color = described_class.new(255, 0, 0, alpha: 0.5)
        expect(color.to_s).to eq('rgba(255, 0, 0, 0.5)')
      end
    end

    describe '#== with alpha' do
      it 'returns false for same RGB but different alpha' do
        a = described_class.new(255, 0, 0, alpha: 1.0)
        b = described_class.new(255, 0, 0, alpha: 0.5)
        expect(a).not_to eq(b)
      end

      it 'returns true for same RGB and same alpha' do
        a = described_class.new(255, 0, 0, alpha: 0.5)
        b = described_class.new(255, 0, 0, alpha: 0.5)
        expect(a).to eq(b)
      end
    end
  end
end
