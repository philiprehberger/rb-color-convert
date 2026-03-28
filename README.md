# philiprehberger-color_convert

[![Tests](https://github.com/philiprehberger/rb-color-convert/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-color-convert/actions/workflows/ci.yml) [![Gem Version](https://img.shields.io/gem/v/philiprehberger-color_convert)](https://rubygems.org/gems/philiprehberger-color_convert) [![GitHub release](https://img.shields.io/github/v/release/philiprehberger/rb-color-convert)](https://github.com/philiprehberger/rb-color-convert/releases) [![GitHub last commit](https://img.shields.io/github/last-commit/philiprehberger/rb-color-convert)](https://github.com/philiprehberger/rb-color-convert/commits/main) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Bug Reports](https://img.shields.io/badge/bug-reports-red.svg)](https://github.com/philiprehberger/rb-color-convert/issues) [![Feature Requests](https://img.shields.io/badge/feature-requests-blue.svg)](https://github.com/philiprehberger/rb-color-convert/issues) [![GitHub Sponsors](https://img.shields.io/badge/sponsor-philiprehberger-ea4aaa.svg?logo=github)](https://github.com/sponsors/philiprehberger)

Color format conversion with parsing, manipulation, harmony generation, color blindness simulation, and CSS named colors.

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-color_convert"
```

Or install directly:

```bash
gem install philiprehberger-color_convert
```

## Usage

```ruby
require "philiprehberger/color_convert"

color = Philiprehberger::ColorConvert.parse("#ff6347")
color.to_hex  # => "#ff6347"
color.to_rgb  # => { r: 255, g: 99, b: 71 }
color.to_hsl  # => { h: 9.1, s: 100.0, l: 63.9 }
color.to_hsv  # => { h: 9.1, s: 72.2, v: 100.0 }
color.to_cmyk # => { c: 0.0, m: 61.2, y: 72.2, k: 0.0 }
color.to_lab  # => { l: 62.2, a: 57.86, b: 46.42 }
```

### Parsing Formats

```ruby
Philiprehberger::ColorConvert.parse("#ff0000")           # hex
Philiprehberger::ColorConvert.parse("f00")                # short hex
Philiprehberger::ColorConvert.parse("rgb(255, 0, 0)")     # RGB
Philiprehberger::ColorConvert.parse("hsl(0, 100%, 50%)")  # HSL
Philiprehberger::ColorConvert.parse("hsv(0, 100%, 100%)") # HSV
Philiprehberger::ColorConvert.parse("cmyk(0, 100, 100, 0)") # CMYK
Philiprehberger::ColorConvert.parse("tomato")              # CSS named color
```

### Color Manipulation

```ruby
color = Philiprehberger::ColorConvert.parse("steelblue")

color.lighten(20)    # lighter by 20%
color.darken(10)     # darker by 10%
color.saturate(15)   # more saturated by 15%
color.desaturate(15) # less saturated by 15%
color.complement     # complementary color (180 degrees)
```

### Color Blending

```ruby
red = Philiprehberger::ColorConvert.parse("red")
blue = Philiprehberger::ColorConvert.parse("blue")

red.blend(blue)              # => equal mix (purple)
red.blend(blue, weight: 0.25) # => 75% red, 25% blue
```

### Color Harmonies

```ruby
color = Philiprehberger::ColorConvert.parse("#ff6347")

color.analogous           # => [Color, Color, Color] (-30, 0, +30 degrees)
color.triadic             # => [Color, Color, Color] (0, 120, 240 degrees)
color.tetradic            # => [Color, Color, Color, Color] (0, 90, 180, 270 degrees)
color.split_complementary # => [Color, Color, Color] (0, 150, 210 degrees)
```

### Color Blindness Simulation

```ruby
color = Philiprehberger::ColorConvert.parse("#ff6347")

color.simulate_color_blindness(:protanopia)   # red-blind
color.simulate_color_blindness(:deuteranopia) # green-blind
color.simulate_color_blindness(:tritanopia)   # blue-blind
```

### Palette Generation

```ruby
red = Philiprehberger::ColorConvert.parse("red")
blue = Philiprehberger::ColorConvert.parse("blue")

red.gradient(blue, steps: 5)    # => [Color, ...] gradient from red to blue
red.monochromatic(steps: 5)     # => [Color, ...] dark to light shades of red
```

### Contrast Ratio

```ruby
white = Philiprehberger::ColorConvert.parse("white")
black = Philiprehberger::ColorConvert.parse("black")
white.contrast_ratio(black) # => 21.0 (WCAG contrast ratio)
```

### CSS Named Colors

```ruby
colors = Philiprehberger::ColorConvert.named_colors
colors["tomato"]       # => "#ff6347"
colors["cornflowerblue"] # => "#6495ed"
colors.size            # => 148
```

## API

### `ColorConvert`

| Method | Description |
|--------|-------------|
| `.parse(str)` | Parse a color string (hex, RGB, HSL, HSV, CMYK, or CSS name) |
| `.named_colors` | Return all 148 CSS named colors as name => hex hash |

### `Color`

| Method | Description |
|--------|-------------|
| `#to_hex` | Convert to hex string (e.g., "#ff0000") |
| `#to_rgb` | Convert to RGB hash ({ r:, g:, b: }) |
| `#to_hsl` | Convert to HSL hash ({ h:, s:, l: }) |
| `#to_hsv` | Convert to HSV hash ({ h:, s:, v: }) |
| `#to_cmyk` | Convert to CMYK hash ({ c:, m:, y:, k: }) |
| `#to_lab` | Convert to CIELAB hash ({ l:, a:, b: }) |
| `#to_xyz` | Convert to CIE XYZ hash ({ x:, y:, z: }) |
| `#lighten(n)` | Lighten by n percent |
| `#darken(n)` | Darken by n percent |
| `#saturate(n)` | Increase saturation by n percent |
| `#desaturate(n)` | Decrease saturation by n percent |
| `#complement` | Return the complementary color |
| `#blend(other, weight:)` | Blend with another color (weight 0.0-1.0) |
| `#analogous` | Generate analogous color harmony (3 colors) |
| `#triadic` | Generate triadic color harmony (3 colors) |
| `#tetradic` | Generate tetradic color harmony (4 colors) |
| `#split_complementary` | Generate split-complementary harmony (3 colors) |
| `#simulate_color_blindness(type)` | Simulate protanopia, deuteranopia, or tritanopia |
| `#gradient(other, steps:)` | Generate gradient palette between two colors |
| `#monochromatic(steps:)` | Generate monochromatic palette (dark to light) |
| `#contrast_ratio(other)` | WCAG contrast ratio (1.0 to 21.0) |
| `.from_hsl(h, s, l)` | Create Color from HSL values |
| `.from_cmyk(c, m, y, k)` | Create Color from CMYK values |
| `.from_lab(l, a, b)` | Create Color from CIELAB values |
| `.from_xyz(x, y, z)` | Create Color from CIE XYZ values |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Philip%20Rehberger-blue?logo=linkedin)](https://linkedin.com/in/philiprehberger) [![More Packages](https://img.shields.io/badge/more-packages-blue.svg)](https://github.com/philiprehberger?tab=repositories)

## License

[MIT](LICENSE)
