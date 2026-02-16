#!/bin/bash
# Example: Creating Polish locale using Learning Mode

set -e

echo "🇵🇱 Creating Polish locale for gphotos-cdp"
echo "=========================================="
echo ""

# Step 1: Instructions
echo "📝 Step 1: Change Google Account Language"
echo "1. Go to: https://myaccount.google.com/language"
echo "2. Click 'Edit' (pencil icon)"
echo "3. Select 'Polski' (Polish)"
echo "4. Click 'Select'"
echo "5. Wait a moment for it to apply"
echo ""
read -p "Press Enter when done..."

# Step 2: Run learning mode
echo ""
echo "🎓 Step 2: Starting Learning Mode"
echo ""

if command -v docker-compose &> /dev/null; then
    echo "Using Docker..."
    docker-compose build
    docker-compose run --rm -it gphotos-cdp \
        gphotos-cdp -learn -profile /data/profile -dldir /data/photos
else
    echo "Using native binary..."
    go run . -learn -dev -dldir photos
fi

# Step 3: Instructions for testing
echo ""
echo "✅ Learning Mode Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Copy generated locale to main file:"
echo "   cat locales-pl.yaml >> locales.yaml"
echo ""
echo "2. Test it:"
echo "   make up"
echo "   make logs"
echo ""
echo "3. Check for locale detection:"
echo "   # Should see: 'using locale pl'"
echo ""
echo "4. (Optional) Submit as PR to help others!"
echo "   See CONTRIBUTING.md"
echo ""
