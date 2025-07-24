# frozen_string_literal: true

module OmniAI
  module Llama
    # An Llama chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::Llama::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.choice.message.content # '...'
    class Chat < OmniAI::Chat
      JSON_RESPONSE_FORMAT = { type: "json_object" }.freeze

      module Model
        LLAMA_4_SCOUT_17B_16E_INSTRUCT_FP8 = "Llama-4-Scout-17B-16E-Instruct-FP8"
        LLAMA_4_MAVERICK_17B_128E_INSTRUCT_FP_8 = "Llama-4-Maverick-17B-128E-Instruct-FP8"
        LLAMA_3_3_70B_INSTRUCT = "Llama-3.3-70B-Instruct"
        LLAMA_3_3_8B_INSTRUCT = "Llama-3.3-8B-Instruct"
        LLAMA_4_SCOUT = LLAMA_4_SCOUT_17B_16E_INSTRUCT_FP8
        LLAMA_4_MAVERICK = LLAMA_4_MAVERICK_17B_128E_INSTRUCT_FP_8
      end

      DEFAULT_MODEL = Model::LLAMA_4_SCOUT

      # @return [Context]
      CONTEXT = Context.build do |context|
        context.deserializers[:response] = ResponseSerializer.method(:deserialize)
        context.deserializers[:choice] = ChoiceSerializer.method(:deserialize)
        context.deserializers[:content] = ContentSerializer.method(:deserialize)
        context.deserializers[:usage] = UsageSerializer.method(:deserialize)
      end

    protected

      # @return [HTTP::Response]
      def request!
        logger&.debug("Chat#request! payload=#{payload.inspect}")

        @client
          .connection
          .accept(stream? ? "text/event-stream" : :json)
          .post(path, json: payload)
      end

      # @return [Context]
      def context
        CONTEXT
      end

      # @return [Hash]
      def payload
        OmniAI::Llama.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          response_format: (JSON_RESPONSE_FORMAT if @format.eql?(:json)),
          stream: stream? || nil,
          temperature: @temperature,
          tools: (@tools.map(&:serialize) if @tools&.any?),
        }).compact
      end

      # @return [String]
      def path
        "/#{OmniAI::Llama::Client::VERSION}/chat/completions"
      end
    end
  end
end
