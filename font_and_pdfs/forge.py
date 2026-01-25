import fontforge
import re
import sys
import os

# Track metrics
all_widths = []
all_heights = []
glyph_data = {}

# First pass: analyze all SVGs
print("Analyzing SVGs...")
for i in range(ord('a'), ord('z') + 1):
    letter = chr(i)
    svg_file = f"letters/{letter}.svg"
    
    if not os.path.exists(svg_file):
        print(f"Warning: {svg_file} not found", file=sys.stderr)
        continue
    
    try:
        with open(svg_file, 'r') as f:
            content = f.read()
    except:
        print(f"Warning: Could not read {svg_file}", file=sys.stderr)
        continue
    
    # Get viewBox
    viewbox_match = re.search(r'viewBox="([^"]+)"', content)
    if not viewbox_match:
        print(f"Warning: No viewBox in {svg_file}", file=sys.stderr)
        continue
    
    vx, vy, vw, vh = map(float, viewbox_match.group(1).split())
    vx = int(vx)
    vy = int(vy)
    vw = int(vw)
    vh = int(vh)
    
    glyph_data[letter] = {
        'vw': vw,
        'vh': vh,
        'file': svg_file
    }
    
    all_widths.append(vw)
    all_heights.append(vh)
    print(f"  '{letter}': {vw}×{vh} units")

if not glyph_data:
    print("Error: No valid SVG files found!", file=sys.stderr)
    sys.exit(1)

# Set font metrics based on your SVG units
# Use the max height as em size (or any value you prefer)
max_height = max(all_heights)
max_width = max(all_widths)

# Option 1: Use max height as em size
# font_em = max_height

# Option 2: Use a round number that fits everything
font_em = int(max_height * 1.2)  # Add 20% padding

# Option 3: Fixed em size (like 1000) but DON'T scale - just adjust metrics
# font_em = 1000

print(f"\nFont metrics:")
print(f"  Max SVG width: {max_width}")
print(f"  Max SVG height: {max_height}")
print(f"  Setting font.em to: {font_em}")

# Create font
font = fontforge.font()
font.fontname = "MyFont"
font.familyname = "My Font"
font.fullname = "My Font Regular"
font.em = font_em  # This is in SVG units!

# Set metrics (in SVG units)
# Ascent = top of tallest glyph to baseline
# Descent = baseline to bottom of lowest glyph
ascent = int(max_height * 0.5)
descent = int(max_height * 0.5)

# Or if you know your SVGs have consistent baseline:
# ascent = 800  # in SVG units
# descent = 200  # in SVG units

font.ascent = ascent
font.descent = descent

# Set OS/2 metrics (important for proper display)
font.os2_winascent = ascent
font.os2_windescent = descent
font.hhea_ascent = ascent
font.hhea_descent = -descent

print(f"  Ascent: {ascent}, Descent: {descent}")

# Create glyphs WITHOUT scaling
print("\nCreating glyphs...")
for letter, data in glyph_data.items():
    svg_file = data['file']
    vw = data['vw']
    
    # Create glyph
    glyph = font.createChar(ord(letter), letter)
    
    # Import SVG - NO SCALING!
    glyph.importOutlines(svg_file)
    
    # Optional cleanup
    # glyph.removeOverlap()
    # glyph.simplify(0.3)
    
    # Set width to actual SVG width
    glyph.width = vw * 1  # This is in SVG units!
    
    print(f"  '{letter}': width={vw}")

# Add space character (use average width)
avg_width = sum(all_widths) / len(all_widths) if all_widths else 500
space = font.createChar(ord(' '), "space")
space.width = int(avg_width)

print(f"\nSpace width: {space.width}")

# Generate font
font.generate("otf.otf")
# font.generate("output.ttf")
print("\nDone! Generated output.otf and output.ttf")
print("All glyphs use their original SVG sizes.")
