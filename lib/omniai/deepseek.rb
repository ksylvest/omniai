# frozen_string_literal: true

module OmniAI
  # A namespace for everything DeepSeek.
  module DeepSeek
    # @return [OmniAI::DeepSeek::Config]
    def self.config
      @config ||= OmniAI.config.deepseek
    end

    # @yield [OmniAI::DeepSeek::Config]
    def self.configure
      yield OmniAI.config.deepseek
    end
  end
end
