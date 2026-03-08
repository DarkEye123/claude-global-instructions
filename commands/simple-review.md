
# Review flow

do a code-review against branch origin/develop (if detected, if not, try origin/main and after that origin/master)
Use `gh` tool and read available PR comments before your review begins to gather the context. 

Export your findings in readable & easy to follow manner into claude-simple-review.md.
Your report needs to be human friendly and easy to follow and understand. 
Each reported issue needs to be human friendly. If complexity of the issue is high, try to use examples of scenarios and sub-scenarios leading to the reported behavior. 

Good test for readability - if medior programer would understand what you talk about, it is a good sign.

Remember, more is better than less. This is even more important if your feedback connects more views/pages and code surfaces all together.
 
Don't run any lint, format, test commands, just if instructed specifically