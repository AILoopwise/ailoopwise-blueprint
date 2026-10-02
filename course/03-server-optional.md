# Folge 3 · Server (optional)

**Deutsch** · [English](#english) · [Übersicht](README.md) · Zurück: [Folge 2](02-desktop-setup.md) · Weiter: [Folge 4](04-guardrails.md)

**In dieser Folge (≈ 90 Min. zum Umsetzen):**

- Einen eigenen Server, nur über dein privates Tailscale-Netz erreichbar.
- Claude Code in einem abgeschotteten Container, ohne offene Ports.
- Eine Session, die weiterläuft, gesteuert von deinem Handy.

**Diese Folge ist ein Extra.** Ist sie dir zu technisch, überspring sie. Die Folgen 4 bis 6 brauchen keinen Server.

Du mietest einen kleinen virtuellen Server (Hetzner oder Hostinger) und lässt Claude Code dort in einem abgeschotteten Docker-Container laufen. Tailscale macht den Server von außen unsichtbar. Auf dem Handy öffnest du Termius, hängst dich an eine tmux-Session, damit nichts abreißt, und mit `/remote-control` steuerst du die Session auch aus der Claude-App. Der Laptop kann zu bleiben.

Die Wand: Ein Server heißt auch Updates, Backups und Zugriffsrechte, dauerhaft, nicht einmalig.

## Was du am Ende hast

- Einen Server, der nur über dein privates Tailscale-Netz per SSH erreichbar ist.
- Claude Code in einem Container, als normaler Nutzer, ohne offene Ports.
- Eine tmux-Session, an die du dich vom Handy hängst, und eine Remote-Control-Sitzung in der Claude-App.

## Was du brauchst

- **Einen VPS** mit Ubuntu und mindestens 4 GB RAM (Mindestanforderung von Claude Code): Hetzner Cloud https://www.hetzner.com/cloud oder Hostinger VPS https://www.hostinger.com/vps-hosting
- **Tailscale** auf Laptop und Handy: https://tailscale.com/download · auf dem Server: https://tailscale.com/kb/1031/install-linux
- **Termius** auf dem Handy: https://termius.com
- **Docker Engine** für Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- **tmux**: https://github.com/tmux/tmux/wiki/Getting-Started
- **Die Claude-App** auf dem Handy: https://claude.ai/download
- **Die Checkliste zum Abhaken:** [examples/server-checklist.md](examples/server-checklist.md)

## Schritt für Schritt

1. **SSH-Schlüssel auf dem Laptop erzeugen** (Enter für den Standardpfad, dann eine Passphrase setzen):
   ```bash
   ssh-keygen -t ed25519 -C "laptop"
   cat ~/.ssh/id_ed25519.pub
   ```
   Nur diese `.pub`-Zeile gibst du weiter. Die Datei ohne `.pub` bleibt auf dem Laptop.
2. **Server bestellen.** Hetzner: im Projekt **Servers → Add server**, Image Ubuntu, Typ mit mindestens 4 GB RAM, unter **SSH key** die `.pub`-Zeile einfügen. Das geht bei Hetzner nur beim Anlegen ([Anleitung](https://docs.hetzner.com/cloud/servers/getting-started/creating-a-server/)). Hostinger: Schlüssel beim Einrichten oder später unter **VPS → Manage → Settings → SSH keys** ([Anleitung](https://www.hostinger.com/support/4792364-how-to-use-ssh-keys-at-hostinger-vps/)). Kein Passwort-Login.
3. **Einloggen:** `ssh root@<öffentliche-IP>`
4. **Tailscale auf dem Server:** installieren nach https://tailscale.com/kb/1031/install-linux (Befehl von dort), dann:
   ```bash
   sudo tailscale up
   tailscale ip -4
   ```
   Öffne die angezeigte URL und melde dich mit **demselben** Konto an wie auf Laptop und Handy. Notiere die Adresse `100.x.y.z`.
5. **Neu einloggen über Tailscale** (`exit`, dann `ssh root@100.x.y.z`) und **erst dann** alles andere sperren (Schritte aus https://tailscale.com/kb/1077/secure-server-ubuntu):
   ```bash
   sudo ufw allow in on tailscale0
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw enable
   sudo ufw status verbose
   ```
   Test vom Laptop: `ssh root@<öffentliche-IP>` läuft ins Timeout, `ssh root@100.x.y.z` klappt.
6. **Docker** nach https://docs.docker.com/engine/install/ubuntu/ installieren, dann tmux: `sudo apt install tmux`
7. **Container starten** und `jq` hineinlegen (die Blueprint-Hooks brauchen es):
   ```bash
   sudo docker run -dit --name claude-box --restart unless-stopped \
     --user node -w /home/node -v claude-home:/home/node node:22 bash
   sudo docker exec -u root claude-box apt-get update
   sudo docker exec -u root claude-box apt-get install -y jq
   ```
   Claude läuft dort als Nutzer `node`, nicht als root. Das Home-Verzeichnis liegt im Volume `claude-home`, Login und Projekte überstehen also einen Neustart. Kein `-p`: Kein Port des Containers ist von außen erreichbar.
8. **Blueprint auf den Server** (erste Zeile auf dem Laptop, die anderen auf dem Server):
   ```bash
   scp -r ~/ailoopwise-blueprint root@100.x.y.z:/root/
   sudo docker cp /root/ailoopwise-blueprint claude-box:/home/node/
   sudo docker exec -u root claude-box chown -R node:node /home/node/ailoopwise-blueprint
   ```
9. **tmux-Session öffnen und in den Container wechseln:**
   ```bash
   tmux new -As claude
   sudo docker exec -it claude-box bash
   ```
   Installiere Claude Code im Container mit dem Linux-Befehl von https://code.claude.com/docs/de/setup und prüfe mit `claude --version`.
10. **Anmelden:** `claude` starten. Auf dem Server öffnet sich kein Browser: Drücke `c`, öffne die kopierte URL auf Laptop oder Handy, melde dich an und füge den angezeigten Code bei `Paste code here if prompted` ein.
11. **Projekt einrichten wie in Folge 2**, nur im Terminal: `cd ~/ailoopwise-blueprint`, `claude`, den Prompt aus [Folge 2](02-desktop-setup.md) einfügen. Danach `cd ~/<dein-projekt>` und `claude`. Den Vertrauensdialog bestätigst du einmal.
12. **Termius auf dem Handy:** **Keychain → Generate Key** (Ed25519), Host anlegen mit `100.x.y.z`, Nutzer `root`, diesem Schlüssel. Dann den Schlüssel per **Export to host** auf den Server bringen ([Anleitung](https://docs.termius.com/keychain/ssh-keys-and-certificates)). Verbinden und:
    ```bash
    tmux attach -t claude
    ```
13. **Remote Control einschalten**, im Terminal auf dem Handy in der laufenden Session:
    ```text
    /remote-control
    ```
    Bestätige **Enable Remote Control**. In der Claude-App tippst du auf **Code** und findest die Sitzung mit Computer-Symbol und grünem Punkt.
14. **Loslassen:** `Ctrl+b`, dann `d` trennt dich, Claude läuft weiter. Die Doku sagt dazu: „To keep a session running on a remote machine after you disconnect from SSH, start it inside `tmux` or `screen`.“ ([Remote Control](https://code.claude.com/docs/de/remote-control))

**Sicherheit, ohne Ausnahme:** SSH-Schlüssel statt Passwörter. Nach Schritt 5 ist Port 22 öffentlich zu. Veröffentliche keine Container-Ports: Mit `-p` freigegebene Ports umgehen ufw ([Docker-Doku](https://docs.docker.com/engine/install/ubuntu/)). Nie API-Schlüssel ins Image oder Dockerfile, nie `~/.ssh` oder Cloud-Zugangsdaten in den Container mounten ([Claude-Code-Doku](https://code.claude.com/docs/de/devcontainer)). Solange Remote Control verbunden ist, liegt das Transkript der Sitzung auf Anthropics Servern; ausgeführt wird alles auf deinem Server.

## Beispiel zum Kopieren

Die komplette Reihenfolge zum Abhaken: [examples/server-checklist.md](examples/server-checklist.md). Der Kern:

```markdown
- [ ] ufw: `allow in on tailscale0`, eingehend alles andere gesperrt, aktiviert
- [ ] Container `claude-box` läuft als Nutzer `node`, ohne veröffentlichte Ports (`-p`)
- [ ] Kein API-Schlüssel im Image, keine `~/.ssh` oder Cloud-Zugangsdaten gemountet
```

## Bevor du zur nächsten Folge gehst

Klapp den Laptop zu, verbinde dich per Termius, tippe `tmux attach -t claude` und sieh nach, ob deine Session noch läuft.

## Wenn etwas hakt

- **`Killed` während der Installation, Exit-Code 137:** Dem Server ist der Speicher ausgegangen. Nimm einen Typ mit mindestens 4 GB RAM oder lege Swap an. Quelle: https://code.claude.com/docs/de/troubleshoot-install#install-killed-on-low-memory-linux-servers
- **Login-Code wird nicht angenommen:** Der Browser lief auf einem anderen Gerät. Kopiere die URL mit `c`, melde dich an und füge den Code im Terminal ein. Klappt das Einfügen nicht, nimm `claude auth login`. Quelle: https://code.claude.com/docs/de/troubleshoot-install#oauth-login-fails-in-wsl2-ssh-or-containers
- **Nach einiger Zeit kommst du über Tailscale nicht mehr rein:** Tailscale verlangt regelmäßig eine neue Anmeldung. Für diesen Server in der Admin-Konsole unter **Machines** „Disable Key Expiry“ wählen. Quelle: https://tailscale.com/kb/1028/key-expiry
- **Die Sitzung ist in der App offline, sobald du Termius schließt:** Claude lief nicht in tmux. `tmux new -As claude` starten, darin Claude neu starten. Quelle: https://code.claude.com/docs/de/remote-control#limitations

## Sag deiner KI

Füge das vor dem Bestellen in Claude Code auf deinem Laptop ein. Claude geht die Checkliste mit dir durch und hält überall an, wo Geld oder deine Konten im Spiel sind.

```text
Geh mit mir ~/ailoopwise-blueprint/course/examples/server-checklist.md durch, Punkt für Punkt und in dieser Reihenfolge. Ich bin kein Entwickler, erkläre jeden Punkt in einem einfachen Satz.
1. Zeig mir zu jedem Punkt den passenden Befehl oder Klickweg aus ~/ailoopwise-blueprint/course/03-server-optional.md und warte, bis ich dir das Ergebnis sage, bevor du weitermachst.
2. HALT vor allem, was Geld kostet oder in einem meiner Konten passiert (Server bestellen, Hetzner, Hostinger, Tailscale, GitHub). Sag mir, was ich dort selbst tun muss, und warte, bis ich sage, dass es erledigt ist.
3. Lass mich ufw erst einschalten, wenn der Login über die Tailscale-Adresse (100.x.y.z) klappt, sonst sperre ich mich aus.
4. Ändere selbst nichts, weder in diesem Ordner noch außerhalb. Befehle, die nur etwas anzeigen, darfst du auf diesem Rechner ausführen, nachdem du sie erklärt hast. Alles andere tippe ich selbst.
5. Öffne oder zeig nie den privaten Schlüssel ~/.ssh/id_ed25519 (weitergegeben wird nur die .pub-Datei), und zeig nie Passwörter, Tokens oder Login-Codes an.
6. Führ nie git commit oder git push aus, ohne dass ich darum bitte. Nenne mir zum Schluss die Punkte, die noch offen sind.
```

---

## English

[Overview](README.md) · Back: [Episode 2](02-desktop-setup.md) · Next: [Episode 4](04-guardrails.md)

**In this episode (≈ 90 min of hands-on work):**

- Your own server, reachable only through your private Tailscale network.
- Claude Code in a sealed-off container with no open ports.
- A session that keeps running while you steer it by phone.

**This episode is an extra.** If it feels too technical, skip it. Episodes 4 to 6 don't need a server.

You rent a small virtual server (Hetzner or Hostinger) and run Claude Code there in a sealed-off Docker container. Tailscale makes the server invisible from outside. On your phone you open Termius, attach to a tmux session so nothing drops, and with `/remote-control` you can also drive the session from the Claude app. The laptop can stay shut.

The wall: a server also means updates, backups and access rights, forever, not once.

### What you'll have at the end

- A server reachable by SSH only through your private Tailscale network.
- Claude Code in a container, as a normal user, with no open ports.
- A tmux session you attach to from your phone, and a Remote Control session in the Claude app.

### What you need

- **A VPS** with Ubuntu and at least 4 GB RAM (the Claude Code minimum): Hetzner Cloud https://www.hetzner.com/cloud or Hostinger VPS https://www.hostinger.com/vps-hosting
- **Tailscale** on laptop and phone: https://tailscale.com/download · on the server: https://tailscale.com/kb/1031/install-linux
- **Termius** on your phone: https://termius.com
- **Docker Engine** for Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- **tmux**: https://github.com/tmux/tmux/wiki/Getting-Started
- **The Claude app** on your phone: https://claude.ai/download
- **The checklist:** [examples/server-checklist.md](examples/server-checklist.md)

### Step by step

1. **Create an SSH key on the laptop** (Enter for the default path, then set a passphrase):
   ```bash
   ssh-keygen -t ed25519 -C "laptop"
   cat ~/.ssh/id_ed25519.pub
   ```
   Only share that `.pub` line. The file without `.pub` stays on the laptop.
2. **Order the server.** Hetzner: in your project **Servers → Add server**, image Ubuntu, a type with at least 4 GB RAM, paste the `.pub` line under **SSH key**. At Hetzner this only works at creation ([guide](https://docs.hetzner.com/cloud/servers/getting-started/creating-a-server/)). Hostinger: add the key during setup or later under **VPS → Manage → Settings → SSH keys** ([guide](https://www.hostinger.com/support/4792364-how-to-use-ssh-keys-at-hostinger-vps/)). No password login.
3. **Log in:** `ssh root@<public-IP>`
4. **Tailscale on the server:** install from https://tailscale.com/kb/1031/install-linux (use the command there), then:
   ```bash
   sudo tailscale up
   tailscale ip -4
   ```
   Open the URL shown and sign in with the **same** account as on laptop and phone. Note the `100.x.y.z` address.
5. **Log back in over Tailscale** (`exit`, then `ssh root@100.x.y.z`) and **only then** block everything else (steps from https://tailscale.com/kb/1077/secure-server-ubuntu):
   ```bash
   sudo ufw allow in on tailscale0
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw enable
   sudo ufw status verbose
   ```
   Test from the laptop: `ssh root@<public-IP>` times out, `ssh root@100.x.y.z` works.
6. **Docker:** install from https://docs.docker.com/engine/install/ubuntu/, then tmux: `sudo apt install tmux`
7. **Start the container** and add `jq` (the blueprint hooks need it):
   ```bash
   sudo docker run -dit --name claude-box --restart unless-stopped \
     --user node -w /home/node -v claude-home:/home/node node:22 bash
   sudo docker exec -u root claude-box apt-get update
   sudo docker exec -u root claude-box apt-get install -y jq
   ```
   Claude runs there as user `node`, not root. The home directory lives in the `claude-home` volume, so login and projects survive a restart. No `-p`: no container port is reachable from outside.
8. **Blueprint onto the server** (first line on the laptop, the others on the server):
   ```bash
   scp -r ~/ailoopwise-blueprint root@100.x.y.z:/root/
   sudo docker cp /root/ailoopwise-blueprint claude-box:/home/node/
   sudo docker exec -u root claude-box chown -R node:node /home/node/ailoopwise-blueprint
   ```
9. **Open a tmux session and enter the container:**
   ```bash
   tmux new -As claude
   sudo docker exec -it claude-box bash
   ```
   Install Claude Code inside the container with the Linux command from https://code.claude.com/docs/en/setup and check with `claude --version`.
10. **Sign in:** start `claude`. No browser opens on a server: press `c`, open the copied URL on laptop or phone, sign in, and paste the code shown at `Paste code here if prompted`.
11. **Set up the project as in episode 2**, just in the terminal: `cd ~/ailoopwise-blueprint`, `claude`, paste the prompt from [episode 2](02-desktop-setup.md). Then `cd ~/<your-project>` and `claude`. Accept the trust dialog once.
12. **Termius on the phone:** **Keychain → Generate Key** (Ed25519), add a host with `100.x.y.z`, user `root`, that key. Then push the key to the server with **Export to host** ([guide](https://docs.termius.com/keychain/ssh-keys-and-certificates)). Connect and run:
    ```bash
    tmux attach -t claude
    ```
13. **Turn on Remote Control**, in the running session in the phone terminal:
    ```text
    /remote-control
    ```
    Confirm **Enable Remote Control**. In the Claude app, tap **Code** and find the session with a computer icon and a green dot.
14. **Let go:** `Ctrl+b`, then `d` detaches you; Claude keeps running. The docs: "To keep a session running on a remote machine after you disconnect from SSH, start it inside `tmux` or `screen`." ([Remote Control](https://code.claude.com/docs/en/remote-control))

**Security, no exceptions:** SSH keys, not passwords. After step 5, port 22 is closed to the public. Publish no container ports: ports published with `-p` bypass ufw ([Docker docs](https://docs.docker.com/engine/install/ubuntu/)). Never put API keys in the image or Dockerfile, never mount `~/.ssh` or cloud credentials into the container ([Claude Code docs](https://code.claude.com/docs/en/devcontainer)). While Remote Control is connected, the session transcript is stored on Anthropic's servers; everything still executes on your server.

### Example to copy

The full order to tick off: [examples/server-checklist.md](examples/server-checklist.md). The core:

```markdown
- [ ] ufw: `allow in on tailscale0`, all other incoming blocked, enabled
- [ ] Container `claude-box` runs as user `node`, with no published ports (`-p`)
- [ ] No API key in the image, no `~/.ssh` or cloud credentials mounted
```

### Before the next episode

Shut the laptop, connect with Termius, type `tmux attach -t claude` and check that your session is still running.

### If something goes wrong

- **`Killed` during install, exit code 137:** the server ran out of memory. Pick a type with at least 4 GB RAM or add swap. Source: https://code.claude.com/docs/en/troubleshoot-install#install-killed-on-low-memory-linux-servers
- **Login code not accepted:** the browser ran on another device. Copy the URL with `c`, sign in, paste the code in the terminal. If pasting fails, use `claude auth login`. Source: https://code.claude.com/docs/en/troubleshoot-install#oauth-login-fails-in-wsl2-ssh-or-containers
- **After a while you can't get in over Tailscale:** Tailscale requires periodic re-authentication. For this server choose "Disable Key Expiry" under **Machines** in the admin console. Source: https://tailscale.com/kb/1028/key-expiry
- **The session goes offline in the app as soon as you close Termius:** Claude wasn't running inside tmux. Start `tmux new -As claude` and restart Claude inside it. Source: https://code.claude.com/docs/en/remote-control#limitations

### Tell your AI

Paste this into Claude Code on your laptop before you order anything. Claude walks you through the checklist and stops wherever money or your accounts are involved.

```text
Walk me through ~/ailoopwise-blueprint/course/examples/server-checklist.md, one item at a time and in its order. I am not a developer, so explain each item in one plain sentence.
1. For each item, show me the matching command or click path from ~/ailoopwise-blueprint/course/03-server-optional.md, then wait until I tell you the result before you go on.
2. STOP before anything that costs money or happens in one of my accounts (ordering the server, Hetzner, Hostinger, Tailscale, GitHub). Tell me what to do there myself and wait until I say it is done.
3. Do not let me switch on ufw before login over the Tailscale address (100.x.y.z) works, or I lock myself out.
4. Change nothing yourself, in this folder or outside it. You may run commands that only display something on this computer, after explaining them. I type everything else myself.
5. Never open or print the private key ~/.ssh/id_ed25519 (only the .pub file is shared), and never print passwords, tokens or login codes.
6. Never run git commit or git push unless I ask. At the end, list the items that are still open.
```
