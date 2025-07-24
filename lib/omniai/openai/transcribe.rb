# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI transcribe implementation.
    class Transcribe < OmniAI::Transcribe
      module Model
        WHISPER_1 = "whisper-1"
        GPT_4O_TRANSCRIBE = "gpt-4o-transcribe"
        GPT_4O_MINI_TRANSCRIBE = "gpt-4-0-mini-transcribe"
        WHISPER = WHISPER_1
      end

      DEFAULT_MODEL = Model::WHISPER

    protected

      # @return [Hash]
      def payload
        OmniAI::OpenAI
          .config.transcribe_options
          .merge(super)
          .merge({ response_format: @format || Format::JSON })
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/audio/transcriptions"
      end
    end
  end
end
