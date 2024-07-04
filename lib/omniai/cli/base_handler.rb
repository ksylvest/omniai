# frozen_string_literal: true

module OmniAI
  class CLI
    # A generic handler for CLI commands (e.g. 'omnia chat').
    class BaseHandler
      # @param stdin [IO] an optional stream for stdin
      # @param stdout [IO] an optional stream for stdout
      # @param provider [String] an optional provider (defaults to 'openai')
      # @param argv [Array<String>]
      def self.handle!(argv:, stdin: $stdin, stdout: $stdout, provider: 'openai')
        new(stdin:, stdout:, provider:).handle!(argv:)
      end

      # @param stdin [IO] an optional stream for stdin
      # @param stdout [IO] an optional stream for stdout
      # @param provider [String] an optional provider (defaults to 'openai')
      def initialize(stdin: $stdin, stdout: $stdout, provider: 'openai')
        @stdin = stdin
        @stdout = stdout
        @provider = provider
        @args = {}
      end

      # @param argv [Array<String>]
      def handle!(argv:)
        raise NotImplementedError, "#{self.class}#handle! undefined"
      end

      private

      # @return [OmniAI::Client]
      def client
        @client ||= OmniAI::Client.find(provider: @provider)
      end
    end
  end
end
