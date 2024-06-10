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

### Client

#### Anthropic (Claude)

```ruby
require 'omniai-anthropic'

client = OmniAI::Anthropic::Client.new
```

#### Google (Gemini)

```ruby
require 'omniai-google'

client = OmniAI::Google::Client.new
```

#### Mistral (LeChat)

```ruby
require 'omniai-mistral'

client = OmniAI::Mistral::Client.new
```

#### OpenAI (ChatGPT)

```ruby
require 'omniai-openai'

client = OmniAI::OpenAI::Client.new
completion = client.chat.completion('Tell me a joke.')
completion.choice.message.content # '...'
```

### Chat

#### Basic

```ruby
completion = client.chat.completion('Tell me a joke.')
puts(completion.choice.message.content) # '...'
```

#### Streaming

```ruby
stream = proc do |chunk|
  print(chunk.choice.delta.content) # '...'
end
```
