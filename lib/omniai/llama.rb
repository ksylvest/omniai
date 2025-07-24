# frozen_string_literal: true

module OmniAI
  # A namespace for everything Llama.
  module Llama
    # @return [OmniAI::Llama::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::Llama::Config]
    def self.configure
      yield config
    end
  end
end
