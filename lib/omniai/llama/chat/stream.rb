# frozen_string_literal: true

module OmniAI
  module Llama
    class Chat
      # A stream is used to process a series of chunks of data. It converts the following into a combined payload.
      class Stream < OmniAI::Chat::Stream
        # @yield [delta]
        # @yieldparam delta [OmniAI::Chat::Delta]
        #
        # @return [Hash]
        def stream!(&block)
          @message = { "role" => "assistant" }
          @metrics = []

          @chunks.map do |chunk|
            parser.feed(chunk) do |type, data, id|
              process!(type, data, id, &block)
            end
          end

          {
            "completion_message" => @message,
            "metrics" => @metrics,
          }
        end

      protected

        #
        # @param data [Hash]
        #
        # @yield [delta]
        # @yieldparam delta [OmniAI::Chat::Delta]
        def process_data!(data:, &)
          event = data["event"]

          process_metrics(metrics: event["metrics"]) if event["metrics"]
          process_delta(delta: event["delta"], &) if event["delta"]
        end

        # @param delta [Hash]
        #
        # @yield [delta]
        # @yieldparam delta [OmniAI::Chat::Delta]
        def process_delta(delta:, &block)
          block&.call(OmniAI::Chat::Delta.new(text: delta["text"])) if delta["text"] && !delta["text"].empty?

          case delta["type"]
          when "text" then process_delta_text(delta:)
          when "tool_call" then process_delta_tool_call(delta:)
          end
        end

        # @param delta [Hash]
        def process_delta_text(delta:)
          return if delta["text"].empty?

          if @message["content"]
            @message["content"]["text"] += delta["text"]
          else
            @message["content"] = delta
          end
        end

        # @param delta [Hash]
        def process_delta_tool_call(delta:)
          @message["tool_calls"] ||= []

          latest = @message["tool_calls"][-1]

          if delta["id"]
            @message["tool_calls"] << {
              "id" => delta["id"],
              "function" => delta["function"],
            }
          else
            latest["function"]["arguments"] ||= ""
            latest["function"]["arguments"] += delta["function"]["arguments"]
          end
        end

        # @param metrics [Array<Hash>]
        def process_metrics(metrics:)
          return unless metrics

          @metrics = metrics
        end
      end
    end
  end
end
