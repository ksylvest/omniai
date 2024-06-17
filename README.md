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

Clients that support chat (e.g. Anthropic w/ "Claude", Google w/ "Gemini", Mistral w/ "LeChat", OpenAI w/ "ChatGPT", etc) generate completions using the following calls:

#### w/ a Simple Prompt

```ruby
completion = client.chat('Tell me a joke.')
completion.choice.message.content # '...'
```

#### w/ a Collection of Messages

```ruby
messages = [
  {
    role: 'system',
    content: 'You are a helpful assistant with an expertise in geography.',
  },
  'What is the capital of Canada?'
]
completion = client.chat(messages, model: '...', temperature: 0.7, format: :json)
completion.choice.message.content
```

#### w/ a Collection of Files

```ruby

image_a_url = "https://images.unsplash.com/photo-1517849845537-4d257902454a?w=800&h=800&format=jpeg&fit=crop"
image_b_url = "https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?q=80&w=1024&h=1024&format=jpeg"

message = {
  role: 'user',
  content: [
    OmniAI::Chat::Content.new('What are in these images and are they different?'),
    OmniAI::Chat::Content.new(image_a_url, type: :image),
    OmniAI::Chat::Content.new(image_b_url, type: :image),
  ]
}

completion = client.chat(message)
completion.choice.message.content
```

#### Streaming

```ruby
stream = proc do |chunk|
  print(chunk.choice.delta.content) # '...'
end
client.chat('Tell me a joke.', stream:)
```
