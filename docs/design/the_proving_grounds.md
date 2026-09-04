# The Proving Grounds

A repeatable, skill-testing wave-survival arena - WoW's Proving Grounds /
Trial-of-the-Champion pattern: short, replayable, cooldown-gated rather
than a one-time story quest. Different pacing again from everything else
in the pack: not daily (like the bounties), not a one-time story beat -
just "wait 15 minutes, try again."

## Concept

Pull the lever, and five waves of monsters spawn back-to-back in a single
arena. Survive all five and everyone still standing in the arena gets
rewarded. There's no NPC-mediated "accept" step and no map object to
fetch - the whole thing runs off a lever and a background timer.

Waves deliberately reuse monsters already built elsewhere in this pack
(Timber Wolf, Roadside Bandit, Forge Slave, Cinderforge Smelter, Molten
Hound) rather than adding new ones - a "greatest hits" gauntlet that
doubles as a decent gut-check for whether a character is ready for the
zones those monsters come from.

| Wave | Monster | Count |
|---|---|---|
| 1 | Timber Wolf | 4 |
| 2 | Roadside Bandit | 4 |
| 3 | Forge Slave | 3 |
| 4 | Cinderforge Smelter | 3 |
| 5 | Molten Hound | 5 |

## How it works

- **Starting a run**: use the lever (actionid 10041). Blocked if a run is
  already active anywhere (see "One shared arena" below) or if you're on
  cooldown.
- **Per-player cooldown**: 15 minutes between attempts, tracked on the
  player (`TrialLog.storage.lastAttempt`).
- **Wave progression**: a background check
  (`data/scripts/globalevents/trial_tick.lua`, every 5s) watches the arena;
  once every monster from the current wave is dead, the next wave spawns
  automatically. No lever-pulling between waves.
- **Completion**: clearing wave 5 pays out 2,500 experience + 1,000 gold
  (+500 bonus if the whole run took 5 minutes or less) to everyone still in
  the arena, and grants the **Proving Grounds Champion** achievement.
- **Safety timeout**: if a run somehow drags on past 20 minutes (a
  disconnected group, a monster that wandered out of range), it force-resets
  so the arena doesn't get stuck.

## One shared arena

This engine has no real instancing, so - like the two dungeons and the raid
- the arena is one physical room shared by anyone who walks in. Unlike
those, though, Proving Grounds session state (which wave is active) lives
in a plain in-memory table (`data/lib/trial_log.lua`), not in any player's
storage, specifically *because* only one run can meaningfully be active at
a time. Practical implications:
- Only one group can run it at once. A second group needs to wait for the
  first to finish (the lever refuses while `TrialLog.isRunning()`).
- If the server restarts mid-run, that run's state is gone (by design -
  it's meant to be low-stakes and disposable, not something worth building
  persistence for).

## Files

| Piece | Path |
|---|---|
| Lib | `data/lib/trial_log.lua` |
| Lever | `data/scripts/actions/trial/proving_grounds_lever.lua` (actionid 10041) |
| Wave-progression timer | `data/scripts/globalevents/trial_tick.lua` (self-registering `GlobalEvent`) |
| NPC | `data/npc/trial_marshal_vex.lua` |
| Storage | `TrialLog.storage.lastAttempt` = 45050 (per player) |
| Achievement | `AchievementLog.storage.provingGroundsChampion` = 45114 |

## Map checklist

- [ ] Build one arena room, open enough (7x7 or bigger) for up to 5
      monsters to spawn without excessive stacking.
- [ ] Place Trial Marshal Vex just outside the arena, and a lever
      (actionid `10041`) at the entrance.
- [ ] Update `TrialLog.arenaPosition` in `data/lib/trial_log.lua` to the
      arena's real center once it exists on your map - it's a placeholder
      (`Position(1000, 1005, 7)`) until then.
