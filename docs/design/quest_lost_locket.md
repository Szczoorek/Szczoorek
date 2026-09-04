# Quest 2: The Lost Locket

A short fetch quest in the WoW mould of low-level "go find my thing in that
cave" quests (e.g. Elwynn's "A Threat Denied"/item-retrieval style quests).
No combat required - good as a very first or non-combat-friendly quest.

## Story

Old Man Corwin, at the edge of the village, lost his late wife's locket in a
small cave years ago and can no longer make the climb down. He asks a
passer-by to retrieve it.

## Flow

1. Player talks to **Old Man Corwin**, says `locket`.
2. If the quest hasn't started, he explains and sets it to **STARTED**.
3. Player travels to the small cave north of the village and uses the old
   **chest** inside (actionid `10001`). This grants a **Tarnished Locket**
   (`QuestLog.items.tarnishedLocket`, id 20003) once.
4. Player returns to Corwin and says `locket` again (the NPC script checks
   for the item automatically - no separate "hand in" keyword needed).
5. He removes the locket, grants:
   - 300 experience
   - 100 gold
   - 1x **Corwin's Lucky Ring** (ring, id 20004, +1 armor)
   and sets the quest to **COMPLETED**.

## Files

| Piece | Path |
|---|---|
| NPC definition | `data/npc/old_man_corwin.lua` |
| NPC dialogue | `data/npc/old_man_corwin.lua` |
| Chest action | `data/scripts/actions/quests/lost_locket_chest.lua` |
| Storage | `QuestLog.storage.locket` = 45010 |
| Items | `QuestLog.items.tarnishedLocket` = 20003, `QuestLog.items.corwinsLuckyRing` = 20004 |

## Map checklist

- [ ] Place Old Man Corwin NPC at the edge of the village.
- [ ] Build a small cave to the north (a handful of rooms is plenty - this
      is meant to be quick, not a dungeon).
- [ ] Place a chest-looking item inside the cave and set its **Action ID**
      to `10001` in the map editor.
- [ ] Optional flavor: a couple of low-level cave critters (bats, spiders,
      whatever your base monster set has) along the way, purely for
      atmosphere - this quest doesn't require any kills.
