# frozen_string_literal: true

module OmniAI
  class CLI
    # Used by CLI to process commands like:
    #
    #    omniai speak "Sally sells seashells by the seashore." > ./audio.aac
    class SpeakHandler < BaseHandler
      # @param argv [Array<String>]
      def handle!(argv:)
        parser.parse!(argv)

        speak(argv.join(" "))
      end

    private

      # @param input [String]
      def speak(input)
        client.speak(input, **@args) do |chunk|
          @stdout.write(chunk)
        end
        @stdout.flush
      end

      # @return [OptionParser]
      def parser
        OptionParser.new do |options|
          options.banner = 'usage: omniai speak [options] "<prompt>"'

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

          options.on("-v", "--voice=VOICE", "voice") do |voice|
            @args[:voice] = voice
          end

          options.on("-s", "--speed=SPEED", Float, "speed") do |speed|
            @args[:speed] = speed
          end

          options.on("-f", "--format=FORMAT", "format") do |format|
            @args[:format] = format
          end
        end
      end
    end
  end
end
