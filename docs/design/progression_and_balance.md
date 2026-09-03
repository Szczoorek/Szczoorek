# Progression & Balance Reference

A single place to see every number in this pack at once - useful for
sanity-checking pacing before you commit to a map layout, and for
rebalancing against your own server's exp rate / combat formulas, which
this doc deliberately doesn't assume anything about (see the caveat at the
bottom before reading "recommended tier" as gospel).

All numbers below are pulled directly from the XML/Lua in this pack as of
this doc's last update - if you rebalance something, this table will drift
out of date; there's no automation keeping it in sync, so treat it as a
snapshot, not a source of truth (the source of truth is always the actual
monster/item/npc files).

## Quest rewards

| Quest | Experience | Gold | Renown | Item reward |
|---|---:|---:|---:|---|
| 0. Boot Camp | 50 | 50 | +10 | Recruit's Training Blade |
| 1. Wolves at the Doorstep | 500 | 150 | +20 | Ranger's Charm (necklace, +2 armor) |
| 2. The Lost Locket | 300 | 100 | +15 | Corwin's Lucky Ring (+1 armor) |
| 3. Signal the Watch | 700 | 250 | +25 | Watchman's Badge (necklace, +3 armor) |
| 4. Sunken Vault (dungeon) | 4,000 | 1,500 | *(see below)* | Vault Captain's Cutlass |
| 5. Crimson Cathedral (dungeon) | 9,000 | 3,000 | *(see below)* | Ember-Warded Amulet |
| 10. Cinderforge Depths (raid) | 15,000 | 6,000 | *(see below)* | Emberlord's Signet |

Roughly doubling at each major tier (quests → dungeon 1 → dungeon 2 →
raid), which is a deliberate curve, not a coincidence - keep that ratio if
you rescale. The four simple quests (0-3) grant Renown once, at their NPC
hand-in; the dungeons and raid instead grant it per boss kill (everyone
credited for the kill gets it, same as faction reputation) - see
`docs/design/renown_and_pvp.md` for the full per-boss table.

## Repeatable content payouts

| Content | Payout | Cadence |
|---|---|---|
| Daily bounty (either dungeon) | 800 gold + 100 reputation + 10 renown | once/day/dungeon/player |
| Proving Grounds clear | 2,500 exp + 1,000 gold (+500 if under 5 min) + 15 renown | 15-min cooldown/player |

## Monster stat progression

Sorted by content tier. `HP`/`EXP` are each monster's own `<health now>` /
`experience` attribute - trash rows are the base (non-elite) stat line even
where a monster has slight variance.

### Quest trash (Quests 0-3)

| Monster | HP | EXP | Notes |
|---|---:|---:|---|
| Training Dummy | 90 | 0 | Never attacks - see Quest 0 |
| Timber Wolf | 90 | 30 | Quest 1; also a Fenrir/Proving Grounds add |
| Bilge Rat | 35 | 10 | Sunken Vault trash + Rustbeard's summon |
| Roadside Bandit | 110 | 45 | Quest 3; also a Proving Grounds wave |

### The Sunken Vault (Dungeon 1)

| Monster | HP | EXP | Role |
|---|---:|---:|---|
| Vault Goblin | 140 | 65 | trash |
| Vault Corsair | 160 | 80 | trash + Blackscale's summon |
| Rustbeard the Mad | 1,400 | 450 | mini-boss |
| Foreman Grix | 1,800 | 600 | mini-boss |
| Captain Blackscale | 4,200 | 1,500 | final boss |

### The Crimson Cathedral (Dungeon 2)

| Monster | HP | EXP | Role |
|---|---:|---:|---|
| Crimson Zealot | 260 | 140 | trash |
| Flame Acolyte | 220 | 150 | trash |
| Cathedral Guard | 360 | 190 | elite trash (sigil drop) |
| Animated Tome | 70 | 20 | Malachar's summon |
| Lesser Fire Elemental | 300 | 90 | Flameseer's summon |
| Brother Malachar | 2,600 | 900 | boss |
| Sister Ophelia | 2,400 | 950 | boss |
| Highlord Varek | 3,000 | 1,100 | boss |
| The Flameseer | 6,500 | 3,200 | final boss |

### The Cinderforge Depths (Raid)

| Monster | HP | EXP | Role |
|---|---:|---:|---|
| Molten Hound | 260 | 180 | trash + Proving Grounds wave |
| Forge Slave | 420 | 220 | trash + Proving Grounds wave |
| Cinderforge Smelter | 380 | 260 | trash + Proving Grounds wave |
| Ember Sentinel | 500 | 60 | Ashgrave's summon |
| Son of Cinder | 450 | 150 | Ignareth's summon |
| Kex Ironhide | 5,200 | 1,400 | boss (paired) |
| Dross Cinderhand | 5,200 | 1,400 | boss (paired) |
| Warden Grimtooth | 9,000 | 2,600 | boss |
| High Templar Ashgrave | 10,000 | 3,000 | boss |
| Slagmaw the Devourer | 11,000 | 3,200 | boss |
| Ignareth, the Cinderlord | 20,000 | 8,000 | final boss |

### World

| Monster | HP | EXP | Role |
|---|---:|---:|---|
| Fenrir the Alpha | 2,200 | 900 | open-world rare (sits between dungeon 1 and dungeon 2 in power) |

## The overall curve

```
Quest trash (10-45 exp)
  -> Vault/Cathedral trash (65-190 exp)
    -> Fenrir the Alpha (900 exp, rare)
      -> Sunken Vault bosses (450-1,500 exp)
        -> Crimson Cathedral bosses (900-3,200 exp)
          -> Cinderforge trash (180-260 exp)
            -> Cinderforge bosses (1,400-8,000 exp)
```

Note Fenrir sits deliberately between the two dungeons in power (900 exp,
2,200 HP) rather than being a true "early game" rare - he's meant to
remain a worthwhile detour even for a group that's already through the
Sunken Vault, not something you one-shot and forget about after Quest 1.

## Caveat: this is relative pacing, not absolute levels

This doc intentionally does **not** say "recommended character level X"
anywhere, because that number depends entirely on server-specific
variables this pack has no visibility into: your exp-rate multiplier,
your combat formula/skill scaling, your vocation balance, and whether
you're running anything close to stock 7.x/8.x/10.x Tibia combat math or
something heavily modified. A HP/EXP number that's "trivial for a level 30"
on one server's rates can be "unfair for a level 60" on another's.

What you can trust here is the **relative** shape: trash < mini-boss <
boss < final boss within a zone, and quest tier < dungeon 1 < dungeon 2 <
raid across the whole pack, consistently, everywhere. Use that shape as
your starting point and scale the absolute numbers (`<health>`,
`experience`, `<attack>` values, loot chances) to match wherever your own
server's characters actually sit power-wise at each stage - the design
docs for each piece call out which storage/item ids to touch if you
rename or renumber anything while you do.
