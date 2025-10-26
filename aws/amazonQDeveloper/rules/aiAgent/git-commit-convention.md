# Git Commits

## Format
`<type>(<scope>):<desc>\n\n[body]\n\n[footer]`

## Types
feat:new|fix:bug|docs:doc|style:format|refactor:restructure|perf:performance|test:tests|chore:build/deps|ci:CI/CD

## Scopes
blog|infra|lambda|api|config|deps

## Rules
English|Imperative("add" not "added")|No period|<72 chars|Body for details|Footer:`Fixes #123`

## Examples
`feat(blog):add Bedrock guide`|`fix(api):handle rate limit`|`chore(deps):update Node 24`

## Anti
❌"update"|"fixed bug"|"WIP"|"feat(blog) added."→✅`feat(blog):add guide`
