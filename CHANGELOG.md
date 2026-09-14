# Changelog

## 3.9.0

### Added

- `OmniAI::Chat` accepts `on_response:`, a proc handed the `Response` for each completed round of a tool-call chain, in order, before that round's tool calls are executed. It fires for single-round chats too, so the yielded usages always sum to the final `Response#total_usage`, and it is independent of `stream:`.

  Only the final `Response` is returned from `#process!`, so when a caller aborts a chain mid-flight — a stream block raising to stop a runaway tool loop, or a tool raising — the stack unwinds with no `Response` at all and every completed round's usage is lost. A chain of 20 real, billed rounds books as zero. `on_response` hands each round to the caller as it completes, so an aborted run can still be accounted for.

  ```ruby
  rounds = []

  begin
    client.chat(prompt, tools:, stream:, on_response: proc { |round| rounds << round })
  rescue TooManyRounds
    rounds.filter_map(&:usage).sum { |usage| usage.input_tokens.to_i + usage.output_tokens.to_i }
  end
  ```

  Deliberately not a `Delta`: deltas are provider chunks, usage is a round-level fact, and a delta cannot reach a caller streaming to an `IO`. Passing the whole `Response` also carries each round's `#finish_reason`, `#tool_call_list`, and raw `#data` (e.g. Anthropic's cache usage keys).

### Upgrading

- Nothing to do. Callers that pass no `on_response:` are unaffected, streaming and non-streaming alike.
- **`on_response:` reaches `OmniAI::Chat` only through a `Client#chat` that forwards `**`.** omniai-anthropic, omniai-google, and omniai-openai do; omniai-mistral < 3.0.1 enumerates its keywords and raises `ArgumentError`.
- **Subclasses that override `#spawn!` must forward `on_response:`.** The base implementation now passes it along with `stream:`, `tools:`, and the rest; an override that enumerates keywords will silently drop it after the first round. No provider gem overrides `#spawn!`.

## 3.8.0

### Added

- `OmniAI::Chat::Usage#thinking_tokens` reports the subset of `output_tokens` a provider attributes to internal reasoning. It defaults to `nil`, which means the provider reported no breakdown — deliberately distinct from `0`, which means the provider reported that no reasoning occurred. `#serialize` emits the key only when a value is present, so payloads for providers that report no breakdown are unchanged.

  `thinking_tokens` is always a *subset* of `output_tokens`, never an addition to it. Providers that fold reasoning into their output count keep that count as-is and gain only the breakdown; providers that report reasoning separately have it added into `output_tokens` so the field means the same thing everywhere.

  **This class reads only its own `thinking_tokens` key.** Each provider's own vocabulary is read by that provider's `:usage` deserializer, so the field is populated only by provider gems that ship one:

  | Provider | Populated | Read from |
  | --- | --- | --- |
  | omniai-google >= 3.12 | yes | `thoughtsTokenCount` |
  | omniai-anthropic >= 3.6 | yes | `usage.output_tokens_details.thinking_tokens` |
  | omniai-openai >= 3.2 | yes | `usage.output_tokens_details.reasoning_tokens` (Responses API) |
  | omniai-mistral | no | no breakdown reported |

  Against an older provider gem, or one not listed, `thinking_tokens` is `nil`. That is the same value it held before this release, so nothing regresses — but do not read `nil` as "no reasoning occurred".

### Fixed

- `OmniAI::Chat::Response#total_usage` now sums each response's provider-reported `total_tokens` and falls back to `input + output` only where a provider reported none. It previously recomputed the total unconditionally, which discarded any tokens a provider counts as neither input nor output — Google's `totalTokenCount` includes thinking tokens, so an aggregate could report a smaller total than the individual responses it summed. `thinking_tokens` is aggregated alongside, and stays `nil` when no response in the chain reported one.

  Known limitation: Anthropic reports no total at all, so its contribution is always the derived `input + output`, which excludes `cache_creation_input_tokens` and `cache_read_input_tokens`. An aggregate spanning Anthropic responses therefore understates cache-heavy conversations.

### Upgrading

- **Verified doubles of `OmniAI::Chat::Usage` need `thinking_tokens` stubbed.** `Response#total_usage` now reads the new attribute, so an `instance_double(OmniAI::Chat::Usage, input_tokens:, output_tokens:, total_tokens:)` raises on the unstubbed method. RSpec is behaving correctly — the double is verified against the real class — but it surfaces at upgrade time in specs rather than in application code. Add `thinking_tokens:` to affected doubles; `nil` is a valid value and matches a provider that reports no breakdown.

Earlier changes are recorded in the GitHub releases.
