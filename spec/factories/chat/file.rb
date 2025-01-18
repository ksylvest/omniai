# frozen_string_literal: true

FactoryBot.define do
  factory :chat_file, class: "OmniAI::Chat::File" do
    initialize_with { new(io, type) }

    io { StringIO.new("...") }
    type { "image/png" }
  end
end
