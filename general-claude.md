# General Claude Guidelines - Reusable Patterns

## Core Development Principles

### Truthfulness Framework
#### What You MUST Do:
- Use Read/Grep/Glob tools to verify file existence before claiming they exist
- Copy exact code snippets from files, never paraphrase or recreate from memory
- Run commands to check actual state (git status, npm list, etc.)
- Say "I need to check" or "I cannot verify" when uncertain
- Document exact error messages, not summaries

#### What You MUST NOT Do:
- Write "the file probably contains" or "it should have"
- Create example code that "would work" without testing
- Assume file locations or function names exist
- Hide failures or errors to appear competent
- Continue when core requirements are unclear

### Escalation Examples:
- "I found 3 different implementations and need guidance on which to modify"
- "The tests are failing with this specific error: [exact error]"
- "I cannot find the file mentioned in the requirements"
- "Two approaches are possible, and I need a decision on direction"

## Code Style Guidelines

### Function Naming Conventions
- **Boolean functions**: Use prefixes `is`, `can`, `has`, `should` (e.g., `canShowFeature`, `isEnabled`)
- **Avoid**: Verb prefixes for booleans (e.g., `calculateShowFeature` when returning boolean)
- **Exceptions**: Only when it truly makes sense - think carefully before breaking this convention

### Function Parameters
- **More than 3 parameters**: Always use an options object with proper typing
- **Inline types preferred**: Use inline object types for single-use cases
- **Named types/interfaces**: Create when the shape is used in multiple places
- **Example**:
  ```typescript
  // Bad - too many parameters
  function createItem(name: string, type: string, value: number, enabled: boolean) {}
  
  // Good - options object with inline type
  function createItem(options: { name: string; type: string; value: number; enabled: boolean }) {}
  
  // Good - reusable interface when used multiple times
  interface ItemOptions { name: string; type: string; value: number; enabled: boolean }
  function createItem(options: ItemOptions) {}
  ```

### Function Immutability
- **Never mutate input parameters** - Functions should not modify their input arguments
- **Return new objects** - Use spread operator or Object.assign to create new objects
- **Pure functions preferred** - Functions should return new data without side effects
- **Example**:
  ```typescript
  // Bad - mutates input parameter
  function updateConfig(config: Config): void {
    config.enabled = true;  // Direct mutation
  }
  
  // Good - returns new object
  function updateConfig(config: Config): Config {
    return {
      ...config,
      enabled: true
    };
  }
  ```

### Readable Object Construction
- **Avoid ternary operators with conditional spreads** - They create hard-to-read code
- **Use clear if-statements** - Build objects step by step for better readability
- **Example**:
  ```typescript
  // Bad - nested ternary operators with spreads
  function buildObject(options: Options): Result {
    return {
      ...base,
      ...(options.includeA ? { a: options.a } : {}),
      ...(options.includeB ? { b: options.b } : {})
    };
  }
  
  // Good - clear, step-by-step construction
  function buildObject(options: Options): Result {
    const result = { ...base };
    
    if (options.includeA) {
      result.a = options.a;
    }
    
    if (options.includeB) {
      result.b = options.b;
    }
    
    return result;
  }
  ```

## Code Organization Patterns

### Type Definition Placement
- **Bottom-up approach**: Place types as close to usage as possible
- **Local types**: If shared within a directory, use local `types.ts` file
  - Component-specific: `src/components/MyComponent/types.ts`
  - Feature-specific: `src/features/myFeature/types.ts`
  - Service-specific: `src/services/myService/types.ts`
- **Global types**: For cross-layer/cross-feature types, use `src/@types/` or `src/types/`
- **Decision flow**: Is it used in multiple layers/features? → Global types. Otherwise → local `types.ts`

### Utility Function Placement
- **Bottom-up approach**: Place utilities as close to usage as possible
- **Component utilities**: If only used by one component → `src/components/MyComponent/utils.ts`
- **Feature utilities**: If only used by one feature → `src/features/MyFeature/utils.ts`
- **Shared utilities**: If used across multiple components/features → `src/utils/`
  - Organize by domain: `src/utils/validation/`, `src/utils/format/`, etc.
  - Use descriptive filenames that indicate purpose
- **Decision flow**: 
  - Used by single component/feature? → Keep local
  - Used by multiple components/features? → Move to `src/utils/[domain]/`

