# Serve viewers with a local React from membrane, kept running by lingering (v0.1, 2026-11-06)

saphir: "write it out so I can have it linger on membrane".

This sets up a small static web server on membrane, port 8088. It serves `~/membrane_viewers/www`, including React 18.3.1 and ReactDOM 18.3.1, so React pages work without the internet.

Two systemd **user** services run it, one bound to membrane's LAN address and one to its Tailscale address. Nothing listens on 0.0.0.0.

Membrane already has lingering on for `saphir` (`Linger=yes`; your chat pilot runs this way), so the services start at boot and survive logout. No sudo is needed.

## 1. React files
These are the same files that agora serves now. Each was fetched from both cdnjs and jsdelivr, and the two sources gave identical bytes.

| file | sha256 |
|---|---|
| `react.production.min.js` (10,751 B) | `d949f1c3687aedadcedac85261865f29b17cd273997e7f6b2bfc53b2f9d4c4dd` |
| `react-dom.production.min.js` (131,835 B) | `35f4f974f4b2bcd44da73963347f8952e341f83909e4498227d4e26b98f66f0d` |

On membrane:

```bash
mkdir -p ~/membrane_viewers/www/vendor ~/.config/systemd/user
```

```bash
scp saphir@[ts-redact-5]:agora-viewers/www/vendor/react.production.min.js saphir@[ts-redact-5]:agora-viewers/www/vendor/react-dom.production.min.js ~/membrane_viewers/www/vendor/
```

```bash
cd ~/membrane_viewers/www/vendor && sha256sum *.js | tee SHA256SUMS
```

The two hashes must match the table above.

## 2. The service, a template with one copy per address
Create `~/.config/systemd/user/membrane-viewers@.service` with:

```ini
[Unit]
Description=Static viewer hosting on %i:8088 (membrane_viewers/www; React served locally)
After=network-online.target

[Service]
Type=simple
WorkingDirectory=%h/membrane_viewers/www
ExecStart=/usr/bin/python3 -m http.server 8088 --bind %i --directory %h/membrane_viewers/www
Restart=on-failure
RestartSec=5
Nice=10

[Install]
WantedBy=default.target
```

## 3. Enable and start
Over SSH, set the runtime directory first.

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
```

```bash
systemctl --user daemon-reload
```

```bash
systemctl --user enable --now membrane-viewers@192.168.0.210.service membrane-viewers@[ts-redact-4].service
```

```bash
systemctl --user status membrane-viewers@192.168.0.210.service membrane-viewers@[ts-redact-4].service --no-pager
```

## 4. Check
```bash
ss -ltn | grep ':8088 '
```

From another machine on the LAN or on Tailscale:
```bash
curl -sS -o /dev/null -w "%{http_code}\n" http://[ts-redact-4]:8088/vendor/react-dom.production.min.js
```

The expected result is `200`.

**Addresses:**
- LAN: `http://192.168.0.210:8088/`
- Tailscale: `http://[ts-redact-4]:8088/`

## 5. Pages
Copy verified viewer pages into `~/membrane_viewers/www/`. A page that loads React from `./vendor/` then works from these addresses with no internet. The Mandelbrot orbit viewer v0.1.1, now being built, does this.

## Notes
- **Port check:** port 8088 was free on membrane when I checked.
- **The agora copy:** the copy on agora (`http://192.168.0.225:8088/`, `~/agora-viewers/`) is still running, but it is not persistent there because agora has lingering off. Once membrane is up you can stop it with `pkill -f "http.server 8088"` on agora, or keep both.
- **To remove the membrane copy:** `systemctl --user disable --now membrane-viewers@192.168.0.210.service membrane-viewers@[ts-redact-4].service`, then delete the unit file.
- **Why you run these steps yourself:** the Claude Code auto-mode classifier blocked my attempt to install the service on membrane. If you'd rather I do it, it can be allowed in the session's permission settings.
