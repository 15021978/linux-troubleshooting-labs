
```bash
#!/bin/bash
set -euo pipefail

SERVICE="${1:-myapp.service}"

echo "Checking status for service: ${SERVICE}"
systemctl status "${SERVICE}" --no-pager || true

echo
echo "Recent logs:"
journalctl -u "${SERVICE}" -n 30 --no-pager || true
```
