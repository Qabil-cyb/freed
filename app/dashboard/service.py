"""Dashboard service for system statistics using psutil."""
import psutil
import time
from datetime import datetime


def get_system_stats():
    """Get system statistics."""
    cpu_percent = psutil.cpu_percent(interval=0.5)
    cpu_count = psutil.cpu_count()

    ram = psutil.virtual_memory()
    ram_total = ram.total
    ram_used = ram.used
    ram_percent = ram.percent

    disk = psutil.disk_usage("/")
    disk_total = disk.total
    disk_used = disk.used
    disk_percent = disk.percent

    net = psutil.net_io_counters()
    net_sent = net.bytes_sent
    net_recv = net.bytes_recv

    load_avg = [round(x, 2) for x in psutil.getloadavg()]
    uptime = int(time.time() - psutil.boot_time())

    return {
        "cpu_percent": cpu_percent,
        "cpu_count": cpu_count,
        "ram_total": ram_total,
        "ram_used": ram_used,
        "ram_percent": ram_percent,
        "disk_total": disk_total,
        "disk_used": disk_used,
        "disk_percent": disk_percent,
        "net_sent": net_sent,
        "net_recv": net_recv,
        "load_avg": load_avg,
        "uptime": uptime,
    }
