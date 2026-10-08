/* 3 Days of Spec-Driven Development — per-team environment profile.
   Data only: this file defines one object and runs no logic.

   Every page writes the generic wording inline, like this:

       <span data-env="sourceConnector">your read-only source-control connector</span>

   When this file defines a non-empty string for that key, the page shows your
   team's wording instead. Delete a key, or leave this file exactly as shipped,
   and the generic wording stays. Nothing here is required for the course to run.

   What a team changes before handing the course to its engineers:

     1. Connector names — what your read-only MCP connectors are called in the
        tools your engineers already use: source control, design, tickets, API
        docs. Use the name that appears in your tooling, not a vendor name.
     2. Model tiers — the two models your engineers can actually pick between,
        named the way your platform names them. Day 2 asks which tier a subagent
        should run on, and the answer is easier when the names are yours.
     3. Write path — the one sanctioned command that sends a change outward,
        and the shortest true sentence about where it runs. Day 2, Lesson 4.
     4. Team repo path — where your shared instructions, rules and skills live,
        so learners look in the right place on their first day on the team.
     5. Agent sandbox limits — what the agent may reach from inside the sandbox,
        and the iteration cap your runners stop at.

   Rules for whoever edits this file: keep every value a short plain-text
   fragment that reads inside a sentence (no trailing period, no HTML, no URL
   that only works inside your network), and keep it generic enough to publish.
   Nothing here should name a customer, a private hostname, or a credential. */

window.ENV_PROFILE = {
  /* 1. Connectors (read-only unless your platform team says otherwise) */
  sourceConnector: "your read-only source-control connector",
  designConnector: "your design-tool connector",
  ticketConnector: "your ticket-tracker connector",
  apiDocsConnector: "your API-documentation connector",

  /* 2. Model tiers */
  modelCapable: "the higher-capability model your team can select",
  modelFast: "the faster, cheaper model your team can select",

  /* 3. The sanctioned write path */
  writeCommand: "your team's vetted write script",
  writeScope: "a review comment on a pull request",
  writeRunsWhere: "outside the agent's sandbox, from your own terminal",

  /* 4. Shared team configuration */
  teamRepo: "your team's shared agent-configuration repository",
  teamRepoPath: "team-agent-config/",

  /* 5. Agent sandbox limits */
  sandboxWriteRoot: "day2-work/, the copy of your lane at the course root",
  sandboxNetwork: "outbound network access is blocked from the agent's sandbox",
  iterationCap: "5",

  /* Wording used on the setup page */
  signIn: "the sign-in your team uses for Claude Code"
};
