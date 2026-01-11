#!/bin/bash
# Test script to verify icon rendering

echo "========================================"
echo "Icon Rendering Test"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Nerd Font Installation
echo "1. Checking Nerd Font installation..."
if fc-list | grep -qi "nerd"; then
    echo -e "${GREEN}✓ Nerd Fonts found${NC}"
    fc-list | grep -i "nerd" | head -3
else
    echo -e "${RED}✗ No Nerd Fonts found${NC}"
    echo "  Install from: https://www.nerdfonts.com/"
fi
echo ""

# Test 2: Terminal Icon Test
echo "2. Terminal icon rendering test:"
echo "   If you see icons below, your terminal is configured correctly."
echo "   If you see boxes [], your terminal needs a Nerd Font."
echo ""
echo "   Folder icons:     "
echo "   File icons:      󰈙 "
echo "   Git icons:   ✚  ✖  󰁕 "
echo "   Language icons:       "
echo ""

# Test 3: UTF-8 Support
echo "3. Checking UTF-8 support..."
if [[ "$LANG" == *"UTF-8"* ]] || [[ "$LANG" == *"utf8"* ]]; then
    echo -e "${GREEN}✓ UTF-8 locale detected: $LANG${NC}"
else
    echo -e "${YELLOW}⚠ UTF-8 locale not detected: $LANG${NC}"
    echo "  Consider setting: export LANG=en_US.UTF-8"
fi
echo ""

# Test 4: Terminal Type
echo "4. Checking terminal type..."
echo "   TERM: $TERM"
if [[ "$TERM" == *"256color"* ]]; then
    echo -e "${GREEN}✓ 256 color support detected${NC}"
else
    echo -e "${YELLOW}⚠ No 256 color support${NC}"
fi
echo ""

# Test 5: Tmux Check
echo "5. Checking tmux configuration..."
if [ -f ~/.tmux.conf ]; then
    echo -e "${GREEN}✓ tmux.conf found${NC}"
    if grep -q "utf8" ~/.tmux.conf; then
        echo -e "${GREEN}✓ UTF-8 support configured in tmux${NC}"
    else
        echo -e "${YELLOW}⚠ UTF-8 not explicitly configured in tmux${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No tmux.conf found${NC}"
fi
echo ""

# Test 6: Nvim Config Check
echo "6. Checking nvim configuration..."
if [ -f ~/.config/nvim/lua/config/options.lua ]; then
    echo -e "${GREEN}✓ nvim options.lua found${NC}"
    if grep -q "have_nerd_font" ~/.config/nvim/lua/config/options.lua; then
        echo -e "${GREEN}✓ Nerd Font enabled in nvim config${NC}"
    else
        echo -e "${YELLOW}⚠ Nerd Font not explicitly enabled${NC}"
    fi
else
    echo -e "${RED}✗ nvim options.lua not found${NC}"
fi

if [ -f ~/.config/nvim/lua/plugins/neo-tree.lua ]; then
    echo -e "${GREEN}✓ neo-tree.lua found${NC}"
else
    echo -e "${YELLOW}⚠ neo-tree.lua not found${NC}"
fi
echo ""

echo "========================================"
echo "Next Steps:"
echo "========================================"
echo "1. If terminal icons don't display correctly:"
echo "   → Configure your terminal to use 'JetBrainsMono Nerd Font'"
echo ""
echo "2. If in tmux:"
echo "   → Run: tmux kill-server (or tmux source ~/.tmux.conf)"
echo "   → Start new tmux session"
echo ""
echo "3. Test in nvim:"
echo "   → nvim"
echo "   → :Neotree toggle"
echo "   → Expand folders to see icons"
echo ""
echo "4. For detailed troubleshooting:"
echo "   → Read: ~/.config/nvim/ICON-FIX.md"
echo ""
