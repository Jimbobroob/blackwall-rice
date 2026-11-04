#!/usr/bin/env python3
"""One line of weather for hyprlock. Prints the cached value instantly, refreshes it in the background.

Location and units come from generated/settings.json (weather block), same as the Quickshell widget.
"""
import json
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

SETTINGS = Path(__file__).resolve().parents[2] / "generated/settings.json"
CACHE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "rice" / "lock-weather.txt"
MAX_AGE = 600

CODES = {
    0: ("󰖙", "Clear"), 1: ("󰖙", "Mostly clear"), 2: ("󰖕", "Part cloud"), 3: ("󰖐", "Overcast"),
    45: ("󰖑", "Fog"), 48: ("󰖑", "Rime fog"),
    51: ("󰖗", "Drizzle"), 53: ("󰖗", "Drizzle"), 55: ("󰖗", "Drizzle"),
    61: ("󰖗", "Rain"), 63: ("󰖗", "Rain"), 65: ("󰖖", "Heavy rain"),
    71: ("󰖘", "Snow"), 73: ("󰖘", "Snow"), 75: ("󰖘", "Heavy snow"), 77: ("󰖘", "Snow grains"),
    80: ("󰖗", "Showers"), 81: ("󰖗", "Showers"), 82: ("󰖖", "Heavy showers"),
    85: ("󰖘", "Snow showers"), 86: ("󰖘", "Snow showers"),
    95: ("󰖓", "Thunder"), 96: ("󰖓", "Thunder"), 99: ("󰖓", "Thunder"),
}


def fetch():
    w = json.loads(SETTINGS.read_text())["weather"]
    fahrenheit = w["temperature_unit"] == "F"
    wind = w["wind_unit"] if w["wind_unit"] in ("kmh", "ms") else "mph"
    url = (
        f"https://api.open-meteo.com/v1/forecast?latitude={w['latitude']}&longitude={w['longitude']}"
        f"&current=temperature_2m,weather_code,wind_speed_10m"
        f"&temperature_unit={'fahrenheit' if fahrenheit else 'celsius'}&wind_speed_unit={wind}"
    )
    with urllib.request.urlopen(url, timeout=8) as r:
        cur = json.load(r)["current"]
    icon, label = CODES.get(cur["weather_code"], ("󰖐", "Unknown"))
    unit = "°F" if fahrenheit else "°C"
    line = f"{icon}  {label}  ·  {round(cur['temperature_2m'])}{unit}  ·  {round(cur['wind_speed_10m'])} {wind}"
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(line)
    return line


def main():
    if "--refresh" in sys.argv:
        try:
            fetch()
        except Exception:
            pass
        return
    if CACHE.exists():
        print(CACHE.read_text())
        if time.time() - CACHE.stat().st_mtime > MAX_AGE:
            subprocess.Popen([sys.executable, __file__, "--refresh"], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return
    try:
        print(fetch())
    except Exception:
        print("weather unavailable")


main()
