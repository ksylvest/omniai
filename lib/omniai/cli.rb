# frozen_string_literal: true

require "optparse"

module OmniAI
  # Used when interacting with the suite from the command line interface (CLI).
  #
  # Usage:
  #
  #   cli = OmniAI::CLI.new
  #   cli.parse
  class CLI
    ChatArgs = Struct.new(:provider, :model, :temperature)

    # @param stdin [IO] a stream
    # @param stdout [IO] a stream
    # @param provider [String] a provider
    def initialize(stdin: $stdin, stdout: $stdout, provider: "openai")
      @stdin = stdin
      @stdout = stdout
      @provider = provider
      @args = {}
    end

    # @param argv [Array<String>]
    def parse(argv = ARGV)
      parser.order!(argv)
      command = argv.shift
      return if command.nil?

      handler =
        case command
        when "chat" then ChatHandler
        when "embed" then EmbedHandler
        else raise Error, "unsupported command=#{command.inspect}"
        end

      handler.handle!(stdin: @stdin, stdout: @stdout, provider: @provider, argv:)
    end

  private

    # @return [OptionParser]
    def parser
      OptionParser.new do |options|
        options.banner = "usage: omniai [options] <command> [<args>]"

        options.on("-h", "--help", "help") do
          @stdout.puts(options)
          exit
        end

        options.on("-v", "--version", "version") do
          @stdout.puts(VERSION)
          exit
        end

        options.on("-p", "--provider=PROVIDER", 'provider (default="openai")') do |provider|
          @provider = provider
        end

        options.separator <<~COMMANDS
          commands:
            chat
        COMMANDS
      end
    end
  end
end
