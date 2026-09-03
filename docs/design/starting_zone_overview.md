# Starting Zone Overview

A map-level reference tying every piece in this pack into one coherent
starting zone - the equivalent of a WoW starting zone like Elwynn Forest:
a hub town, a couple of nearby wilds for early quests, and two dungeon
entrances leading out of it. This doc is for whoever builds the actual
`.otbm` - it doesn't introduce any new mechanics of its own, just lays out
where everything from the other design docs should sit relative to each
other.

## Suggested map

```
                      [Timber Wolf forest]
                       - Quest 1 trash spawn
                       - Fenrir the Alpha (rare, see fenrir_the_alpha.md)
                                |
                                |
[Cave: locket chest] ---- [VILLAGE HUB] ---- [Docks]
 - Quest 2 dungeon          |         |        - Harbor Master Thessaly
                     [Village entrance]|        - Quartermaster Reyes
                      - Sergeant Coleman|       - Sunken Vault entrance
                      - Training Dummy  |
                     [Village NPCs]     |
                      - Ranger Elyndra  |
                      - Old Man Corwin  |
                      - Watchman Farro  |
                      - Bounty Clerk Sarna
                      - Provisioner Nadia
                                        |
                              [Cathedral approach]
                               - Inquisitor Dane
                               - Armsmaster Cael
                               - Crimson Cathedral entrance
                                        |
                                        |
                          [Cinderforge Depths entrance]
                           - Forge Marshal Aldric
                           - achievement-gated raid entrance

                          [The Proving Grounds]
                           - Trial Marshal Vex
                           - wave-survival arena (not gated to anywhere
                             above - can sit anywhere convenient)
```

## Zone-by-zone

### Village entrance
The very first thing a new character sees, before anything else:
- **Sergeant Coleman** and the **Training Dummy** (Quest 0: Boot Camp) —
  see `docs/design/quest_boot_camp.md`. Place these ahead of everyone else
  on the path in from character creation/the temple.

### Village hub
The player's home base. Everything here is low-risk, dialogue-only content:
- **Ranger Elyndra** (Quest 1 giver) — near the village gate, facing the
  forest.
- **Old Man Corwin** (Quest 2 giver) — near the village gate, facing the
  cave.
- **Watchman Farro** (Quest 3 giver) — somewhere central, with sightlines
  toward the outskirts (his dialogue implies he can see the beacons from
  where he stands), see `docs/design/quest_signal_the_watch.md`.
- **Bounty Clerk Sarna** (daily bounties for both dungeons) — anywhere
  central in the hub, see `docs/design/daily_bounties.md`.
- **Provisioner Nadia** (ungated potions + the Hearthstone) — ideally near
  Sergeant Coleman, since she's meant to be the first shop a new character
  visits, see `docs/design/general_goods.md`. The Hearthstone's home
  position should point at wherever you consider the "town center" bind
  spot to be — doesn't need to be Nadia's own tile.

### The outskirts (Quest 3)
Three beacon sites (north/east/south) ringing the village, each guarded by
a couple of Roadside Bandits — see `docs/design/quest_signal_the_watch.md`.
These can overlap loosely with the edges of the Timber Wolf forest or the
road to the docks/cathedral; they don't need their own dedicated area.

### Timber Wolf forest
North of the village. A single connected wood, not a maze - this is meant
to be a quick first-quest zone.
- Timber Wolf spawn (`data/monster/quest_wolves/timber_wolf.xml`), see
  `docs/design/quest_wolves_at_the_doorstep.md`.
- Fenrir the Alpha's spawn point lives somewhere in this same forest, see
  `docs/design/fenrir_the_alpha.md` — pick a clearing distinct from the
  regular wolf spawn so his appearance is noticeable.

### The cave (Quest 2)
A short, self-contained cave, not a dungeon — see
`docs/design/quest_lost_locket.md`. No connection needed to anything else;
a dead-end off the village is fine.

### The docks (Sunken Vault)
- **Harbor Master Thessaly** (dungeon quest giver) and **Quartermaster
  Reyes** (reputation vendor) stand together at the docks, near the
  dungeon's entrance — see `docs/design/dungeon_sunken_vault.md` and
  `docs/design/factions_and_achievements.md`.
- The Sunken Vault itself is the flooded vault beneath/behind the docks.

### The cathedral approach (Crimson Cathedral)
- **Inquisitor Dane** (dungeon quest giver) and **Armsmaster Cael**
  (reputation vendor) camp outside the cathedral, at a safe distance from
  the fire — see `docs/design/dungeon_crimson_cathedral.md`.
- The Crimson Cathedral itself is the building they're camped outside of.

### The Cinderforge Depths entrance (raid)
- **Forge Marshal Aldric** stands at the entrance — logically placed
  somewhere reachable from both the docks and the cathedral approach,
  since he requires proof from both. Placing the entrance beneath or
  behind the Crimson Cathedral (as the design doc's story suggests) keeps
  it out of the way of new characters while still being a short walk from
  both other dungeons. See `docs/design/dungeon_cinderforge_depths.md`.
- The entrance itself is gated: nothing to build here beyond the gate
  object and its usable action - see that doc's map checklist.

### The Proving Grounds
A single arena room with **Trial Marshal Vex** and a lever outside it -
see `docs/design/the_proving_grounds.md`. Not gated behind anything else
in the pack, so it can go anywhere convenient (the village hub is a
reasonable choice, since it's meant to be quick and replayable rather than
an "expedition").

## Suggested play order

1. **Boot Camp** — every brand-new character's literal first minute, before
   anything else.
2. **Wolves at the Doorstep** and **The Lost Locket** — either order, both
   meant as early content right after Boot Camp.
3. **Signal the Watch** — a step up in difficulty from steps 2, good as the
   last stop before the first dungeon.
4. **The Sunken Vault** — first dungeon, once a small group can handle
   ~1400-4200 HP bosses (see the dungeon doc for per-boss numbers).
5. **The Crimson Cathedral** — bigger, four-boss follow-up dungeon for a
   fuller group.
6. **The Cinderforge Depths** — a full raid tier above both starter
   dungeons, unlocked only after clearing both (see its doc's gating
   section). The pack's current endgame.
7. **Fenrir the Alpha** — not gated to any point in this order; he's ambient
   world content a player might stumble into any time after Quest 1 opens
   up the forest.
8. **Daily bounties** and **the Proving Grounds** — repeatable content for
   after steps 4-5, not one-time steps at all. The Proving Grounds in
   particular has no prerequisite and can be tried the moment a character
   can survive a Timber Wolf, long before the dungeons.

Reputation and achievements aren't a separate step — they accrue
automatically as players work through steps 4, 5, 6 and 8.

## Full file index

See the root `README.md` for the folder-by-folder breakdown and
installation steps. Design docs, one per content piece:

- `docs/design/quest_boot_camp.md`
- `docs/design/quest_wolves_at_the_doorstep.md`
- `docs/design/quest_lost_locket.md`
- `docs/design/quest_signal_the_watch.md`
- `docs/design/dungeon_sunken_vault.md`
- `docs/design/dungeon_crimson_cathedral.md`
- `docs/design/dungeon_cinderforge_depths.md`
- `docs/design/factions_and_achievements.md`
- `docs/design/fenrir_the_alpha.md`
- `docs/design/daily_bounties.md`
- `docs/design/the_proving_grounds.md`
- `docs/design/general_goods.md`
- `docs/design/progression_and_balance.md` — every monster/quest reward's
  numbers in one place, for pacing/rebalancing
- `docs/design/starting_zone_overview.md` (this file)
