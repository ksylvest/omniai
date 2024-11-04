# frozen_string_literal: true

FactoryBot.define do
  factory :tool_object, class: 'OmniAI::Tool::Object' do
    initialize_with { new(**attributes) }

    description { 'A person.' }
    properties do
      {
        name: build(:tool_property, :string, description: 'The name of the person.'),
        age: build(:tool_property, :integer, description: 'The age of the person.'),
        employeed: build(:tool_property, :boolean, description: 'Is the person employeed?'),
      }
    end
    required { %i[name] }
  end
end
