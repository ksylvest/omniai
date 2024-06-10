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
  spec.metadata['source_code_uri'] = 'https://github.com/ksylvest/omniai'
  spec.metadata['changelog_uri'] = 'https://github.com/ksylvest/omniai/releases'

  spec.files = Dir.glob('{bin,lib}/**/*') + %w[README.md Gemfile]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
