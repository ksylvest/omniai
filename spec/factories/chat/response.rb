# frozen_string_literal: true

FactoryBot.define do
  factory :chat_response, class: "OmniAI::Chat::Response" do
    initialize_with { new(**attributes) }

    usage factory: :chat_usage
    choices { [] }
    data { {} }
  end
end
