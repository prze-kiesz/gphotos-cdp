package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"

	"github.com/chromedp/chromedp"
	"github.com/rs/zerolog/log"
	"gopkg.in/yaml.v3"
)

type LearnedTexts struct {
	AllAriaLabels    map[string]bool
	AllTextContents  map[string]bool
	PhotoDetailTexts map[string]bool
}

// collectAllAriaLabels collects all aria-label attributes from the page
func collectAllAriaLabels(ctx context.Context) ([]string, error) {
	var labelsJSON string
	err := chromedp.Run(ctx,
		chromedp.EvaluateAsDevTools(`
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
		`, &labelsJSON),
	)
	if err != nil {
		return nil, err
	}

	var labels []string
	if err := json.Unmarshal([]byte(labelsJSON), &labels); err != nil {
		return nil, err
	}

	return labels, nil
}

// collectDialogTexts collects text from dialogs and overlays
func collectDialogTexts(ctx context.Context) ([]string, error) {
	var textsJSON string
	err := chromedp.Run(ctx,
		chromedp.EvaluateAsDevTools(`
			(function() {
				const texts = new Set();
				// Look for common dialog selectors
				const selectors = ['[role="dialog"]', '[role="alertdialog"]', '.dialog', '[class*="dialog"]'];
				selectors.forEach(selector => {
					const elements = document.querySelectorAll(selector);
					elements.forEach(el => {
						const text = el.textContent.trim();
						if (text && text.length < 200) {
							texts.add(text);
						}
					});
				});
				return JSON.stringify(Array.from(texts));
			})()
		`, &textsJSON),
	)
	if err != nil {
		return nil, err
	}

	var texts []string
	if err := json.Unmarshal([]byte(textsJSON), &texts); err != nil {
		return nil, err
	}

	return texts, nil
}

// runLearningMode is the main learning mode function
func runLearningMode(s *Session) error {
	log.Info().Msg("🎓 Starting Learning Mode")
	log.Info().Msg("This will help you create locale translations for Google Photos")
	log.Info().Msg("")

	ctx, cancel := s.NewWindow()
	defer cancel()

	startupCtx, startupCancel := context.WithTimeout(ctx, 10*time.Minute)
	defer startupCancel()

	// Login
	log.Info().Msg("Step 1: Logging in to Google Photos...")
	if err := s.login(startupCtx); err != nil {
		return fmt.Errorf("login failed: %w", err)
	}

	// Detect locale
	locale, err := s.getLocale(startupCtx)
	if err != nil {
		log.Warn().Msg("Could not detect locale, will continue anyway")
		locale = "unknown"
	}
	log.Info().Msgf("Detected locale: %s", locale)

	// Navigate to photos
	log.Info().Msg("Step 2: Navigating to Google Photos...")
	if err := chromedp.Run(startupCtx, chromedp.Navigate(gphotosUrl+s.userPath+s.albumPath)); err != nil {
		return fmt.Errorf("navigation failed: %w", err)
	}

	// Wait for page to load
	time.Sleep(3 * time.Second)

	// Collect main page aria-labels
	log.Info().Msg("Step 3: Collecting interface texts from main page...")
	mainLabels, err := collectAllAriaLabels(startupCtx)
	if err != nil {
		return fmt.Errorf("failed to collect aria-labels: %w", err)
	}
	log.Info().Msgf("Found %d unique aria-labels", len(mainLabels))

	// Try to open a photo
	log.Info().Msg("Step 4: Opening a photo to collect detail texts...")
	var imageId string
	err = chromedp.Run(startupCtx,
		chromedp.EvaluateAsDevTools(`
			(function() {
				const links = Array.from(document.querySelectorAll('a[href*="/photo/"]'));
				if (links.length > 0) {
					links[0].click();
					return links[0].href;
				}
				return null;
			})()
		`, &imageId),
	)

	if err == nil && imageId != "" {
		time.Sleep(2 * time.Second)

		// Collect photo detail labels
		photoLabels, err := collectAllAriaLabels(startupCtx)
		if err == nil {
			log.Info().Msgf("Found %d unique aria-labels in photo view", len(photoLabels))
			// Merge with main labels
			for _, label := range photoLabels {
				found := false
				for _, ml := range mainLabels {
					if ml == label {
						found = true
						break
					}
				}
				if !found {
					mainLabels = append(mainLabels, label)
				}
			}
		}

		// Try to open info panel
		log.Info().Msg("Step 5: Opening info panel...")
		chromedp.Run(startupCtx,
			chromedp.EvaluateAsDevTools(`
				(function() {
					const infoButtons = Array.from(document.querySelectorAll('[aria-label]')).filter(el => 
						el.getAttribute('aria-label').toLowerCase().includes('info') ||
						el.getAttribute('aria-label').toLowerCase().includes('details')
					);
					if (infoButtons.length > 0) {
						infoButtons[0].click();
						return true;
					}
					// Try keyboard shortcut
					document.dispatchEvent(new KeyboardEvent('keydown', {key: 'i', code: 'KeyI'}));
					return false;
				})()
			`, nil),
		)

		time.Sleep(2 * time.Second)

		// Collect info panel labels
		infoLabels, err := collectAllAriaLabels(startupCtx)
		if err == nil {
			for _, label := range infoLabels {
				found := false
				for _, ml := range mainLabels {
					if ml == label {
						found = true
						break
					}
				}
				if !found {
					mainLabels = append(mainLabels, label)
				}
			}
		}
	}

	startupCancel()

	// Sort labels
	sort.Strings(mainLabels)

	log.Info().Msgf("\n📋 Total unique labels collected: %d", len(mainLabels))
	log.Info().Msg("\n" + strings.Repeat("=", 70))

	// Start interactive learning
	return interactiveLearning(locale, mainLabels)
}

