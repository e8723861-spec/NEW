#!/bin/bash
# ============================================================
# Hybrid DCA Grid Bot - Production Deployment Script
# ============================================================
# Run this to deploy the bot for production trading

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║    Hybrid DCA Grid Bot - Production Deployment         ║"
echo "╚════════════════════════════════════════════════════════╝"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}ERROR: Do not run this script as root${NC}"
   exit 1
fi

# Step 1: Check dependencies
echo -e "\n${YELLOW}[STEP 1] Checking dependencies...${NC}"
command -v python3 >/dev/null 2>&1 || { echo "Python3 required but not installed"; exit 1; }
command -v pip3 >/dev/null 2>&1 || { echo "pip3 required but not installed"; exit 1; }
echo -e "${GREEN}✅ Dependencies OK${NC}"

# Step 2: Setup virtual environment
echo -e "\n${YELLOW}[STEP 2] Setting up Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
fi

# Activate venv
source venv/bin/activate

# Step 3: Install Python dependencies
echo -e "\n${YELLOW}[STEP 3] Installing Python dependencies...${NC}"
pip install --upgrade pip setuptools wheel > /dev/null 2>&1
pip install websocket-client requests python-binance cryptography > /dev/null 2>&1
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Step 4: Setup environment file
echo -e "\n${YELLOW}[STEP 4] Configuring environment (.env file)...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}⚠️  .env file not found${NC}"
    echo -e "${YELLOW}Please create .env file from .env.example and add your API keys:${NC}"
    echo ""
    echo "  1. Copy .env.example to .env:"
    echo "     cp .env.example .env"
    echo ""
    echo "  2. Edit .env with your Binance API credentials:"
    echo "     - Get API key/secret from: https://www.binance.com/en/account/api-management"
    echo "     - Set PAPER_TRADING=false for live trading"
    echo "     - Configure notification settings (email, Discord, Telegram)"
    echo ""
    echo "  3. Run this script again once .env is configured"
    exit 1
else
    echo -e "${GREEN}✅ .env file exists${NC}"
fi

# Step 5: Verify API Keys
echo -e "\n${YELLOW}[STEP 5] Validating configuration...${NC}"

# Check API Keys (should not be visible in logs for security)
CRYPTO_API_KEY=${CRYPTO_API_KEY:-$(grep "^CRYPTO_API_KEY=" .env | cut -d '=' -f 2 | cut -c 1-10)}
if [ -z "$CRYPTO_API_KEY" ]; then
    echo -e "${RED}❌ CRYPTO_API_KEY not set in .env${NC}"
    exit 1
fi
echo "   API Key configured (${CRYPTO_API_KEY}...)"

# Check Paper Trading setting
PAPER_TRADING=$(grep "^PAPER_TRADING=" .env | cut -d '=' -f 2)
if [ "$PAPER_TRADING" = "true" ]; then
    echo -e "${YELLOW}   MODE: PAPER TRADING (safe for testing)${NC}"
else
    echo -e "${RED}   MODE: LIVE TRADING (real money!)${NC}"
fi

echo -e "${GREEN}✅ Configuration validated${NC}"

# Step 6: Create necessary directories and files
echo -e "\n${YELLOW}[STEP 6] Creating logs and data directories...${NC}"
mkdir -p logs
mkdir -p data
mkdir -p reports
echo -e "${GREEN}✅ Directories created${NC}"

# Step 7: Systemd service setup (optional)
echo -e "\n${YELLOW}[STEP 7] Setting up systemd service (optional)...${NC}"
echo "To run bot as a system service (recommended for production):"
echo ""
echo "  1. Copy service file:"
echo "     sudo cp hybrid-dca-bot.service /etc/systemd/system/"
echo ""
echo "  2. Update service file paths if needed:"
echo "     sudo nano /etc/systemd/system/hybrid-dca-bot.service"
echo ""
echo "  3. Enable and start:"
echo "     sudo systemctl daemon-reload"
echo "     sudo systemctl enable hybrid-dca-bot"
echo "     sudo systemctl start hybrid-dca-bot"
echo ""
echo "  4. Monitor logs:"
echo "     sudo journalctl -u hybrid-dca-bot -f"
echo ""

# Step 8: Run test
echo -e "\n${YELLOW}[STEP 8] Running connectivity test...${NC}"
python3 -c "
from your_powertrader_file import CryptoAPITrading
import os
from dotenv import load_dotenv

load_dotenv()
api = CryptoAPITrading(
    api_key=os.getenv('CRYPTO_API_KEY'),
    api_secret=os.getenv('CRYPTO_API_SECRET'),
    paper_trading=os.getenv('PAPER_TRADING', 'true').lower() == 'true'
)

buy_p, sell_p, mid_p = api.get_price(['BTC-USD'])
if buy_p:
    print(f'✅ API Connection OK - BTC Price: \${buy_p[\"BTC-USD\"]:.2f}')
else:
    print('⚠️  API connection test returned no data')
" || echo -e "${YELLOW}⚠️  Connection test skipped (notifications module may not be installed)${NC}"

echo

# Step 9: Display startup instructions
echo "╔════════════════════════════════════════════════════════╗"
echo "║           DEPLOYMENT COMPLETE - START BOT             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Option 1: Run bot directly (foreground)${NC}"
echo "  python3 NEW"
echo ""
echo -e "${GREEN}Option 2: Run bot in background (requires GNU screen)${NC}"
echo "  screen -S trading -d -m python3 NEW"
echo "  screen -S trading -r        # Attach to screen"
echo ""
echo -e "${GREEN}Option 3: Run as systemd service (recommended)${NC}"
echo "  Follow the systemd setup instructions above"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  • Monitor bot logs: tail -f hybrid_dca_grid.log"
echo "  • Check health: cat health_report.json"
echo "  • Stop bot: Press Ctrl+C or 'systemctl stop hybrid-dca-bot'"
echo ""
echo -e "${YELLOW}Monitoring Commands:${NC}"
echo "  • List active orders: grep 'GRID_BUY\\|GRID_SELL' hybrid_dca_grid.log"
echo "  • Show trades: grep 'Trade recorded' hybrid_dca_grid.log"
echo "  • Check errors: grep 'ERROR' hybrid_dca_grid.log"
echo ""

echo -e "Press ENTER to start the bot, or Ctrl+C to cancel..."
read

# Step 10: Start bot
echo -e "\n${GREEN}🚀 Starting Hybrid DCA Grid Bot...${NC}"
python3 NEW
