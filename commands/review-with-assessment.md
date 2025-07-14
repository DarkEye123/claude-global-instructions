# Context-Aware Code Review with Assessment

Perform a comprehensive code review based on the current context, then assess the findings with a decision-helper.

## Context Detection (Main Agent)
I'll gather minimal context to pass to the review task:
- Current branch name: `git branch --show-current`
- Main branch determination (in order of precedence):
  1. If on PR branch: use `gh pr view --json baseRefName` to get target branch
  2. Check project-level CLAUDE.md for defined main branch
  3. Fallback: `git symbolic-ref refs/remotes/origin/HEAD`
- Any specific areas mentioned: $ARGUMENTS

## Review Process (Main Agent Orchestration)

**Flow Overview**: The main agent orchestrates the entire process by:
1. Gathering minimal context
2. Spawning code review task
3. Receiving code review results
4. Spawning decision-helper task with review results
5. Presenting final combined output

### Step 1: Spawn Code Review Task
The main agent will spawn a code review task with minimal context following a handoff pattern.

**Main Branch Detection Logic**:
```yaml
MAIN_BRANCH_DETECTION:
  PRIORITY_ORDER:
    1. PULL_REQUEST_TARGET:
       - Run: gh pr view --json baseRefName 2>/dev/null
       - If successful, extract baseRefName as main branch
       - This is the branch the PR will merge into
       - Takes precedence to ensure PR reviews are accurate
    
    2. PROJECT_CLAUDE_MD:
       - Check if ./CLAUDE.md exists
       - Look for: main_branch: "branch_name" or default_branch: "branch_name"
       - Use the specified branch if found
       - Only used when not on a PR branch
    
    3. GIT_DEFAULT_FALLBACK:
       - Run: git symbolic-ref refs/remotes/origin/HEAD
       - Extract branch name from refs/remotes/origin/main format
       - Use as last resort
  
  EXAMPLE_FLOW:
    - If on PR targeting "staging" → use "staging" (even if CLAUDE.md says "develop")
    - Else if CLAUDE.md has "main_branch: develop" → use "develop"
    - Else use git default (usually "main" or "master")
```

**Handoff Information** (following HANDOVER.md structure):
```yaml
Work Completed (by Main Agent):
  - Current branch name: obtained via `git branch --show-current`
  - Main branch: determined via priority order:
    1. PR target branch from `gh pr view --json baseRefName` (if on PR)
    2. Project CLAUDE.md main_branch setting (if not on PR)
    3. Default from `git symbolic-ref refs/remotes/origin/HEAD`
  - Review focus: extracted from $ARGUMENTS

Current Task (for Code Review Agent):
  Context Initialization: "ultrathink - Comprehensive code review with deep context analysis"
  
  - Check if on PR branch and load PR comments via `gh pr view --comments`
  - Load full git diff between branches using determined main branch
  - Extract Linear issue ID from branch name
  - CRITICAL: Perform deep context gathering:
    - Follow all Linear ticket references (up to depth 2)
    - Follow GitHub PR cross-references and related repos
    - Build dependency graph of related work
    - Extract constraints from parent/blocking tickets
  - Analyze all changed files with full context
  - Perform comprehensive code review
  - Create code-review.md with findings including context map

Key Decision:
  - Main agent does NOT pre-analyze changes
  - All heavy lifting delegated to spawned task
  - This prevents duplicate work and improves efficiency
```

### Step 2: Detailed Analysis (Code Review Task)
The spawned code review agent will:
1. **Gather full context**:
   - Determine main branch using provided context from main agent
   - Check current git branch for PR reference
   - If on a PR branch:
     - Run: `gh pr view --comments` to get PR comments
     - Run: `gh pr view --json baseRefName` to confirm target branch
   - Extract Linear ID from branch name (e.g., feat/LIN-123-feature)
   - Load Linear issue for additional context if available
   - Compare with main branch: `git diff origin/{main}...HEAD`
   - List changed files: `git diff --name-only origin/{main}...HEAD`
   - Check uncommitted changes: `git status --porcelain`
   - Read and analyze all changed files
   - Track line numbers for all findings to enable VSCode-compatible links

