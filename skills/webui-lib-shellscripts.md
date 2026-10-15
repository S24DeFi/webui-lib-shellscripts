---
applyTo:
  - filePaths: []
  - fileNames:
      - "*.md"
      - "*.ts"
      - "*.tsx"
      - "*.js"
      - "*.jsx"
      - "*.py"
      - "*.sh"
---

# PROJECT Skills and Agent Configuration

This folder contains AI agent instructions, custom skills, and domain-specific knowledge for this project.

## Folder Structure

```
skills/
├── PROJECT.md              # Main project skills (this file)
├── [feature-name].md       # Feature-specific agent instructions
├── [module-name].md        # Module-specific context
└── [AGENT-NAME].md         # Custom agents for specialized workflows
```

## What Goes Here

Use these files to document:
- Project structure and conventions
- Development workflows
- Coding patterns
- AI context
- Tool integrations
- Custom agents

## Getting Started

1. Define your project fundamentals in this file
2. Create feature-specific skills as needed
3. Use `source .shell-config` to activate project utilities
4. Share `skills/` with team members for consistent AI assistance
