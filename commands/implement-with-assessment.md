# Context-Aware Implementation Assistant with Assessment

Provide comprehensive implementation assistance by gathering context from Linear issues, GitHub PRs, and existing code, then orchestrating parallel implementation tasks.

## Context Detection (Main Agent)
I'll gather context and metadata to coordinate implementation:
- Current branch name: `git branch --show-current`
- Default branch: `git symbolic-ref refs/remotes/origin/HEAD`
- Implementation scope: $ARGUMENTS
- Check for existing context files in `./agentic-help/`

## Implementation Process (Main Agent Orchestration)

**Flow Overview**: The main agent orchestrates the entire process by:
1. Detecting and loading cached context from agentic-help folder
2. If no cache exists, spawning context gathering task(s)
3. Analyzing implementation requirements
4. Spawning parallel implementation sub-agents
5. Coordinating results and presenting consolidated output

### Step 1: Context Cache Management

The main agent checks for existing context files:

```yaml
CONTEXT_CACHE_CHECK:
  FOLDER: ./agentic-help/
  FILES_TO_CHECK:
    - LINEAR-{ISSUE_ID}.md (if Linear issue detected in branch)
    - {BRANCH_NAME}.md (for GitHub/PR context)
    - Any image folders from previous runs
  
  IF_CACHE_EXISTS:
    - Read existing context files
    - Ask user: "Found existing context from [date]. Use cached data or refresh?"
    - If refresh requested, spawn new gathering tasks
  
  IF_NO_CACHE:
    - Create ./agentic-help/ if not exists
    - Proceed to context gathering
```

### Step 2: Spawn Context Gathering Task(s)

**Parallel Context Gathering** (CRITICAL for speed):
```yaml
SPAWN_PARALLEL_TASKS:
  LINEAR_CONTEXT_TASK:
    IF branch contains Linear ID (e.g., feat/LIN-123-feature):
      SPAWN: Linear context gatherer
      CONTEXT: "ultrathink - Enhanced Linear issue context gathering"
      OUTPUT: ./agentic-help/LINEAR-{ROOT_ISSUE}.md
  
  GITHUB_CONTEXT_TASK:
    IF on branch with PR or commits:
      SPAWN: GitHub context gatherer
      CONTEXT: "ultrathink - Enhanced GitHub PR and commit context analysis"
      OUTPUT: ./agentic-help/{BRANCH_NAME}.md
  
  CODEBASE_ANALYSIS_TASK:
    SPAWN: Code structure analyzer
    CONTEXT: "ultrathink - Deep codebase structure and pattern analysis"
    OUTPUT: In-memory analysis for main agent
```

**Linear Context Gatherer Task**:
```yaml
LINEAR_DEEP_DIVE:
  PRIMARY_OUTPUT: ./agentic-help/LINEAR-{ROOT_ISSUE}.md
  
  GATHERING_PROCESS:
    1. Extract root issue ID from branch name
    2. Use mcp__linear__get_issue for main ticket
    3. Use mcp__linear__list_comments for all comments
    4. RECURSIVELY follow all references:
       - Parent/child tickets
       - Blocking/blocked by relationships
       - Mentioned tickets in description/comments
       - Related epic tickets
    5. For EACH ticket found:
       - Record: ID, title, status, assignee
       - Extract: Requirements, constraints, acceptance criteria
       - Note: Breaking changes, API contracts, deadlines
    6. Extract ALL images:
       - Create ./agentic-help/LINEAR-{ROOT_ISSUE}-images/
       - Use WebFetch to analyze each image
       - Cache analysis in metadata.json
    
  OUTPUT_STRUCTURE:
    ```markdown
    # LINEAR-{ROOT_ISSUE} Context Cache
    Generated: {timestamp}
    
    ## Primary Issue
    - ID: {id}
    - Title: {title}
    - Status: {status}
    - Description: {full description}
    - Acceptance Criteria: {extracted criteria}
    
    ## Related Issues Dependency Graph
    ```mermaid
    graph TD
      LIN-123[Main Issue] --> LIN-124[Subtask 1]
      LIN-123 --> LIN-125[Subtask 2]
      LIN-122[Parent Epic] --> LIN-123
    ```
    
    ## Extracted Requirements
    - Functional: {list}
    - Non-functional: {list}
    - Constraints: {list}
    
    ## Visual Context
    - {image_url}: {analysis from WebFetch}
    
    ## Implementation Notes from Comments
    - {timestamp}: {comment excerpt with insights}
    ```
```

