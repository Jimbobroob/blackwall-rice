pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current weather from Open-Meteo (no API key). Location and units come from settings.json.
Singleton {
    id: root
    property bool ok: false
    property real temp: 0
    property real feels: 0
    property real wind: 0
    property int code: 0
    readonly property string unit: Settings.data.weather.temperature_unit === "F" ? "°F" : "°C"
    readonly property string windUnit: Settings.data.weather.wind_unit

    readonly property var table: ({
        0: ["󰖙", "Clear"], 1: ["󰖙", "Mostly clear"], 2: ["󰖕", "Part cloud"], 3: ["󰖐", "Overcast"],
        45: ["󰖑", "Fog"], 48: ["󰖑", "Rime fog"],
        51: ["󰖗", "Drizzle"], 53: ["󰖗", "Drizzle"], 55: ["󰖗", "Drizzle"],
        61: ["󰖗", "Rain"], 63: ["󰖗", "Rain"], 65: ["󰖖", "Heavy rain"],
        71: ["󰖘", "Snow"], 73: ["󰖘", "Snow"], 75: ["󰖘", "Heavy snow"], 77: ["󰖘", "Snow grains"],
        80: ["󰖗", "Showers"], 81: ["󰖗", "Showers"], 82: ["󰖖", "Heavy showers"],
        85: ["󰖘", "Snow showers"], 86: ["󰖘", "Snow showers"],
        95: ["󰖓", "Thunder"], 96: ["󰖓", "Thunder"], 99: ["󰖓", "Thunder"]
    })
    readonly property string icon: (table[code] || ["󰖐", ""])[0]
    readonly property string label: (table[code] || ["", "Unknown"])[1]

    function refresh() {
        const w = Settings.data.weather
        const url = "https://api.open-meteo.com/v1/forecast?latitude=" + w.latitude + "&longitude=" + w.longitude
            + "&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m"
            + "&temperature_unit=" + (w.temperature_unit === "F" ? "fahrenheit" : "celsius")
            + "&wind_speed_unit=" + (w.wind_unit === "kmh" ? "kmh" : w.wind_unit === "ms" ? "ms" : "mph")
        fetch.command = ["curl", "-sf", "--max-time", "10", url]
        fetch.running = true
    }

    Process {
        id: fetch
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const c = JSON.parse(text).current
                    root.temp = c.temperature_2m
                    root.feels = c.apparent_temperature
                    root.wind = c.wind_speed_10m
                    root.code = c.weather_code
                    root.ok = true
                } catch (e) {
                    // keep the last good reading; try again next tick
                }
            }
        }
    }

    Timer {
        interval: Math.max(1, Settings.data.weather.refresh_minutes) * 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
