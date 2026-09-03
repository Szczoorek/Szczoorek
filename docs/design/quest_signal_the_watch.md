# Quest 3: Signal the Watch

A multi-stage "go light three things" quest - the WoW pattern used by
quests like lighting a set of signal fires or watch beacons around a zone.
Different shape from the other three quests on purpose: progress lives on
three separate map objects instead of a kill count or a single fetch item,
and light difficulty (Roadside Bandits) sits between Quest 1's wolves and
the dungeons' trash.

## Story

Bandits have doused the three signal beacons around the village outskirts
that the town watch relies on to know when the road needs attention.
**Watchman Farro** wants them relit - and the bandits still guarding them
dealt with.

## Flow

1. Player talks to **Watchman Farro**, says `watch` (or `signal`/`beacon`).
2. He explains and sets the quest to **STARTED**.
3. Player finds and fights past **Roadside Bandits** at three beacon sites
   (north, east, south) and uses each beacon once to light it. Each use:
   - Does nothing (with a hint) if the quest hasn't been started yet.
   - Lights that beacon and reports how many remain, if it wasn't already lit.
   - Reports "already lit" harmlessly if used again.
4. Once all three are lit, the player is told to report back. Saying
   `watch` to Farro again (with all three lit) immediately hands in the
   quest - no separate item to carry back, since the three storage flags
   *are* the proof.
5. Reward: 700 experience, 250 gold, 1x **Watchman's Badge** (necklace,
   id 20023, +3 armor).

## Files

| Piece | Path |
|---|---|
| NPC | `data/npc/watchman_farro.xml` + `.../scripts/watchman_farro.lua` |
| Beacon action | `data/actions/scripts/quests/signal_beacon.lua` (actionids 10003/10004/10005) |
| Trash monster | `data/monster/quest_signal/roadside_bandit.xml` |
| Storage | `QuestLog.storage.signal.{quest,beaconNorth,beaconEast,beaconSouth}` = 45004-45007 |
| Item | `QuestLog.items.watchmansBadge` = 20023 |

## Map checklist

- [ ] Place Watchman Farro somewhere central in the village, ideally with
      sightlines toward the outskirts (his dialogue implies he can see the
      beacons from where he stands).
- [ ] Place three existing brazier/torch-stand-looking map objects around
      the outskirts (north, east, south of the village) and give them
      actionids **10003**, **10004** and **10005** respectively. These
      reuse whatever decorative torch graphic your `items.otb` already
      has - no new item id needed for the beacons themselves.
- [ ] Scatter 2-3 Roadside Bandits near each beacon.
