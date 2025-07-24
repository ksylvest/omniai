# frozen_string_literal: true

module OmniAI
  module Mistral
    # A Mistral chat implementation.
    #
    # Usage:
    #
    #   chat = OmniAI::Mistral::Chat.new(client: client)
    #   chat.completion('Tell me a joke.')
    #   chat.completion(['Tell me a joke.'])
    #   chat.completion({ role: 'user', content: 'Tell me a joke.' })
    #   chat.completion([{ role: 'system', content: 'Tell me a joke.' }])
    class Chat < OmniAI::Chat
      module ResponseFormat
        TEXT_TYPE = "text"
        JSON_TYPE = "json_object"
        SCHEMA_TYPE = "json_schema"
      end

      module Model
        MISTRAL_SMALL_2402 = "mistral-small-2402" # LEGACY
        MISTRAL_SMALL_2409 = "mistral-small-2409" # LEGACY
        MISTRAL_SMALL_2501 = "mistral-small-2501" # LEGACY
        MISTRAL_SMALL_2503 = "mistral-small-2503" # LEGACY
        MISTRAL_SMALL_LATEST = "mistral-small-latest"
        MISTRAL_MEDIUM_2312 = "mistral-medium-2312" # LEGACY
        MISTRAL_MEDIUM_2505 = "mistral-medium-2505"
        MISTRAL_MEDIUM_LATEST = "mistral-medium-latest"
        MISTRLA_LARGE_2402 = "mistral-large-2402" # LEGACY
        MISTRAL_LARGE_2411 = "mistral-large-2411"
        MISTRAL_LARGE_LATEST = "mistral-large-latest"
        CODESTRAL_2405 = "codestral-2405"
        CODESTRAL_LATEST = "codestral-latest"
        MINISTRAL_3B_2410 = "ministral-3b-2410"
        MINISTRAL_3B_LATEST = "ministral-3b-latest"
        MINISTRAL_8B_2410 = "ministral-8b-2410"
        MINISTRAL_8B_LATEST = "ministral-8b-latest"
        MISTRAL_MODERATION_2411 = "mistral-moderation-2411"
        MISTRAL_MODERATION_LATEST = "mistral-moderation-latest"
        MISTRAL_EMBED = "mistral-embed"
        PIXTRAL_LARGE_2411 = "pixtral-large-2411"
        PIXTRAL_LARGE_LATEST = "pixtral-large-latest"
        SMALL = MISTRAL_SMALL_LATEST
        MEDIUM = MISTRAL_MEDIUM_LATEST
        LARGE = MISTRAL_LARGE_LATEST
        PIXTRAL = PIXTRAL_LARGE_LATEST
        CODESTRAL = CODESTRAL_LATEST
      end

      DEFAULT_MODEL = Model::MISTRAL_MEDIUM_LATEST

      module Role
        ASSISTANT = "assistant"
        USER = "user"
        SYSTEM = "system"
      end

    protected

      # @return [Hash]
      def payload
        OmniAI::Mistral.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          stream: stream? || nil,
          temperature: @temperature,
          response_format:,
          tools: (@tools.map(&:serialize) if @tools&.any?),
        }).compact
      end

      # @return [String]
      def path
        "/#{OmniAI::Mistral::Client::VERSION}/chat/completions"
      end

      # @raise [ArgumentError]
      #
      # @return [Hash, nil]
      def response_format
        return if @format.nil?

        case @format
        when :text then { type: ResponseFormat::TEXT_TYPE }
        when :json then { type: ResponseFormat::JSON_TYPE }
        when OmniAI::Schema::Format then { type: ResponseFormat::SCHEMA_TYPE, json_schema: @format.serialize }
        else raise ArgumentError, "unknown format=#{@format}"
        end
      end
    end
  end
end
