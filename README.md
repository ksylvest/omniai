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
I, [...]  INFO -- : > POST https://...
D, [...] DEBUG -- : Authorization: Bearer ...
...
{"messages":[{"role":"user","content":"Tell me a joke!"}],"model":"..."}
I, [...]  INFO -- : < 200 OK
D, [...] DEBUG -- : Date: ...
...
{
  "id": "...",
  "object": "...",
  ...
}
```

The level of the logger can be configured to either `INFO` and `DEBUG`:

**INFO**:

```ruby
logger.level = Logger::INFO
```

- Request: verb / URI
- Response: status

**DEBUG**:

```ruby
logger.level = Logger::DEBUG
```

- Request: verb / URI / headers / body
- Response: status / headers / body

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

#### Completions using Single Message

```ruby
completion = client.chat('Tell me a joke.')
completion.choice.message.content # '...'
```

#### Completions using Multiple Messages

```ruby
messages = [
  {
    role: OmniAI::Chat::Role::SYSTEM,
    content: 'You are a helpful assistant with an expertise in geography.',
  },
  'What is the capital of Canada?'
]
completion = client.chat(messages, model: '...', temperature: 0.7, format: :json)
completion.choice.message.content  # '...'
```

#### Completions using Real-Time Streaming

```ruby
stream = proc do |chunk|
  print(chunk.choice.delta.content) # '...'
end
client.chat('Tell me a joke.', stream:)
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
