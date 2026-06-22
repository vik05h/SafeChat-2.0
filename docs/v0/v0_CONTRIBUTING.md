# Contributing to SafeChat

Thank you for your interest in contributing. This document describes how to work on SafeChat productively.

---

## Code of Conduct

We expect contributors to behave with the same respect we expect users of SafeChat to show each other. Harassment, discrimination, or aggressive behavior toward other contributors is grounds for immediate removal from the project.

---

## Getting Set Up

### Prerequisites

```
Node.js          20+
Python           3.11+
Git              latest
VS Code          (recommended)
Firebase CLI     latest
Google Cloud CLI latest
Docker           (for testing Cloud Run locally)
```

### First-time setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/SafeChat-2.0.git
   cd SafeChat-2.0
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/ADNAN-ZEYA/SafeChat-2.0.git
   ```
4. Request credentials from the maintainer (Firebase Admin SDK key, API keys)
5. Follow setup instructions in `README.md` for backend and frontend
6. Read `docs/ARCHITECTURE.md` and `docs/MODERATION.md` before writing any code

---

## Branching Strategy

We use a simplified Git flow:

```
main                        Production-ready code only
├── develop                 Active development branch
│   ├── feature/<name>      New features
│   ├── fix/<name>          Bug fixes
│   └── docs/<name>         Documentation changes
└── hotfix/<name>           Emergency production fixes
```

### Branch naming

```
feature/post-creation
feature/dm-realtime
fix/moderation-timeout
fix/feed-pagination
docs/api-contracts
refactor/auth-middleware
```

Branch names use kebab-case. The prefix indicates the type of change.

### Creating a branch

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/your-feature-name
```

---

## Commit Messages

We follow Conventional Commits:

```
<type>(<scope>): <short description>

<optional longer description>

<optional footer with breaking changes or issue refs>
```

### Types

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Maintenance, dependencies, tooling |
| `ci` | CI/CD configuration |

### Scopes

```
backend, frontend, admin, moderation, auth, posts, messages,
chats, stories, infra, docs, deps
```

### Examples

```
feat(moderation): add Hinglish keyword bypass detection

fix(messages): handle Firestore listener disconnection on logout

docs(api): document new /uploads/sign endpoint

refactor(auth): extract token verification into middleware

chore(deps): upgrade Expo to 50.x
```

### What to avoid

- Vague messages: `fix stuff`, `update`, `wip`
- Multiple unrelated changes in one commit
- Commits with `[skip ci]` unless absolutely necessary

---

## Code Style

### Python (Backend)

- **Formatter:** Black (line length 100)
- **Linter:** Ruff
- **Type checking:** mypy in strict mode
- **All functions require type hints**
- **All public functions require docstrings**
- **Imports:** stdlib → third-party → local, separated by blank lines
- **Naming:** `snake_case` for functions, variables; `PascalCase` for classes; `UPPER_SNAKE_CASE` for constants

Example:

```python
from datetime import datetime
from typing import Optional

from firebase_admin import firestore
from pydantic import BaseModel

from .moderation import moderate_text


class CreatePostRequest(BaseModel):
    """Request body for creating a new post."""
    caption: str
    media_urls: list[str]


async def create_post(
    request: CreatePostRequest,
    author_uid: str,
) -> dict:
    """Create a new post after running through moderation.
    
    Args:
        request: Post content from the user.
        author_uid: Firebase UID of the post author.
    
    Returns:
        The created post document.
    
    Raises:
        ModerationBlockedError: If content fails moderation.
    """
    verdict = await moderate_text(request.caption)
    if verdict.blocked:
        raise ModerationBlockedError(reason=verdict.reason)
    # ... implementation
```

### JavaScript / TypeScript (Frontend)

- **Formatter:** Prettier (single quotes, no semicolons, line length 100)
- **Linter:** ESLint with `@react-native` and TypeScript rules
- **TypeScript** required for new files (no plain JS)
- **Functional components only**, no class components
- **Naming:** `camelCase` for variables, functions; `PascalCase` for components, types
- **File naming:** `PascalCase.tsx` for components, `camelCase.ts` for utilities

Example:

```typescript
import { useState } from 'react'
import { View, Text } from 'react-native'

import { useAuth } from '../hooks/useAuth'
import { createPost } from '../services/api'

interface PostComposerProps {
  onSuccess: (postId: string) => void
}

export function PostComposer({ onSuccess }: PostComposerProps) {
  const { user } = useAuth()
  const [caption, setCaption] = useState('')

  const handleSubmit = async () => {
    const result = await createPost({ caption, mediaUrls: [] })
    onSuccess(result.id)
  }

  return (
    <View>
      <Text>Compose a post</Text>
    </View>
  )
}
```

---

## Pull Request Process

### Before opening a PR