**GitHub Context Gatherer Task**:
```yaml
GITHUB_DEEP_DIVE:
  PRIMARY_OUTPUT: ./agentic-help/{BRANCH_NAME}.md
  
  GATHERING_PROCESS:
    1. Check if PR exists: gh pr view
    2. If PR exists:
       - Get PR description and metadata
       - Load ALL comments: gh pr view --comments
       - Extract review comments with file/line context
    3. Git history analysis:
       - Recent commits on branch
       - Related commits mentioning same files
       - Cross-referenced PRs
    4. For each reference found:
       - Check access permissions
       - Load if accessible
       - Note relationships
    5. Extract ALL images from PR/comments:
       - Create ./agentic-help/PR-{NUMBER}-images/
       - Analyze with WebFetch
       - Cache results
  
  OUTPUT_STRUCTURE:
    ```markdown
    # {BRANCH_NAME} GitHub Context Cache
    Generated: {timestamp}
    
    ## PR Information
    - Number: {pr_number}
    - Title: {title}
    - Status: {status}
    - Reviews: {review_status}
    
    ## Key Discussions
    - File: {path}, Line: {line}
      Comment: {comment}
      Resolution: {resolution_status}
    
    ## Related Work
    - PR #{num}: {title} - {relationship}
    - Commit {sha}: {message} - {relevance}
    
    ## Implementation Decisions from Comments
    - {decision point}: {resolution}
    ```
```

### Step 3: Implementation Planning

After context gathering completes, the main agent:

```yaml
IMPLEMENTATION_ANALYSIS:
  READ_CONTEXT:
    - Load all context files from ./agentic-help/
    - Synthesize requirements and constraints
    - Identify implementation components
  
  TASK_DECOMPOSITION:
    - Break down work into parallel tasks
    - Identify dependencies between tasks
    - Estimate complexity for each task
    - Determine optimal parallelization strategy
  
  PARALLELIZATION_RULES:
    - Independent files/modules: Always parallel
    - Test writing: Parallel with implementation
    - Documentation: Parallel after implementation
    - Refactoring: Sequential if affects same files
    - API changes: Coordinate to maintain compatibility
```

### Step 4: Spawn Implementation Sub-Agents

**Parallel Implementation Execution**:
```yaml
SPAWN_IMPLEMENTATION_AGENTS:
  PATTERN: Maximum parallelization for speed
  
  EXAMPLE_PARALLELIZATION:
    If implementing a new feature with API, frontend, and tests:
    
    PARALLEL_BATCH_1:
      - Agent A: Implement API endpoints
        Context: "ultrathink - API endpoint implementation"
        Resources: LINEAR-123.md, existing API patterns
        Output: New/modified API files
      
      - Agent B: Create data models
        Context: "ultrathink - Data model creation"
        Resources: LINEAR-123.md, database schema
        Output: Model files
      
      - Agent C: Setup test structure
        Context: "ultrathink - Test framework setup"
        Resources: Testing patterns, requirements
        Output: Test file skeletons
    
    PARALLEL_BATCH_2: (after Batch 1)
      - Agent D: Implement frontend components
        Context: "ultrathink - Frontend component implementation"
        Resources: API from Agent A, UI requirements
        Output: React/Vue/etc components
      
      - Agent E: Write API tests
        Context: "ultrathink - API test implementation"
        Resources: Agent A output
        Output: API test files
      
      - Agent F: Write model tests
        Context: "ultrathink - Model test implementation"
        Resources: Agent B output
        Output: Model test files
  
  COORDINATION:
    - Share context files via ./agentic-help/
    - Each agent reads relevant cached context
    - Agents output to designated files
    - Main agent monitors progress
```

