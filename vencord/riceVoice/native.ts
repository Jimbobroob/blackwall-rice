/*
 * Rice voice bridge (main process).
 * Serves newline-delimited JSON on $XDG_RUNTIME_DIR/rice/discord.sock:
 *   plugin -> clients: the latest voice state, re-sent to every new client
 *   clients -> plugin: {"cmd":"mute"|"deafen"} (queued for the renderer to poll)
 */
import { mkdirSync, unlinkSync } from "fs";
import { createServer, Server, Socket } from "net";
import { join } from "path";

let server: Server | null = null;
const clients = new Set<Socket>();
let last = "{}";
let commands: string[] = [];

function start() {
    const dir = join(process.env.XDG_RUNTIME_DIR ?? "/tmp", "rice");
    const path = join(dir, "discord.sock");
    mkdirSync(dir, { recursive: true });
    try { unlinkSync(path); } catch { }

    server = createServer(sock => {
        clients.add(sock);
        sock.write(last + "\n");
        let buf = "";
        sock.on("data", d => {
            buf += d.toString();
            let i;
            while ((i = buf.indexOf("\n")) >= 0) {
                const line = buf.slice(0, i).trim();
                buf = buf.slice(i + 1);
                try {
                    const { cmd } = JSON.parse(line);
                    if (cmd === "mute" || cmd === "deafen") commands.push(cmd);
                } catch { }
            }
        });
        sock.on("close", () => clients.delete(sock));
        sock.on("error", () => clients.delete(sock));
    });
    server.on("error", () => { });
    server.listen(path);
}

export function publish(_, state: string) {
    if (!server) start();
    if (state === last) return;
    last = state;
    for (const c of clients) c.write(state + "\n");
}

export function pollCommands(_): string[] {
    const out = commands;
    commands = [];
    return out;
}

export function stop() {
    for (const c of clients) c.destroy();
    clients.clear();
    server?.close();
    server = null;
}
