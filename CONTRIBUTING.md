# Contributing to gphotos-cdp

Thank you for considering contributing! Here's how you can help.

## Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🌍 Add language support
- 🔧 Submit bug fixes
- ✨ Add new features

## Getting Started

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/gphotos-cdp.git
cd gphotos-cdp
```

### 2. Set Up Development Environment

```bash
# Install dependencies
./install.sh

# Run tests
go test ./...

# Build
go build .
```

### 3. Create a Branch

```bash
git checkout -b feature/my-awesome-feature
```

### 4. Make Your Changes

- Write clean, documented code
- Follow existing code style
- Add tests if applicable
- Update documentation

### 5. Test Your Changes

```bash
# Run Go tests
go test -v ./...

# Test Docker build
docker-compose build

# Test functionality
./setup-auth.sh
make up
make logs
```

### 6. Commit

Use clear, descriptive commit messages:

```bash
git commit -m "Add feature: description of what you did"
```

Examples:
- `fix: resolve Chrome crash on startup`
- `feat: add support for Polish locale`
- `docs: improve Docker setup instructions`
- `chore: update dependencies`

### 7. Push and Create PR

```bash
git push origin feature/my-awesome-feature
```

Then create a Pull Request on GitHub.

## Code Guidelines

### Go Code

- Follow standard Go formatting (`go fmt`)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small
- Handle errors appropriately

```go
// Good
func downloadPhoto(url string) error {
    // Clear, documented, handles errors
    resp, err := http.Get(url)
    if err != nil {
        return fmt.Errorf("failed to download: %w", err)
    }
    defer resp.Body.Close()
    // ...
}

// Avoid
func d(u string) { // Unclear names, no error handling
    http.Get(u)
}
```

### Docker

- Keep images small
- Use multi-stage builds
- Run as non-root user
- Document environment variables
- Set resource limits

### Documentation

- Use clear, simple language
- Include examples
- Keep formatting consistent
- Update relevant docs when changing features

## Adding Language Support

**Easy way:** Use Learning Mode! 🎓

```bash
# 1. Change your Google account language to target language
# 2. Run learning mode
gphotos-cdp -learn -dev -dldir photos

# 3. Follow interactive prompts
# 4. Generated locale file: locales-XX.yaml
```

See [LEARNING_MODE.md](LEARNING_MODE.md) for detailed guide.

**Manual way:** Edit `locales.yaml` directly:

1. Find your Google Photos language code (e.g., `pl` for Polish)
2. Log in to Google Photos in that language
3. Note the exact text for each UI element
4. Add translations to `locales.yaml`:

```yaml
pl:  # ISO 639-1 language code
  selectAllPhotosLabel:
    matchType: startsWith
    matchValue: "Wybierz wszystkie zdjęcia z"
  fileNameLabel:
    matchType: startsWith
    matchValue: "Nazwa pliku:"
  # ... more translations
```

5. Test thoroughly with Google Photos in that language
6. Submit PR with your translations

## Reporting Bugs

**Before reporting:**
- Check if it's already reported in [Issues](../../issues)
- Try latest version
- Gather relevant logs

**When reporting, include:**
- OS and architecture
- Docker version (if using Docker)
- Go version (if building from source)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs (with sensitive data removed)
- Screenshots if applicable

**Example:**

```markdown
## Bug Description
Chrome crashes after authenticating

## Environment
- OS: Ubuntu 22.04
- Docker: 24.0.7
- Container: latest

## Steps to Reproduce
1. Run `./setup-auth.sh`
2. Log in to Google account
3. Chrome crashes with "out of memory"

## Logs
```
[error] Chrome process exited unexpectedly
...
```

## Expected
Should proceed to photo download

## Actual
Crashes immediately after login
```

## Feature Requests

When suggesting features:
- Explain the use case
- Describe desired behavior
- Consider implementation complexity
- Check if it's already planned

## Code Review Process

1. Automated tests must pass
2. Docker build must succeed
3. Code review by maintainer
4. Address any feedback
5. Merge when approved

## Recognition

All contributors will be:
- Listed in git history
- Mentioned in release notes (for significant contributions)
- Credited in CHANGELOG.md

## Questions?

- 💬 Open a [Discussion](../../discussions)
- 📧 Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
