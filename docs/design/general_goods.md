# General Goods

A small, ungated consumables vendor - unlike Quartermaster Reyes and
Armsmaster Cael (`docs/design/factions_and_achievements.md`), nothing here
requires reputation or an achievement. It's meant to be the very first shop
a new character can use, right after Boot Camp.

## Catalog

**Provisioner Nadia** sells three items for gold, no other requirement. Say
`goods` (or `shop`) for the catalog, or an item's keyword directly:

| Item | Keyword | Price | Effect |
|---|---|---|---|
| Healing Draught | `draught` | 100g | Consumed on use, heals 150 HP |
| Greater Healing Draught | `greater` | 300g | Consumed on use, heals 300 HP |
| Traveler's Hearthstone | `hearthstone` | 2,500g | **Not** consumed - teleports the player to a fixed home point, 30-minute cooldown |

The two draughts are plain single-use potions (`item:remove(1)` on use, no
cooldown - the gold cost and modest heal amount are the balance). The
Hearthstone is the interesting one: a direct homage to WoW's Hearthstone -
a keepsake item you use repeatedly rather than consume, gated by its own
cooldown rather than a price-per-use.

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/provisioner_nadia.xml` + `.../scripts/provisioner_nadia.lua` |
| Use scripts | `data/actions/scripts/consumables/{healing_draught,greater_healing_draught,travelers_hearthstone}.lua` (registered by **itemid**, not actionid - see `data/actions/actions.xml`) |
| Items | `QuestLog.items.{healingDraught,greaterHealingDraught,travelersHearthstone}` = 20031-20033 |
| Storage | `QuestLog.storage.hearthstoneCooldown` = 45051 (per player) |

## Map checklist

- [ ] Place Provisioner Nadia in the village hub, near the other NPCs.
- [ ] Update `HOME_POSITION` in
      `data/actions/scripts/consumables/travelers_hearthstone.lua` to the
      real village hub bind spot once it exists on your map - it's a
      placeholder (`Position(1000, 1000, 7)`) until then.
- [ ] No action/unique ids required for the NPC; the three consumables
      register themselves by item id, so nothing needs Action ID tagging
      in the map editor either.
