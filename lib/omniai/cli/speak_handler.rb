# frozen_string_literal: true

module OmniAI
  class CLI
    # Used by CLI to process commands like:
    #
    #    omniai speak
    #    omniai speak "Sally sells seashells by the seashore."
    class SpeakHandler < BaseHandler
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

      # @param file [File]
      def play(file)
        system("afplay #{file.path}")
      end

      def listen!
        @stdout.puts('Type "exit" or "quit" to leave.')

        loop do
          @stdout.print("# ")
          @stdout.flush
          input = @stdin.gets&.chomp

          break if input.nil? || input.match?(/\A(exit|quit)\z/i)

          speak(input)
        rescue Interrupt
          break
        end
      end

      # @param input [String]
      def speak(input)
        tempfile = Tempfile.new
        client.speak(input, **@args, stream: @stdout) do |chunk|
          tempfile << chunk
        end
        play(file: tempfile)
      ensure
        tempfile.unlink
        tempfile.close
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

          options.on("-m", "--format=FORMAT", "format") do |format|
            @args[:format] = format
          end

          options.on("-t", "--temperature=TEMPERATURE", Float, "temperature") do |temperature|
            @args[:temperature] = temperature
          end

          options.on("-f", "--format=FORMAT", "format") { |format| @args[:format] = format.intern }
        end
      end
    end
  end
end
