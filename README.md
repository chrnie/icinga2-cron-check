# icinga2-cron-check
external check script for 2 icinga2 masters

# Requires

  - curl
  - jq

# Cron example
```
*/5 * * * * /usr/local/bin/check_icinga_masters.sh
```
