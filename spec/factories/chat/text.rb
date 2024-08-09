# frozen_string_literal: true

FactoryBot.define do
  factory :chat_text, class: 'OmniAI::Chat::Text' do
    initialize_with { new(text) }

    text { 'Hello!' }
  end
end
