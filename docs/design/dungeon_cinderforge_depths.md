# Raid: The Cinderforge Depths

A bigger, harder follow-up instance above the two starter dungeons -
inspired by WoW's early raid tier (Molten Core / Blackrock Depths): a
forge complex reclaimed by fire, gated behind proving yourself in both
5-man dungeons first, aimed at a full group (6-10 players) rather than a
small party. This is the pack's first content explicitly designed around
raid-style mechanics - a hard berserk timer, a paired/linked boss
encounter, a "protect the healer target" swallow mechanic, and an add-based
shield - rather than the single-trigger phase changes used by the two
starter dungeons' bosses.

## Story

Deep beneath the Crimson Cathedral's foundations (or wherever you choose to
place it - see the map checklist), an ancient forge complex has been
reclaimed by something that calls itself Ignareth, the Cinderlord. The
Forge Wardens guarding its entrance won't let just anyone through -
**Forge Marshal Aldric** explains that only those who've already proven
themselves against the Vault and the Cathedral are allowed near it.

## Gating

Entry is locked behind **both** the Vault Cleaner and Cathedral's Bane
achievements (`AchievementLog.storage`, see
`docs/design/factions_and_achievements.md`), checked at the entrance gate
itself (`data/scripts/actions/raid/cinderforge_gate.lua`) - not by talking
to the NPC first. A player without both achievements gets turned away at
the gate with an explanation; Forge Marshal Aldric gives the same
explanation in dialogue if asked before qualifying.

## Quest: "The Cinderforge Depths"

- Starts automatically the first time a qualifying player opens the gate
  (`QuestLog.storage.raid.quest` → STARTED).
- Say `depths` (or `cinderforge`/`raid`) to Forge Marshal Aldric any time
  for a status line naming which of the five bosses are still alive.
- Handed in by saying `emblem` while carrying the **Cinderforge Emblem**
  (guaranteed drop from Ignareth). Reward: 15,000 experience, 6,000 gold,
  the **Emberlord's Signet** (id 20030), and the **Cinderforge Conqueror**
  achievement.

## Suggested layout

A straight gauntlet works fine for a raid this size - five rooms in
sequence, trash between each:

```
[Gate, uid 10030] -> [Grimtooth's forge] -> [Twins' hall] -> [Slagmaw's pit] -> [Ashgrave's sanctum] -> [Ignareth's chamber]
```

- **Trash** (`data/monster/cinderforge_depths/`): Forge Slave, Cinderforge
  Smelter, Molten Hound. Distribute through the connecting corridors.
- Bosses are meant to be fought **in this order** - later bosses assume a
  raid-sized group has already worn itself in on the earlier ones. Nothing
  in script enforces the order (there's no sequential gate between rooms,
  only the single entrance gate), so it's a layout/pacing choice, not a
  hard mechanic.

## Boss encounters

### 1. Warden Grimtooth
`warden_grimtooth.xml` · AI: `grimtooth_ai.lua`

- **Molten Slam**: an AoE (60-100 dmg, 3-tile radius) around himself every
  12s (7s once enraged).
- **Hard berserk timer**: 180 seconds after engaging, he permanently
  enrages (faster, shorter Slam cooldown) regardless of his current health
  - a straight DPS check, not a health-triggered one. This is the first
  boss in the pack whose enrage is time-based rather than health-based.

### 2. The Twin Forgesmiths (Kex Ironhide & Dross Cinderhand)
`kex_ironhide.xml` + `dross_cinderhand.xml` · AI: `twins_ai.lua` (one
script, attached to both)

- Fought **simultaneously** - place them together in one room.
- The moment either twin notices its sibling has died, it enrages once
  ("Vengeance for my kin!", +200 speed). In practice: don't let one twin
  sit at low health while ignoring the other, or you'll finish the fight
  against an enraged solo boss instead of two moderate ones.
- On death: whichever twin dies *last* is the one that credits the kill -
  see the inline comment in `twins_ai.lua` for why this can't double-fire
  or miss regardless of kill order.

