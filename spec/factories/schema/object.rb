# frozen_string_literal: true

FactoryBot.define do
  factory :schema_object, class: "OmniAI::Schema::Object" do
    initialize_with { new(**attributes) }

    description { "A person." }
    properties do
      {
        name: build(:schema_scalar, :string, description: "The name of the person."),
        age: build(:schema_scalar, :integer, description: "The age of the person."),
        employed: build(:schema_scalar, :boolean, description: "Is the person employed?"),
      }
    end
    required { %i[name] }
  end
end
