# frozen_string_literal: true

require_relative 'lib/omniai/version'

Gem::Specification.new do |spec|
  spec.name = 'omniai'
  spec.version = OmniAI::VERSION
  spec.authors = ['Kevin Sylvestre']
  spec.email = ['kevin@ksylvest.com']

  spec.summary = 'A generalized framework for interacting with many AI services'
  spec.description = "An interface for OpenAI's ChatGPT, Google's Gemini, Anthropic's Claude, Mistral's LeChat, etc."
  spec.homepage = 'https://github.com/ksylvest/omniai'

  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{bin,lib}/**/*') + %w[README.md Gemfile]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http'
  spec.add_dependency 'zeitwerk'
end
