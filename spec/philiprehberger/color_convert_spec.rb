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
end
