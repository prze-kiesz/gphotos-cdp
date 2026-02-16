# Learning Mode Architecture

## Overview

Learning Mode is an interactive tool for creating locale translations without manually inspecting Google Photos interface.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Learning Mode                          │
│                     (learning.go)                           │
└─────────────┬───────────────────────────────────────────────┘
              │
              ├─► 1. Login to Google Photos
              │      - Uses existing Session.login()
              │      - Reuses chrome profile if available
              │
              ├─► 2. Detect Locale
              │      - Reads HTML lang attribute
              │      - Parses meta tags
              │      - Falls back to user input
              │
              ├─► 3. Collect Labels (Main Page)
              │      - Query all [aria-label] elements
              │      - Extract and deduplicate text
              │      - Store in sorted list
              │
              ├─► 4. Navigate to Photo
              │      - Click first available photo
              │      - Wait for detail view
              │
              ├─► 5. Collect Labels (Photo View)
              │      - Query aria-labels again
              │      - Merge with main page labels
              │
              ├─► 6. Open Info Panel
              │      - Try to find "info" button
              │      - Fall back to keyboard shortcut
              │
              ├─► 7. Collect Labels (Info Panel)
              │      - Query aria-labels again
              │      - Merge all unique labels
              │
              ├─► 8. Interactive Mapping
              │      - Display numbered label list
              │      - Ask user to map each field
              │      - Validate input
              │      - Allow text trimming for startsWith
              │
              ├─► 9. Collect String Fields
              │      - Today/Yesterday words
              │      - Status messages
              │      - Error texts
              │
              ├─► 10. Collect Day/Month Names
              │      - Short day names (7)
              │      - Long day names (7)
              │      - Short month names (12)
              │
              └─► 11. Generate & Save YAML
                    - Create GPhotosLocale struct
                    - Marshal to YAML
                    - Save as locales-XX.yaml
                    - Display usage instructions
```

## Data Flow

```
Google Photos UI
       │
       │ aria-label attributes
       ▼
JavaScript Collector
       │
       │ JSON array
       ▼
Go Parser (collectAllAriaLabels)
       │
       │ []string
       ▼
Deduplicator & Sorter
       │
       │ sorted unique labels
       ▼
Interactive Mapper (interactiveLearning)
       │
       │ user input (numbers)
       ▼
Locale Builder
       │
       │ GPhotosLocale struct
       ▼
YAML Generator
       │
       │ locales-XX.yaml
       ▼
File System
```

## Key Functions

### In learning.go

#### collectAllAriaLabels(ctx) → []string
- Executes JavaScript in browser
- Queries all elements with aria-label
- Deduplicates and sorts
- Returns label array

#### collectDialogTexts(ctx) → []string
- Finds dialog elements
- Extracts text content
- Returns dialog texts (for future use)

#### runLearningMode(s *Session) → error
- Main orchestrator
- Controls entire learning flow
- Handles errors and cleanup

#### interactiveLearning(locale, labels) → error
- Interactive terminal UI
- Guides user through mapping
- Validates all inputs
- Builds locale structure

#### saveLearnedLocale(locale, data) → error
- Marshals struct to YAML
- Writes file
- Prints usage instructions

## Integration Points

### With main.go

```go
// main.go flag
learnFlag = flag.Bool("learn", false, "Learning mode...")

// main.go execution
if *learnFlag {
    s, _ := NewSession()
    runLearningMode(s)
    return
}
```

### With locales.go

Uses same structures:
- `GPhotosLocale` struct
- `NodeLabelMatch` struct
- Same YAML format

### With Session

Reuses:
- `Session.login()` - authentication
- `Session.getLocale()` - locale detection
- `Session.NewWindow()` - Chrome context

## JavaScript Collectors

### Label Collector
```javascript
(function() {
    const labels = new Set();
    const elements = document.querySelectorAll('[aria-label]');
    elements.forEach(el => {
        const label = el.getAttribute('aria-label');
        if (label && label.trim()) {
            labels.add(label.trim());
        }
    });
    return JSON.stringify(Array.from(labels).sort());
})()
```

### Photo Clicker
```javascript
(function() {
    const links = Array.from(document.querySelectorAll('a[href*="/photo/"]'));
    if (links.length > 0) {
        links[0].click();
        return links[0].href;
    }
    return null;
})()
```

### Info Panel Opener
```javascript
(function() {
    const infoButtons = Array.from(document.querySelectorAll('[aria-label]'))
        .filter(el => {
            const label = el.getAttribute('aria-label').toLowerCase();
            return label.includes('info') || label.includes('details');
        });
    if (infoButtons.length > 0) {
        infoButtons[0].click();
        return true;
    }
    // Fallback: keyboard shortcut
    document.dispatchEvent(new KeyboardEvent('keydown', {key: 'i'}));
    return false;
})()
```

## User Experience Flow

```
User runs: gphotos-cdp -learn
            ↓
    Login to Google Photos
            ↓
    Locale auto-detected (or user inputs)
            ↓
    Tool navigates & collects labels
    (User sees progress logs)
            ↓
    Display numbered label list
            ↓
    For each required field:
      - Show description
      - User enters number
      - Confirm/edit text
            ↓
    Collect string fields
    (Today, Yesterday, etc.)
            ↓
    Collect arrays
    (Days, Months)
            ↓
    Generate locales-XX.yaml
            ↓
    Display YAML preview
            ↓
    Show usage instructions
