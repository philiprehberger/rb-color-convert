# frozen_string_literal: true

require_relative 'lib/philiprehberger/color_convert/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-color_convert'
  spec.version = Philiprehberger::ColorConvert::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Color format conversion with parsing, manipulation, and CSS named colors'
  spec.description = 'A color conversion library supporting hex, RGB, HSL, and HSV formats with ' \
                     'parsing, manipulation (lighten, darken, saturate, desaturate), contrast ratio ' \
                     'calculation, and all 148 CSS named colors.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-color_convert'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-color-convert'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-color-convert/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-color-convert/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
