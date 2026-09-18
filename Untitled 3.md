

$ cat ~/.config/cyber-foundry/enrich.env.example
# =============================================================================
# cyber-foundry inflow enrichment — environment file TEMPLATE
# =============================================================================
# Real file:   ~/.config/cyber-foundry/enrich.env     (this is the .example)
#
# WHAT THIS IS FOR
#   vm/taskboard/inflow_enrich.py reads GITHUB_TOKEN from this file to lift
#   the GitHub API rate limit from 60 req/hr (anonymous) to 5,000 req/hr
#   (authenticated), so one swarm trigger can clear the whole repo-metadata
#   backlog (~1,229 unique repos) instead of ~43 triggers at 40/run.
#
# HOW TO USE (your hands only — agents never write this file)
#   1. Mint the token (see spec below).
#   2. Store it in Vaultwarden (orcrist vault, item name: GITHUB_TOKEN).
#   3. Copy this template and inject the secret straight from the vault:
#        cp ~/.config/cyber-foundry/enrich.env.example ~/.config/cyber-foundry/enrich.env
#        echo "GITHUB_TOKEN=$(bw get password GITHUB_TOKEN)" > ~/.config/cyber-foundry/enrich.env
#        chmod 600 ~/.config/cyber-foundry/enrich.env
#      (or paste it into an editor — never into a chat, a commit, or agent context)
#
# TOKEN SPEC — mint EXACTLY this, nothing broader (operator decision A, 2026-09-18)
#   github.com -> Settings -> Developer settings -> Personal access tokens
#   -> Fine-grained tokens -> Generate new token
#     Resource owner:    your account
#     Repository access: Public repositories (read-only)
#     Permissions:       NONE (metadata-read is automatic — it is all we use)
#     Expiration:        90 days is plenty
#   The pipeline needs ZERO write capability: the kit is local-only (no remote)
#   and the token is only ever sent to api.github.com as a Bearer header on
#   GET /repos/{owner}/{repo} metadata calls.
#   NOTE: a contents READ-WRITE token also exists (30d, expires 2026-10-18) —
#   do NOT use it here. Its downgrade/retirement is tracked on the board task
#   `github-token-hygiene`. If fine-grained scopes cannot be verified, the
#   script treats any present token as WRITE-CAPABLE and guards accordingly.
#
# SAFETY RULES (enforced in code where possible)
#   - File permissions MUST be 0600: inflow_enrich.py REFUSES to run otherwise
#     (group/world-readable = hard stop with instructions).
#   - The token is never logged, never written to the enrichment cache, never
#     committed (this path is outside the kit repo), never echoed in output —
#     authenticated runs only print `"github_auth": true` and budget numbers.
#   - Expected behavior when set: default github budget 40 -> 1500/run,
#     rate-limit floor 5 -> 50, critical-care banner on stderr at start.
#   - Env var GITHUB_TOKEN (exported in a shell) is also honored, but the env
#     file is preferred: exports leak into process listings and shell history.
#
# -----------------------------------------------------------------------------

# GitHub fine-grained PAT, public-metadata read-only. Replace the placeholder:
GITHUB_TOKEN=github_pat_YOUR_READONLY_PUBLIC_METADATA_TOKEN_HERE

# -----------------------------------------------------------------------------
# NOT YET READ by inflow_enrich.py v0.1 (documented for future use only —
# do not populate; uncommenting has no effect until the code supports it):
#
#   HF_TOKEN=hf_your_optional_huggingface_token   # HF API works fine anonymous
# -----------------------------------------------------------------------------