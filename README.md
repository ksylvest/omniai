# OmniAI

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ksylvest/omniai/blob/main/LICENSE)
[![RubyGems](https://img.shields.io/gem/v/omniai)](https://rubygems.org/gems/omniai)
[![GitHub](https://img.shields.io/badge/github-repo-blue.svg)](https://github.com/ksylvest/omniai)
[![Yard](https://img.shields.io/badge/docs-site-blue.svg)](https://omniai.ksylvest.com)
[![CircleCI](https://img.shields.io/circleci/build/github/ksylvest/omniai)](https://circleci.com/gh/ksylvest/omniai)

OmniAI provides a unified Ruby API for integrating with multiple AI providers, including Anthropic, DeepSeek, Google, Mistral, and OpenAI. It streamlines AI development by offering a consistent interface for features such as chat, text-to-speech, speech-to-text, and embeddings—ensuring seamless interoperability across platforms. Switching between providers is effortless, making any integration more flexible and reliable.

- [OmniAI::Anthropic](https://github.com/ksylvest/omniai-anthropic)
- [OmniAI::DeepSeek](https://github.com/ksylvest/omniai-deepseek)
- [OmniAI::Llama](https://github.com/ksylvest/omniai-llama)
- [OmniAI::Google](https://github.com/ksylvest/omniai-google)
- [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)
- [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

## 📄 Examples

### Example #1: [💬 Chat w/ Text](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_text)

This example demonstrates using `OmniAI` with **Anthropic** to ask for a joke. The response is parsed and printed.

```ruby
require 'omniai/anthropic'

client = OmniAI::Anthropic::Client.new

puts client.chat("Tell me a joke").text
```

```
Why don't scientists trust atoms? Because they make up everything!
```

### Example #2: [💬 Chat w/ Prompt](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_prompt)

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

### Example #3: [💬 Chat w/ Vision](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_vision)

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

### Example #4: [💬 Chat w/ Tools](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_tools)

This example demonstrates using `OmniAI` with **Google** to ask for the weather. A tool “Weather” is provided. The tool accepts a location and unit (Celsius or Fahrenheit) then calculates the weather. The LLM makes multiple tool-call requests and is automatically provided with a tool-call response prior to streaming in real-time the result.

```ruby
require 'omniai/google'

client = OmniAI::Google::Client.new

class WeatherTool < OmniAI::Tool
  description "Lookup the weather for a lat / lng."

  parameter :lat, :number, description: "The latitude of the location."
  parameter :lng, :number, description: "The longitude of the location."
  parameter :unit, :string, enum: %w[Celsius Fahrenheit], description: "The unit of measurement."
  required %i[lat lng]

  # @param lat [Float]
  # @param lng [Float]
  # @param unit [String] "Celsius" or "Fahrenheit"
  #
  # @return [String] e.g. "20° Celsius at lat=43.7 lng=-79.4"
  def execute(lat:, lng:, unit: "Celsius")
    puts "[weather] lat=#{lat} lng=#{lng} unit=#{unit}"
    "#{rand(20..50)}° #{unit} at lat=#{lat} lng=#{lng}"
  end
end

class GeocodeTool < OmniAI::Tool
  description "Lookup the latitude and longitude of a location."

  parameter :location, :string, description: "The location to geocode."
  required %i[location]

  # @param location [String] "Toronto, Canada"
  #
  # @return [Hash] { lat: Float, lng: Float, location: String }
  def execute(location:)
    puts "[geocode] location=#{location}"

    {
      lat: rand(-90.0..+90.0),
      lng: rand(-180.0..+180.0),
      location:,
    }
  end
end

tools = [
  WeatherTool.new,
  GeocodeTool.new,
]

client.chat(stream: $stdout, tools:) do |prompt|
  prompt.system "You are an expert in weather."
  prompt.user 'What is the weather in "London" in Celsius and "Madrid" in Fahrenheit?'
end
```

```
[geocode] location=London
[weather] lat=... lng=... unit=Celsius
[geocode] location=Madrid
[weather] lat=... lng=... unit=Fahrenheit

The weather is 24° Celsius in London and 42° Fahrenheit in Madrid.
```

_For a set of pre-built tools for interacting with browsers, databases, docker, and more try the [OmniAI::Tools](https://omniai-tools.ksylvest.com/) project._

### Example #5: [💬 Chat w/ History](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_history)

Tracking a prompt history over multiple user and assistant messages is especially helpful when building an agent like conversation experience. A prompt can be used to track this back-and-forth conversation:

```ruby
require "omniai/openai"

puts("Type 'exit' or 'quit' to leave.")

client = OmniAI::OpenAI::Client.new

conversation = OmniAI::Chat::Prompt.build do |prompt|
  prompt.system "You are a helpful assistant. Respond in both English and French."
end

loop do
  print "> "
  text = gets.chomp.strip
  next if text.empty?
  break if text.eql?("exit") || text.eql?("quit")

  conversation.user(text)
  response = client.chat(conversation, stream: $stdout)
  conversation.assistant(response.text)
end
```

### Example #6 [💬 Chat w/ Schema](https://github.com/ksylvest/omniai/blob/main/examples/chat_with_schema)

Requesting structured data back from an LLM is possible by defining a schema, then passing the schema into the chat. The following example defines a structured schema using `OmniAI::Schema` to model a `Contact`. The results of the LLM call are then parsed using the schema to ensure all types are correct.

```ruby
format = OmniAI::Schema.format(name: "Contact", schema: OmniAI::Schema.object(
  description: "A contact with a name, relationship, and addresses.",
  properties: {
    name: OmniAI::Schema.string,
    relationship: OmniAI::Schema.string(enum: %w[friend family]),
    addresses: OmniAI::Schema.array(
      items: OmniAI::Schema.object(
        title: "Address",
        description: "An address with street, city, state, and zip code.",
        properties: {
          street: OmniAI::Schema.string,
          city: OmniAI::Schema.string,
          state: OmniAI::Schema.string,
          zip: OmniAI::Schema.string,
        },
        required: %i[street city state zip]
      )
    ),
  },
  required: %i[name]
))

response = client.chat(format:) do |prompt|
  prompt.user <<~TEXT
    Parse the following contact:

    NAME: George Harrison
    RELATIONSHIP: friend
    HOME: 123 Main St, Springfield, IL, 12345
    WORK: 456 Elm St, Springfield, IL, 12345
  TEXT
end

puts format.parse(response.text)
```

```
{
  name: "George Harrison",
  relationship: "friend",
  addresses: [
    { street: "123 Main St", city: "Springfield", state: "IL", zip: "12345" },
    { street: "456 Elm St", city: "Springfield", state: "IL", zip: "12345" },
  ]
}
```

### Example #7: [🐚 CLI](https://github.com/ksylvest/omniai/blob/main/examples/cli)

The `OmniAI` gem also ships with a CLI to simplify quick tests.

```bash
# Chat

omniai chat "Who designed the Ruby programming language?"
omniai chat --provider="google" --model="gemini-2.0-flash" "Who are you?"

## Speech to Text

omniai speak "Salley sells sea shells by the sea shore." > ./files/audio.wav

# Text to Speech

omniai transcribe "./files/audio.wav"

# Embed

omniai embed "What is the capital of France?"
```

### Example #8: [🔈 Text-to-Speech](https://github.com/ksylvest/omniai/blob/main/examples/text_to_speech)

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

### Example #9: [🎤 Speech-to-Text](https://github.com/ksylvest/omniai/blob/main/examples/speech_to_text)

This example demonstrates using `OmniAI` with **OpenAI** to convert speech to text.

```ruby
require 'omniai/openai'

client = OmniAI::OpenAI::Client.new

File.open(File.join(__dir__, 'audio.wav'), 'rb') do |file|
  transcription = client.transcribe(file)
  puts(transcription.text)
end
```

### Example #10: [💻 Embeddings](https://github.com/ksylvest/omniai/blob/main/examples/embeddings)

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

## 📦 Installation

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

## 📖 Usage

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

#### [OmniAI::Llama](https://github.com/ksylvest/omniai-llama)

```ruby
require 'omniai/llama'

client = OmniAI::Llama::Client.new
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
client = OmniAI::OpenAI::Client.new(timeout: 8) # 8 seconds
```

Timeouts are also configurable by passing a `timeout` hash with `timeout` / `read` / `write` keys using:

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

### 💬 Chat

Clients that support chat (e.g. Anthropic w/ "Claude", Google w/ "Gemini", Mistral w/ "LeChat", OpenAI w/ "ChatGPT", etc) generate text using the following calls:

#### Using a Basic Prompt

A chat response can be generated using a string for a prompt:

```ruby
response = client.chat('Tell me a joke.')
response.text # 'Why don't scientists trust atoms? They make up everything!'
```

#### Using a Complex Prompt

A chat response can be generated using a combination of messages and parts for a prompt:

```ruby
response = client.chat do |prompt|
  prompt.system 'You are a helpful assistant with an expertise in animals.'
  prompt.user do |message|
    message.text 'What animals are in the attached photos?'
    message.url('https://.../cat.jpeg', "image/jpeg")
    message.url('https://.../dog.jpeg', "image/jpeg")
    message.file('./hamster.jpeg', "image/jpeg")
  end
end
response.text  # 'They are photos of a cat, a cat, and a hamster.'
```

#### Streaming via Proc

A chat real-time stream of chunks can be generated with a proc:

```ruby
stream = proc do |chunk|
  print(chunk.text) # '...'
end
client.chat('Tell me a joke.', stream:)
```

#### Streaming via IO

A chat real-time stream of chunks can also work with any IO object (e.g., `File`, `$stdout`, `$stdin`, etc.):

```ruby
client.chat('Tell me a story', stream: $stdout)
```

#### Using Tools

The chat API can be provided with a set of tools to be invoked:

```ruby
class WeatherTool
  description "Lookup the weather at a location in either Celsius or Fahrenheit."

  parameter :location, :string, description: "The location to find the weather.", nullable: false
  parameter :unit, :string, enum: %w[Celsius Fahrenheit], description: "The unit of measurement.", nullable: true
  required %i[location unit]

  # @param location [String]
  # @param unit [String] "Celsius" or "Fahrenheit"
  #
  # @return [Hash]
  def execute(location:, unit: "Celsius")
    puts "[weather] location=#{location} unit=#{unit}"

    {
      temperature: "#{rand(20..50)}°",
      humidity: rand(0..100),
    }
  end
end

client.chat('What is the weather in "London" in Celsius and "Paris" in Fahrenheit?', tools: [WeatherTool.new])
```

#### Extended Thinking / Reasoning

Some models support extended thinking or reasoning capabilities. OmniAI provides a unified `thinking:` option that works across all supported providers:

```ruby
# Enable thinking (provider uses sensible defaults)
response = client.chat("What is 25 * 25?", thinking: true)

# Access thinking content
response.choices.first.message.contents.each do |content|
  case content
  when OmniAI::Chat::Thinking
    puts "Thinking: #{content.thinking}"
  when OmniAI::Chat::Text
    puts "Response: #{content.text}"
  end
end
```

With streaming:

```ruby
client.chat("Solve this step by step: What is 123 * 456?", thinking: true, stream: $stdout)
```

**Provider Support:**

| Provider | Option | Notes |
|----------|--------|-------|
| Anthropic | `thinking: true` or `thinking: { budget_tokens: N }` | Requires Claude 3.5+ models |
| Google | `thinking: true` | Requires Gemini 2.0+ with thinking enabled |
| OpenAI | `thinking: true` or `thinking: { effort: "high" }` | Requires o1/o3 models |

### 🎤 Speech to Text

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

### 🔈 Text to Speech

Clients that support speak (e.g. OpenAI w/ "Whisper") convert text to speech via the following calls:

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

### 💻 Embeddings

Clients that support generating embeddings (e.g. OpenAI, Mistral, etc.) convert text to embeddings via the following:

```ruby
response = client.embed('The quick brown fox jumps over a lazy dog')
response.usage # <OmniAI::Embed::Usage prompt_tokens=5 total_tokens=5>
response.embedding # [0.1, 0.2, ...] >
```

Theese APIs support generating embeddings in batches using the following code:

```ruby
response = client.embed([
  'The quick brown fox jumps over a lazy dog',
  'Pack my box with five dozen liquor jugs',
])
response.usage # <OmniAI::Embed::Usage prompt_tokens=5 total_tokens=5>
response.embeddings.each do |embedding|
  embedding # [0.1, 0.2, ...]
end
```

## 🐚 CLI

OmniAI packages a basic command line interface (CLI) to allow for exploration of various APIs. CLI documentation is available with the `--help` flag:

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
# What is the warmest place on earth?
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
# What is the capital of Spain?
The capital of Spain is **Madrid**.
```

```
0.0
...
```

#### Text-to-Speech

```bash
omniai speak "Sally sells sea shells on the sea shore." > audio.aac
```

#### Speech-to-Text

```bash
omniai transcribe ./audio.aac
```

## MCP

[MCP](https://modelcontextprotocol.io/introduction) is an open protocol designed to standardize giving context to LLMs. The OmniAI implementation supports building an MCP server that operates via the [stdio](https://modelcontextprotocol.io/docs/concepts/transports) transport.

**main.rb**

```ruby
class Weather < OmniAI::Tool
  description "Lookup the weather for a location"

  parameter :location, :string, description: "A location (e.g. 'London' or 'Madrid')."
  required %i[location]

  # @param location [String] required
  # @return [String]
  def execute(location:)
    case location
    when 'London' then 'Rainy'
    when 'Madrid' then 'Sunny'
    end
  end
end

transport = OmniAI::MCP::Transport::Stdio.new
mcp = OmniAI::MCP::Server.new(tools: [Weather.new])
mcp.run(transport:)
```

```bash
ruby main.rb
```

```bash
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": { "name": "echo", "arguments": { "message": "Hello, world!" } }
}
```
