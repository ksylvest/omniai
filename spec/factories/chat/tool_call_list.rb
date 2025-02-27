# frozen_string_literal: true

FactoryBot.define do
  factory :chat_tool_call_list, class: "OmniAI::Chat::ToolCallList" do
    initialize_with { new(**attributes) }

    entries { [] }
  end
end
