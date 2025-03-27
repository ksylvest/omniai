# frozen_string_literal: true

module OmniAI
  module MCP
    module Transport
      # @example
      #   transport = OmniAI::MCP::Transport::Base.new
      #   transport.puts("Hello World")
      #   transport.gets
      class Base
        # @param text [String]
        def puts(text)
          raise NotImplementedError, "#{self.class}#gets undefined"
        end

        # @return [String]
        def gets
          raise NotImplementedError, "#{self.class}#gets undefined"
        end
      end
    end
  end
end
