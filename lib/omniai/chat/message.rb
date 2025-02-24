# frozen_string_literal: true

module OmniAI
  class Chat
    # Used to standardize the process of building message within a prompt:
    #
    #   completion = client.chat do |prompt|
    #     prompt.user do |message|
    #       message.text 'What are these photos of?'
    #       message.url 'https://example.com/cat.jpg', type: "image/jpeg"
    #       message.url 'https://example.com/dog.jpg', type: "image/jpeg"
    #       message.file File.open('hamster.jpg'), type: "image/jpeg"
    #       message.
    #     end
    #   end
    class Message
      # @example
      #   prompt.build('What is the capital of Canada?')
      #
      # @example
      #   prompt.build(role: 'user') do |message|
      #     message.text 'What is the capital of Canada?'
      #   end
      #
      # @param content [String, nil]
      # @param role [Symbol]
      #
      # @yield [builder]
      # @yieldparam builder [Message::Builder]
      #
      # @return [Message]
      def self.build(content = nil, role: Role::USER, &block)
        raise ArgumentError, "content or block is required" if content.nil? && block.nil?

        Builder.build(role:) do |builder|
          builder.text(content) if content
          block&.call(builder)
        end
      end

      # @!attribute [rw] content
      #   @return [Array<Content>, String]
      attr_accessor :content

      # @!attribute [rw] role
      #   @return [String]
      attr_accessor :role

      # @!attribute [rw] tool_call_list
      #   @return [Array<ToolCall>, nil]
      attr_accessor :tool_call_list

      # @param content [String, nil]
      # @param role [String]
      # @param tool_call_list [Array<ToolCall>, nil]
      def initialize(content:, role: Role::USER, tool_call_list: nil)
        @content = content
        @role = role
        @tool_call_list = tool_call_list
      end

      # @return [String]
      def inspect
        "#<#{self.class} role=#{@role.inspect} content=#{@content.inspect}>"
      end

      # @return [String]
      def summarize
        <<~TEXT
          #{@role}
          #{Content.summarize(@content)}
        TEXT
      end

      # Usage:
      #
      #   Message.deserialize({ role: :user, content: 'Hello!' }) # => #<Message ...>
      #
      # @param data [Hash]
      # @param context [Context] optional
      #
      # @return [Message]
      def self.deserialize(data, context: nil)
        deserialize = context&.deserializer(:message)
        return deserialize.call(data, context:) if deserialize

        role = data["role"]
        content = Content.deserialize(data["content"], context:)
        tool_call_list = data["tool_calls"]&.map { |subdata| ToolCall.deserialize(subdata, context:) }

        new(content:, role:, tool_call_list:)
      end

      # Usage:
      #
      #   message.serialize # => { role: :user, content: 'Hello!' }
      #   message.serialize # => { role: :user, content: [{ type: 'text', text: 'Hello!' }] }
      #
      # @param context [Context] optional
      #
      # @return [Hash]
      def serialize(context: nil)
        serializer = context&.serializer(:message)
        return serializer.call(self, context:) if serializer

        content = @content.is_a?(Array) ? @content.map { |content| content.serialize(context:) } : @content
        tool_calls = @tool_call_list&.map { |tool_call| tool_call.serialize(context:) }

        { role: @role, content:, tool_calls: }.compact
      end

      # @param other [OmniAI::Chat::Message]
      #
      # @return [OmniAI::Chat::Message]
      def merge(other)
        content =
          if @content && other.content
            @content + other.content
          else
            @content || other.content
          end

        tool_call_list =
          if @tool_call_list && other.tool_call_list
            @tool_call_list + other.tool_call_list
          else
            @tool_call_list || other.tool_call_list
          end

        self.class.new(content:, role:, tool_call_list:)
      end

      # @return [Boolean]
      def role?(role)
        String(@role).eql?(String(role))
      end

      # @return [Boolean]
      def system?
        role?(Role::SYSTEM)
      end

      # @return [Boolean]
      def user?
        role?(Role::USER)
      end

      # @return [Boolean]
      def tool?
        role?(Role::TOOL)
      end

      # @return [Boolean]
      def text?
        !text.nil?
      end

      # @return [String, nil]
      def text
        return if @content.nil?
        return @content if @content.is_a?(String)

        parts = arrayify(@content).filter { |content| content.is_a?(Text) }
        parts.map(&:text).join("\n") unless parts.empty?
      end

      # @param object [Object]
      # @return [Array]
      def arrayify(object)
        return if object.nil?
        return object if object.is_a?(Array)

        [object]
      end
    end
  end
end
