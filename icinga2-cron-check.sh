#!/bin/bash

# Icinga2 API Zugangsdaten
USER="api-user"
PASS="api-pass"

# Mail Contact
MY_MAIL="user@example.org"

# Hostnamen oder IPs der Icinga2 Master
MASTERS=("icinga-master1.local" "icinga-master2.local")

# API-Endpunkt (Service Health als Beispiel)
ENDPOINT="/v1/status"

# Optional: Logfile
LOGFILE="/var/log/icinga_master_check.log"

# Aktuelles Datum
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting Icinga2 master check..." >> "$LOGFILE"

for HOST in "${MASTERS[@]}"; do
    echo "[$DATE] Checking $HOST..." >> "$LOGFILE"

    RESPONSE=$(curl -s -k -u "$USER:$PASS" "https://$HOST:5665$ENDPOINT")

    if [[ $? -ne 0 ]]; then
        echo "[$DATE] ERROR: Could not connect to $HOST" >> "$LOGFILE"
        continue
    fi

    # Prüfen, ob Icinga korrekt antwortet
    HEALTH=$(echo "$RESPONSE" | jq -r '.icingaapplication.status')

    if [[ "$HEALTH" == "Connected" || "$HEALTH" == "Up" ]]; then
        echo "[$DATE] $HOST is healthy. Status: $HEALTH" >> "$LOGFILE"
    else
        echo "[$DATE] WARNING: $HOST returned status: $HEALTH" >> "$LOGFILE"
    fi
done



