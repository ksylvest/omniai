# frozen_string_literal: true

FactoryBot.define do
  factory :chat_payload, class: "OmniAI::Chat::Payload" do
    initialize_with { new(**attributes) }

    usage factory: :chat_usage
    choices { [] }
  end
end
