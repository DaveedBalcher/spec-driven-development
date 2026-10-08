# Environment profile

Six rows. Fill each one with the shortest true sentence, then keep the file next
to your spec template and read it out loud the next time you brief an agent.

Keep every entry generic. No employer, no product name, no repository name, no
hostname, no ticket id. A profile you cannot paste into a public gist is a
profile that will not leave your laptop, and this one is meant to be shared with
the next engineer who joins the team.

The defaults below are the wording the course pages use when a team has not
filled this in yet. They match the keys in `assets/env-profile.js`, so a team
that fills both keeps the pages and this file saying the same thing.

| # | Row | What goes in it | Default wording |
| --- | --- | --- | --- |
| 1 | Connectors and direction | Every connector attached to your session, and whether it can write. Name the kind, not the vendor: source control, design, tickets, API docs. | your read-only source-control connector, your design-tool connector, your ticket-tracker connector, your API-documentation connector — all read-only |
| 2 | Egress | What the agent's sandbox can reach on the network, and what it cannot. If the answer is "nothing", say so; that is the single most useful line in the file. | outbound network access is blocked from the agent's sandbox |
| 3 | Sanctioned write commands | The commands that are allowed to send a change outward, and where each one runs. One line per command. | your team's vetted write script, posting a review comment on a pull request, run outside the agent's sandbox, from your own terminal |
| 4 | Available models | The models an engineer here can actually pick between, named the way your platform names them. Day 2 asks which one a subagent runs on; this is the answer sheet. | the higher-capability model your team can select; the faster, cheaper model your team can select |
| 5 | Shared configuration | Where the team's committed instructions, rules, skills and settings live, and who reviews a change to them. | your team's shared agent-configuration repository, at team-agent-config/ |
| 6 | Sandbox limits | The directory a run may write in, and the iteration cap your runners stop at. | `day2-work/`, the copy of your lane at the course root; iteration cap 5 |

## Your answers

Replace each line. Delete the bracketed prompt when you have.

1. **Connectors and direction:** <which connectors are attached, and which of
   them can write>
2. **Egress:** <what the sandbox can reach, and what it cannot>
3. **Sanctioned write commands:** <the command, and where it runs>
4. **Available models:** <the two you can pick between>
5. **Shared configuration:** <the path, and who reviews a change to it>
6. **Sandbox limits:** <the writable directory, and the iteration cap>

## Why this is part of the spec

An agent that does not know the network is closed will plan a dependency
install. An agent that does not know the ticket tracker is read-only will plan
to move the ticket. Both are iterations you paid for and got nothing from. The
constraints belong in the brief the same way the acceptance criteria do, and
writing them once means you paste six lines instead of remembering five of them.

## What this file is not

It is not a permission boundary. Permission rules are what the tool enforces,
and the connector's own configuration and the service account's own permissions
are what the far side enforces. This file tells an agent the truth about its
situation; `.claude/settings.json` is where you make the truth binding.

<!-- Sources: cc-automation-11 (/mcp is the in-session view of which servers are attached); enterprise-11 (shared settings live in .claude/settings.json, personal ones in .claude/settings.local.json). -->
