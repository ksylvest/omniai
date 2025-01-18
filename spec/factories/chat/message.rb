# frozen_string_literal: true

FactoryBot.define do
  factory :chat_message, class: "OmniAI::Chat::Message" do
    initialize_with { new(**attributes) }

    role { "user" }
    content { [] }
  end
end
