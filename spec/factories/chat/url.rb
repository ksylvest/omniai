# frozen_string_literal: true

FactoryBot.define do
  factory :chat_url, class: "OmniAI::Chat::URL" do
    initialize_with { new(uri, type) }

    type { "image/png" }
    uri { "https://localhost/hamster.png" }
  end
end
