/*
 * Rice voice: publishes the current voice channel (members, speaking, mute/deafen)
 * to the Quickshell side-monitor widget, and lets the widget toggle mute/deafen.
 */
import definePlugin, { PluginNative } from "@utils/types";
import { findByPropsLazy } from "@webpack";
import { ChannelStore, FluxDispatcher, GuildMemberStore, SelectedChannelStore, UserStore, VoiceStateStore } from "@webpack/common";

const Native = VencordNative.pluginHelpers.RiceVoice as PluginNative<typeof import("./native")>;
const VoiceActions = findByPropsLazy("toggleSelfMute", "toggleSelfDeaf");

const speaking = new Set<string>();
let timer: ReturnType<typeof setInterval> | undefined;

function avatarUrl(user: any, size = 64): string | null {
    try { return user.getAvatarURL(undefined, size, false); } catch { return null; }
}

function snapshot() {
    const me = UserStore.getCurrentUser();
    const channelId = SelectedChannelStore.getVoiceChannelId();
    if (!me || !channelId) return { connected: false };

    const channel = ChannelStore.getChannel(channelId);
    const states = VoiceStateStore.getVoiceStatesForChannel(channelId) as Record<string, any>;
    const members = Object.values(states).map(s => {
        const user = UserStore.getUser(s.userId);
        const nick = channel?.guild_id ? GuildMemberStore.getNick(channel.guild_id, s.userId) : null;
        return {
            id: s.userId,
            name: nick ?? (user as any)?.globalName ?? user?.username ?? s.userId,
            avatar: user ? avatarUrl(user) : null,
            speaking: speaking.has(s.userId),
            mute: !!(s.mute || s.selfMute),
            deaf: !!(s.deaf || s.selfDeaf),
            self: s.userId === me.id
        };
    });
    const mine = members.find(m => m.self);
    return {
        connected: true,
        channel: channel?.name ?? "Voice",
        mute: mine?.mute ?? false,
        deaf: mine?.deaf ?? false,
        members
    };
}

function onSpeaking({ userId, speakingFlags }: { userId: string; speakingFlags: number; }) {
    if (speakingFlags) speaking.add(userId); else speaking.delete(userId);
}

export default definePlugin({
    name: "RiceVoice",
    description: "Exposes voice channel state to the rice Quickshell widget over a local Unix socket",
    authors: [{ name: "blackwall", id: 0n }],

    start() {
        FluxDispatcher.subscribe("SPEAKING", onSpeaking);
        timer = setInterval(async () => {
            Native.publish(JSON.stringify(snapshot()));
            for (const cmd of await Native.pollCommands()) {
                if (cmd === "mute") VoiceActions.toggleSelfMute();
                else if (cmd === "deafen") VoiceActions.toggleSelfDeaf();
            }
        }, 250);
    },

    stop() {
        FluxDispatcher.unsubscribe("SPEAKING", onSpeaking);
        clearInterval(timer);
        speaking.clear();
        Native.stop();
    }
});
