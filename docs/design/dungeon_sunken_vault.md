# Dungeon 1: The Sunken Vault

A 3-boss dungeon inspired by WoW's **Deadmines** — a pirate/goblin crew has
holed up in a flooded old harbor vault. Aimed at a small group (2-4 players)
past the two starter quests.

## Story

The harbor's old treasury vault flooded and was abandoned generations ago.
Recently, the pirate captain **Blackscale** and his crew broke in, pumped it
half-dry, and have been using it as a hideout - and a base to raid harbor
shipping from. **Harbor Master Thessaly**, at the docks, wants it cleared.

## Quest: "Secrets of the Sunken Vault"

- Given by **Harbor Master Thessaly** (say `vault`), tracked via
  `QuestLog.storage.vault.quest`.
- Say `vault` again any time for a status line naming which of the three
  bosses are still alive.
- Handed in by saying `ledger` while carrying the **Sunken Vault Ledger**
  (guaranteed drop from Captain Blackscale). Reward: 4000 exp, 1500 gold,
  and the **Vault Captain's Cutlass** (id 20006).

## Suggested layout

```
[Entrance] -> [Trash room A] -> [Rustbeard's chamber] -\
                                                          -> [Junction] -> [Barred gate, uid 10010]
[Entrance] -> [Trash room B] -> [Grix's workshop]      -/         |
                                                                    v
                                                         [Blackscale's flooded hall]
```

- **Trash** (`data/monster/sunken_vault/`): Vault Goblin, Vault Corsair,
  Bilge Rat. Mix freely through the entrance rooms; Bilge Rats are also
  used as Rustbeard's summoned add so keep a few of them "canon" to the
  early rooms too.
- The two mini-bosses (Rustbeard, Grix) can be fought in either order or in
  parallel by a group that splits up - neither depends on the other.
- **The gate**: a lever with actionid `10002`
  (`data/actions/scripts/dungeons/sunken_vault_gate.lua`) guards the final
  hall. It opens once *both* mini-bosses are dead, or immediately for
  anyone carrying a **Rusty Vault Key** (id 20007, a shortcut item - hand
  one out from a side objective or rare drop if you want a bypass route).
  Place the gate object itself with uniqueid `10010` on a tile that blocks
  movement; the script removes it entirely rather than "opening" it, so any
  barred-gate/grille graphic works.

## Boss encounters

### 1. Rustbeard the Mad (mini-boss)
`data/monster/sunken_vault/rustbeard_the_mad.xml` · AI: `rustbeard_ai.lua`

- Standard melee tank-and-spank until **50% health**.
- At 50% (once): enrages (+150 speed) and summons **2 Bilge Rats**.
- On death: everyone nearby is credited (`QuestLog.storage.vault.rustbeard`).
- Rare drop: Corsair's Trophy (flavor, 15%).

### 2. Foreman Grix (mini-boss)
`data/monster/sunken_vault/foreman_grix.xml` · AI: `grix_ai.lua`

- Every 8 seconds casts **Overcharged Blast**: an AoE hit (45-75 dmg) in a
  3-tile radius around himself, telegraphed by "Take cover!". Groups should
  spread out or step away on the yell.
- On death: everyone nearby is credited (`QuestLog.storage.vault.grix`).

### 3. Captain Blackscale (final boss)
`data/monster/sunken_vault/captain_blackscale.xml` · AI: `blackscale_ai.lua`

Three-phase fight:
1. **100-60%**: melee plus a **Tidal Wave** AoE (60-100 dmg, 4-tile radius)
   every 10s.
2. **At 60% (once)**: calls in **2 Vault Corsairs** as reinforcements.
3. **At 25% (once)**: enrages - +200 speed and Tidal Wave cooldown drops to
   6s. This is the DPS check: burn through the last 25% quickly or the
   group takes repeated wave damage.

On death: everyone nearby is credited
(`QuestLog.storage.vault.blackscale`), a server-wide message announces the
kill, and he guarantees a drop of the **Sunken Vault Ledger** (quest item)
plus a chance at the Corsair's Trophy.

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/harbor_master_thessaly.xml` + `.../scripts/harbor_master_thessaly.lua` |
| Trash monsters | `data/monster/sunken_vault/{vault_goblin,vault_corsair,bilge_rat}.xml` |
| Bosses | `data/monster/sunken_vault/{rustbeard_the_mad,foreman_grix,captain_blackscale}.xml` |
| Boss AI | `data/creaturescripts/scripts/dungeons/{rustbeard,grix,blackscale}_ai.lua` |
| Gate | `data/actions/scripts/dungeons/sunken_vault_gate.lua` (actionid 10002, gate uid 10010) |
| Storage | `QuestLog.storage.vault.*` = 45020-45023 |
| Items | ledger 20005, cutlass 20006, key 20007, trophy 20008 |

## Map checklist

- [ ] Build entrance + two side rooms (Rustbeard, Grix) + junction + final
      flooded hall (Blackscale).
- [ ] Populate side rooms/entrance with trash spawns.
- [ ] Place Rustbeard, Grix and Blackscale as single-spawn (1 count) spawns
      in their rooms - do not put them in a shared spawn with trash.
- [ ] Place the lever (actionid `10002`) at the junction.
- [ ] Place the barred gate item (uniqueid `10010`) blocking the path to
      Blackscale's hall.
- [ ] Place Harbor Master Thessaly at the docks near the dungeon entrance.
