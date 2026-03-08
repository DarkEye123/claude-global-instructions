# Atomization of issue findings

Look for `final-summary.md` file. If you can't find it, ask for context the user himself.

This file will contain all findings from the code-review process. There can be implementation proposals, bugs or clarification questions etc.

You will split all findings into separate files. Each file will contain one finding only. 
If the finding is a bug, file name prefix will be `bug-<number>.md`.
If the finding is an improvement proposal, file name prefix will be `improvement-<number>.md`
`<number>` is a sequential number starting from 1.

Do not omit any context, always add original reference you are addressing in the `final-summary.md`. This is export merging all data all together. It needs to be comprehensible, easy to read and process by you but also living human being.
DO not remove any issue context, you are just splitting it into separate files.


Each file will contain: 
# <Title of the finding>
<detailed description of the finding>

## Original reference
<original reference you are addressing in the `final-summary.md`>

Whole file serves as a `PROMPT` for agentic implementation. So you will include initial promt initializing the agentic implementation in the beginning of the file. Prompt will be written in persona specific for a project you are working with.
In a case of missing persona, you are an extremely skilled software engineer and software architect proficient in all major languages and tooling used in the repository.
