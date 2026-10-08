# local-repo

A directory pretending to be a repository. The write wrapper posts here, so
nothing in Day 2 can reach a real pull request on a real service.

`post-pr-comment.sh --repo local-repo --pr 1` appends to
`pulls/1/comments.md`, creating it if it is not there. The layout mirrors the
REST path the wrapper would otherwise call,
`repos/{owner}/{repo}/pulls/{pull_number}/comments`, so the dry-run line and the
file path read the same way.

Delete `pulls/1/comments.md` to start over. Nothing else here is load-bearing.

<!-- Sources: enterprise-13 (the REST path for a pull-request review comment). -->