2. **Deep Context Gathering** (CRITICAL - Follow all referenced tickets and PRs):
   
   **Linear Ticket Chain Following**:
   ```yaml
   TICKET_DEEP_DIVE:
     MAX_DEPTH: 2  # Prevent infinite loops
     VISITED_TRACKING: Set()  # Track processed tickets
     
     TOOLS:
       - Use mcp__linear__get_issue for ticket details
       - Use mcp__linear__list_comments for ticket comments
       - Pre-configured MCP tools handle authentication
       
     PROCESS:
       1. Extract main ticket ID from branch name
       2. Add ticket to visited set before loading
       3. Load main ticket content via MCP tools
       4. Search main ticket for references:
          - Other ticket IDs in description (e.g., "Depends on LIN-456")
          - Ticket IDs in comments
          - Parent/child ticket relationships
          - "Blocks/Blocked by" relationships
       5. For each referenced ticket:
          - Check if already in visited set (skip if yes)
          - Check depth < MAX_DEPTH (skip if exceeded)
          - Add to visited set BEFORE loading (prevent cycles)
          - Load its content
          - Note its status (Open/In Progress/Done)
          - Extract key requirements or constraints
          - Check if it mentions breaking changes
       6. Create context map showing ticket relationships
       7. Include cycle detection notes (e.g., "LIN-123 ↔ LIN-456 circular ref")
   
   IMAGE_ANALYSIS:
     EXTRACTION:
       - Search ticket description for image URLs/markdown
       - Extract images from all ticket comments
       - Pattern match: ![...](url), <img src="...">, direct image URLs
       - Support formats: .jpg, .jpeg, .png, .gif, .webp, .svg
     
     CACHING_MECHANISM:
       INITIALIZATION:
         - Check if ./code-reviews/ exists, create if missing
         - Create {TICKET_ID}-images/ directory if not exists
         - Set directory permissions (755)
         - Initialize empty metadata.json if not exists
       
       FILENAME_GENERATION:
         1. Use the full URL as the filename
         2. Example: www.example.com/super-duper-pic.jpg
         3. Sanitize for filesystem safety (replace / with _)
       
       CACHE_CHECK:
         - If file exists in cache: Load existing analysis from metadata.json
         - If not cached: Proceed to fetch and analyze
       4. Maintain metadata.json:
          ```json
          {
            "processed": [
              {"url": "...", "hash": "...", "analysis": "..."}
            ],
            "failed": [
              {"url": "...", "error": "403 Forbidden", "timestamp": "..."}
            ],
            "skipped": [
              {"url": "...", "reason": "already cached", "hash": "..."}
            ]
          }
          ```
     
     PROCESSING:
       WEBFETCH_INTEGRATION:
         1. For each image URL:
            - Calculate SHA256 hash for cache key
            - Check if already processed (skip if yes)
            - If not cached:
              a. Call WebFetch with URL and analysis prompt
              b. Extract analysis text from WebFetch response
              c. Note: WebFetch views the image but doesn't return image data
              d. Store analysis in metadata.json
              e. Mark image URL as processed
         
         2. WebFetch prompts based on context:
            - UI/Screenshot: "Analyze this UI screenshot for layout, components, and any visible issues. Describe the visual elements, their arrangement, and any potential problems."
            - Diagram: "Describe this diagram's flow, components, and relationships. Identify the main elements and how they connect."
            - Mockup: "Identify UI elements, layout structure, and design patterns. Note any interactive elements and their purpose."
            - Error: "Describe the error shown and any relevant details. Include error messages, stack traces, or visual indicators."
         
         3. Response handling:
            - Success: Store analysis in metadata.json
            - Redirect: Follow redirect and retry
            - Error: Log failure reason in metadata.json
     
     ERROR_HANDLING:
       - 403/401: Note as "requires authentication"
       - 404: Note as "image no longer available"
       - Timeout: Note as "failed to load"
       - Invalid format: Note as "unsupported format"
     
     PROCESS_FLOW:
       1. Extract all image URLs from ticket/comments
       2. For each image URL:
          a. Sanitize URL for filesystem (replace / with _)
          b. Cache filename is the sanitized URL
          c. Check if ./code-reviews/{TICKET_ID}-images/{filename} exists
          
          IF already cached:
            - Load analysis from metadata.json
            - Mark as "skipped - already analyzed"
            - Use existing analysis in output
          
          ELSE (not cached):
            - Call WebFetch with URL and context prompt
            - Store analysis result in metadata.json
            - Mark as "processed" with timestamp
            - Include new analysis in output
       
       3. Update metadata.json with all results
       4. Generate visual context summary
     
     OUTPUT_INTEGRATION:
       - Add "Visual Context" section to ticket summary
       - Include successful image analyses grouped by source
       - List problematic images with specific error reasons
       - Show cache status: (cached) vs (newly analyzed)
       - Reference image URLs for manual verification
   
   RELEVANCE_FILTERING:
     INCLUDE:
       - Parent tickets (epic/story this task belongs to)
       - Blocking tickets (dependencies)
       - Related implementation tickets in same epic
       - Tickets mentioning same files/components
     EXCLUDE:
       - Closed tickets > 30 days old (unless critical)
       - Tickets in different products/areas
       - Pure documentation tickets (unless API changes)
   ```
   
   **GitHub Cross-Reference Following**:
   ```yaml
   GITHUB_REFERENCE_FOLLOWING:
     TOOLS:
       - Use gh CLI for all GitHub operations (pre-configured)
       - Access is already authenticated via gh auth
     
     PRIVACY_CONTROLS:
       - Only access repos user has explicit permissions for
       - Test access with: gh repo view org/repo 2>/dev/null
       - Never include private repo details in public reviews
       - Sanitize any customer/internal references
       - Log inaccessible repos as "private/inaccessible"
       - Replace sensitive branch names with generic labels
     
     PR_COMMENTS_SCAN:
       1. Parse all PR comments for:
          - References to other PRs (#123 or org/repo#123)
          - Links to other repositories
          - Mentions of related issues
       2. For each referenced PR/issue:
          - Check access permissions first
          - If accessible:
            - Load title and description
            - Check merge status
            - Extract relevant implementation details
          - If not accessible:
            - Note as "Referenced PR/issue (private)"
            - Skip detailed loading
     
     CROSS_REPO_REFERENCES:
       1. Identify mentions of other repositories:
          - In PR description/comments
          - In Linear ticket
          - In commit messages
       2. For each mentioned repo:
          - Test access with gh repo view
          - Only proceed if access granted
       3. For accessible repos:
          - Check for related PRs by same author
          - Look for similar file changes
          - Identify shared dependencies
       4. Document cross-repo dependencies:
          - Public repos: Include full details
          - Private repos: Generic reference only
   ```
   
   **PR Image Analysis**:
   ```yaml
   PR_IMAGE_PROCESSING:
     EXTRACTION:
       - Parse PR description for images
       - Extract images from all PR comments
       - Check issue comments if linked
       - Support same formats as Linear
     
     CACHING:
       - Create folder: ./code-reviews/PR-{NUMBER}-images/
       - Use same URL-based naming as Linear
       - Share metadata.json structure
       - Check for already processed images
     
     GITHUB_SPECIFIC:
       - Handle githubusercontent.com URLs
       - Process GitHub asset attachments  
       - Extract images from linked issues
       - Access is pre-authenticated via gh CLI
     
     INTEGRATION:
       - Add visual context to PR summary
       - Link images to specific comments
       - Track which images relate to which discussions
   ```
   
   **Context Synthesis**:
   ```yaml
   BUILD_CONTEXT_SUMMARY:
     CREATE:
       - Dependency graph of related tickets
       - Timeline of related changes
       - List of constraints from related work
       - Breaking changes mentioned anywhere
       - API contracts that must be maintained
       - Performance requirements from tickets
       - Security requirements from related work
     
     PRIORITY_CONTEXT:
       - P0: Direct parent/blocking tickets
       - P1: Same epic/feature tickets  
       - P2: Cross-referenced PRs
       - P3: Related repo changes
   ```
   
   **Error Handling & Edge Cases**:
   ```yaml
   GRACEFUL_DEGRADATION:
     HANDLE:
       - API rate limits: Cache responses, continue with partial data
       - Access denied: Note inaccessible resources, continue review
       - Circular references: Track visited tickets, stop at MAX_DEPTH
       - Broken links: Log and skip, don't fail review
       - Missing tickets: Note as "referenced but not found"
     
     TIMEOUT_MANAGEMENT:
       - Set 30s timeout per external API call
       - If context gathering exceeds 5 minutes total:
         - Use data collected so far
         - Note incomplete context in review
         - Prioritize main ticket + direct references
   
   CONTEXT_DOCUMENTATION:
     ALWAYS_INCLUDE:
       - List of successfully loaded references
       - List of inaccessible/failed references
       - Confidence level in context completeness
       - Any assumptions made due to missing data
   ```

