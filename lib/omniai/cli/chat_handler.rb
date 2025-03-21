# frozen_string_literal: true

module OmniAI
  class CLI
    # Used by CLI to process commands like:
    #
    #    omniai chat
    #    omniai chat "What is the capital of France?"
    #    omniai chat --provider="google" --model="gemini-2.0-flash" "Who are you?"
    class ChatHandler < BaseHandler
      # @param argv [Array<String>]
      def handle!(argv:)
        parser.parse!(argv)

        if argv.empty?
          listen!
        else
          chat(prompt: argv.join(" "))
        end
      end

    private

      def listen!
        @stdout.puts('Type "exit" or "quit" to leave.')

        loop do
          @stdout.print("# ")
          @stdout.flush
          prompt = @stdin.gets&.chomp

          break if prompt.nil? || prompt.match?(/\A(exit|quit)\z/i)

          chat(prompt:)
        rescue Interrupt
          break
        end
      end

      # @param prompt [String]
      def chat(prompt:)
        client.chat(prompt, **@args, stream: @stdout)
      end

      # @return [OptionParser]
      def parser
        OptionParser.new do |options|
          options.banner = 'usage: omniai chat [options] "<prompt>"'

          options.on("-h", "--help", "help") do
            @stdout.puts(options)
            exit
          end

          options.on("-p", "--provider=PROVIDER", "provider") do |provider|
            @provider = provider
          end

          options.on("-m", "--model=MODEL", "model") do |model|
            @args[:model] = model
          end

          options.on("-t", "--temperature=TEMPERATURE", Float, "temperature") do |temperature|
            @args[:temperature] = temperature
          end

          options.on("-f", "--format=FORMAT", "format") do |format|
            @args[:format] = format.intern
          end
        end
      end
    end
  end
end
