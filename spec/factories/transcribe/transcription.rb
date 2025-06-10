# frozen_string_literal: true

FactoryBot.define do
  factory :transcribe_transcription, class: "OmniAI::Transcribe::Transcription" do
    initialize_with { new(**attributes) }

    text { "Hi!" }
    model { "whisper" }
    format { "text" }
  end
end
