#!/bin/bash

echo "======================================"
echo "📊 REDIS REPLICATION LAG MONITOR"
echo "======================================"

while true; do
    clear
    echo "⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo "--------------------------------------"
    
    # Ambil data
    master_info=$(docker exec -it redis-master redis-cli INFO replication 2>/dev/null)
    replica_info=$(docker exec -it redis-replica redis-cli INFO replication 2>/dev/null)
    
    # Extract values
    master_offset=$(echo "$master_info" | grep master_repl_offset | cut -d: -f2 | tr -d '\r')
    replica_offset=$(echo "$replica_info" | grep slave_repl_offset | cut -d: -f2 | tr -d '\r')
    link_status=$(echo "$replica_info" | grep master_link_status | cut -d: -f2 | tr -d '\r')
    connected_slaves=$(echo "$master_info" | grep connected_slaves | cut -d: -f2 | tr -d '\r')
    
    # Calculate lag
    lag=$((master_offset - replica_offset))
    
    echo "👥 Connected Slaves : $connected_slaves"
    echo "🔗 Link Status      : $link_status"
    echo "📊 Master Offset    : $master_offset"
    echo "📊 Replica Offset   : $replica_offset"
    echo "⚡ Replication Lag  : $lag bytes"
    
    if [ $lag -eq 0 ]; then
        echo "✅ STATUS: Replication synchronized!"
    else
        echo "⚠️  STATUS: Lag detected: $lag bytes"
    fi
    
    echo ""
    echo "🔄 Press Ctrl+C to stop"
    sleep 3
done
