# frozen_string_literal: true

module OmniAI
  class CLI
    # Used for CLI usage of 'omnia embed'.
    class EmbedHandler < BaseHandler
      # @param argv [Array<String>]
      def handle!(argv:)
        parser.parse!(argv)

        if argv.empty?
          listen!
        else
          embed(input: argv.join(' '))
        end
      end

      private

      def listen!
        @stdout.puts('Type "exit" or "quit" to leave.')

        loop do
          @stdout.print('# ')
          @stdout.flush
          input = @stdin.gets&.chomp

          break if input.nil? || input.match?(/\A(exit|quit)\z/i)

          embed(input:)
        rescue Interrupt
          break
        end
      end

      # @param input [String]
      def embed(input:)
        response = client.embed(input, **@args)
        @stdout.puts(response.embedding)
      end

      # @return [OptionParser]
      def parser
        OptionParser.new do |options|
          options.banner = 'usage: omniai embed [options] "<prompt>"'

          options.on('-h', '--help', 'help') do
            @stdout.puts(options)
            exit
          end

          options.on('-p', '--provider=PROVIDER', 'provider') { |provider| @provider = provider }
          options.on('-m', '--model=MODEL', 'model') { |model| @args[:model] = model }
        end
      end
    end
  end
end