// interactiveLearning guides user through mapping labels
func interactiveLearning(locale string, labels []string) error {
	reader := bufio.NewReader(os.Stdin)

	fmt.Println("\n🎯 Interactive Learning Mode")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Printf("Locale code (e.g., 'pl', 'fr', 'de'): ")
	if locale == "unknown" || locale == "" {
		localeInput, _ := reader.ReadString('\n')
		locale = strings.TrimSpace(localeInput)
	} else {
		fmt.Printf("[detected: %s] ", locale)
		confirmation, _ := reader.ReadString('\n')
		if strings.TrimSpace(confirmation) != "" {
			locale = strings.TrimSpace(confirmation)
		}
	}

	if locale == "" {
		return fmt.Errorf("locale code is required")
	}

	fmt.Println("\n📝 Now I'll show you all collected labels.")
	fmt.Println("For each required field, type the number of the matching label.")
	fmt.Println("If no match exists, press Enter to skip.")
	fmt.Println("")

	// Print all labels with numbers
	fmt.Println("\n📋 Available labels:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	for i, label := range labels {
		fmt.Printf("%3d. %s\n", i+1, label)
	}
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	// Required fields with hints
	requiredFields := []struct {
		name        string
		description string
		matchType   string
		example     string
	}{
		{"SelectAllPhotosLabel", "Button to select all photos from a date (contains date)", "startsWith", "Select all photos from"},
		{"FileNameLabel", "Label for filename in photo info", "startsWith", "Filename:"},
		{"DateLabel", "Label for date in photo info", "startsWith", "Date taken:"},
		{"TimeLabel", "Label for time in photo info", "startsWith", "Time taken:"},
		{"TzLabel", "Timezone label", "startsWith", "GMT"},
		{"ViewPreviousPhotoMatch", "Aria-label for previous photo button", "equals", "View previous photo"},
		{"MoreOptionsLabel", "More options menu button", "equals", "More options"},
		{"DownloadLabel", "Download button (with shortcut)", "equals", "Download - Shift+D"},
		{"DownloadOriginalLabel", "Download original button", "equals", "Download original"},
		{"OpenInfoMatch", "Open info/details panel button", "equals", "Open info"},
		{"VideoStillProcessingDialogLabel", "Dialog shown when video is processing", "startsWith", "Video still is processing"},
	}

	newLocale := GPhotosLocale{
		ShortDayNames:   []string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"},
		LongDayNames:    []string{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"},
		ShortMonthNames: []string{"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
	}

	fmt.Println("\n🔍 Match required fields:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	for _, field := range requiredFields {
		fmt.Printf("\n📌 %s\n", field.name)
		fmt.Printf("   Description: %s\n", field.description)
		fmt.Printf("   Match type: %s\n", field.matchType)
		fmt.Printf("   Example (English): %s\n", field.example)
		fmt.Print("   Enter label number (or press Enter to skip): ")

		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		if input == "" {
			log.Warn().Msgf("Skipped: %s", field.name)
			continue
		}

		var labelNum int
		if _, err := fmt.Sscanf(input, "%d", &labelNum); err != nil || labelNum < 1 || labelNum > len(labels) {
			log.Warn().Msgf("Invalid number, skipped: %s", field.name)
			continue
		}

		selectedLabel := labels[labelNum-1]
		match := NodeLabelMatch{
			MatchType:  field.matchType,
			MatchValue: selectedLabel,
		}

		// Ask if we should trim the label
		if field.matchType == "startsWith" {
			fmt.Printf("   Use full text '%s'? (y/n/edit): ", selectedLabel)
			trimInput, _ := reader.ReadString('\n')
			trimInput = strings.TrimSpace(strings.ToLower(trimInput))

			if trimInput == "n" || trimInput == "edit" {
				fmt.Print("   Enter the text to match (what it starts with): ")
				customText, _ := reader.ReadString('\n')
				match.MatchValue = strings.TrimSpace(customText)
			}
		}

		// Set the field
		switch field.name {
		case "SelectAllPhotosLabel":
			newLocale.SelectAllPhotosLabel = match
		case "FileNameLabel":
			newLocale.FileNameLabel = match
		case "DateLabel":
			newLocale.DateLabel = match
		case "TimeLabel":
			newLocale.TimeLabel = match
		case "TzLabel":
			newLocale.TzLabel = match
		case "ViewPreviousPhotoMatch":
			newLocale.ViewPreviousPhotoMatch = match
		case "MoreOptionsLabel":
			newLocale.MoreOptionsLabel = match
		case "DownloadLabel":
			newLocale.DownloadLabel = match
		case "DownloadOriginalLabel":
			newLocale.DownloadOriginalLabel = match
		case "OpenInfoMatch":
			newLocale.OpenInfoMatch = match
		case "VideoStillProcessingDialogLabel":
			newLocale.VideoStillProcessingDialogLabel = match
		}

		log.Info().Msgf("✓ Matched: %s = %s", field.name, match.MatchValue)
	}

	// Collect simple string fields
	fmt.Println("\n📝 String fields (enter text or press Enter to use default):")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	stringFields := []struct {
		name        string
		defaultVal  string
		description string
	}{
		{"Today", "Today", "Word for 'today'"},
		{"Yesterday", "Yesterday", "Word for 'yesterday'"},
		{"VideoStillProcessingStatusText", "Video is still processing &amp; can be downloaded later", "Status text for processing videos"},
		{"NoWebpageFoundText", "No webpage was found for the web address:", "Error text when page not found"},
		{"NotNow", "Not now", "Text for 'Not now' button"},
	}

	for _, field := range stringFields {
		fmt.Printf("\n%s [default: %s]\n", field.description, field.defaultVal)
		fmt.Print("Enter text: ")
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		if input == "" {
			input = field.defaultVal
		}

		switch field.name {
		case "Today":
			newLocale.Today = input
		case "Yesterday":
			newLocale.Yesterday = input
		case "VideoStillProcessingStatusText":
			newLocale.VideoStillProcessingStatusText = input
		case "NoWebpageFoundText":
			newLocale.NoWebpageFoundText = input
		case "NotNow":
			newLocale.NotNow = input
		}
	}

	// Day and month names
	fmt.Println("\n📅 Day and Month Names:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Print("Enter short day names (Sun,Mon,Tue,Wed,Thu,Fri,Sat): ")
	dayInput, _ := reader.ReadString('\n')
	if strings.TrimSpace(dayInput) != "" {
		days := strings.Split(strings.TrimSpace(dayInput), ",")
		if len(days) == 7 {
			for i := range days {
				days[i] = strings.TrimSpace(days[i])
			}
			newLocale.ShortDayNames = days
		}
	}

	fmt.Print("Enter long day names (Sunday,Monday,...): ")
	longDayInput, _ := reader.ReadString('\n')
	if strings.TrimSpace(longDayInput) != "" {
		days := strings.Split(strings.TrimSpace(longDayInput), ",")
		if len(days) == 7 {
			for i := range days {
				days[i] = strings.TrimSpace(days[i])
			}
			newLocale.LongDayNames = days
		}
	}

	fmt.Print("Enter short month names (Jan,Feb,...Dec): ")
	monthInput, _ := reader.ReadString('\n')
	if strings.TrimSpace(monthInput) != "" {
		months := strings.Split(strings.TrimSpace(monthInput), ",")
		if len(months) == 12 {
			for i := range months {
				months[i] = strings.TrimSpace(months[i])
			}
			newLocale.ShortMonthNames = months
		}
	}

	// Generate YAML
	fmt.Println("\n💾 Generating YAML...")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	return saveLearnedLocale(locale, newLocale)
}

// saveLearnedLocale saves the learned locale to a YAML file
func saveLearnedLocale(locale string, localeData GPhotosLocale) error {
	outputFile := fmt.Sprintf("locales-%s.yaml", locale)

	data := map[string]GPhotosLocale{
		locale: localeData,
	}

	yamlData, err := yaml.Marshal(data)
	if err != nil {
		return fmt.Errorf("failed to marshal YAML: %w", err)
	}

	if err := os.WriteFile(outputFile, yamlData, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	log.Info().Msgf("✅ Saved locale to: %s", outputFile)
	fmt.Println("\n✨ Success!")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Printf("Locale configuration saved to: %s\n", outputFile)
	fmt.Println("\nTo use this locale:")
	fmt.Println("1. Copy the content to locales.yaml")
	fmt.Println("2. Or set environment variable: export GPHOTOS_LOCALE_FILE=" + outputFile)
	fmt.Println("3. Test with: gphotos-cdp -v -dldir photos")
	fmt.Println("")
	fmt.Println("📝 Generated YAML preview:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Println(string(yamlData))

	return nil
}