3. **Determine review scope**:
   - All changes between current branch and determined main branch
   - Include both committed and uncommitted changes
   - Focus on areas mentioned in arguments if provided
   - Main branch priority:
     1. Project CLAUDE.md configuration
     2. PR target branch (if applicable)
     3. Git default branch

### Step 3: Comprehensive Code Review
The code review agent will examine all detected changes for:
- Security vulnerabilities
- Performance implications
- Best practices adherence
- Code quality and maintainability
- Potential bugs or edge cases
- Architecture and design patterns
- Testing coverage
- Breaking changes or API compatibility

**Output**: The code review agent will create a `code-review.md` file with all findings, categorized by severity and impact. Each finding MUST include VSCode-compatible file references in the format `path/to/file:line` or `path/to/file:line:column` so users can click to navigate directly to the code being discussed.

**CRITICAL**: File references must be inline with the text, NOT in parentheses. For example:
- ❌ WRONG: "The logic flaw (src/utils.ts:340) causes..."
- ✅ CORRECT: "The logic flaw in `src/utils.ts:340` causes..."
- ✅ CORRECT: "Check the function at `src/utils.ts:340-354`"

**Note**: If a project-specific CLAUDE.md exists, I will also check for and apply any custom review criteria defined there.

### Step 4: Decision-Helper Assessment
After receiving the code review results, the main agent will spawn a decision-helper with context "ultrathink - Objective assessment of code review findings" to:
- Read the `code-review.md` file
- Evaluate each review finding objectively
- Score findings by actual impact (0-10)
- Distinguish between critical issues and preferences
- Provide implementation priorities
- Consider effort vs benefit trade-offs
- Identify which findings block merge vs nice-to-have

