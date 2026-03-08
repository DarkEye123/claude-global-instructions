# Trigger reviews

## Instructions

Check existence of `./review-context.md` file. If you can't find it, read contents of `~/.claude/prompts/gather-context.md` and execute what it tells you to do.

This prompt you read will create `review-context.md` file for you to proceed further.

After you have `review-context.md` file, launch 3 review agents in parallel using the Agent tool with `run_in_background: true`.

Each agent receives a slightly different prompt:
- **Low-effort agent**: append `"Export your findings into claude-summary-low.md in the repo root."` to the base prompt.
- **Medium-effort agent**: append `"Export your findings into claude-summary-medium.md in the repo root."` to the base prompt.
- **High-effort agent**: append `"Export your findings into claude-summary-high.md in the repo root."` to the base prompt.

Send all three Agent tool calls in a single message so they run concurrently.

## Rules

Agent needs to work diligently and thoroughly. It needs to be very precise and detailed in its findings. He should review the work you did, but also look into the issue you were solving originally by himself to see if there is anything else which needs to be fixed or improved. Agent always follows persona of the project and does according to best practices of the current project you are working on. Agent is reviewing code, he can ignore `.md` files unless it is `README.md` or you are instructed to tell him otherwise.

Agent always needs to export his findings into the file.

Agent with low effort will export his findings into `claude-summary-low.md` file.
Agent with medium effort will export his findings into `claude-summary-medium.md` file.
Agent with high effort will export his findings into `claude-summary-high.md` file.

## If you already saw this prompt during our conversation

It may happen that you already did this in the past.
It means that `review-context.md` file already exists, `claude-summary-low.md`, `claude-summary-medium.md` and `claude-summary-high.md` files also exist.
That means that you already did code-review with 3 agents, but you have new changes in the codebase and you need to iterate on the code again to confirm it was fixed and issues addressed.
You will add new findings and proper followup in `review-context.md`. You will update this file, do not remove previous content.

Launch the three agents again in parallel (same approach as above). Each agent will iterate and update its original output file to confirm if issues were fixed.

### Common pitfalls
- Do not launch the three agents separately across multiple messages; send all three Agent tool calls in a single message so they run concurrently.
- Do not add the same export instruction to all three agents; each gets its own file name (low/medium/high).
- Avoid running `claude exec` directly — use the Agent tool instead.

### Review process

Specifically instruct agents to not use any cached results from the past. E.g. git diff results. This also apply to you. Always do steps again as a fresh process.
You and agents will describe issues (and improvements proposals) in a detailed manner. Do that according to the complexity of the issue. If the issue is simple, you may include just quick notion about it and what to fix. If the issue is tricky and needs deep technical understanding, add a great amount of details. Do the same for improvements proposals. This also applies to each of the agents.

## Example base prompt

`"You are a skilled software engineer. Do a code-review of my changes. Context can be found in review-context.md. Do NOT use cached git diff results — always re-run git commands fresh."`

Then pass this base prompt to all three Agent calls, each with its own export instruction appended.

## Custom context
User can add additional context to you. If you use content of "$ARGUMENTS", you will append it to the `review-context.md` file. Do not remove previous content, just add new content to the end of the file.

Read custom instructions from "$ARGUMENTS" and execute them if any are present and relevant to the current context of your active prompt.

## What you must do
Always follow instruction of the project you are working with. Always add original user prompt to the `review-context.md` file. Always be very detailed and descriptive, new agents doesn't know what you know, add as much usable information as possible.
