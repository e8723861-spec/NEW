# Hybrid DCA + Infinity Grid Trading Bot

A sophisticated cryptocurrency trading bot that combines Dollar-Cost Averaging (DCA) with dynamic grid trading, featuring comprehensive risk management and paper trading capabilities.

## Features

✅ **Hybrid Strategy**

- DCA buying at configurable price levels (e.g., -5%, -10%, -15%, -20%)
- Dynamic grid trading (buy/sell at multiple price levels)
- Staged position sizing with multipliers

✅ **Risk Management**

- Position tracking with cost basis and PnL calculations
- Drawdown protection (stops if losses exceed threshold)
- Daily trade limits
- Profit-taking on gains
- Lower price floor to prevent over-averaging

✅ **Safety & Testing**

- **Paper trading mode** - Simulate trading without risking real capital
- Comprehensive error handling and recovery
- Persistent state files for configuration restoration
- Graceful shutdown logic

✅ **Monitoring & Audit Trail**

- Detailed logging to both console and rotating log files
- Audit trail for all significant events
- Position tracking with entry/exit prices
- Real-time drawdown monitoring

✅ **Secret Management**

- Environment variable support for API keys
- Never hardcode credentials
- Support for multiple trading accounts via .env files

## Installation

### Prerequisites

- Python 3.8+
- pip (Python package manager)

### Setup Steps

1. **Clone/Extract the project**

```bash
cd /workspaces/NEW
```

1. **Install dependencies**

```bash
pip install websocket-client
```

1. **Configure environment variables**

```bash
# Copy example config
cp .env.example .env

# Edit .env with your settings
nano .env  # or use your editor
```

1. **Set API credentials (for live trading only)**

```bash
# In .env file, set:
CRYPTO_API_KEY=your_key_here
CRYPTO_API_SECRET=your_secret_here
PAPER_TRADING=false  # Only when ready for live trading!
```

## Quick Start

### Paper Trading (Safe Testing)

```bash
# Ensure PAPER_TRADING=true in .env
export PAPER_TRADING=true
python hybrid_dca_grid.py
```

Expected output:

```text
2026-04-12 10:30:45 | HybridDCAInfinityGrid | INFO     | ✅ PAPER TRADING MODE ENABLED - Starting balance: $10000
2026-04-12 10:30:45 | HybridDCAInfinityGrid | INFO     | Initial price: $45000.0000
```

### Live Trading (Use with Caution)

```bash
# Only after thorough testing with paper trading!
export PAPER_TRADING=false
export CRYPTO_API_KEY=your_real_key
export CRYPTO_API_SECRET=your_real_secret
python hybrid_dca_grid.py
```

## Configuration

### Default Settings (in `hybrid_dca_grid.py`)

| Setting | Value | Description |
| --- | --- | --- |
| `target_usd_pct` | 0.08 | % of account to allocate to strategy |
| `base_grid_spacing_pct` | 0.9 | Grid spacing as % of current price |
| `num_grids` | 10 | Number of buy/sell grid levels |
| `profit_release_threshold_pct` | 4.0 | Trigger profit-taking at this gain % |
| `profit_release_pct` | 0.30 | Take 30% of position at profit target |
| `max_drawdown_pct` | 20.0 | Stop if drawdown exceeds this |
| `lower_floor_pct` | 0.78 | Don't buy below 78% of peak price |
| `max_daily_trades` | 15 | Maximum trades per 24 hours |

### DCA Levels (configurable)

```python
DCA_LEVELS = [-5, -10, -15, -20]  # Buy at 5%, 10%, 15%, 20% drops
DCA_MULTIPLIER = 1.5  # Each level buys 1.5x more than previous
```

## Usage

### Starting the Bot

```bash
python hybrid_dca_grid.py
```

### Monitoring Logs

**Real-time console output:**

```bash
tail -f hybrid_dca_grid_BTC.log
```

**Audit trail (significant events):**

```bash
tail -f audit_trail_BTC.log
```

### Stopping the Bot Gracefully

Press `Ctrl+C` to initiate graceful shutdown:

- Closes all active orders
- Saves state to disk
- Logs final statistics

## Output Files

```text
hybrid_dca_grid_BTC.log     # Main bot log (all activity)
audit_trail_BTC.log          # Important events and errors
hybrid_state_BTC.json        # Bot state (positions, DCA stages)
position_tracker_BTC.json    # Detailed position tracking
```

## Architecture

### Core Components