**Sub-Agent Instructions Template**:
```yaml
HANDOFF_TO_SUB_AGENT:
  Context Initialization: "ultrathink - Critical implementation task"
  
  Context Available:
    - ./agentic-help/LINEAR-{ID}.md - Full ticket context
    - ./agentic-help/{BRANCH}.md - GitHub context
    - Specific implementation scope
  
  Your Task:
    - {Specific implementation piece}
    - Read context files for requirements
    - Implement following project patterns
    - Ensure compatibility with parallel work
  
  Constraints:
    - {From context analysis}
    - {From related tickets}
    - {From PR discussions}
  
  Output:
    - Create/modify specific files
    - Add inline documentation
    - Note any blockers or decisions needed
```

### Step 5: Progress Monitoring & Coordination

```yaml
MAIN_AGENT_COORDINATION:
  WHILE agents_running:
    - Monitor agent outputs
    - Check for conflicts or blockers
    - Spawn additional agents if needed
    - Update user on progress
  
  CONFLICT_RESOLUTION:
    - If agents modify same file:
      - Sequence the changes
      - Or merge if non-overlapping
    - If API contract conflicts:
      - Halt affected agents
      - Resolve with user input
      - Resume with resolution
```

### Step 6: Integration and Self-Review

After all implementation agents complete:

```yaml
POST_IMPLEMENTATION:
  INTEGRATION:
    - Verify all pieces work together
    - Run build/compile checks
    - Execute existing tests
  
  SELF_REVIEW_TRIGGER:
    - MANDATORY: Trigger /loop command
    - Review all changes made by agents
    - Create code-review.md as normal
    - Run decision-helper assessment
  
  FINAL_SUMMARY:
    - Implementation completed items
    - Any remaining TODOs
    - Decisions that need user input
    - Next recommended steps
```

## Output Structure

### Primary Outputs:
1. **./agentic-help/LINEAR-{ID}.md** - Cached Linear context
2. **./agentic-help/{BRANCH}.md** - Cached GitHub context
3. **./agentic-help/*-images/** - Cached image analyses
4. **Modified/created code files** - Actual implementation
5. **implementation-summary.md** - Final summary of work done

### Console Output Format:
```
🚀 Implementation Assistant Starting...

📋 Context Gathering:
  ✓ Linear issue LIN-123 context loaded (cached)
  ✓ GitHub PR #456 context loaded (refreshed)
  ✓ Found 3 UI mockups, 2 diagrams

🔄 Spawning 4 parallel implementation tasks:
  • API endpoints (Agent A)
  • Data models (Agent B)  
  • Frontend components (Agent C)
  • Test structure (Agent D)

📊 Progress:
  [████████░░] 80% - 3/4 agents completed

✅ Implementation Complete:
  • Created: 8 files
  • Modified: 3 files
  • Tests: 12 added
  • All constraints satisfied

🔍 Self-review triggered...
```

## Usage Examples

### Basic Implementation:
```
/implement-with-assessment Implement user authentication feature
```

### With Specific Context:
```
/implement-with-assessment Complete LIN-123 requirements for checkout flow
```

### Refresh Cached Context:
```
/implement-with-assessment --refresh Implement the API changes from PR comments
```

## Key Benefits

1. **Speed**: Massive parallelization of implementation tasks
2. **Context**: Never miss requirements from tickets/PRs
3. **Consistency**: All agents work from same cached context
4. **Traceability**: Clear record of decisions and sources
5. **Reusability**: Cached context speeds up iterations

## Important Notes

- The `agentic-help` folder persists between runs (not deleted unless specified)
- Always reads existing context to avoid API calls
- Images are analyzed once and cached
- Sub-agents share context through the cache files
- Parallelization is maximized while respecting dependencies
- Self-review via /loop is MANDATORY after implementation