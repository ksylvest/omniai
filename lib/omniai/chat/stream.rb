# frozen_string_literal: true

module OmniAI
  class Chat
    # A stream is used to process a series of chunks of data. It converts the following into a combined payload:
    #
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "role" :"assistant", "content":"" } }] }
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "content" :"A" } }] }
    #   { "id":"...", "choices": [{ "index": 0,"delta": { "content" :"B" } }] }
    #   ...
    #
    # Every
    class Stream
      # @param logger [OmniAI::Client]
      # @param chunks [Enumerable<String>]
      def initialize(chunks:, logger: nil)
        @chunks = chunks
        @logger = logger
      end

      # @yield [delta]
      # @yieldparam delta [OmniAI::Chat::Delta]
      #
      # @return [Hash]
      def stream!(&block)
        @data = { "choices" => [] }

        @chunks.map do |chunk|
          parser.feed(chunk) do |type, data, id|
            process!(type, data, id, &block)
          end
        end

        @data
      end

    protected

      # @yield [delta]
      # @yieldparam delta [OmniAI::Chat::Delta]
      #
      # @param type [String]
      # @param data [String]
      # @param id [String]
      def log(type, data, id)
        arguments = [
          ("type=#{type.inspect}" if type),
          ("data=#{data.inspect}" if data),
          ("id=#{id.inspect}" if id),
        ].compact

        @logger&.debug("Stream#process! #{arguments.join(' ')}")
      end

      # @yield [delta]
      # @yieldparam delta [OmniAI::Chat::Delta]
      #
      # @param type [String]
      # @param data [String]
      # @param id [String]
      def process!(type, data, id, &)
        log(type, data, id)

        return if data.eql?("[DONE]")

        process_data!(data: JSON.parse(data), &)
      end

      # @yield [delta]
      # @yieldparam delta [OmniAI::Chat::Delta]
      #
      # @param data [Hash]
      def process_data!(data:, &block)
        data.each do |key, value|
          @data[key] = value unless key.eql?("choices") || key.eql?("object")
        end

        data["choices"].each do |choice|
          merge_choice!(choice:)

          text = choice["delta"]["content"]
          block&.call(Delta.new(text:)) if text
        end
      end

      # @param choice [Hash]
      def merge_choice!(choice:)
        index = choice["index"]
        delta = choice["delta"]

        if @data["choices"][index].nil?
          @data["choices"][index] = {
            "index" => index,
            "message" => delta,
          }
        else
          message = @data["choices"][index]["message"]

          message["content"] += delta["content"] if delta["content"]

          merge_tool_call_list!(tool_call_list: delta["tool_calls"], message:)
        end
      end

      # @param tool_call_list [Array<Hash>, nil]
      # @param message [Hash]
      def merge_tool_call_list!(tool_call_list:, message:)
        return unless tool_call_list

        message["tool_calls"] ||= []

        tool_call_list.each do |tool_call|
          merge_tool_call_data!(tool_call:, message:)
        end
      end

      # @param tool_call [Hash]
      # @param message [Hash]
      def merge_tool_call_data!(tool_call:, message:)
        tool_call_index = tool_call["index"]

        if message["tool_calls"][tool_call_index].nil?
          message["tool_calls"][tool_call_index] = tool_call
        else
          message["tool_calls"][tool_call_index]["function"]["arguments"] += tool_call["function"]["arguments"]
        end
      end

      # @return [EventStreamParser::Parser]
      def parser
        @parser ||= EventStreamParser::Parser.new
      end
    end
  end
end