### 3. Slagmaw the Devourer
`slagmaw_the_devourer.xml` · AI: `slagmaw_ai.lua`

- Every 20s: **Swallow** - grabs the lowest-health-percentage player within
  8 tiles and hits them for a heavy burst (80-130 dmg). Not necessarily the
  tank: whoever's lowest on health eats the hit, so healers need to watch
  the whole raid's health, not just one target.

### 4. High Templar Ashgrave
`high_templar_ashgrave.xml` · AI: `ashgrave_ai.lua`

- Every 25s, if no **Ember Sentinel** is currently up, summons one. While
  the sentinel is alive, it channels a 400 HP heal into Ashgrave every 4s.
  This is the "shield" mechanic for this fight: kill the sentinel fast, or
  Ashgrave effectively stops taking net damage.

### 5. Ignareth, the Cinderlord (final boss)
`ignareth_the_cinderlord.xml` · AI: `ignareth_ai.lua`

Three-tier fight:
1. **100-50%**: **Cinderfall**, a wide AoE (90-140 dmg, 5-tile radius)
   around himself every 9s.
2. **At 50% (once, phase 2)**: summons **3 Sons of Cinder** and Cinderfall
   cooldown drops to 6s.
3. **At 20% (once, enrage)**: +150 speed and Cinderfall cooldown drops
   further to 4s - the hardest sustained AoE pressure in the pack.

On death: credits `QuestLog.storage.raid.ignareth`, broadcasts a
server-wide kill message, and guarantees a drop of the **Cinderforge
Emblem** (quest item) plus a chance at **Ignareth's Molten Crown** (id
20028, the pack's best-in-slot headpiece).

## Loot

Each boss drops one piece of gear at a moderate chance (25-35%), pitched
above the two starter dungeons' rewards - see the item comments in
`data/items/quest_items.xml` for exactly what each piece is and treat the
armor/attack numbers there as a starting point to rebalance against
whatever your server's overall progression curve actually looks like by
this point.

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/forge_marshal_aldric.lua` |
| Trash monsters | `data/monster/cinderforge_depths/{forge_slave,cinderforge_smelter,molten_hound}.xml` |
| Add monsters | `data/monster/cinderforge_depths/{ember_sentinel,son_of_cinder}.xml` |
| Bosses | `data/monster/cinderforge_depths/{warden_grimtooth,kex_ironhide,dross_cinderhand,slagmaw_the_devourer,high_templar_ashgrave,ignareth_the_cinderlord}.xml` |
| Boss AI | `data/scripts/creaturescripts/raid/{grimtooth,twins,slagmaw,ashgrave,ignareth}_ai.lua` |
| Gate | `data/scripts/actions/raid/cinderforge_gate.lua` (actionid 10022, gate uid 10030) |
| Storage | `QuestLog.storage.raid.*` = 45040-45045 |
| Items | gear 20024-20028, emblem (quest item) 20029, signet reward 20030 |
| Achievement | `AchievementLog.storage.cinderforgeConqueror` = 45113 |

## Map checklist

- [ ] Build a gate room + 5 boss rooms in sequence (or your own layout),
      with trash filling the connecting space.
- [ ] Place the entrance gate item (uniqueid `10030`) and its usable
      object (actionid `10022`) at the entrance.
- [ ] Place Warden Grimtooth as a single-count spawn in his own room.
- [ ] Place Kex Ironhide and Dross Cinderhand together as two single-count
      spawns in the same room.
- [ ] Place Slagmaw the Devourer as a single-count spawn, in a room large
      enough that "lowest health player gets grabbed" is a meaningful
      raid-wide positioning/healing concern, not just a tank mechanic.
- [ ] Place High Templar Ashgrave as a single-count spawn with enough open
      floor for an Ember Sentinel to spawn and be focused down.
- [ ] Place Ignareth as a single-count spawn in the final chamber, with
      enough open floor for his 5-tile Cinderfall radius to matter.
- [ ] Place Forge Marshal Aldric outside the entrance.
