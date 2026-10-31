pragma Singleton
import QtQuick
import Quickshell

// Lyrics for the current track (Players.player) from lrclib.net (free, no key). One request per new
// song, cached for the session. lines = [{ t: seconds, text }] when synced; plain = unsynced fallback.
Singleton {
    id: root
    property var lines: []
    property string plain: ""
    property string status: ""      // "" | "loading" | "none" | "instrumental" | "offline"
    property var cache: ({})
    property string key: ""

    readonly property var p: Players.player
    readonly property string want: p && p.trackTitle ? p.trackArtist + "\n" + p.trackTitle : ""
    // length often lands a moment after the title, so wait a little before asking
    onWantChanged: debounce.restart()
    Timer { id: debounce; interval: 600; onTriggered: root.fetch() }

    function get(url, cb) {
        const x = new XMLHttpRequest()
        x.onreadystatechange = () => {
            if (x.readyState !== XMLHttpRequest.DONE) return
            let d = null
            try { d = JSON.parse(x.responseText) } catch (e) {}
            cb(x.status, d)
        }
        x.open("GET", url)
        x.setRequestHeader("User-Agent", "rice-quickshell (personal desktop widget)")
        x.send()
    }

    function parse(lrc) {
        const out = []
        for (const l of (lrc || "").split("\n")) {
            const m = l.match(/^\[(\d+):(\d+(?:\.\d+)?)\](.*)$/)
            if (m) out.push({ t: Number(m[1]) * 60 + Number(m[2]), text: m[3].trim() })
        }
        return out
    }

    function apply(e) {
        lines = e.lines
        plain = e.plain
        status = e.offline ? "offline" : e.instrumental ? "instrumental" : (e.lines.length || e.plain) ? "" : "none"
    }

    function fetch() {
        const k = want
        key = k
        if (!k) { apply({ lines: [], plain: "" }); status = ""; return }
        if (cache[k]) { apply(cache[k]); return }
        lines = []; plain = ""; status = "loading"

        const enc = encodeURIComponent
        const artist = p.trackArtist || "", title = p.trackTitle
        // offline = no answer (or a server error): shown as such and not cached, so it retries next time
        const done = (d, offline) => {
            const e = { lines: parse(d && d.syncedLyrics), plain: (d && d.plainLyrics) || "",
                        instrumental: !!(d && d.instrumental), offline: offline }
            if (!offline) cache[k] = e
            if (root.key === k) apply(e)
        }
        let q = "artist_name=" + enc(artist) + "&track_name=" + enc(title)
        if (p.trackAlbum) q += "&album_name=" + enc(p.trackAlbum)
        if (p.length > 0) q += "&duration=" + Math.round(p.length)
        get("https://lrclib.net/api/get?" + q, (st, d) => {
            if (st === 0) return done(null, true)
            const busy = st >= 500
            if (st === 200 && d && (d.syncedLyrics || d.plainLyrics || d.instrumental)) return done(d, false)
            // no exact match: loose search, prefer a synced hit
            get("https://lrclib.net/api/search?track_name=" + enc(title) + "&artist_name=" + enc(artist), (st2, arr) => {
                const hit = st2 === 200 && Array.isArray(arr) ? (arr.find(x => x.syncedLyrics) || arr[0] || null) : null
                done(hit, st2 === 0 || st2 >= 500 || (busy && !hit))
            })
        })
    }
}
