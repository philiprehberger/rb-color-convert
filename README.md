# philiprehberger-color_convert

[![Tests](https://github.com/philiprehberger/rb-color-convert/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-color-convert/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-color_convert.svg)](https://rubygems.org/gems/philiprehberger-color_convert)
[![License](https://img.shields.io/github/license/philiprehberger/rb-color-convert)](LICENSE)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

Color format conversion with parsing, manipulation, and CSS named colors

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
```

### Parsing Formats

```ruby
Philiprehberger::ColorConvert.parse("#ff0000")          # hex
Philiprehberger::ColorConvert.parse("f00")               # short hex
Philiprehberger::ColorConvert.parse("rgb(255, 0, 0)")    # RGB
Philiprehberger::ColorConvert.parse("hsl(0, 100%, 50%)") # HSL
Philiprehberger::ColorConvert.parse("hsv(0, 100%, 100%)")# HSV
Philiprehberger::ColorConvert.parse("tomato")             # CSS named color
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
| `.parse(str)` | Parse a color string (hex, RGB, HSL, HSV, or CSS name) |
| `.named_colors` | Return all 148 CSS named colors as name => hex hash |

### `Color`

| Method | Description |
|--------|-------------|
| `#to_hex` | Convert to hex string (e.g., "#ff0000") |
| `#to_rgb` | Convert to RGB hash ({ r:, g:, b: }) |
| `#to_hsl` | Convert to HSL hash ({ h:, s:, l: }) |
| `#to_hsv` | Convert to HSV hash ({ h:, s:, v: }) |
| `#lighten(n)` | Lighten by n percent |
| `#darken(n)` | Darken by n percent |
| `#saturate(n)` | Increase saturation by n percent |
| `#desaturate(n)` | Decrease saturation by n percent |
| `#complement` | Return the complementary color |
| `#contrast_ratio(other)` | WCAG contrast ratio (1.0 to 21.0) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

[MIT](LICENSE)