1. **CryptoAPITrading** (`your_powertrader_file.py`)
   - API client for trading operations
   - Simulates trading in paper mode
   - Handles order placement and cancellation

2. **PositionTracker**
   - Tracks all open positions
   - Calculates cost basis and unrealized PnL
   - Maintains trade history

3. **HybridDCAInfinityGrid**
   - Main bot logic
   - Coordinate strategies (DCA + Grid)
   - Risk management layer
   - Monitoring loop

### Key Methods

| Method | Purpose |
| --- | --- |
| `start()` | Initialize and start the bot |
| `_monitor_loop()` | Main async loop (checks signals, prices, DCA, profit-taking) |
| `_handle_dca()` | Execute DCA buys at configured levels |
| `_check_profit_release()` | Sell positions when profit target reached |
| `_check_drawdown()` | Calculate drawdown from peak |
| `_place_grid_orders()` | Place buy/sell grid orders |
| `stop()` | Graceful shutdown |

## Risk Management

### Drawdown Protection

- Continuously monitors peak price
- Calculates current drawdown percentage
- **Automatically stops bot if drawdown > threshold**

### Position Size Limits

- `target_usd_pct`: Limits capital per symbol
- `num_grids`: Spreads risk across grid levels
- `max_daily_trades`: Prevents overtrading

### DCA Safeguards

- `max_dca_buys_per_24h`: Limits pyramiding frequency
- `lower_floor_pct`: Prevents average-down at unsustainable prices
- `dca_levels`: Discrete levels prevent continuous buying

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'your_powertrader_file'"

**Solution:** Ensure `your_powertrader_file.py` exists in the same directory

```bash
ls -la *.py  # Check files exist
```

### Issue: "No price data available"

**Solution:** Check API connectivity and exchange is responding

- Verify internet connection
- Check API rate limits not exceeded
- Ensure trading pair exists

### Issue: "No buying power"

**Solution:** In paper trading, check initial balance is set

- In production, ensure account has funds
- Check API key permissions include trading

### Issue: Bot keeps stopping

**Solution:** Check logs for reason

```bash
tail -50 hybrid_dca_grid_BTC.log
tail -20 audit_trail_BTC.log
```

## Testing Checklist

- [ ] Paper trading test (1+ hour)
- [ ] Check logs for errors
- [ ] Verify grid orders place correctly
- [ ] Verify position tracking accurate
- [ ] Test bot restart (state recovery)
- [ ] Test Ctrl+C shutdown
- [ ] Review position_tracker_BTC.json
- [ ] Verify profit-taking calculations
- [ ] Test drawdown protection

## Advanced Configuration

### Custom Settings File

```bash
# Create gui_settings.json
cat > gui_settings.json << 'EOF'
{
  "trade_start_level": 10,
  "start_allocation_pct": 0.25,
  "dca_multiplier": 2.0,
  "dca_levels": [-3, -8, -15],
  "max_dca_buys_per_24h": 8
}
EOF

# Point to it
export SETTINGS_FILE=gui_settings.json
```

### Change Trading Pair

```bash
export TRADING_SYMBOL=ETH-USD
python hybrid_dca_grid.py
```

## ⚠️ Important Warnings

**NEVER:**

- Commit `.env` file with real API keys to version control
- Run live trading without extensive paper trading first
- Use funds you can't afford to lose
- Share API credentials with anyone

**ALWAYS:**

- Start with paper trading
- Test thoroughly before going live
- Monitor the bot regularly
- Have a manual stop plan
- Keep API keys in environment variables only

## Performance Notes

- Paper trading uses simulated prices from stub API
- Grid orders place instantly in paper mode
- Loop cycle: 30 seconds (configurable)
- State saved every 5 minutes
- Daily reset in UTC time

## Future Enhancements

- [ ] WebSocket real-time price updates
- [ ] Multiple symbol support
- [ ] Backtesting framework
- [ ] Performance analytics dashboard
- [ ] Dynamic grid adjustment based on volatility
- [ ] SMS/Email alerts on profit release
- [ ] Database persistence instead of JSON files

## Support & Issues

For issues:

1. Check logs: `tail -f hybrid_dca_grid_BTC.log`
2. Enable debug logging: Set `logging.DEBUG`
3. Review state files: `cat hybrid_state_BTC.json`
4. Check position tracker: `cat position_tracker_BTC.json`

## License

This software is provided for educational and trading purposes. Use at your own risk.

---

**Last Updated:** April 2026
