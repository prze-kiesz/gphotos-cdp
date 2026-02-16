# Learning Mode Guide

Learning Mode helps you create locale translations for Google Photos interface in any language.

## 🎓 What is Learning Mode?

Learning Mode is an interactive tool that:
1. Logs into Google Photos
2. Collects all text labels from the interface
3. Guides you through mapping them to required fields
4. Generates a ready-to-use locale configuration file

## 🚀 Quick Start

```bash
# Run learning mode
gphotos-cdp -learn -profile /path/to/profile

# With Docker
docker-compose run --rm gphotos-cdp gphotos-cdp -learn -profile /data/profile
```

## 📋 Prerequisites

1. **Chrome profile with login**: You need to be logged in to Google Photos
2. **Google Photos language**: Set your Google account to the language you want to learn
3. **Terminal access**: Interactive mode requires terminal input

## 🔧 Step-by-Step Process

### 1. Change Google Photos Language

Before running learning mode:
1. Go to your Google Account settings
2. Change language to the one you want to learn (e.g., Polish, German, French)
3. Save and refresh Google Photos

### 2. Run Learning Mode

```bash
# Native
gphotos-cdp -learn -dev -dldir photos

# With Docker (interactive)
docker-compose run --rm -it gphotos-cdp gphotos-cdp -learn -profile /data/profile
```

### 3. Login Phase

The tool will:
- Open Chrome browser
- Navigate to Google Photos
- Wait for you to log in (if needed)
- Detect your account language

### 4. Collection Phase

The tool automatically:
- Collects all aria-labels from main page
- Opens a photo to collect detail page labels
- Opens info panel to collect metadata labels
- Shows total number of unique labels found

### 5. Interactive Mapping

You'll see output like:

```
📋 Available labels:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Pobierz - Shift+D
  2. Więcej opcji
  3. Otwórz informacje
  4. Nazwa pliku:
  5. Data wykonania zdjęcia:
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Match required fields:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 SelectAllPhotosLabel
   Description: Button to select all photos from a date (contains date)
   Match type: startsWith
   Example (English): Select all photos from
   Enter label number (or press Enter to skip): 
```

For each field:
1. Read the description
2. Find matching label in the numbered list above
3. Enter the number
4. Confirm or edit the matched text

### 6. String Fields

After matching aria-labels, you'll be asked for simple strings:

```
📝 String fields (enter text or press Enter to use default):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Word for 'today' [default: Today]
Enter text: Dzisiaj

Word for 'yesterday' [default: Yesterday]
Enter text: Wczoraj
```

### 7. Day and Month Names

```
📅 Day and Month Names:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Enter short day names (Sun,Mon,Tue,Wed,Thu,Fri,Sat): nie,pon,wt,śr,czw,pt,sob
Enter long day names (Sunday,Monday,...): niedziela,poniedziałek,wtorek,środa,czwartek,piątek,sobota
Enter short month names (Jan,Feb,...Dec): sty,lut,mar,kwi,maj,cze,lip,sie,wrz,paź,lis,gru
```

### 8. Generate YAML

The tool will:
- Create a YAML file: `locales-XX.yaml` (where XX is your locale code)
- Display the generated configuration
- Show usage instructions

## 📝 Required Fields

Learning mode will ask you to map these fields:

| Field | Description | Match Type | Example (EN) |
|-------|-------------|------------|--------------|
| SelectAllPhotosLabel | Button to select all photos from date | startsWith | "Select all photos from" |
| FileNameLabel | Filename label in info panel | startsWith | "Filename:" |
| DateLabel | Date taken label | startsWith | "Date taken:" |
| TimeLabel | Time taken label | startsWith | "Time taken:" |
| TzLabel | Timezone label | startsWith | "GMT" |
| ViewPreviousPhotoMatch | Previous photo button | equals | "View previous photo" |
| MoreOptionsLabel | More options menu | equals | "More options" |
| DownloadLabel | Download button with shortcut | equals | "Download - Shift+D" |
| DownloadOriginalLabel | Download original option | equals | "Download original" |
| OpenInfoMatch | Open info panel button | equals | "Open info" |
| VideoStillProcessingDialogLabel | Video processing dialog | startsWith | "Video still is processing" |

### String Fields

| Field | Description | Default |
|-------|-------------|---------|
| Today | Word for "today" | "Today" |
| Yesterday | Word for "yesterday" | "Yesterday" |
| VideoStillProcessingStatusText | Processing status message | "Video is still processing..." |
| NoWebpageFoundText | Page not found error | "No webpage was found..." |
| NotNow | "Not now" button text | "Not now" |

### Arrays

- **ShortDayNames**: 7 short day names (Sun, Mon, ...)
- **LongDayNames**: 7 long day names (Sunday, Monday, ...)
- **ShortMonthNames**: 12 short month names (Jan, Feb, ...)

## 🎯 Match Types

### startsWith
The label begins with the specified text.
```yaml
matchType: startsWith
matchValue: "Filename:"
```
Matches: "Filename: photo.jpg", "Filename: video.mp4"

### equals
The label must exactly match.
```yaml
matchType: equals
matchValue: "Download - Shift+D"
```
Matches only: "Download - Shift+D"

