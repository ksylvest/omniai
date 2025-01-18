# frozen_string_literal: true

FactoryBot.define do
  factory :chat_media, class: "OmniAI::Chat::Media" do
    initialize_with { new(type) }

    type { "image/png" }
  end
end
