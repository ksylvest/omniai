# frozen_string_literal: true

module OmniAI
  module MCP
    module Transport
      # @example
      #   transport = OmniAI::MCP::Transport::Stdio.new
      #   transport.puts("Hello World")
      #   transport.gets
      class Stdio < Base
        # @param stdin [IO]
        # @param stdout [IO]
        # @param stderr [IO]
        def initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)
          super()
          @stdin = stdin
          @stdout = stdout
          @stderr = stderr
        end

        # @param text [String]
        def puts(text)
          @stdout.puts(text)
        end

        # @return [String]
        def gets
          @stdin.gets
        end
      end
    end
  end
end
