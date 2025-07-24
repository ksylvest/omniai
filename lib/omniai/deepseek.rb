# frozen_string_literal: true

module OmniAI
  # A namespace for everything DeepSeek.
  module DeepSeek
    # @return [OmniAI::DeepSeek::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::DeepSeek::Config]
    def self.configure
      yield config
    end
  end
end
