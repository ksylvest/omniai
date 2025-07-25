# frozen_string_literal: true

module OmniAI
  # A namespace for everything Llama.
  module Llama
    # @return [OmniAI::Llama::Config]
    def self.config
      OmniAI.config.llama
    end

    # @yield [OmniAI::Llama::Config]
    def self.configure
      yield OmniAI.config.llama
    end
  end
end
