# Daily Bounties

Repeatable "kill X trash" dailies at both starter dungeons, the WoW
daily-quest-hub pattern applied to this pack's two dungeons - a reason to
go back after the main dungeon quests are done, without needing any new
content of its own (it rides entirely on the existing trash mobs).

## How it works

- **No accept step.** Kills toward a bounty always count while today's
  bounty for that dungeon isn't already turned in - see
  `data/scripts/creaturescripts/bounties/{vault,cathedral}_trash_death.lua`,
  attached to every trash monster in each dungeon (not the named bosses,
  which have their own AI scripts and already reward reputation directly).
- Talk to **Bounty Clerk Sarna** and say `bounty` for a status line on both
  tracks, or `vault bounty` / `cathedral bounty` to collect once ready.
- **15 kills** per dungeon, reward **800 gold + 100 reputation** with that
  dungeon's faction (Harbor Trade Concern for the Vault, Order of the
  Ember for the Cathedral - see `docs/design/factions_and_achievements.md`).
- Resets once per **real-world calendar day** (`data/lib/bounty_log.lua`
  compares year+day-of-year on every check, so it rolls over at midnight
  server time regardless of when the player last logged in).

Note: Bilge Rats count toward the Vault bounty whether they're the regular
trash spawn or the pair Rustbeard the Mad summons mid-fight - a minor bonus
for groups already running the dungeon quest, not a bug.

## Files

| Piece | Path |
|---|---|
| Lib | `data/lib/bounty_log.lua` |
| NPC | `data/npc/bounty_clerk_sarna.lua` |
| Kill-credit scripts | `data/scripts/creaturescripts/bounties/{vault,cathedral}_trash_death.lua` |
| Storage | `BountyLog.storage.{vault,cathedral}.{progress,day,completed}` = 45120-45125 |

## Map checklist

- [ ] Place Bounty Clerk Sarna in the village hub, near the other NPCs.
- [ ] No new monsters or action ids required - this rides entirely on the
      existing Sunken Vault and Crimson Cathedral trash spawns.
