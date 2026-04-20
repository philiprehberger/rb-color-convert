# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-04-20

### Added
- `Color#invert` returns a new color with inverted RGB channels (255 - r/g/b) while preserving the alpha channel — useful for negatives and accessibility previews

## [0.4.0] - 2026-04-16

### Added
- Alpha channel support: `Color` gains an `@alpha` attribute (Float 0.0-1.0, default 1.0)
- `Color#initialize` accepts optional `alpha:` keyword argument
- Parse `rgba(r, g, b, a)` and `hsla(h, s%, l%, a)` string formats
- Parse 8-digit hex (`#rrggbbaa`) — alpha extracted from last 2 hex digits
- `#to_rgba` returns `{ r:, g:, b:, a: }` hash including alpha
- `#opacity` returns the alpha value (0.0-1.0)
- `#alpha` attribute reader (alias via `attr_reader`)
- `#with_opacity(val)` returns a new Color with the given alpha
- `#opaque?` returns true when alpha is 1.0
- `#transparent?` returns true when alpha is less than 1.0
- `#to_s` includes alpha in `rgba(...)` format when alpha is not 1.0

## [0.3.0] - 2026-04-15

### Added
- Color temperature classification with `#temperature` returning `:warm`, `:cool`, or `:neutral` based on HSL hue
- Convenience predicates `#warm?` and `#cool?` for quick temperature checks

## [0.2.3] - 2026-04-08

### Changed
- Align gemspec summary with README description.

## [0.2.2] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.2.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.2.0] - 2026-03-28

### Added
- CMYK color space support with `to_cmyk` and `Color.from_cmyk` conversion methods
- CIELAB color space support with `to_lab` and `Color.from_lab` via XYZ (D65 illuminant)
- XYZ color space support with `to_xyz` and `Color.from_xyz`
- Color blending with `blend(other, weight: 0.5)` to mix two colors
- Color harmony generation: `analogous`, `triadic`, `tetradic`, `split_complementary`
- Color blindness simulation: `simulate_color_blindness(:protanopia | :deuteranopia | :tritanopia)`
- Palette generation: `gradient(other, steps:)` and `monochromatic(steps:)`
- CMYK string parsing support in `ColorConvert.parse`

## [0.1.3] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.2] - 2026-03-24

### Fixed
- Fix stray character in CHANGELOG formatting

## [0.1.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Color parsing from hex, RGB, HSL, HSV, and CSS named color strings
- Conversion between hex, RGB, HSL, and HSV formats
- Color manipulation: lighten, darken, saturate, desaturate, complement
- WCAG contrast ratio calculation
- All 148 CSS named colors
