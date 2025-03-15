# OmniAI

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ksylvest/omniai/blob/main/LICENSE)
[![RubyGems](https://img.shields.io/gem/v/omniai)](https://rubygems.org/gems/omniai)
[![GitHub](https://img.shields.io/badge/github-repo-blue.svg)](https://github.com/ksylvest/omniai)
[![Yard](https://img.shields.io/badge/docs-site-blue.svg)](https://omniai.ksylvest.com)
[![CircleCI](https://img.shields.io/circleci/build/github/ksylvest/omniai)](https://circleci.com/gh/ksylvest/omniai)

OmniAI provides a unified Ruby API for integrating with multiple AI providers, including Anthropic, DeepSeek, Google, Mistral, and OpenAI. It streamlines AI development by offering a consistent interface for features such as chat, text-to-speech, speech-to-text, and embeddings—ensuring seamless interoperability across platforms. Switching between providers is effortless, making any integration more flexible and reliable.

- [OmniAI::Anthropic](https://github.com/ksylvest/omniai-anthropic)
- [OmniAI::DeepSeek](https://github.com/ksylvest/omniai-deepseek)
- [OmniAI::Google](https://github.com/ksylvest/omniai-google)
- [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)
- [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

## Examples

### Example #1: [Chat w/ Text](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_text)

This example demonstrates using `OmniAI` with **Anthropic** to ask for a joke. The response is parsed and printed.

```ruby
require 'omniai/anthropic'

client = OmniAI::Anthropic::Client.new

puts client.chat("Tell me a joke").text
```

```
Why don't scientists trust atoms? Because they make up everything!
```

### Example #2: [Chat w/ Prompt](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_prompt)

This example demonstrates using `OmniAI` with **Mistral** to ask for the fastest animal. It includes a system and user message in the prompt. The response is streamed in real time.

```ruby
require "omniai/mistral"

client = OmniAI::Mistral::Client.new

client.chat(stream: $stdout) do |prompt|
  prompt.system "Respond in both English and French."
  prompt.user "What is the fastest animal?"
end
```

```
**English**: The peregrine falcon is generally considered the fastest animal, reaching speeds of over 390 km/h.
**French**: Le faucon pèlerin est généralement considéré comme l'animal le plus rapide, atteignant des vitesses de plus de 390 km/h.
```

### Example #3: [Chat w/ Vision](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_vision)

This example demonstrates using `OmniAI` with **OpenAI** to prompt a “biologist” for an analysis of photos, identifying the animals within each one. A system and user message are provided, and the response is streamed in real time.

```ruby
require "omniai/openai"

client = OmniAI::OpenAI::Client.new

CAT_URL = "https://images.unsplash.com/photo-1472491235688-bdc81a63246e?q=80&w=1024&h=1024&fit=crop&fm=jpg"
DOG_URL = "https://images.unsplash.com/photo-1517849845537-4d257902454a?q=80&w=1024&h=1024&fit=crop&fm=jpg"

client.chat(stream: $stdout) do |prompt|
  prompt.system("You are a helpful biologist with expertise in animals who responds with the Latin names.")
  prompt.user do |message|
    message.text("What animals are in the attached photos?")
    message.url(CAT_URL, "image/jpeg")
    message.url(DOG_URL, "image/jpeg")
  end
end
```

```
The first photo is of a cat, *Felis Catus*.
The second photo is of a dog, *Canis Familiaris*.
```

### Example #4: [Chat w/ Tools](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_tools)

This example demonstrates using `OmniAI` with **Google** to ask for the weather. A tool “Weather” is provided. The tool accepts a location and unit (Celsius or Fahrenheit) then calculates the weather. The LLM makes multiple tool-call requests and is automatically provided with a tool-call response prior to streaming in real-time the result.

```ruby
require 'omniai/google'

client = OmniAI::Google::Client.new

tool = OmniAI::Tool.new(
  proc { |location:, unit: "Celsius"| "#{rand(20..50)}° #{unit} in #{location}" },
  name: "Weather",
  description: "Lookup the weather in a location",
  parameters: OmniAI::Tool::Parameters.new(
    properties: {
      location: OmniAI::Tool::Property.string(description: "e.g. Toronto"),
      unit: OmniAI::Tool::Property.string(enum: %w[Celsius Fahrenheit]),
    },
    required: %i[location]
  )
)

client.chat(stream: $stdout, tools: [tool]) do |prompt|
  prompt.system "You are an expert in weather."
  prompt.user 'What is the weather in "London" in Celsius and "Madrid" in Fahrenheit?'
end
```

```
The weather is 24° Celsius in London and 42° Fahrenheit in Madrid.
```

### Example #5: [Text-to-Speech](https://github.com/ksylvest/omniai/blob/main/examples/text_to_speech)

This example demonstrates using `OmniAI` with **OpenAI** to convert text to speech and save it to a file.

```ruby
require 'omniai/openai'

client = OmniAI::OpenAI::Client.new

File.open(File.join(__dir__, 'audio.wav'), 'wb') do |file|
  client.speak('Sally sells seashells by the seashore.', format: OmniAI::Speak::Format::WAV) do |chunk|
    file << chunk
  end
end
```

### Example #6: [Speech-to-Text](https://github.com/ksylvest/omniai/blob/main/examples/speech_to_text)

This example demonstrates using `OmniAI` with **OpenAI** to convert speech to text.

```ruby
require 'omniai/openai'

client = OmniAI::OpenAI::Client.new

File.open(File.join(__dir__, 'audio.wav'), 'rb') do |file|
  transcription = client.transcribe(file)
  puts(transcription.text)
end
```

### Example #7: [Embeddings](https://github.com/ksylvest/omniai/blob/main/examples/embeddings)

This example demonstrates using `OmniAI` with **Mistral** to generate embeddings for a dataset. It defines a set of entries (e.g. "George is a teacher." or "Ringo is a doctor.") and then compares the embeddings generated from a query (e.g. "What does George do?" or "Who is a doctor?") to rank the entries by relevance.

```ruby
require 'omniai/mistral'

CLIENT = OmniAI::Mistral::Client.new

Entry = Data.define(:text, :embedding) do
  def initialize(text:)
    super(text:, embedding: CLIENT.embed(text).embedding)
  end
end

ENTRIES = [
  Entry.new(text: 'John is a musician.'),
  Entry.new(text: 'Paul is a plumber.'),
  Entry.new(text: 'George is a teacher.'),
  Entry.new(text: 'Ringo is a doctor.'),
].freeze

def search(query)
  embedding = CLIENT.embed(query).embedding

  results = ENTRIES.sort_by do |data|
    Math.sqrt(data.embedding.zip(embedding).map { |a, b| (a - b)**2 }.reduce(:+))
  end

  puts "'#{query}': '#{results.first.text}'"
end

search('What does George do?')
search('Who is a doctor?')
search('Who do you call to fix a toilet?')
```

```
'What does George do?': 'George is a teacher.'
'Who is a doctor?': 'Ringo is a doctor.'
'Who do you call to fix a toilet?': 'Paul is a plumber.'
```

## Installation

The main `omniai` gem is installed with:

```sh
gem install omniai
```

Specific provider gems are installed with:

```sh
gem install omniai-anthropic
gem install omniai-deepseek
gem install omniai-mistral
gem install omniai-google
gem install omniai-openai
```

## Usage

OmniAI implements APIs for a number of popular clients by default. A client can be initialized using the specific gem (e.g. `omniai-openai` for `OmniAI::OpenAI`). Vendor specific docs can be found within each repo.

### Client

#### [OmniAI::Anthropic](https://github.com/ksylvest/omniai-anthropic)

```ruby
require 'omniai/anthropic'

client = OmniAI::Anthropic::Client.new
```

#### [OmniAI::DeepSeek](https://github.com/ksylvest/omniai-deepseek)

```ruby
require 'omniai/deepseek'

client = OmniAI::DeepSeek::Client.new
```

#### [OmniAI::Google](https://github.com/ksylvest/omniai-google)

```ruby
require 'omniai/google'

client = OmniAI::Google::Client.new
```

#### [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)

```ruby
require 'omniai/mistral'

client = OmniAI::Mistral::Client.new
```

#### [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

```ruby
require 'omniai/openai'

client = OmniAI::OpenAI::Client.new
```

#### Usage with LocalAI

LocalAI support is offered through [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai):

[Usage with LocalAI](https://github.com/ksylvest/omniai-openai#usage-with-localai)

#### Usage with Ollama

Ollama support is offered through [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai):

[Usage with Ollama](https://github.com/ksylvest/omniai-openai#usage-with-ollama)

#### Logging

Logging the **request** / **response** is configurable by passing a logger into any client:

```ruby
require 'omniai/openai'
require 'logger'

logger = Logger.new(STDOUT)
client = OmniAI::OpenAI::Client.new(logger:)
```

```
[INFO]: POST https://...
[INFO]: 200 OK
...
```

#### Timeouts

Timeouts are configurable by passing a `timeout` an integer duration for the request / response of any APIs using:

```ruby
require 'omniai/openai'
require 'logger'

logger = Logger.new(STDOUT)
client = OmniAI::OpenAI::Client.new(timeout: 8) # i.e. 8 seconds
```

Timeouts are also configurable by passing a `timeout` hash with `timeout` / `read` / `write` / keys using:

```ruby
require 'omniai/openai'
require 'logger'

logger = Logger.new(STDOUT)
client = OmniAI::OpenAI::Client.new(timeout: {
  read: 2, # i.e. 2 seconds
  write: 3, # i.e. 3 seconds
  connect: 4, # i.e. 4 seconds
})
```

### Chat

Clients that support chat (e.g. Anthropic w/ "Claude", Google w/ "Gemini", Mistral w/ "LeChat", OpenAI w/ "ChatGPT", etc) generate completions using the following calls:

#### Completions using a Simple Prompt

Generating a completion is as simple as sending in the text:

```ruby
completion = client.chat('Tell me a joke.')
completion.text # 'Why don't scientists trust atoms? They make up everything!'
```

#### Completions using a Complex Prompt

More complex completions are generated using a block w/ various system / user messages:

```ruby
completion = client.chat do |prompt|
  prompt.system 'You are a helpful assistant with an expertise in animals.'
  prompt.user do |message|
    message.text 'What animals are in the attached photos?'
    message.url('https://.../cat.jpeg', "image/jpeg")
    message.url('https://.../dog.jpeg', "image/jpeg")
    message.file('./hamster.jpeg', "image/jpeg")
  end
end
completion.text  # 'They are photos of a cat, a cat, and a hamster.'
```

#### Completions using Streaming via Proc

A real-time stream of messages can be generated by passing in a proc:

```ruby
stream = proc do |chunk|
  print(chunk.text) # '...'
end
client.chat('Tell me a joke.', stream:)
```

#### Completion using Streaming via IO

The above code can also be supplied any IO (e.g. `File`, `$stdout`, `$stdin`, etc):

```ruby
client.chat('Tell me a story', stream: $stdout)
```

#### Completion with Tools

A chat can also be initialized with tools:

```ruby
tool = OmniAI::Tool.new(
  proc { |location:, unit: 'Celsius'| "#{rand(20..50)}° #{unit} in #{location}" },
  name: 'Weather',
  description: 'Lookup the weather in a location',
  parameters: OmniAI::Tool::Parameters.new(
    properties: {
      location: OmniAI::Tool::Property.string(description: 'e.g. Toronto'),
      unit: OmniAI::Tool::Property.string(enum: %w[Celsius Fahrenheit]),
    },
    required: %i[location]
  )
)
client.chat('What is the weather in "London" in Celsius and "Paris" in Fahrenheit?', tools: [tool])
```

### Transcribe

Clients that support transcribe (e.g. OpenAI w/ "Whisper") convert recordings to text via the following calls:

#### Transcriptions with Path

```ruby
transcription = client.transcribe("example.ogg")
transcription.text # '...'
```

#### Transcriptions with Files

```ruby
File.open("example.ogg", "rb") do |file|
  transcription = client.transcribe(file)
  transcription.text # '...'
end
```

### Speak

Clients that support speak (e.g. OpenAI w/ "Whisper") convert text to recordings via the following calls:

#### Speech with Stream

```ruby
File.open('example.ogg', 'wb') do |file|
  client.speak('The quick brown fox jumps over a lazy dog.', voice: 'HAL') do |chunk|
    file << chunk
  end
end
```

#### Speech with File

```ruby
tempfile = client.speak('The quick brown fox jumps over a lazy dog.', voice: 'HAL')
tempfile.close
tempfile.unlink
```

### Embeddings

Clients that support generating embeddings (e.g. OpenAI, Mistral, etc.) convert text to embeddings via the following:

```ruby
response = client.embed('The quick brown fox jumps over a lazy dog')
response.usage # <OmniAI::Embed::Usage prompt_tokens=5 total_tokens=5>
response.embedding # [0.1, 0.2, ...] >
```

Batches of text can also be converted to embeddings via the following:

```ruby
response = client.embed([
  '',
  '',
])
response.usage # <OmniAI::Embed::Usage prompt_tokens=5 total_tokens=5>
response.embeddings.each do |embedding|
  embedding # [0.1, 0.2, ...]
end
```

## CLI

OmniAI packages a basic command line interface (CLI) to allow for exploration of various APIs. A detailed CLI documentation can be found via help:

```bash
omniai --help
```

### Chat

#### w/ a Prompt

```bash
omniai chat "What is the coldest place on earth?"
```

```
The coldest place on earth is Antarctica.
```

#### w/o a Prompt

```bash
omniai chat --provider="openai" --model="gpt-4" --temperature="0.5"
```

```
Type 'exit' or 'quit' to abort.
# What is the warmet place on earth?
```

```
The warmest place on earth is Africa.
```

### Embed

#### w/ input

```bash
omniai embed "The quick brown fox jumps over a lazy dog."
```

```
0.0
...
```

#### w/o input

```bash
omniai embed --provider="openai" --model="text-embedding-ada-002"
```

```
Type 'exit' or 'quit' to abort.
# Whe quick brown fox jumps over a lazy dog.
```

```
0.0
...
```
