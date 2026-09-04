# Quest 0: Boot Camp

A zero-risk tutorial quest meant to be the very first thing a brand-new
character does - the same role Northshire Abbey's training dummies play in
WoW's human starting experience. Purely mechanical (teaches "walk up to a
monster and attack it"), no lore weight, over in under a minute.

## Story

Sergeant Coleman drills new arrivals before letting them loose on the rest
of the village. He points new characters at a Training Dummy - a monster
that never fights back - so their first swing in the world doesn't risk
their first death too.

## Flow

1. Player talks to **Sergeant Coleman**, says `training`.
2. He explains and sets the quest to **STARTED**.
3. Player attacks the **Training Dummy** until it dies (90 HP, 0 attack -
   it cannot hurt the player under any circumstance).
4. Player returns to Coleman and says `training` again.
5. He grants:
   - 50 experience
   - 50 gold
   - 1x **Recruit's Training Blade** (a basic starter weapon, id 20022)
   sets the quest to **COMPLETED**, and points the player at Ranger Elyndra
   and Old Man Corwin (Quests 1 and 2) for their first real content.

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/sergeant_coleman.lua` |
| Monster | `data/monster/quest_bootcamp/training_dummy.lua` |
| Death script | `data/scripts/creaturescripts/quests/training_dummy_death.lua` |
| Storage | `QuestLog.storage.bootcamp.{quest,dummyDefeated}` = 45002-45003 |
| Item | `QuestLog.items.recruitsTrainingBlade` = 20022 |

## Map checklist

- [ ] Place Sergeant Coleman at the very entrance of the starting village -
      this should be the first NPC a new character sees.
- [ ] Place a single Training Dummy a few tiles away, in full view of
      Coleman, with a 1-count spawn (instant respawn is fine, or a short
      one - it never dies "for real", it's meant to always be available).
- [ ] No action/unique ids required.
