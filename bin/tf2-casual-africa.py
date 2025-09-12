#!/usr/bin/env python3
# Updates the name of a given server to display the current number of players on Valve Casual in the Africa region.
# Intended to be run as a systemd oneshot service on a timer using tf2-casual-africa.{service,timer}

import shutil
import json
import time
import sys
import subprocess  # nosec B404
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError
from datetime import datetime

# This can be any server, we just happen to run it on localhost here.
RCON_ADDRESS = "localhost:27016"
RCON_PASSWORD = (
    Path("~/.tf2_rcon_password").expanduser().read_text(encoding="utf-8").strip()
)
RCON_COMMAND = shutil.which("rcon") or str(Path.home() / "bin" / "rcon")
STEAM_API_KEY = (
    Path("~/.steam_api_key").expanduser().read_text(encoding="utf-8").strip()
)

# On the Valve side, go ahead and filter for: TF2, non-empty games, and two methods of checking that we're on official servers.
# Note that we're not using region=7 here, as that's actually for Community. Valve servers show up as region=255, so we
# check for gametype=valve and then match on "Valve Matchmaking Server (Johannesburg*"
FILTER = f"\\appid\\440\\empty\\1\\gametype\\valve\\name_match\\Valve%20Matchmaking%20Server%20%28Johannesburg%2A"
URL = f"https://api.steampowered.com/IGameServersService/GetServerList/v1/?filter={FILTER}&key={STEAM_API_KEY}&limit=999"

# We loop this using systemd, but if you don't want to set that up, you can use this and _loop below:
LOOP_DELAY_MIN = 5


def fetch_json(url):
    req = Request(url, headers={"User-Agent": "python-urllib/3"})
    try:
        with urlopen(req, timeout=15) as r:  # nosec B310
            return json.load(r)
    except (HTTPError, URLError) as e:
        print("Error fetching JSON:", e, file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print("Error decoding JSON:", e, file=sys.stderr)
        return None


def to_int(v):
    try:
        return int(v)
    except Exception:
        try:
            return int(float(v))
        except Exception:
            return 0


def main():
    print("=== Contacting Steam...", file=sys.stderr)
    data = fetch_json(URL)
    if data is None:
        raise ValueError("Error, not proceeding")
    servers = data.get("response", {}).get("servers", []) or []

    print(
        f"Received list of {len(servers)} servers...",
        file=sys.stderr,
    )

    def keep(s):
        name = s.get("name") or ""
        num_players = s.get("players") or 0
        return (
            num_players > 0
            and ("Valve Matchmaking Server" in name)
            and ("qtland" not in name.lower())
        )

    # This should be done in our server-side check, but no harm in double-checking our filter
    filtered = [s for s in servers if keep(s)]

    filtered.sort(key=lambda x: x.get("players") or 0, reverse=True)

    total_players = 0
    total_servers = 0
    server_info_list = []
    for server in filtered[:5]:
        num_players = server.get("players") or 0
        gametype = (server.get("map") or "").split("_", 1)[0]
        gamestring = f"({num_players}/{gametype})"
        server_info_list.append(gamestring)
        total_players += num_players
        total_servers += 1

    gametypes = list(set((s.get("map") or "").split("_", 1)[0] for s in filtered))

    if len(filtered) > 5:
        server_info_list.append("...")

    p_plural = "" if total_players == 1 else "s"
    s_plural = "" if total_servers == 1 else "s"

    gametypes_suffix = ""
    if len(server_info_list) > 0:
        # gametypes_suffix = ",".join(server_info_list)
        gametypes_suffix = ",".join(gametypes)
        gametypes_suffix = f": ({gametypes_suffix})"

    title = f">>> Valve Casual Africa: {total_players} player{p_plural} on {total_servers} server{s_plural}{gametypes_suffix}"

    now = datetime.now().ctime()
    print(f"Time: {now}", file=sys.stderr)
    print(f"Setting title to '{title}'", file=sys.stderr)

    try:
        subprocess.run(
            [
                RCON_COMMAND,
                "--address",
                RCON_ADDRESS,
                "--password",
                RCON_PASSWORD,
                f"hostname {title}",
            ]
        )  # nosec B607 B603
    except FileNotFoundError:
        print("ERROR! rcon command not found, failing entirely!", file=sys.stderr)
        sys.exit(1)

    print(f"=== Done.", file=sys.stderr)


# Using systemd to loop instead
def _loop():
    while True:
        try:
            try:
                main()
            except KeyboardInterrupt as kb:
                raise kb
            except Exception as e:
                print(f"ERROR: {e}")
            time.sleep(LOOP_DELAY_MIN * 60)
        except KeyboardInterrupt:
            sys.exit(130)


if __name__ == "__main__":
    #_loop()
    main()
