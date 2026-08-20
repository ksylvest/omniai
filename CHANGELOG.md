# Changelog

## 3.8.0

### Added

- `OmniAI::Chat::Usage#thinking_tokens` reports the subset of `output_tokens` a provider attributes to internal reasoning. It defaults to `nil`, which means the provider reported no breakdown — deliberately distinct from `0`, which means the provider reported that no reasoning occurred. The generic deserializer populates it from the breakdown each provider already sends alongside its output count: `output_tokens_details.thinking_tokens` (Anthropic) or `completion_tokens_details.reasoning_tokens` (OpenAI). `#serialize` emits the key only when a value is present, so payloads for providers that report no breakdown are unchanged.

  `thinking_tokens` is always a *subset* of `output_tokens`, never an addition to it. Providers that fold reasoning into their output count keep that count as-is and gain only the breakdown; providers that report reasoning separately have it added into `output_tokens` so the field means the same thing everywhere.

### Fixed

- `OmniAI::Chat::Response#total_usage` now sums each response's provider-reported `total_tokens` and falls back to `input + output` only where a provider reported none. It previously recomputed the total unconditionally, which discarded any tokens a provider counts as neither input nor output — Google's `totalTokenCount` includes thinking tokens, so an aggregate could report a smaller total than the individual responses it summed. `thinking_tokens` is aggregated alongside, and stays `nil` when no response in the chain reported one.

  Known limitation: Anthropic reports no total at all, so its contribution is always the derived `input + output`, which excludes `cache_creation_input_tokens` and `cache_read_input_tokens`. An aggregate spanning Anthropic responses therefore understates cache-heavy conversations.

Earlier changes are recorded in the GitHub releases.