### contains
The label contains the text anywhere.
```yaml
matchType: contains
matchValue: "Download"
```
Matches: "Download photo", "Download - Shift+D", "Re-download"

### endsWith
The label ends with the text.
```yaml
matchType: endsWith
matchValue: "photo"
```
Matches: "View previous photo", "Download photo"

## 💡 Tips

### Finding the Right Labels

1. **Look for keywords**: Search for key words like "download", "info", "filename"
2. **Check shortcuts**: Download labels often include " - Shift+D"
3. **Info panel**: Open a photo and click info icon to see all labels
4. **Ask AI**: If you're translating, ask what the equivalent terms would be

### Common Issues

**"I can't find the right label"**
- Make sure you're logged in to Google Photos
- Open a photo manually and check the interface
- The tool might not have collected all labels - try refreshing the page
- Press Enter to skip and manually edit the YAML later

**"The detected locale is wrong"**
- The tool will ask you to confirm or override the detected locale
- Just enter the correct locale code (e.g., 'pl', 'de', 'fr')

**"Labels are incomplete"**
- You can run learning mode multiple times
- You can manually edit the generated YAML file
- Reference existing locales in `locales.yaml` for examples

## 📤 Using Generated Locale

### Option 1: Merge into locales.yaml

```bash
# Copy the content from locales-XX.yaml
cat locales-XX.yaml

# Paste it into locales.yaml under your locale code
```

### Option 2: Use separate file

```bash
# Set environment variable
export GPHOTOS_LOCALE_FILE=locales-pl.yaml

# Run with custom locale file
gphotos-cdp -dldir photos

# With Docker
docker-compose run --rm \
  -v ./locales-pl.yaml:/usr/local/bin/locales.yaml:ro \
  gphotos-cdp gphotos-cdp -profile /data/profile -dldir /data/photos
```

### Option 3: Test immediately

```bash
# Copy generated file
cp locales-XX.yaml locales.yaml

# Test (verbose to see locale being used)
gphotos-cdp -v -dev -dldir photos

# Check logs for: "using locale XX"
```

## 🧪 Testing Your Locale

After creating a locale:

```bash
# 1. Set your Google account to that language
# 2. Run the tool in verbose mode
gphotos-cdp -v -dev -dldir photos

# 3. Check logs for:
#    - "using locale XX"
#    - No errors about missing labels
#    - Successful photo downloads

# 4. Test specific features:
#    - Download a photo
#    - View photo info
#    - Check date/time parsing
```

## 📊 Example Output

Complete example session:

```
🎓 Starting Learning Mode
This will help you create locale translations for Google Photos

Step 1: Logging in to Google Photos...
Step 2: Navigating to Google Photos...
Step 3: Collecting interface texts from main page...
Found 127 unique aria-labels

Step 4: Opening a photo to collect detail texts...
Found 156 unique aria-labels in photo view

Step 5: Opening info panel...

📋 Total unique labels collected: 183

🎯 Interactive Learning Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Locale code (e.g., 'pl', 'fr', 'de'): [detected: pl] 

📋 Available labels:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Pobierz - Shift+D
  2. Pobierz oryginał
  3. Więcej opcji
  ...

🔍 Match required fields:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 DownloadLabel
   Description: Download button (with shortcut)
   Match type: equals
   Example (English): Download - Shift+D
   Enter label number: 1
   ✓ Matched: DownloadLabel = Pobierz - Shift+D

...

✨ Success!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Locale configuration saved to: locales-pl.yaml
```

## 🤝 Contributing Locales

After creating a locale:

1. Test it thoroughly
2. Create a pull request with your locale added to `locales.yaml`
3. Include locale code and language name in PR description
4. Mention which Google Photos interface language you used

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## 🔧 Advanced Usage

### Headless Learning Mode

Not recommended, but possible with VNC or X11 forwarding:

```bash
# With X11 forwarding (SSH)
ssh -X user@server
gphotos-cdp -learn -dev -dldir photos

# With VNC
# Start VNC server on remote machine
# Run learning mode in VNC session
```

### Batch Multiple Languages

```bash
#!/bin/bash
# Script to create multiple locales

for lang in pl de fr es it; do
  echo "Creating locale for: $lang"
  # Change Google account language to $lang
  # Run learning mode
  gphotos-cdp -learn -dev -dldir photos
  # The tool will create locales-$lang.yaml
done
```

### Editing Generated YAML

The generated file is standard YAML - you can edit it manually:

```yaml
pl:
  selectAllPhotosLabel:
    matchType: startsWith
    matchValue: "Wybierz wszystkie zdjęcia od"  # ← Edit this
  downloadLabel:
    matchType: equals
    matchValue: "Pobierz - Shift+D"              # ← Edit this
  today: "Dzisiaj"                                # ← Edit this
```

## 📞 Getting Help

- 🐛 [Report issues](../../issues/new)
- 💬 [Ask questions](../../discussions)
- 📖 [See examples in locales.yaml](../locales.yaml)
- 🤝 [Contributing guide](../CONTRIBUTING.md)

## 🌍 Supported Locales

Currently supported languages (see `locales.yaml`):
- English (en) - default
- Dutch (nl)
- **Your language here!** - use learning mode to add it

---

**Ready to start?** Run: `gphotos-cdp -learn -dev -dldir photos`
