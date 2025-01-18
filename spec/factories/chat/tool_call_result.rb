# frozen_string_literal: true

FactoryBot.define do
  factory :tool_call_result, class: "OmniAI::Chat::ToolCallResult" do
    initialize_with { new(**attributes) }

    tool_call_id { "fake_tool_call_id" }
    content { "Greetings" }
  end
end
