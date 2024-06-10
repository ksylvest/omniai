# OmniAI

OmniAI is a flexible AI library that standardizes the APIs for multipe AI providers:

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
require 'omniai-anthropic'

client = OmniAI::Anthropic::Client.new
```

#### [OmniAI::Google](https://github.com/ksylvest/omniai-google)

```ruby
require 'omniai-google'

client = OmniAI::Google::Client.new
```

#### [OmniAI::Mistral](https://github.com/ksylvest/omniai-mistral)

```ruby
require 'omniai-mistral'

client = OmniAI::Mistral::Client.new
```

#### [OmniAI::OpenAI](https://github.com/ksylvest/omniai-openai)

```ruby
require 'omniai-openai'

client = OmniAI::OpenAI::Client.new
```

### Chat

Clients that support chat (e.g. Anthropic w/ "Claude", Google w/ "Gemini", Mistral w/ "LeChat", OpenAI w/ "ChatGPT", etc) can generate completions using either a basic or streaming API:

#### Basic

```ruby
completion = client.chat.completion('Tell me a joke.')
puts(completion.choice.message.content) # '...'
```

#### Streaming

```ruby
client.chat.completion 'Tell me a joke.', stream: proc do |chunk|
  print(chunk.choice.delta.content) # '...'
end
```
