# OmniAI

[![CircleCI](https://circleci.com/gh/ksylvest/omniai.svg?style=svg)](https://circleci.com/gh/ksylvest/omniai)

OmniAI is a flexible AI library that standardizes the APIs for multiple AI providers:

- [OmniAI::Anthropic](https://github.com/ksylvest/omniai-anthropic)
- [OmniAI::Google](https://github.com/ksylvest/omniai-google)
- [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)
- [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

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
