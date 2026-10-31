pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current weather, the next 12 hours, 5 days and sunrise/sunset from Open-Meteo (no API key).
// Location and units come from settings.json.
Singleton {
    id: root
    property bool ok: false
    property real temp: 0
    property real feels: 0
    property real wind: 0
    property int code: 0
    property var hourly: []       // next 12 h: [{ t (ms), temp, rain (%), code, night }]
    property var daily: []        // today + 4: [{ t, code, hi, lo, rain, sunrise, sunset }]
    readonly property real sunrise: daily.length ? daily[0].sunrise : 0
    readonly property real sunset: daily.length ? daily[0].sunset : 0
    readonly property real nextSunrise: daily.length > 1 ? daily[1].sunrise : 0
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

    // icon for any code; clear / mostly clear / part cloud get moon variants at night
    function iconFor(c, night) {
        if (night && c <= 1) return "󰖔"
        if (night && c === 2) return "󰼱"
        return (table[c] || ["󰖐", ""])[0]
    }

    function refresh() {
        const w = Settings.data.weather
        const url = "https://api.open-meteo.com/v1/forecast?latitude=" + w.latitude + "&longitude=" + w.longitude
            + "&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m"
            + "&hourly=temperature_2m,precipitation_probability,weather_code"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset"
            + "&timezone=auto&forecast_days=6"
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
                    const j = JSON.parse(text)
                    const c = j.current
                    // times are local ("2026-10-31T14:00"), which Date reads as local time
                    const d = j.daily
                    const days = d.time.map((day, i) => ({
                        t: new Date(day + "T00:00").getTime(), code: d.weather_code[i],
                        hi: d.temperature_2m_max[i], lo: d.temperature_2m_min[i],
                        rain: d.precipitation_probability_max[i] || 0,
                        sunrise: new Date(d.sunrise[i]).getTime(), sunset: new Date(d.sunset[i]).getTime()
                    }))
                    const h = j.hourly, now = Date.now(), hours = []
                    for (let i = 0; i < h.time.length && hours.length < 12; i++) {
                        const t = new Date(h.time[i]).getTime()
                        if (t + 3600000 <= now) continue
                        const day = days.find(x => t >= x.t && t < x.t + 86400000)
                        hours.push({ t, temp: h.temperature_2m[i], rain: h.precipitation_probability[i] || 0,
                                     code: h.weather_code[i], night: day ? (t < day.sunrise || t > day.sunset) : false })
                    }
                    root.hourly = hours
                    root.daily = days.slice(0, 5)
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
