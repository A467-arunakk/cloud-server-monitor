
#!/bin/bash
mkdir -p logs
LOG_FILE="logs/server-report-$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee "$LOG_FILE") 2>&1

echo "========================================"
echo "       LINUX SERVER HEALTH REPORT"
echo "========================================"

echo ""
echo "System Information"
echo "----------------------------------------"

echo "Hostname       : $(hostname)"
echo "OS             : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "Uptime         : $(uptime -p)"

echo ""
echo "Resource Usage"
echo "----------------------------------------"

echo "CPU Load       : $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage   :"
free -h

echo ""
echo "Disk Usage"
echo "----------------------------------------"

df -h /

echo ""
echo "Users Logged In"
echo "----------------------------------------"

who

echo ""
echo "IP Address"
echo "----------------------------------------"

hostname -I

echo ""
echo "Top Processes"
echo "----------------------------------------"

ps aux --sort=-%cpu | head -6


echo ""
echo "Network Information"
echo "----------------------------------------"

echo "Interface      : eth0"
echo "IP Address     : $(hostname -I | awk '{print $1}')"
echo "Gateway        : $(ip route | awk '/default/ {print $3}')"

echo ""
echo "Internet Connectivity"
echo "----------------------------------------"

if ping -c 2 -W 2 8.8.8.8 > /dev/null 2>&1
then
    echo "Internet       : OK"
else
    echo "Internet       : FAILED"
fi

echo ""
echo "DNS Resolution"
echo "----------------------------------------"

if ping -c 2 -W 2 google.com > /dev/null 2>&1
then
    echo "DNS            : OK"
else
    echo "DNS            : FAILED"
fi

echo ""
echo "Service Status"
echo "------------------------------------------"
systemctl --type=service --state=running
echo ""
echo "Health Summary"
echo "----------------------------------------"

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$DISK_USAGE" -lt 80 ]
then
    echo "Disk Health    : HEALTHY"
elif [ "$DISK_USAGE" -lt 90 ]
then
    echo "Disk Health    : WARNING"
else
    echo "Disk Health    : CRITICAL"
fi

echo "Overall Status : MONITORING COMPLETED"
echo "========================================"
echo "          END OF REPORT"
echo "========================================"


