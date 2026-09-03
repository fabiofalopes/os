# Session Queue

> The runner picks the **top unchecked** `- [ ]` job each wave, runs up to
> `WORKERS_PER_TICK` of them in parallel, and checks off the ones that return `ok`.
> Add jobs anywhere; order = priority. Keep each job to one bounded session's worth.
> Tag each with a role so sessions know their hat: e.g. [research] [build] [curate]
> [maintain] [review] [steward] — invent your own; the tag is prompt context, not code.
> Job text may name a target note (`Write wiki/x.md …`); the runner de-dups targets so
> two parallel workers never write the same file in one wave.
>
> **Two formatting rules** (LOG.md is pipe-delimited and the de-dup regex is simple):
> no `|` characters in job text, and no spaces in target file names.
>
> Line lifecycle: `- [ ]` pending → `- [x]` done · `- [!]` quarantined (breaker tripped
> after MAX_JOB_RETRIES real fails — a review job should triage) · `- [>]` merged from
> proposals.md by the bridge.

## Bootstrap jobs (delete or edit to fit your workspace)
- [ ] [curate] Create (or fill in, if it already exists) INDEX.md at the workspace root: catalog every existing note as a wikilink + one-line summary. This is the map every future session consults.
- [ ] [curate] Create (or fill in, if it already exists) MEMORY.md at the workspace root (≤2000 chars): always-in-context working memory — mission, layout, current top priority.
- [ ] [research] Pick ONE open question that matters to the workspace mission; research it and write one atomic, verdicted note (claims + evidence + "what it gives us").

## Self-review (recurring — the parent watching the child)
> Re-add this job whenever you want the swarm to tune itself.
- [ ] [steward] META-REVIEW: read LOG.md since the last review. Is the cadence right? Are sessions producing durable artifacts or burning tokens? Which job types recur as failures? Append 3–5 tuned jobs to this queue and adjust the caps in config.env if warranted. Write the review to journal/sessions/meta-review-<today, YYYY-MM-DD>.md.

---
## Done jobs archive
*(runner checks jobs off in place above; move old checked jobs here periodically)*
