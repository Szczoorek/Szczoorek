# Szczoorek — WoW-Inspired Content Pack for an Open Tibia Server (OTS)

This repository is a **content pack** (NPCs, monsters, scripts, items and design
docs) meant to be dropped into the `data/` folder of an Open Tibia Server.
It is *not* a full server distribution — it assumes you already have a working
OTS core and just want to bolt WoW-flavoured quests and dungeons onto it.

## Target engine

Everything here is written against **The Forgotten Server (TFS) 1.x** Lua/XML
conventions (`Player`/`Monster`/`Creature` userdata API, classic
`data/npc` + `data/monster` + `data/actions` + `data/creaturescripts` +
`data/talkactions` folder layout with XML registration files). Most
long-lived forks (OTX3, older TFS 0.4-derived servers, etc.) speak the same
dialect with only minor differences — if your server uses a different
scripting system (e.g. pure "revscriptsys"), you'll need to re-register the
events, but the Lua logic itself should port with little change.

## What's in here

```
data/
  lib/                     Shared helper libraries (auto-loaded before other scripts)
    quest_log.lua           Quest status tracking (storage values, status enum)
    dungeon_lib.lua          AoE damage / heal / summon helpers used by boss AI

  npc/                      Quest-giver NPCs (XML definition + look)
  npc/scripts/               NPC dialogue (Lua)

  monster/quest_wolves/      Trash mob for Quest 1
  monster/sunken_vault/       All creatures for Dungeon 1
  monster/crimson_cathedral/  All creatures for Dungeon 2

  creaturescripts/            Boss AI: spawn yells, phase changes, enrage,
                               adds, on-death rewards & broadcasts
  actions/                    Quest chest, dungeon gates/levers
  talkactions/                GM helper command to inspect/reset quest storages

  items/quest_items.xml       All new item definitions (fragment, see below)

docs/design/                  Lore, encounter design & walkthroughs for every
                               quest and dungeon, written for a GM/builder
                               who still has to place the map pieces
```

## The four starter quests/dungeons

| # | Name | Type | Design doc |
|---|------|------|------------|
| 1 | **Wolves at the Doorstep** | simple kill-and-collect quest | `docs/design/quest_wolves_at_the_doorstep.md` |
| 2 | **The Lost Locket** | simple fetch quest | `docs/design/quest_lost_locket.md` |
| 3 | **The Sunken Vault** | 3-boss dungeon (Deadmines-inspired) | `docs/design/dungeon_sunken_vault.md` |
| 4 | **The Crimson Cathedral** | 4-boss dungeon (Scarlet Monastery-inspired) | `docs/design/dungeon_crimson_cathedral.md` |

Each design doc contains the full story, NPC dialogue tree, encounter
mechanics for every boss, loot table and a suggested map layout — read it
alongside the scripts, since a lot of "what does this script assume about
the map" lives there rather than in code comments.

## Installing this pack

1. **Merge folders.** Copy everything under `data/` into your server's
   `data/` directory, keeping the sub-paths (e.g. `data/npc/ranger_elyndra.xml`
   goes to `<server>/data/npc/ranger_elyndra.xml`).
2. **Register the fragments.** The `*.xml` files that end in `.xml` inside
   `actions/`, `creaturescripts/` and `talkactions/` at the top of those
   folders (`data/actions/actions.xml`, `data/creaturescripts/creaturescripts.xml`,
   `data/talkactions/talkactions.xml`) are **fragments**: copy the `<action>`,
   `<event>` and `<talkaction>` lines they contain into your server's real
   `actions.xml` / `creaturescripts.xml` / `talkactions.xml` (don't overwrite
   your existing file, merge into it). Each fragment file says so again at
   the top as an XML comment.
3. **Add the items to `items.otb` before merging `items.xml`.** `items.xml`
   only carries *flags and text* for a server id that must already exist in
   `items.otb` — it cannot invent a new id by itself. `data/items/quest_items.xml`
   reserves server ids **20001–20012** for this pack:
   - Use your Item Editor (or otb generator of choice) to add entries for ids
     20001–20012 in `items.otb`. Each item's design doc / comment names what
     kind of object it is (a small trinket, a book, a key, a piece of jewellery,
     a one-handed sword) — reuse the client sprite of any existing similar item,
     since these are new server ids riding on an existing graphic, not new
     artwork.
   - Then merge the contents of `data/items/quest_items.xml` into your real
     `items.xml`.
   - If ids 20001–20012 collide with something you already use, renumber them
     consistently across `quest_items.xml` and every script that references
     an item id by name via the constants in `data/lib/quest_log.lua`
     (`QuestLog.items`) — every script pulls ids from that table, so it's a
     one-place edit.
4. **Reserved storage range.** All quest/progress state uses storage values
   **45000–45099** (see `QuestLog.storage` in `data/lib/quest_log.lua`). Make
   sure nothing else on your server writes into that range.
5. **Place the map pieces.** This pack ships no `.otbm` — you still need to
   build the actual rooms/caves/dungeon in the map editor. Each design doc
   describes what needs to exist (a wolf-infested clearing, a small cave with
   a chest, a sunken pirate vault, a cathedral with four wings) and calls out
   every unique/action id a placed object needs so the scripts fire.

## Testing

`/questreset <player name> <quest>` (GM-only talkaction, see
`data/talkactions/scripts/questreset.lua`) resets one player's progress on a
given quest (`wolves`, `locket`, `vault`, `cathedral`, or `all`) so you can
replay it while iterating on the map.
