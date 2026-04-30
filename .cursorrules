# Testing Enforcement Rules — testcase_01 (TypeScript + Python)

## TDD Workflow (Non-Negotiable)
1. Write the test FIRST — see it fail (Red)
2. Write minimal code to pass — see it pass (Green)
3. Refactor — tests still pass (Refactor)

## Testing Pyramid
- Pure Unit Tests: No I/O, no framework imports, stub injection only (tests/unit/)
- Integration Tests: Framework mocking allowed, real orchestration (tests/integration/)
- Behavioral Tests: Detector perception — "Does it SEE the files?" (tests/behavioral/)
- Adapter Tests: Real I/O in temp directories, no mocks (tests/integration/adapters/)

## Test Runners
- TypeScript: npx jest --forceExit
- Python: pytest tests/ -v

## Test File Naming
- TypeScript: *.test.ts (unit), *.integration.test.ts (integration)
- Python: test_*.py

## Mock Tax Rule
If test file LOC > 2x source file LOC:
- DELETE the unit test
- Write an integration test instead
- Never try to "fix" or "reduce" the unit test

## Pre-commit Hooks
- NEVER use --no-verify to skip hooks
- Wait for hooks to pass before declaring work complete
- Fix failures, do not bypass them

## Test Location
- Unit tests: tests/unit/ (NO framework imports, NO vscode imports)
- Integration tests: tests/integration/
- Behavioral tests: tests/behavioral/
- Python tests: service/tests/test_*.py

## Before Every Change
1. Check if tests exist for the file being modified
2. If no tests exist, write them FIRST
3. Run the full test suite before declaring complete

## Project Conventions (from docs/mault.yaml)
- Services → src/services/ (*Service.ts, *_service.py)
- Utils → src/utils/ (*Util*.ts, *util*.ts, *_util*.py)
- Models → src/models/ (*Model.ts, *_model.py)
- Tests must live in tests/ directory (TypeScript) or tests/ (Python)
- File naming: kebab-case (TypeScript), snake_case (Python)
- No bare except: in Python — use specific exception types
- No console.log in production src/**/*.ts — use structured logger
