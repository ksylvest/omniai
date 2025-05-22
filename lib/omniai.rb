# frozen_string_literal: true

require "logger"
require "event_stream_parser"
require "http"
require "uri"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect "omniai" => "OmniAI"
loader.inflector.inflect "cli" => "CLI"
loader.inflector.inflect "jrpc" => "JRPC"
loader.inflector.inflect "mcp" => "MCP"
loader.inflector.inflect "url" => "URL"
loader.inflector.inflect "http_error" => "HTTPError"
loader.inflector.inflect "ssl_error" => "SSLError"
loader.setup

# @example
#
#   OmniAI.chat(...)
#   OmniAI.transcribe(...)
#   OmniAI.speak(...)
#   OmniAI.embed(...)
module OmniAI
  class Error < StandardError; end

  # Discover a client by provider ('openai' then 'anthropic' then 'google' then 'mistral' then 'deepseek' then 'llama').
  #
  # @param provider [Symbol] the provider to use (e.g. :openai, :anthropic, :google, :mistral, :deepseek, :llama)
  #
  # @raise [OmniAI::LoadError] if no providers are installed
  #
  # @return [OmniAI::Client]
  def self.client(provider: nil, **)
    provider ? OmniAI::Client.find(provider:, **) : OmniAI::Client.discover(**)
  end

  # @example
  #   response = OmniAI.chat("What is the capital of Spain?")
  #   puts response.text
  #
  # @example
  #   OmniAI.chat(stream: $stdout) do |prompt|
  #     prompt.system("Answer in both English and French.")
  #     prompt.user("How many people live in Tokyo?")
  #   end
  #
  # @see OmniAI::Client#chat
  def self.chat(...)
    client.chat(...)
  end

  # @example
  #   File.open("audio.wav", "rb") do |file|
  #     puts OmniAI.transcribe(file).text
  #   end
  #
  # @see OmniAI::Client#transcribe
  def self.transcribe(...)
    client.transcribe(...)
  end

  # @example
  #   File.open("audio.wav", "wb") do |file|
  #     OmniAI.speak("Sally sells seashells by the seashore.") do |chunk|
  #       file << chunk
  #     end
  #   end
  #
  # @see OmniAI::Client#speak
  def self.speak(...)
    client.speak(...)
  end

  # @example
  #   embedding = OmniAI.embed("The quick brown fox jumps over the lazy dog.").embedding
  #
  # @see OmniAI::Client#embed
  def self.embed(...)
    client.embed(...)
  end
end
