# frozen_string_literal: true

FactoryBot.define do
  factory :chat_stream, class: "OmniAI::Chat::Stream" do
    initialize_with { new(**attributes) }

    chunks { [] }
  end
end
