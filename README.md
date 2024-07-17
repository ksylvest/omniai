# OmniAI

[![CircleCI](https://circleci.com/gh/ksylvest/omniai.svg?style=svg)](https://circleci.com/gh/ksylvest/omniai)

OmniAI is a flexible AI library that standardizes the APIs of many different AIs:

- [OmniAI::Anthropic](https://github.com/ksylvest/omniai-anthropic)
- [OmniAI::Google](https://github.com/ksylvest/omniai-google)
- [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)
- [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

All libraries are community maintained.

## Installation

```sh
gem install omniai
```

```sh
gem install omniai-anthropic
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
client = OmniAI::Example::Client.new(logger:)
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

Timeouts are also be configurable by passing a `timeout` hash with `timeout` / `read` / `write` / `keys using:

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
completion.choice.message.content # 'Why don't scientists trust atoms? They make up everything!'
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
completion.choice.message.content  # 'They are photos of a cat, a cat, and a hamster.'
```

#### Completions using Streaming via Proc

A real-time stream of messages can be generated by passing in a proc:

```ruby
stream = proc do |chunk|
  print(chunk.choice.delta.content) # '...'
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
  proc { |location:, unit: 'celsius'| "#{rand(20..50)}° #{unit} in #{location}" },
  name: 'Weather',
  description: 'Lookup the weather in a location',
  parameters: OmniAI::Tool::Parameters.new(
    properties: {
      location: OmniAI::Tool::Property.string(description: 'e.g. Toronto'),
      unit: OmniAI::Tool::Property.string(enum: %w[celcius farenheit]),
    },
    required: %i[location]
  )
)
client.chat('What is the weather in "London" and "Madrid"?', tools: [tool])
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
