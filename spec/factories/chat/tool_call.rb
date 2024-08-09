# frozen_string_literal: true

FactoryBot.define do
  factory :chat_tool_call, class: 'OmniAI::Chat::ToolCall' do
    initialize_with { new(**attributes) }
    id { 'fake_tool_call_id' }
    function factory: :chat_function
  end
end
