
# Review Aggregation Flow

You are doing an aggregation of all findings from all reviews, and you need to create a final report that is comprehensive and easy to understand (in readable & easy to follow manner into `final-review-summary.md`).

Use `gh` tool and read available PR comments before your review begins to gather the context. 
Follow any slack discussions, if available, to gather more context about the code review and the issues being discussed.
Follow any linear discussions, if available, to gather more context about the code review and the issues being discussed.
Don't run any lint, format, test commands, just if instructed specifically

after that find and analyse reported findings in all files called `claude-simple-low-review.md`, `claude-simple-medium-review.md`, `claude-simple-high-review.md` and `claude-simple-review.md` files, if they are available. If not, ask for context from the user.
it may happen that some of the files are missing, but you should do your best to gather as much information as possible from the available files and context.
You may read and follow any references in mentioned files, but don't read any other files or documentation if not required to finalize your analysis. This is meant to preserve your context.
From all of this, you will aggregate all findings and create a final report. You need to asses each finding separately and rate it. It may be finding, which is not really relevant or is not really an issue, but it was reported as an issue. You need to asses it and rate it accordingly.
In other words: you are doing code-review of the code-reviews. You are evaluating the findings which were already assessed by other agents.

Your report needs to be human friendly and easy to follow and understand. 
If complexity of the analyzed issue is high, try to use examples of scenarios and sub-scenarios leading to the reported behavior. 

Good test for readability - if medior programer would understand what you talk about, it is a good sign.

Remember, more is better than less. This is even more important if your feedback connects more views/pages and code surfaces all together.
 
Don't run any lint, format, test commands, just if instructed specifically