### Comments Policy

#### Core Principles
- **Self-documenting code first** - Use clear naming and structure instead of comments
- **Comments must add value** - If removing the comment doesn't lose information, it shouldn't exist
- **Explain WHY, not WHAT** - Focus on business logic and non-obvious relationships
- **Maintenance risk** - Comments can become outdated; prefer refactoring over commenting

#### Unnecessary Comments to Remove
1. **Direct code restatements**
   ```typescript
   // Bad - states the obvious
   // Check if feature is enabled
   if (feature.enabled) {}
   
   // Good - code is self-explanatory
   if (feature.enabled) {}
   ```

2. **Comments that repeat function names**
   ```typescript
   // Bad - function name already says this
   // Initialize configuration values
   config = getInitialConfiguration();
   ```

#### Acceptable Comments
1. **Non-obvious business logic relationships**
2. **Complex algorithms or formulas**
3. **Workarounds with context** (why a non-obvious approach was needed)
4. **API quirks or external system behaviors**
5. **Security considerations**
6. **Performance optimizations reasoning**

## Git Workflow Best Practices

### Branch Naming Convention
- Format: `{type}/{ticket-id}/{description}` or `{type}/{description}`
- Valid types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`
- Keep descriptions short and descriptive
- Examples:
  - `feat/USER-123/add-authentication`
  - `fix/payment-validation-error`
  - `refactor/extract-utility-functions`

### Safe Git Workflow
```bash
# 1. Check what changed
git status

# 2. Review each file's changes
git diff src/path/to/file.ts

# 3. Add files individually
git add src/specific/file.ts

# 4. Double-check staged files
git status --short

# 5. Commit with clear message
git commit -m "Clear description of changes"
```

### Code Quality Checks
Always run these before committing:
1. **Format code** (prettier, eslint fix, etc.)
2. **Lint check** (eslint, tslint, etc.)
3. **Type check** (TypeScript, Flow, etc.)
4. **Run tests** if affected

## Performance Considerations

### When to Optimize
- **Avoid premature optimization** - Profile first, optimize second
- **Focus on real bottlenecks** - Use performance tools to identify actual issues
- **Consider framework optimizations** - Many frameworks are already optimized
- **Escalate when uncertain** - Performance work can be complex with minimal gain

### Common Pitfalls to Avoid
- **Don't** over-engineer simple features
- **Don't** duplicate utility functions across files
- **Don't** ignore type errors
- **Don't** skip error handling
- **Do** maintain consistent style
- **Do** follow established patterns

## Documentation Standards

### Code Documentation
- **Self-documenting code** is the primary goal
- **README files** for complex features or modules
- **API documentation** for public interfaces
- **Usage examples** for non-obvious functionality

### Session Handover
When switching contexts or reaching limits:
1. Document current state clearly
2. List files modified with exact paths
3. Note any blockers or decisions needed
4. Include commands that were run
5. Specify next steps

## Architecture Patterns

### Separation of Concerns
- **Business logic** separate from UI/presentation
- **Services** for external integrations
- **Utilities** for pure functions
- **State management** isolated from components

### Dependency Management
- **Prefer composition** over inheritance
- **Use dependency injection** for flexibility
- **Avoid circular dependencies**
- **Keep dependencies minimal**

### Error Handling
- **Always handle errors** at appropriate levels
- **Provide meaningful error messages**
- **Log errors appropriately**
- **Fail gracefully** with fallbacks where possible

## Component Creation Patterns

### General Component Guidelines
- **Single responsibility** - Each component does one thing well
- **Props validation** - Always validate/type inputs
- **Clear naming** - Component names should indicate purpose
- **Folder structure** - Group related files together:
  ```
  MyComponent/
  ├── index.ts        # Main component file
  ├── types.ts        # Component-specific types
  ├── utils.ts        # Component-specific utilities
  ├── styles.css      # Component styles (if applicable)
  └── MyComponent.test.ts  # Component tests
  ```

### State Management
- **Local state** for component-specific data
- **Shared state** for cross-component data
- **Derived state** calculated from other state
- **Avoid redundant state** that can be computed

---

*These guidelines represent best practices that can be adapted to any project. Always consider project-specific requirements and team preferences when applying these patterns.*