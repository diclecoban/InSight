# InSight Project TODO

## Product Data and Ingredient Intelligence

- [ ] Add Open Beauty Facts refresh metadata to imported products.
  - Add fields such as `external_source`, `external_updated_at`, and `last_synced_at`.
  - Mark products imported from Open Beauty Facts with `external_source = 'open_beauty_facts'`.
  - Re-check stale imported products periodically, for example after 30 days.
  - Keep normal scans fast by serving cached local DB data first.

- [ ] Enrich ingredient risk scoring with regulatory sources.
  - Match ingredients against CosIng, EU cosmetic annexes, and Health Canada Hotlist.
  - Replace the temporary low-risk default for Open Beauty Facts ingredients with evidence-based `low`, `medium`, or `high` risk levels.

## Product Scan Flow

- [ ] Add user-facing handling for products not found in Open Beauty Facts.
  - Return a clear state that lets the app ask for manual product or ingredient entry later.
  - Avoid saving empty placeholder data as if it were verified product data.

- [ ] Add observability for external product lookups.
  - Log whether a scan used local DB data, imported Open Beauty Facts data, or fallback data.
  - Track lookup failures and timeouts without exposing technical messages to users.
