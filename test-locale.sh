#!/bin/bash
# Test locale configuration

set -e

LOCALE_FILE="${1:-locales.yaml}"

if [ ! -f "$LOCALE_FILE" ]; then
    echo "❌ Error: File not found: $LOCALE_FILE"
    echo "Usage: $0 [locale-file.yaml]"
    exit 1
fi

echo "🔍 Testing locale file: $LOCALE_FILE"
echo ""

# Parse YAML to get locale codes
echo "📋 Locales found in file:"
grep -E '^[a-z]{2}:' "$LOCALE_FILE" | sed 's/:$//' | while read -r locale; do
    echo "  - $locale"
done

echo ""
echo "🧪 Validating YAML syntax..."

# Check YAML syntax (requires python3 or yq)
if command -v python3 &> /dev/null; then
    python3 << 'EOF'
import sys
import yaml

try:
    with open(sys.argv[1], 'r') as f:
        data = yaml.safe_load(f)
    print("✅ YAML syntax is valid")
    
    # Check required fields
    required_fields = [
        'selectAllPhotosLabel', 'fileNameLabel', 'dateLabel',
        'timeLabel', 'tzLabel', 'moreOptionsLabel',
        'downloadLabel', 'downloadOriginalLabel'
    ]
    
    for locale_code, locale_data in data.items():
        print(f"\n🔎 Checking locale: {locale_code}")
        missing = []
        for field in required_fields:
            if field not in locale_data:
                missing.append(field)
        
        if missing:
            print(f"⚠️  Missing fields: {', '.join(missing)}")
        else:
            print("✅ All required fields present")
            
        # Check field structure
        for field in ['selectAllPhotosLabel', 'fileNameLabel', 'dateLabel']:
            if field in locale_data:
                if 'matchType' not in locale_data[field]:
                    print(f"⚠️  {field} missing 'matchType'")
                if 'matchValue' not in locale_data[field]:
                    print(f"⚠️  {field} missing 'matchValue'")
        
except yaml.YAMLError as e:
    print(f"❌ YAML syntax error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
EOF
"$LOCALE_FILE"
else
    echo "⚠️  Python3 not found, skipping detailed validation"
    echo "   (Validation will happen when running the tool)"
fi

echo ""
echo "📝 Quick test commands:"
echo ""
echo "  # Test with this locale file:"
echo "  export GPHOTOS_LOCALE_FILE=$LOCALE_FILE"
echo "  gphotos-cdp -v -dev -dldir photos"
echo ""
echo "  # Or copy to main locale file:"
echo "  cp $LOCALE_FILE locales.yaml"
echo "  gphotos-cdp -v -dev -dldir photos"
echo ""
echo "  # With Docker:"
echo "  docker-compose run --rm \\"
echo "    -v \$(pwd)/$LOCALE_FILE:/usr/local/bin/locales.yaml:ro \\"
echo "    gphotos-cdp gphotos-cdp -v -profile /data/profile -dldir /data/photos"
echo ""
