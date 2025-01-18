# frozen_string_literal: true

FactoryBot.define do
  factory :chat_tool_call_message, class: "OmniAI::Chat::ToolCallMessage" do
    initialize_with { new(**attributes) }

    tool_call_id { "fake_tool_call_id" }
    content { "Greetings" }
  end
end