```

## Match Types

### Used in NodeLabelMatch

| Type | CSS Selector | Use Case |
|------|--------------|----------|
| `equals` | `[aria-label="exact"]` | Buttons with exact text |
| `startsWith` | `[aria-label^="prefix"]` | Labels with dynamic parts |
| `contains` | `[aria-label*="word"]` | Flexible matching |
| `endsWith` | `[aria-label$="suffix"]` | Less common |

## Error Handling

```
Try Login
  ├─► Success → Continue
  └─► Fail → Fatal error

Try Collect Labels
  ├─► Success → Continue
  └─► Fail → Warn, continue with partial data

Try Open Photo
  ├─► Success → Collect more labels
  └─► Fail → Warn, continue with main labels

Try Open Info
  ├─► Success → Collect info labels
  └─► Fail → Warn, continue

User Input
  ├─► Valid → Map field
  ├─► Invalid → Warn, skip
  └─► Empty → Skip

Save File
  ├─► Success → Done
  └─► Fail → Fatal error
```

## Testing

### Manual Test
```bash
# 1. Change Google account language
# 2. Run learning mode
gphotos-cdp -learn -dev -dldir photos

# 3. Follow prompts
# 4. Verify generated file
cat locales-XX.yaml

# 5. Test locale
./test-locale.sh locales-XX.yaml
```

### Validation
```bash
# Check YAML syntax
./test-locale.sh locales-XX.yaml

# Check required fields
python3 << EOF
import yaml
with open('locales-XX.yaml') as f:
    data = yaml.safe_load(f)
    print(data.keys())
EOF
```

## Future Enhancements

### Possible Improvements

1. **Screenshot Mode**: Capture screenshots of UI elements
2. **OCR Integration**: Auto-detect text from screenshots
3. **ML Suggestions**: Suggest mappings based on similarity
4. **Batch Mode**: Process multiple photos to collect more labels
5. **Diff Mode**: Compare with existing locale
6. **Export Format**: Support multiple formats (JSON, TOML)
7. **Validation Mode**: Test generated locale immediately
8. **Cloud Sync**: Upload/download community locales

### Architecture for ML Suggestions

```
Collected Labels + Existing Locales
            ↓
    String Similarity Algorithm
    (Levenshtein, Cosine, etc.)
            ↓
    Suggest top 3 matches
            ↓
    User confirms or chooses different
```

## File Structure

```
gphotos-cdp/
├── learning.go              # Learning mode implementation
├── learning_test.go         # Tests (TODO)
├── LEARNING_MODE.md         # User guide
├── test-locale.sh           # Locale validator
├── locales-*.example.yaml   # Example locales
└── examples/
    └── create-*-locale.sh   # Language-specific guides
```

## Dependencies

- **chromedp**: Browser automation
- **gopkg.in/yaml.v3**: YAML serialization
- **bufio**: Terminal input
- **encoding/json**: JavaScript response parsing
- **zerolog**: Logging

## Security Considerations

- **No credentials stored**: Uses existing Chrome profile
- **Local execution**: All data stays on user's machine
- **Manual review**: User reviews all mappings
- **YAML safety**: Uses safe YAML parser

## Performance

- **One-time operation**: Run only when adding new language
- **Interactive**: Waits for user input (not optimized for batch)
- **Browser overhead**: Requires Chrome to be running
- **Network usage**: Minimal (only loads Google Photos once)

---

**Maintained by**: gphotos-cdp contributors  
**License**: Apache 2.0  
**Version**: 1.0
