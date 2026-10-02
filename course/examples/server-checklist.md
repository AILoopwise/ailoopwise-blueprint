# Server-Checkliste (Folge 3, optional)

**Deutsch** · [English](#english)

Zum Abhaken, in dieser Reihenfolge. Die Befehle und Begründungen stehen in `../03-server-optional.md`.

**Vor dem Bestellen**
- [ ] SSH-Schlüssel auf dem Laptop erzeugt (`ssh-keygen -t ed25519`), öffentlichen Teil (`.pub`) bereit
- [ ] Server gewählt: Ubuntu, mindestens 4 GB RAM (Mindestanforderung von Claude Code)
- [ ] Öffentlichen Schlüssel beim Bestellen hinterlegt (Hetzner: nur beim Anlegen möglich; Hostinger: auch später unter Settings → SSH keys)

**Zugang absichern**
- [ ] Tailscale auf Server, Laptop und Handy, alle mit demselben Konto
- [ ] Login über die Tailscale-Adresse (100.x.y.z) klappt
- [ ] ufw: `allow in on tailscale0`, eingehend alles andere gesperrt, aktiviert
- [ ] Test: SSH auf die öffentliche IP läuft ins Timeout, SSH auf die Tailscale-Adresse klappt
- [ ] Schlüsselablauf für diesen Server in der Tailscale-Konsole bedacht (abschalten oder wissen, wie du wieder reinkommst)

**Container**
- [ ] Docker nach der offiziellen Anleitung installiert
- [ ] Container `claude-box` läuft als Nutzer `node`, ohne veröffentlichte Ports (`-p`)
- [ ] Kein API-Schlüssel im Image, keine `~/.ssh` oder Cloud-Zugangsdaten gemountet
- [ ] `jq` im Container installiert (die Blueprint-Hooks brauchen es)
- [ ] Claude Code im Container installiert, `claude --version` zeigt eine Version, Login mit claude.ai-Konto

**Mobil arbeiten**
- [ ] Termius: eigener Schlüssel erzeugt und auf den Server exportiert, Host mit Tailscale-Adresse angelegt
- [ ] `tmux new -As claude` auf dem Server, darin `claude` im Projektordner, Vertrauensdialog bestätigt
- [ ] `/remote-control` aktiv, Sitzung in der Claude-App unter **Code** sichtbar
- [ ] Getrennt mit `Ctrl+b` dann `d`, später mit `tmux attach -t claude` zurück

**Dauerhaft (die Wand aus dem Video)**
- [ ] Updates: Server und Container regelmäßig aktualisieren
- [ ] Backups: Projekte liegen in einem privaten Git-Repo (Folge 4); Server-Backup beim Anbieter bewusst an- oder abgewählt
- [ ] Zugriffsrechte: Tailscale-Geräteliste ab und zu prüfen, alte Geräte entfernen

---

## English

To tick off, in this order. Commands and reasons are in `../03-server-optional.md`.

**Before ordering**
- [ ] SSH key created on the laptop (`ssh-keygen -t ed25519`), public part (`.pub`) ready
- [ ] Server chosen: Ubuntu, at least 4 GB RAM (the Claude Code minimum)
- [ ] Public key added while ordering (Hetzner: only at creation; Hostinger: also later under Settings → SSH keys)

**Lock down access**
- [ ] Tailscale on server, laptop and phone, all on the same account
- [ ] Login via the Tailscale address (100.x.y.z) works
- [ ] ufw: `allow in on tailscale0`, all other incoming blocked, enabled
- [ ] Test: SSH to the public IP times out, SSH to the Tailscale address works
- [ ] Key expiry for this server handled in the Tailscale console (disable it, or know how you get back in)

**Container**
- [ ] Docker installed from the official guide
- [ ] Container `claude-box` runs as user `node`, with no published ports (`-p`)
- [ ] No API key in the image, no `~/.ssh` or cloud credentials mounted
- [ ] `jq` installed in the container (the blueprint hooks need it)
- [ ] Claude Code installed in the container, `claude --version` prints a version, logged in with a claude.ai account

**Working from the phone**
- [ ] Termius: own key generated and exported to the server, host added with the Tailscale address
- [ ] `tmux new -As claude` on the server, `claude` running inside it in the project folder, trust dialog accepted
- [ ] `/remote-control` on, session visible in the Claude app under **Code**
- [ ] Detached with `Ctrl+b` then `d`, back later with `tmux attach -t claude`

**Ongoing (the wall from the video)**
- [ ] Updates: update server and container regularly
- [ ] Backups: projects live in a private Git repo (episode 4); provider backup switched on or off on purpose
- [ ] Access: review the Tailscale device list now and then, remove old devices
