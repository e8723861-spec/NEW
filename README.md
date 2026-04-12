# Hybrid DCA + Infinity Grid Trading Bot

A production-ready cryptocurrency trading bot combining Dollar-Cost Averaging with dynamic grid trading.

## Quick Start

### Paper Trading (Safe Testing)

```bash
export PAPER_TRADING=true
python hybrid_dca_grid.py
```

### Setup

1. Install: `pip install websocket-client`
2. Configure: Copy `.env.example` to `.env`
3. Read: [SETUP_GUIDE.md](SETUP_GUIDE.md) for full instructions

## Features

- ✅ **Hybrid Strategy** - DCA + Grid Trading
- ✅ **Risk Management** - Drawdown protection, position limits
- ✅ **Paper Trading** - Test without risking capital
- ✅ **Position Tracking** - Cost basis, PnL calculations
- ✅ **Comprehensive Logging** - Audit trail of all actions
- ✅ **Error Recovery** - Graceful shutdown, state persistence
- ✅ **Secrets Management** - Environment variable support

## Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Installation and usage
- [IMPROVEMENTS.md](IMPROVEMENTS.md) - All fixes and enhancements

## Status

- ✅ **Ready for paper trading**
- ⚠️ **Test thoroughly before live trading**

See [IMPROVEMENTS.md](IMPROVEMENTS.md) for complete list of fixes and enhancements made.
