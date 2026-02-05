#!/bin/bash

# Link Validation Script for Markdown Files

echo "🔍 Validating internal links in markdown files..."
echo ""

ERRORS=0
BASE_DIR="."

# Find all markdown files
MD_FILES=$(find "$BASE_DIR" -name "*.md" -type f)

for MD_FILE in $MD_FILES; do
    echo "📄 Checking: $MD_FILE"
    
    # Extract all relative links from markdown files
    LINKS=$(grep -oE '\]\([^)]+\)' "$MD_FILE" | sed 's/\](\(.*\))/\1/g' | grep -v '^http' | grep -v '^#')
    
    for LINK in $LINKS; do
        # Remove anchor links
        FILE_PATH=$(echo "$LINK" | sed 's/#.*//')
        
        if [ -n "$FILE_PATH" ]; then
            # Get directory of current markdown file
            MD_DIR=$(dirname "$MD_FILE")
            
            # Resolve the full path
            FULL_PATH="$MD_DIR/$FILE_PATH"
            
            # Normalize path (remove ./ and ../)
            NORMALIZED_PATH=$(cd "$MD_DIR" 2>/dev/null && cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd)/$(basename "$FILE_PATH") 2>/dev/null
            
            # Check if file exists
            if [ ! -f "$FULL_PATH" ] && [ ! -f "$NORMALIZED_PATH" ]; then
                echo "  ❌ BROKEN LINK: $LINK (from $MD_FILE)"
                ((ERRORS++))
            else
                echo "  ✅ $LINK"
            fi
        fi
    done
    echo ""
done

echo ""
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All internal links are valid!"
    exit 0
else
    echo "❌ Found $ERRORS broken link(s)"
    exit 1
fi
