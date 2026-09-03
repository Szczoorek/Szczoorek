# Dungeon 2: The Crimson Cathedral

A 4-boss dungeon inspired by WoW's **Scarlet Monastery** — a cathedral
seized by a fanatical cult, split into distinct wings that converge on a
central inner sanctum. Aimed at a full group (3-5 players), meant to follow
The Sunken Vault as the bigger of the two starter dungeons.

## Story

A cult calling itself the Crimson Order has taken the old cathedral,
"purifying" everything they can reach with fire. **Inquisitor Dane**, camped
outside, wants it purged before the fires spread beyond the cathedral walls.

## Quest: "Purge the Crimson Cathedral"

- Given by **Inquisitor Dane** (say `cathedral`), tracked via
  `QuestLog.storage.cathedral.quest`.
- Say `cathedral` again any time for a status line naming which of the four
  bosses are still alive.
- Handed in by saying `ember` while carrying the **Flameseer's Ember**
  (guaranteed drop from the final boss). Reward: 9000 exp, 3000 gold, and
  the **Ember-Warded Amulet** (id 20011).

## Suggested layout

Three outer wings feed into a central inner sanctum, exactly like
Scarlet Monastery's Library / Armory / Cathedral converging on the
graveyard, minus a fourth "optional" wing to keep this a tighter starter
dungeon:

```
                 [Library wing: Malachar]
                          |
[Entrance/hub] --- [Infirmary wing: Ophelia]  --- [Inner gate, uid 10020] --- [Sanctum: The Flameseer]
                          |
                 [Armory wing: Varek]
```

- The three outer wings can be cleared in **any order** - each boss AI is
  fully independent.
- **Trash** (`data/monster/crimson_cathedral/`): Crimson Zealot, Cathedral
  Guard, Flame Acolyte. Distribute through all three outer wings. Cathedral
  Guards are the only trash that can drop the **Cathedral Sigil**
  (`QuestLog.items.cathedralSigil`, 8% - a deliberately rare "impatient
  group" shortcut).
- **The inner gate** (`data/actions/scripts/dungeons/crimson_cathedral_gate.lua`,
  actionid `10021`, gate item uniqueid `10020`) opens if the player holds a
  Cathedral Sigil (consumed on use), **or** once all three outer bosses are
  dead - so a group with bad sigil luck can still always get through by
  clearing every wing.

## Boss encounters

### 1. Brother Malachar — Library wing
`data/monster/crimson_cathedral/brother_malachar.xml` · AI: `malachar_ai.lua`

- Every 12 seconds, if fewer than 4 **Animated Tomes** are currently alive,
  summons 2 more ("Rise and defend the archive!"). Left unchecked the add
  count creeps up; kill tomes as they spawn to keep the room manageable.
- On death: credits `QuestLog.storage.cathedral.malachar`. Rare drop:
  Scarlet Prayer Book (flavor, 20%).

### 2. Sister Ophelia — Infirmary wing
`data/monster/crimson_cathedral/sister_ophelia.xml` · AI: `ophelia_ai.lua`

- Every 6 seconds: heals the most wounded nearby Crimson Zealot / Cathedral
  Guard / Flame Acolyte within 8 tiles for 250 HP if one is hurt and still
  alive nearby ("Be whole again!"). If no ally needs it and she's below 90%
  health herself, she tops herself up for 200 instead.
- **Encounter design intent**: pulling her trash guards away and killing
  them *before* engaging Ophelia (or fighting her somewhere the guards
  can't reach) removes her healing target entirely and makes the fight much
  more of a straight DPS race.
- On death: credits `QuestLog.storage.cathedral.ophelia`.

### 3. Highlord Varek — Armory wing
`data/monster/crimson_cathedral/highlord_varek.xml` · AI: `varek_ai.lua`

- Every 12 seconds: **Whirlwind**, a tight 2-tile-radius AoE (50-90 dmg)
  around himself - melee should consider stepping out briefly when he
  yells "Whirlwind!".
- At **30% health** (once): enrages - +180 speed and Whirlwind cooldown
  drops to 7s.
- On death: credits `QuestLog.storage.cathedral.varek`.

### 4. The Flameseer — Inner sanctum (final boss)
`data/monster/crimson_cathedral/the_flameseer.xml` · AI: `flameseer_ai.lua`

- Every 10 seconds: **Fire Nova**, a wide 4-tile-radius AoE (70-110 dmg)
  around himself.
- At **30% health** (once): enrages - summons **2 Lesser Fire Elementals**
  and Fire Nova cooldown drops to 6s. This is the hardest DPS check in the
  pack: the group needs to be ready to either burn him down fast or handle
  two extra adds while eating faster novas.
- On death: credits `QuestLog.storage.cathedral.flameseer`, broadcasts a
  server-wide kill message, and guarantees a drop of the **Flameseer's
  Ember** (quest item).

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/inquisitor_dane.xml` + `.../scripts/inquisitor_dane.lua` |
| Trash monsters | `data/monster/crimson_cathedral/{crimson_zealot,cathedral_guard,flame_acolyte}.xml` |
| Add monsters | `data/monster/crimson_cathedral/{animated_tome,lesser_fire_elemental}.xml` |
| Bosses | `data/monster/crimson_cathedral/{brother_malachar,sister_ophelia,highlord_varek,the_flameseer}.xml` |
| Boss AI | `data/creaturescripts/scripts/dungeons/{malachar,ophelia,varek,flameseer}_ai.lua` |
| Inner gate | `data/actions/scripts/dungeons/crimson_cathedral_gate.lua` (actionid 10021, gate uid 10020) |
| Storage | `QuestLog.storage.cathedral.*` = 45030-45034 |
| Items | ember 20009, sigil 20010, amulet 20011, prayer book 20012 |

## Map checklist

- [ ] Build entrance/hub with three branching wings (Library, Infirmary,
      Armory) plus an inner sanctum gated behind them.
- [ ] Populate each wing with a mix of the three trash types.
- [ ] Place Malachar, Ophelia and Varek as single-count spawns in their
      respective wings.
- [ ] Leave open floor around Ophelia for her guard trash to reach her -
      that's the point of her mechanic.
- [ ] Place the inner gate usable object (actionid `10021`) and the gate
      item itself (uniqueid `10020`) between the hub and the sanctum.
- [ ] Place The Flameseer as a single-count spawn in the sanctum, with
      enough open floor for his Fire Nova radius to matter.
- [ ] Place Inquisitor Dane outside the cathedral entrance.
