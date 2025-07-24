# frozen_string_literal: true

RSpec.describe OmniAI::OpenAI::Tool do
  it { expect(described_class::FILE_SEARCH).to eql({ type: "file_search" }) }
  it { expect(described_class::CODE_INTERPRETER).to eql({ type: "code_interpreter" }) }
end
