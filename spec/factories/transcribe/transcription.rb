# frozen_string_literal: true

FactoryBot.define do
  factory :transcribe_transcription, class: "OmniAI::Transcribe::Transcription" do
    initialize_with { new(**attributes) }

    text { "Sally sells sea shells by the sea shore." }
    model { "whisper" }
    format { "text" }
  end
end
