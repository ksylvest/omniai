# frozen_string_literal: true

module OmniAI
  class CLI
    # Used by CLI to process commands like:
    #
    #    omniai transcribe ./audio.wav
    class TranscribeHandler < BaseHandler
      # @param argv [Array<String>]
      def handle!(argv:)
        parser.parse!(argv)

        argv.each do |path|
          transcribe(path)
        end
      end

    private

      # @param input [String]
      def transcribe(input)
        File.open(input, "rb") do |file|
          @stdout.puts(client.transcribe(file, **@args).text)
        end
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

          options.on("-l", "--language=LANGUAGE", "language") do |language|
            @args[:language] = language
          end

          options.on("-f", "--format=FORMAT", "format") do |format|
            @args[:format] = format
          end
        end
      end
    end
  end
end
