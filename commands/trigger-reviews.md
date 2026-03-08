# Trigger reviews

## Instructions

Check existence of `./review-context.md` file. If you can't find it, read contents of `~/.claude/prompts/gather-context.md` and execute what it tells you to do.

This prompt you read will create `review-context.md` file for you to proceed further.

After you have `review-context.md` file, use the helper script to start the 3 agents for code‑review in parallel:

`~/.claude/scripts/exec_reviews.sh "<PROMPT>"`

where `<PROMPT>` is your base prompt that initializes the code‑review agent and references `review-context.md`.

Important:
- Run this script exactly once per review cycle. Do NOT execute it three times; the script already launches low, medium, and high agents concurrently.
- Do not include any "export findings into ..." instruction in `<PROMPT>`. The script appends the correct export instruction for each agent automatically (low → `summary-low.md`, medium → `summary-medium.md`, high → `summary-high.md`).
- The script launches all three `claude exec` processes back‑to‑back in the background and then waits for the high‑effort agent to finish before collecting the low/medium exit statuses. You do not need to run `wait` yourself.
- If you want to keep the run alive after closing the terminal, execute it with `nohup`, for example: `nohup ~/.claude/exec_reviews.sh "<PROMPT>" > /tmp/claude-reviews.log 2>&1 &`

## Rules

Agent needs to work diligently and thoroughly. It needs to be very precise and detailed in its findings. He should review the work you did, but also look into the issue you were solving originally by himself to see if there is anything else which needs to be fixed or improved. Agent always follows persona of the project and does according to best practices of the current project you are working on. Agent is reviewing code, he can ignore `.md` files unless it is `README.md` or you are instructed to tell him otherwise.

Agent always needs to export his findings into the file.

Agent with `model_reasoning_effort=low` will export his findings into `summary-low.md` file.
Agent with `model_reasoning_effort=medium` will export his findings into `summary-medium.md` file.
Agent with `model_reasoning_effort=high` will export his findings into `summary-high.md` file.

## If you already saw this prompt during our conversation

It may happen that you already did this in the past.
It means that `review-context.md` file already exists, `summary-low.md`, `summary-medium.md` and `summary-high.md` files also exist.
That means that you already did code-review with 3 agents, but you have new changes in the codebase and you need to iterate on the code again to confirm it was fixed and issues addressed. 
You will add new findings and proper followup in `review-context.md`. You will update this file, do not remove previous content.

Run `~/.claude/scripts/exec_reviews.sh "<PROMPT>"` once to re-run all three agents. Each agent will iterate and update its original output file (low → `summary-low.md`, medium → `summary-medium.md`, high → `summary-high.md`) to confirm if issues were fixed.

### Common pitfalls
- Do not call the script three times for the same review; it already starts three agents concurrently.
- Do not append `&` to the script invocation; it backgrounds the agents and manages waiting internally.
- Do not add export-file instructions to `<PROMPT>`; the script injects them per agent.
- Avoid invoking `claude exec …` directly unless debugging the script.

### Review process

Specifically instruct agents to not use any cached results from the past. E.g. git diff results. This also apply to you. Always do steps again as a fresh process.
You and agents will describe issues (and improvements proposals) in a detailed manner. Do that according to the complexity of the issue. If the issue is simple, you may include just quick notion about it and what to fix. If the issue is tricky and needs deep technical understanding, add a great amount of details. Do the same for improvements proposals. This also applies to each of the agents.

## Example of the command to execute
`~/.claude/scripts/exec_reviews.sh "You are a skilled software engineer. Do a code‑review of my changes. Context can be found in review-context.md."`

Note: Do not add file‑specific export instructions to the prompt; `exec_reviews.sh` adds them per agent.

## Custom context
User can add additional context to you. If you use content of "$ARGUMENTS", you will append it to the `review-context.md` file. Do not remove previous content, just add new content to the end of the file.

Read custom instructions from "$ARGUMENTS" and execute them if any are present and relevant to the current context of your active prompt.
## What you must do
Always  follow instruction of the project you are working with. Always add original user prompt to the `review-context.md` file. Always be very detailed and descriptive, new agents doesn't know what you know, add as much usable information as possible.