1. Rebase your branch on the latest `develop`:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```
2. Run tests locally:
   ```bash
   # Backend
   cd backend && pytest
   
   # Frontend
   cd app && npm test
   ```
3. Run formatters:
   ```bash
   # Backend
   black . && ruff check .
   
   # Frontend
   npm run lint && npm run format
   ```
4. Update relevant documentation in `docs/`
5. Verify your changes work locally end-to-end

### Opening the PR

PR title format:

```
<type>(<scope>): <short description>
```

Same convention as commit messages.

### PR description template

```markdown
## Summary
One-paragraph description of what changed and why.

## Changes
- Bullet points of specific changes
- Both code and documentation
- Any breaking changes called out

## Testing
How you verified this works. Include screenshots for UI changes.

## Related Issues
Closes #123
Refs #456
```

### Review process

1. CI runs automatically (lint, type check, tests)
2. Maintainer reviews within 5 business days
3. Address review comments by pushing additional commits (don't force-push during review)
4. Once approved, maintainer squash-merges to `develop`
5. Your feature branch can be deleted

### Review criteria

Reviews check for:
- Correctness — does it work?
- Architecture fit — does it follow patterns in the codebase?
- Test coverage — are new code paths tested?
- Documentation — are user-visible or API changes documented?
- Security — are user inputs properly handled?
- Moderation — does new user content go through the cascade?

---

## Testing

### Backend

- **Framework:** pytest
- **Location:** `backend/tests/`
- **Coverage:** Aim for 80%+ on moderation, auth, and core business logic
- **Integration tests** use Firestore emulator
- **Mock external APIs** (OpenAI, Gemini, Vision)

```bash
cd backend
pytest                              # Run all tests
pytest tests/test_moderation.py     # Single file
pytest -v                           # Verbose output
pytest --cov                        # With coverage report
```

### Frontend

- **Framework:** Jest + React Testing Library
- **Location:** `app/__tests__/`
- Component tests for shared components
- Integration tests for screens

```bash
cd app
npm test                            # Run all tests
npm test -- PostComposer            # Single component
npm test -- --coverage              # Coverage report
```

### What to test

Always test:
- Moderation cascade (every layer, every category)
- Auth flows (signup, login, token refresh)
- Critical user paths (post creation, message send)
- Error handling
- Edge cases (empty input, max length, special characters)

Don't waste time testing:
- Third-party libraries
- Simple getters/setters
- Visual styling (snapshot tests of stable UI is OK)

---

## Working with the Moderation Engine

The moderation engine is the most sensitive part of SafeChat. Special rules apply:

1. **Never bypass moderation** for any user-generated content endpoint, even temporarily for testing
2. **Test multilingually** — your tests must cover English, Hindi, and Hinglish
3. **Test bypass attempts** — character substitutions, repeated letters, emoji combinations
4. **Don't log raw user content** — use hashes (see `MODERATION.md` section 8)
5. **Document moderation changes** — any change to thresholds or categories requires a PR description explaining the reasoning

---

## Documentation Requirements

Documentation lives in `docs/`. Update it when:

- Adding or modifying API endpoints → `API_CONTRACTS.md`
- Changing the database schema → `DATABASE_SCHEMA.md`
- Adjusting moderation behavior → `MODERATION.md`
- Adding new components to architecture → `ARCHITECTURE.md`
- Changing user-facing features → `README.md`

Documentation is part of the code change, not a follow-up task.

---

## Secrets and Credentials

**Never commit:**
- API keys
- Firebase Admin SDK JSON files
- `.env` files
- Service account credentials
- User data dumps

If you accidentally commit secrets:
1. Notify the maintainer immediately
2. Rotate the leaked credential
3. Use `git filter-branch` or BFG Repo-Cleaner to remove from history
4. Force-push the cleaned history

The `.gitignore` is configured to prevent common mistakes, but always double-check `git status` before committing.

---

## Issue Reporting

### Bug reports

```markdown
**Description**
What went wrong.

**Steps to reproduce**
1. Go to ...
2. Click on ...
3. See error

**Expected behavior**
What should have happened.

**Environment**
- Platform: web / android
- Browser/OS version:
- App version:

**Screenshots**
If applicable.
```

### Feature requests

```markdown
**Problem**
What user problem does this solve?

**Proposed solution**
What you'd like to see built.

**Alternatives considered**
Other approaches you thought about.

**Additional context**
Mockups, related issues, etc.
```

---

## Getting Help

If you're stuck:

1. Check existing documentation in `docs/`
2. Search existing issues
3. Open a question issue with the label `question`
4. For sensitive matters, contact the maintainer directly

---

## Recognition

Contributors who make significant contributions will be acknowledged in the project README and given commit access where appropriate.

---

*Last updated: November 2026*
