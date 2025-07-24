# frozen_string_literal: true

module OmniAI
  module DeepSeek
    # An DeepSeek chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::DeepSeek::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.choice.message.content # '...'
    class Chat < OmniAI::Chat
      module ResponseFormat
        TEXT_TYPE = "text"
        JSON_TYPE = "json_object"
        SCHEMA_TYPE = "json_schema"
      end

      module Model
        CHAT = "deepseek-chat"
        REASONER = "deepseek-reasoner"
      end

      DEFAULT_MODEL = Model::CHAT

    protected

      # @return [Hash]
      def payload
        OmniAI::DeepSeek.config.chat_options.merge({
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
        "/chat/completions"
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
