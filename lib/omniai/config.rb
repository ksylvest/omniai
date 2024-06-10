# frozen_string_literal: true

module OmniAI
  # A configuration for each agent w/ `api_key` / `host` / `logger`.
  class Config
    attr_accessor :api_key, :host, :logger

    # @return [String]
    def inspect
      masked_api_key = "#{api_key[..2]}***" if api_key
      "#<#{self.class.name} api_key=#{masked_api_key.inspect} host=#{host.inspect}>"
    end
  end
end
