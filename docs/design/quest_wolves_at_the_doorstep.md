# Quest 1: Wolves at the Doorstep

A short, level-appropriate starter quest in the WoW mould of "kill the local
wildlife, bring back proof" (think Elwynn Forest's wolf/kobold quests).
Meant to be a new character's first quest.

## Story

Timber wolves have been raiding the outskirts of a starting village. Ranger
Elyndra, stationed just outside the village gate, asks any able-bodied
traveler to thin their numbers and bring back pelts as proof.

## Flow

1. Player talks to **Ranger Elyndra**, says `quest` (or `wolves`/`mission`).
2. She explains the job and asks yes/no. Saying `yes` sets the quest to
   **STARTED**.
3. Player kills **Timber Wolves** in the woods near the village. Each wolf
   has a 75% chance to drop a **Wolf Pelt** (`QuestLog.items.wolfPelt`,
   id 20001).
4. Once the player has 5+ pelts, they say `pelts` to Elyndra.
5. She removes 5 pelts, grants:
   - 500 experience
   - 150 gold
   - 1x **Ranger's Charm** (necklace, id 20002, +2 armor)
   and sets the quest to **COMPLETED**.

No map trigger objects are needed for this quest - it's entirely
NPC-dialogue + monster-loot driven, which keeps it simple to place: put
Ranger Elyndra near the village gate and populate a nearby wood/clearing
with a small Timber Wolf spawn (4-8 wolves is plenty).

## Files

| Piece | Path |
|---|---|
| NPC definition | `data/npc/ranger_elyndra.xml` |
| NPC dialogue | `data/npc/scripts/ranger_elyndra.lua` |
| Monster | `data/monster/quest_wolves/timber_wolf.xml` |
| Storage | `QuestLog.storage.wolves` = 45001 (`data/lib/quest_log.lua`) |
| Items | `QuestLog.items.wolfPelt` = 20001, `QuestLog.items.rangersCharm` = 20002 |

## Map checklist

- [ ] Place Ranger Elyndra NPC outside the starting village.
- [ ] Create a Timber Wolf spawn in a nearby wood (suggested: 6 wolves,
      120s respawn).
- [ ] No action/unique ids required.
