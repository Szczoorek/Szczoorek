# World Rare: Fenrir the Alpha

An open-world "rare spawn" in the same forest as Quest 1's Timber Wolves -
the low-stakes, no-quest-required WoW rare-mob pattern (an early-zone rare
elite that shows up unpredictably and gives a reason to keep an eye on a
leveling zone instead of leaving it behind).

## Concept

Fenrir doesn't belong to any quest. He's a chance-based spawn in the
Timber Wolf forest: tougher and more dangerous than the regular wolves
(roughly dungeon-mini-boss strength), announced server-wide on both spawn
and death so players elsewhere have a reason to head over and check.

## Mechanics

`data/monster/world/fenrir_the_alpha.xml` · AI: `data/creaturescripts/scripts/world/fenrir_ai.lua`

- Intro howl on engage.
- At **50% health** (once): howls again, gets a speed boost, and calls in
  **2 regular Timber Wolves** to back him up.
- On death: broadcasts a server-wide message, grants the **Fenrir's Bane**
  achievement to everyone nearby, and has a 60% chance to drop **Fenrir's
  Fang** (id 20021, pure trophy/flavor item, no other use).

## Spawn timer

`data/globalevents/scripts/fenrir_respawn.lua` (registered via
`data/globalevents/globalevents.xml`) checks every **30 minutes** whether
Fenrir is already alive near his spawn point; if not, it rolls a **15%**
chance to spawn him. That works out to an *expected* respawn roughly every
3-4 hours, but with enough randomness that players can't set a watch by it
- again, the point of a "rare."

**The spawn position in that script is a placeholder** (`Position(1000,
1000, 7)`) - update `FENRIR_SPAWN_POSITION` in
`data/globalevents/scripts/fenrir_respawn.lua` to the real coordinates once
the forest exists on your map. Tune `SPAWN_CHANCE_PERCENT` and the
30-minute `interval` in `globalevents.xml` to taste - lower chance +
shorter interval gives smoother variance for the same expected respawn
time, if you'd rather.

## Files

| Piece | Path |
|---|---|
| Monster | `data/monster/world/fenrir_the_alpha.xml` |
| AI | `data/creaturescripts/scripts/world/fenrir_ai.lua` (registered in `creaturescripts.xml` as `FenrirAI`) |
| Spawn timer | `data/globalevents/scripts/fenrir_respawn.lua` + `data/globalevents/globalevents.xml` |
| Achievement | `AchievementLog.storage.fenrirsBane` = 45112 |
| Item | `QuestLog.items.fenrirsFang` = 20021 |

## Map checklist

- [ ] Once the Wolves at the Doorstep forest is built, update
      `FENRIR_SPAWN_POSITION` in `fenrir_respawn.lua` to a clearing inside it.
- [ ] No hand-placed spawn is needed for Fenrir himself - the globalevent
      creates him directly via script.