**Output**: The decision-helper will create a `decision-helper.md` file with the assessment and scoring of each finding.

## Step 5: Final Summary Creation
After both spawned tasks complete, the main agent will:
1. Read both `code-review.md` and `decision-helper.md`
2. Create a comprehensive `code-review-summary.md` that combines insights from both reports
3. Display key findings in the console for immediate viewing

## Output Files

Three files will be created in the current directory:

### 1. `code-review.md`
Created by the code review agent, containing:
- **Enhanced Context Summary**:
  - Current branch and files changed
  - PR comments and discussions
  - Related Linear tickets dependency graph
  - Constraints from parent/blocking tickets
  - Cross-repository dependencies identified
  - Breaking changes mentioned in related work
  - Timeline of related changes
- **Visual Context Analysis**:
  - Successfully analyzed images with insights
  - Failed/problematic images with reasons
  - Image cache status (new vs previously analyzed)
  - UI mockups, diagrams, and screenshot analyses
  - Images grouped by source (ticket/PR/comment)
- Detailed findings categorized by severity
- Security, performance, and best practice observations
- Specific code locations with VSCode-compatible links (e.g., `src/auth/login.js:45` for line 45)
- Recommendations with direct links to affected code
- Context-aware insights based on related tickets/PRs

### 2. `decision-helper.md`
Created by the decision-helper agent, containing:
- Objective assessment of each code review finding
- Relevance scores (0-10) for each suggestion
- Priority categorization (critical/important/nice-to-have)
- Implementation recommendations with file references preserved from code-review.md
- Merge readiness verdict

### 3. `code-review-summary.md`
Created by the main agent, containing:
- Executive summary combining both perspectives
- Prioritized action items based on decision-helper scores with VSCode-compatible file links
- Critical issues that must be addressed with direct links to code locations
- Optional improvements for consideration with clickable references
- Overall merge recommendation with rationale

**Note**: All three files will be overwritten each time this command is run. Save them elsewhere if you need to keep multiple reviews.

**Image Cache**: The command will create folders like `LIN-123-images/` or `PR-456-images/` in the code-reviews directory to cache analyzed images. These folders persist between runs to avoid re-analyzing the same images.

## VSCode-Compatible Link Format

All code references in the output files MUST use Markdown link format with `#L` for line numbers:

### Format Examples:
- `[utils.ts](src/views/general/Checkout/utils.ts#L340)` - Opens utils.ts at line 340
- `[login.js line 42](src/auth/login.js#L42)` - Opens login.js at line 42
- `[settings.json](./config/settings.json#L10)` - Relative path to settings.json, line 10
- `[utils.ts lines 340-354](src/views/general/Checkout/utils.ts#L340)` - Reference to a code block

### Example Output in code-review.md:
```markdown
## Critical Issues

1. **SQL Injection Vulnerability** 
   The user input is directly concatenated into the SQL query at [queries.js](src/database/queries.js#L156), creating a serious security risk. This should use parameterized queries instead.

2. **Missing Error Handling**
   The async operation in [users.js line 78](src/api/users.js#L78) lacks try-catch handling, which will cause unhandled promise rejections when errors occur.

3. **Contact Property Misunderstanding**
   The `hasContactData()` function in [utils.ts lines 340-354](src/views/Checkout/utils.ts#L340) incorrectly assumes contact can be null. According to the codebase patterns, contact objects are always present but contain nullable fields.
```

### IMPORTANT: File Reference Rules

1. **Use Markdown links**: Always use `[text](path#Lnumber)` format
2. **Relative paths**: All paths must be relative to the working directory
3. **Line numbers**: Use `#L` followed by the line number (e.g., `#L42`)
4. **Natural language**: Write findings as complete sentences with embedded file links
5. **Link text**: Can be just filename or include "line X" for clarity

This ensures users can click directly on the file references to jump to the exact code location being discussed.