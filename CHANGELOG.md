# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
