# frozen_string_literal: true

module OmniAI
  module Anthropic
    # An Anthropic chat implementation.
    #
    # Usage:
    #
    #   completion = OmniAI::Anthropic::Chat.process!(client: client) do |prompt|
    #     prompt.system('You are an expert in the field of AI.')
    #     prompt.user('What are the biggest risks of AI?')
    #   end
    #   completion.text # '...'
    class Chat < OmniAI::Chat
      module Model
        CLAUDE_INSTANT_1_0 = "claude-instant-1.2"
        CLAUDE_2_0 = "claude-2.0"
        CLAUDE_2_1 = "claude-2.1"

        CLAUDE_3_HAIKU_20240307 = "claude-3-haiku-20240307"
        CLAUDE_3_5_HAIKU_20241022 = "claude-3-5-haiku-20241022"
        CLAUDE_3_OPUS_20240229 = "claude-3-opus-20240229"
        CLAUDE_3_SONNET_20240209 = "claude-3-sonnet-20240229"
        CLAUDE_3_SONNET_20240307 = "claude-3-sonnet-20240307"
        CLAUDE_3_5_SONNET_20240620 = "claude-3-5-sonnet-20240620"
        CLAUDE_3_5_SONNET_20241022 = "claude-3-5-sonnet-20241022"
        CLAUDE_3_7_SONNET_20250219 = "claude-3-7-sonnet-20250219"

        CLAUDE_3_5_HAIKU_LATEST = "claude-3-5-haiku-latest"
        CLAUDE_3_OPUS_LATEST = "claude-3-opus-latest"
        CLAUDE_3_5_SONNET_LATEST = "claude-3-5-sonnet-latest"
        CLAUDE_3_7_SONNET_LATEST = "claude-3-7-sonnet-latest"

        CLAUDE_SONNET_4_20250514 = "claude-sonnet-4-20250514"
        CLAUDE_OPUS_4_20250514 = "claude-opus-4-20250514"
        CLAUDE_OPUS_4_0 = "claude-opus-4-0"
        CLAUDE_SONNET_4_0 = "claude-sonnet-4-0"

        CLAUDE_HAIKU = CLAUDE_3_5_HAIKU_LATEST
        CLAUDE_OPUS = CLAUDE_OPUS_4_0
        CLAUDE_SONNET = CLAUDE_SONNET_4_0
      end

      DEFAULT_MODEL = Model::CLAUDE_SONNET

      # @return [Context]
      CONTEXT = Context.build do |context|
        context.serializers[:tool] = ToolSerializer.method(:serialize)

        context.serializers[:file] = FileSerializer.method(:serialize)
        context.serializers[:url] = URLSerializer.method(:serialize)

        context.serializers[:choice] = ChoiceSerializer.method(:serialize)
        context.deserializers[:choice] = ChoiceSerializer.method(:deserialize)

        context.serializers[:tool_call] = ToolCallSerializer.method(:serialize)
        context.deserializers[:tool_call] = ToolCallSerializer.method(:deserialize)

        context.serializers[:tool_call_result] = ToolCallResultSerializer.method(:serialize)
        context.deserializers[:tool_call_result] = ToolCallResultSerializer.method(:deserialize)

        context.serializers[:function] = FunctionSerializer.method(:serialize)
        context.deserializers[:function] = FunctionSerializer.method(:deserialize)

        context.serializers[:message] = MessageSerializer.method(:serialize)
        context.deserializers[:message] = MessageSerializer.method(:deserialize)

        context.deserializers[:content] = ContentSerializer.method(:deserialize)
        context.deserializers[:response] = ResponseSerializer.method(:deserialize)
      end

      # @return [Hash]
      def payload
        OmniAI::Anthropic.config.chat_options.merge({
          model: @model,
          messages:,
          system:,
          stream: stream? || nil,
          temperature: @temperature,
          tools: tools_payload,
        }).compact
      end

      # @return [Array<Hash>]
      def messages
        messages = @prompt.messages.reject(&:system?)
        messages.map { |message| message.serialize(context:) }
      end

      # @return [String, nil]
      def system
        messages = @prompt.messages.filter(&:system?)
        return if messages.empty?

        messages.filter(&:text?).map(&:text).join("\n\n")
      end

      # @return [String]
      def path
        "/#{Client::VERSION}/messages"
      end

    protected

      # @return [Context]
      def context
        CONTEXT
      end

      # @return [Array<Message>]
      def build_tool_call_messages(tool_call_list)
        content = tool_call_list.map do |tool_call|
          ToolCallResult.new(tool_call_id: tool_call.id, content: execute_tool_call(tool_call))
        end

        [Message.new(role: OmniAI::Chat::Role::USER, content:)]
      end

    private

      # @return [Array<Hash>, nil]
      def tools_payload
        @tools.map { |tool| tool.serialize(context:) } if @tools&.any?
      end
    end
  end
end
