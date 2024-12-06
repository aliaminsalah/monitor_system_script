#!/bin/bash

# ANSI color codes
RED="\033[31m"      # Red color (for warnings)
GREEN="\033[32m"    # Green color (for success)
BLUE="\033[34m"     # Blue color (for headers)
YELLOW="\033[33m"   # Yellow color (for general info)
RESET="\033[0m"     # Reset color to default

# Define log file
LOG_FILE="/home/ali/scripts/task1/monitor_system_script/test.log"

# Add timestamp to the log file at the beginning of the new report
{
  echo -e "====================================================="
  echo -e "        SYSTEM REPORT - $(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "====================================================="
  echo ""
} >> $LOG_FILE

# Disk Usage Check
{
  echo -e "--------------- Disk Usage Check ---------------"
  
  # Define threshold
  THRESHOLD=80
  
  # Extract and check disk usage
  df -h --output=pcent,target | tail -n +2 | awk -v threshold=$THRESHOLD -v logfile="$LOG_FILE" '
  {
    usage = $1; gsub("%", "", usage); # Remove percentage sign
    mount_point = $2;

    if (usage > threshold) {
      printf "Warning: Disk usage for %-15s is at %3d%% (Threshold: %d%%)\n", mount_point, usage, threshold >> logfile;
      # Send email notification if threshold is exceeded
      system("echo \"Warning: Disk usage for " mount_point " is at " usage "%. Please take action.\" | mutt -s \"Disk Usage Alert\" aliaminsalah09@gmail.com");
    } else {
      printf "OK: Disk usage for %-15s is at %3d%% (Threshold: %d%%)\n", mount_point, usage, threshold >> logfile;
    }
  }'
  echo ""
} >> $LOG_FILE

# CPU Usage Check
{
  echo -e "--------------- CPU Usage Check ---------------"
  
  # Get CPU usage
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"% used"}')
  echo "CPU Usage: $cpu_usage"
  echo ""
} >> $LOG_FILE

# Memory Usage Check
{
  echo -e "--------------- Memory Details ---------------"
  
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_free=$(free -m | awk '/Mem:/ {print $4}')
  mem_percentage=$(awk "BEGIN {printf \"%.2f\", ($mem_used / $mem_total) * 100}")

  printf "Total Memory: %10d MB\n" "$mem_total"
  printf "Used Memory:  %10d MB (%.2f%%)\n" "$mem_used" "$mem_percentage"
  printf "Free Memory:  %10d MB\n" "$mem_free"
  echo ""
} >> $LOG_FILE

# Running Processes Check
{
  echo -e "--------------- Running Processes Check ---------------"
  
  # Top 5 processes by CPU usage
  echo "Top 5 Processes by CPU Usage:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | awk '{printf "PID: %-6s PPID: %-6s CMD: %-20s MEM: %-5s CPU: %-5s\n", $1, $2, $3, $4, $5}'
  echo ""

  # Top 5 processes by Memory usage
  echo "Top 5 Processes by Memory Usage:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | awk '{printf "PID: %-6s PPID: %-6s CMD: %-20s MEM: %-5s CPU: %-5s\n", $1, $2, $3, $4, $5}'
  echo ""
} >> $LOG_FILE

# Add a final separator
{
  echo -e "====================================================="
  echo -e "                   END OF REPORT"
  echo -e "====================================================="
} >> $LOG_FILE
