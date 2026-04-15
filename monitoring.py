"""
Monitoring and health check system for production deployment
Tracks bot health, API connectivity, and performance metrics
"""

import os
import json
import time
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

logger = logging.getLogger("Monitoring")

class HealthMonitor:
    """Monitor bot health and performance"""
    
    def __init__(self):
        self.start_time = time.time()
        self.last_check = time.time()
        self.health_status = "INITIALIZING"
        self.metrics = {
            "uptime_seconds": 0,
            "orders_placed": 0,
            "trades_executed": 0,
            "api_calls": 0,
            "websocket_connected": False,
            "last_price_update": None,
            "last_fill_time": None,
            "errors_count": 0,
            "current_profit_loss": 0.0,
        }
        self.health_check_interval = int(os.getenv("HEALTH_CHECK_INTERVAL", 300))
        self.error_threshold = 10  # Alert if errors exceed this
    
    def update_metrics(self, metric_name: str, value: Any):
        """Update a metric"""
        if metric_name in self.metrics:
            self.metrics[metric_name] = value
            logger.debug(f"Metric updated: {metric_name} = {value}")
        else:
            logger.warning(f"Unknown metric: {metric_name}")
    
    def increment_metric(self, metric_name: str, increment: int = 1):
        """Increment a counter metric"""
        if metric_name in self.metrics and isinstance(self.metrics[metric_name], int):
            self.metrics[metric_name] += increment
        else:
            logger.warning(f"Cannot increment metric: {metric_name}")
    
    def check_health(self) -> Dict[str, Any]:
        """Perform health check"""
        now = time.time()
        self.metrics["uptime_seconds"] = int(now - self.start_time)
        
        # Determine health status
        if self.metrics["errors_count"] > self.error_threshold:
            self.health_status = "DEGRADED"
        elif not self.metrics["websocket_connected"]:
            self.health_status = "WARNING"
        else:
            self.health_status = "HEALTHY"
        
        health_data = {
            "status": self.health_status,
            "timestamp": datetime.utcnow().isoformat(),
            **self.metrics
        }
        
        self._log_health_status(health_data)
        
        return health_data
    
    def _log_health_status(self, health_data: Dict[str, Any]):
        """Log health check results"""
        status = health_data["status"]
        icon = "✅" if status == "HEALTHY" else "⚠️" if status == "WARNING" else "🚨"
        
        logger.info(f"{icon} Health Status: {status}")
        logger.info(f"   Uptime: {health_data['uptime_seconds']}s")
        logger.info(f"   Orders: {health_data['orders_placed']} | Trades: {health_data['trades_executed']}")
        logger.info(f"   API Calls: {health_data['api_calls']}")
        logger.info(f"   WebSocket: {'Connected' if health_data['websocket_connected'] else 'Disconnected'}")
        logger.info(f"   Errors: {health_data['errors_count']}")
    
    def save_health_report(self, filename: str = "health_report.json"):
        """Save health report to file"""
        try:
            health_data = self.check_health()
            with open(filename, 'w') as f:
                json.dump(health_data, f, indent=2)
            logger.info(f"✅ Health report saved: {filename}")
        except Exception as e:
            logger.error(f"Failed to save health report: {e}")


class PerformanceMonitor:
    """Monitor trading performance metrics"""
    
    def __init__(self):
        self.trades = []
        self.starting_balance = 0.0
        self.current_balance = 0.0
        self.peak_balance = 0.0
        self.performance_metrics = {
            "total_trades": 0,
            "winning_trades": 0,
            "losing_trades": 0,
            "total_profit_loss": 0.0,
            "win_rate": 0.0,
            "avg_trade_size": 0.0,
            "largest_win": 0.0,
            "largest_loss": 0.0,
        }
    
    def record_trade(self, trade_data: Dict[str, Any]):
        """Record a trade for performance tracking"""
        self.trades.append({
            "timestamp": datetime.utcnow().isoformat(),
            **trade_data
        })
        self._calculate_performance()
    
    def _calculate_performance(self):
        """Calculate performance metrics from trades"""
        if not self.trades:
            return
        
        self.performance_metrics["total_trades"] = len(self.trades)
        
        # Count wins/losses (simplified - would need actual P&L calculation)
        profit_loss_values = [t.get("profit_loss", 0) for t in self.trades]
        winning = sum(1 for v in profit_loss_values if v > 0)
        losing = sum(1 for v in profit_loss_values if v < 0)
        
        self.performance_metrics["winning_trades"] = winning
        self.performance_metrics["losing_trades"] = losing
        self.performance_metrics["total_profit_loss"] = sum(profit_loss_values)
        
        if self.trades:
            self.performance_metrics["win_rate"] = (winning / len(self.trades)) * 100 if len(self.trades) > 0 else 0.0
            self.performance_metrics["avg_trade_size"] = sum(t.get("qty", 0) for t in self.trades) / len(self.trades)
        
        if profit_loss_values:
            self.performance_metrics["largest_win"] = max(profit_loss_values)
            self.performance_metrics["largest_loss"] = min(profit_loss_values)
    
    def get_performance_report(self) -> Dict[str, Any]:
        """Get performance report"""
        self._calculate_performance()
        return {
            "report_time": datetime.utcnow().isoformat(),
            "total_trades": len(self.trades),
            **self.performance_metrics
        }
    
    def save_performance_report(self, filename: str = "performance_report.json"):
        """Save performance report to file"""
        try:
            report = self.get_performance_report()
            with open(filename, 'w') as f:
                json.dump(report, f, indent=2)
            logger.info(f"✅ Performance report saved: {filename}")
        except Exception as e:
            logger.error(f"Failed to save performance report: {e}")


# Singleton instances
_health_monitor = None
_performance_monitor = None

def get_health_monitor() -> HealthMonitor:
    """Get or create health monitor"""
    global _health_monitor
    if _health_monitor is None:
        _health_monitor = HealthMonitor()
    return _health_monitor

def get_performance_monitor() -> PerformanceMonitor:
    """Get or create performance monitor"""
    global _performance_monitor
    if _performance_monitor is None:
        _performance_monitor = PerformanceMonitor()
    return _performance_monitor
