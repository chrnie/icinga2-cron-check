#!/bin/bash

# Icinga2 API Zugangsdaten
USER="api-user"
PASS="api-pass"

# Hostnamen oder IPs der Icinga2 Master
MASTERS=("master1.local" "master2.local")

# API-Endpunkt
ENDPOINT="/v1/status"

# Logfile
LOGFILE="/var/log/icinga_master_check.log"

# E-Mail-Empfänger
MAILTO="recipient@example.com"
MAILFROM="icinga2i@example.com"

# Aktuelles Datum
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Zähler für erreichbare Master
reachable=0
unreachable_hosts=()

echo "[$DATE] Starting Icinga2 master check..." >> "$LOGFILE"

for HOST in "${MASTERS[@]}"; do
    echo "[$DATE] Checking $HOST..." >> "$LOGFILE"

    RESPONSE=$(curl -s -k -u "$USER:$PASS" "https://$HOST:5665$ENDPOINT")

    if [[ $? -ne 0 || -z "$RESPONSE" ]]; then
        echo "[$DATE] ERROR: Could not connect to $HOST" >> "$LOGFILE"
        unreachable_hosts+=("$HOST")
        continue
    fi
    HEALTH=$(echo "$RESPONSE" | jq 'tostring | contains("ApiListener")')
    if [[ "$HEALTH" == "true" ]]; then
        echo "[$DATE] $HOST is healthy. Status: Up" >> "$LOGFILE"
        ((reachable++))
    else
        echo "[$DATE] WARNING: $HOST returned unhealthy status: $HEALTH" >> "$LOGFILE"
        unreachable_hosts+=("$HOST")
    fi
done

# Ergebnis prüfen und ggf. E-Mail senden
if [[ $reachable -eq 0 ]]; then
    SUBJECT="CRITICAL: Beide Icinga2 Master nicht erreichbar"
    BODY="[$DATE] Kritischer Fehler: Keiner der Icinga2 Master (${MASTERS[*]}) ist erreichbar."
    echo "$BODY" | mail -s "$SUBJECT" -r "$MAILFROM" "$MAILTO"
    echo "[$DATE] CRITICAL alert sent to $MAILTO" >> "$LOGFILE"
elif [[ $reachable -eq 1 ]]; then
    SUBJECT="WARNING: Ein Icinga2 Master nicht erreichbar"
    BODY="[$DATE] Warnung: Folgende(r) Master ist/sind nicht erreichbar: ${unreachable_hosts[*]}"
    echo "$BODY" | mail -s "$SUBJECT" -r "$MAILFROM" "$MAILTO"
    echo "[$DATE] WARNING alert sent to $MAILTO" >> "$LOGFILE"
else
    echo "[$DATE] OK: Beide Icinga2 Master erreichbar." >> "$LOGFILE"
fi

