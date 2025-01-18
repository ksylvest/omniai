# frozen_string_literal: true

FactoryBot.define do
  factory :chat_response, class: "OmniAI::Chat::Response" do
    initialize_with { new(data:) }

    data do
      {
        "choices" => [
          { "index" => 0, "message" => { "role" => "system", "content" => "Hello!" } },
        ],
        "usage" => {
          "input_tokens" => 0,
          "output_tokens" => 0,
          "total_tokens" => 0,
        },
      }
    end
  end
end
