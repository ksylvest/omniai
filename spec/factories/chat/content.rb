# frozen_string_literal: true

FactoryBot.define do
  factory :chat_content, class: 'OmniAI::Chat::Content' do
    initialize_with { new(**attributes) }
  end
end
