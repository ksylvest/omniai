# frozen_string_literal: true

module OmniAI
  # A namespace for everything Google.
  module Google
    # @return [OmniAI::Google::Config]
    def self.config
      @config ||= Config.new
    end

    # @yield [OmniAI::Google::Config]
    def self.configure
      yield config
    end
  end
end
