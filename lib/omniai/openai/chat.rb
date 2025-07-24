# frozen_string_literal: true

module OmniAI
  module OpenAI
    # An OpenAI chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::OpenAI::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.choice.message.content # '...'
    class Chat < OmniAI::Chat
      DEFAULT_STREAM_OPTIONS = { include_usage: ENV.fetch("OMNIAI_STREAM_USAGE", "on").eql?("on") }.freeze

      module ResponseFormat
        TEXT_TYPE = "text"
        JSON_TYPE = "json_object"
        SCHEMA_TYPE = "json_schema"
      end

      module Model
        GPT_5 = "gpt-5"
        GPT_5_MINI = "gpt-5-mini"
        GPT_5_NANO = "gpt-5-nano"
        GPT_4_1 = "gpt-4.1"
        GPT_4_1_NANO = "gpt-4.1-nano"
        GPT_4_1_MINI = "gpt-4.1-mini"
        GPT_4O = "gpt-4o"
        GPT_4O_MINI = "gpt-4o-mini"
        GPT_4 = "gpt-4"
        GPT_4_TURBO = "gpt-4-turbo"
        GPT_3_5_TURBO = "gpt-3.5-turbo"
        O1_MINI = "o1-mini"
        O3_MINI = "o3-mini"
        O4_MINI = "o4-mini"
        O1 = "o1"
        O3 = "o3"
      end

      DEFAULT_MODEL = Model::GPT_4_1

    protected

      # @return [Float, nil]
      def temperature
        return if @temperature.nil?

        if [Model::O1_MINI, Model::O3_MINI, Model::O1].any? { |model| model.eql?(@model) }
          logger&.warn("unsupported temperature=#{@temperature} for model=#{@model}")
          return
        end

        @temperature
      end

      # @return [Hash]
      def payload
        OmniAI::OpenAI.config.chat_options.merge({
          messages: @prompt.serialize,
          model: @model,
          response_format:,
          stream: stream? || nil,
          stream_options: (DEFAULT_STREAM_OPTIONS if stream?),
          temperature:,
          tools: (@tools.map(&:serialize) if @tools&.any?),
        }).compact
      end

      # @return [String]
      def path
        "#{@client.api_prefix}/#{OmniAI::OpenAI::Client::VERSION}/chat/completions"
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
