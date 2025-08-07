# frozen_string_literal: true

module OmniAI
  # A namespace for everything Google.
  module Google
    # @return [OmniAI::Google::Config]
    def self.config
      OmniAI.config.google
    end

    # @yield [OmniAI::Google::Config]
    def self.configure
      yield OmniAI.config.google
    end
  end
end
