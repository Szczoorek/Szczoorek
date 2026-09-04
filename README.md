# Szczoorek — WoW-Inspired Content Pack for an Open Tibia Server (OTS)

This repository is a **content pack** (NPCs, monsters, scripts, items and design
docs) meant to be dropped into the `data/` folder of an Open Tibia Server.
It is *not* a full server distribution — it assumes you already have a working
OTS core and just want to bolt WoW-flavoured quests and dungeons onto it.

## Target engine

Everything here is written against **[Canary](https://github.com/opentibiabr/canary)**,
targeting **protocol 15.25**. Concretely that means:

- **NPCs and monsters are plain Lua files**, not XML — `Game.createNpcType()`
  / `Game.createMonsterType()` plus a config table, each ending in a
  `:register(config)` call. There is no `data/npc/*.xml` or
  `data/monster/*.xml` in this pack at all.
- **Actions, creaturescripts, talkactions and globalevents self-register**
  via revscriptsys metatables (`Action()`, `CreatureEvent("Name")`,
  `TalkAction("words")`, `GlobalEvent("Name")`, each ending in
  `:register()`, with `:aid()`/`:id()`/`:uid()` for actions and
  `:interval()` for globalevents). There is no `actions.xml`,
  `creaturescripts.xml`, `talkactions.xml` or `globalevents.xml` fragment
  to merge — every script is complete and self-contained.
- **NPC dialogue** still runs on the classic `KeywordHandler`/`NpcHandler`/
  `FocusModule` library (Canary ships the same `npclib`), just wired up
  through `npcType.onSay`/`onAppear`/`onThink`/etc. callbacks that take
  `npc`/`creature` objects instead of a bare `cid`, and keyword matching
  uses `MsgContains(message, 'word')` instead of `msg:find('word')`.
- **Monster combat** uses direct `minDamage`/`maxDamage` (negative numbers)
  per attack, not TFS's `skill`+`attack` formula pair, and damage-type
  immunity is expressed via `monster.elements` (percent-based), with a
  separate `monster.immunities` table for status effects (paralyze,
  invisible, etc.) only.
- **Items** are registered in the *core* `data/items/items.xml` (shared
  engine data, alongside `appearances.dat`) rather than in this pack's own
  `data/` tree, and a new item id needs an appearance registered against
  `appearances.dat` before the client renders it — items.xml alone isn't
  enough the way old TFS `items.otb` reuse was. See step 3 under
  "Installing this pack" below.

A few specifics in this pack carry lower confidence than the rest — flagged
inline where they matter: the exact `Action`/`GlobalEvent` accessor method
names (`:id()` for itemid, `:interval()`), and the `CreatureEvent` `onDeath`
parameter shape (confirmed against real Canary source/community examples,
but note the naming inconsistency between `unjustified` and
`lastHitUnjustified` in different docs — same value either way). If a
future Canary version has moved any of these, the actual game-design logic
inside each script is untouched — only the thin registration wrapper would
need to change.

## What's in here

```
data/
  lib/                     Shared helper libraries (auto-loaded before other scripts)
    quest_log.lua            Quest status tracking (storage values, status enum, item ids)
    dungeon_lib.lua          AoE damage / heal / summon / phase-trigger helpers used by boss AI
    reputation_log.lua       Faction standing (two factions, five ranks each)
    achievement_log.lua      One-time achievement flags + server-wide announcements
    vendor_lib.lua           Shared dialogue logic for reputation-gated vendor NPCs
    bounty_log.lua           Daily repeatable bounty progress/reset tracking
    trial_log.lua            Proving Grounds wave-survival session state
    renown_log.lua           General PvE-wide Renown score (PvP-drainable)

  npc/                      Quest-givers and vendors - one self-contained .lua
                             file per NPC (look, dialogue and registration
                             all in the same file, Canary-style)

  monster/quest_bootcamp/     Training Dummy for Quest 0
  monster/quest_wolves/      Trash mob for Quest 1
  monster/quest_signal/       Trash mob for Quest 3
  monster/sunken_vault/        All creatures for Dungeon 1
  monster/crimson_cathedral/    All creatures for Dungeon 2
  monster/cinderforge_depths/    All creatures for the Raid
  monster/world/                  Open-world rare spawn (Fenrir the Alpha)

  scripts/actions/             Quest chest, dungeon/raid gates & levers,
                                General Goods consumables (each self-registers
                                by actionid or itemid - no XML needed)
  scripts/creaturescripts/quests/     Quest 0's training dummy death hook
  scripts/creaturescripts/dungeons/  Boss AI for Dungeons 1 & 2: spawn
                                      yells, phase changes, enrage, adds,
                                      on-death rewards & broadcasts (each
                                      boss = two CreatureEvents, "...Think"
                                      and "...Death")
  scripts/creaturescripts/raid/       Boss AI for the Raid
  scripts/creaturescripts/world/      Fenrir the Alpha's AI
  scripts/creaturescripts/bounties/    Trash-kill credit for daily bounties
  scripts/creaturescripts/pvp/         Renown PvP-kill penalty (needs a
                                        manual login.lua registration - see
                                        step 5 below)
  scripts/talkactions/          /questreset (GM), !quests, !achievements,
                                 !reputation, !renown (players)
  scripts/globalevents/         Fenrir's respawn timer, Proving Grounds tick

  items/quest_items.xml       All new item definitions (fragment - merges
                               into the *core* items.xml, see below)

docs/design/                  Lore, encounter design, loot tables & map
                               placement checklists for every piece, written
                               for a GM/builder who still has to place the
                               map pieces

tools/verify_pack.sh          Static checks over the whole data/ tree - see
                               "Verifying the pack" below
```

## What's in the pack

| # | Name | Type | Design doc |
|---|------|------|------------|
| 0 | **Boot Camp** | zero-risk newbie tutorial quest | `docs/design/quest_boot_camp.md` |
| 1 | **Wolves at the Doorstep** | simple kill-and-collect quest | `docs/design/quest_wolves_at_the_doorstep.md` |
| 2 | **The Lost Locket** | simple fetch quest | `docs/design/quest_lost_locket.md` |
| 3 | **Signal the Watch** | multi-stage "light 3 beacons" quest | `docs/design/quest_signal_the_watch.md` |
| 4 | **The Sunken Vault** | 3-boss dungeon (Deadmines-inspired) | `docs/design/dungeon_sunken_vault.md` |
| 5 | **The Crimson Cathedral** | 4-boss dungeon (Scarlet Monastery-inspired) | `docs/design/dungeon_crimson_cathedral.md` |
| 6 | **Faction reputation & vendors** | systemic (spans dungeons 4 & 5) | `docs/design/factions_and_achievements.md` |
| 7 | **Achievements** | systemic (spans everything) | `docs/design/factions_and_achievements.md` |
| 8 | **Fenrir the Alpha** | open-world rare spawn | `docs/design/fenrir_the_alpha.md` |
| 9 | **Daily bounties** | repeatable trash-clear dailies for dungeons 4 & 5 | `docs/design/daily_bounties.md` |
| 10 | **The Cinderforge Depths** | 5-boss raid (Molten Core/BRD-inspired), gated behind dungeons 4 & 5's achievements | `docs/design/dungeon_cinderforge_depths.md` |
| 11 | **The Proving Grounds** | repeatable 5-wave survival arena, 15-min cooldown | `docs/design/the_proving_grounds.md` |
| 12 | **General Goods** | ungated consumables vendor (potions + a Hearthstone) | `docs/design/general_goods.md` |
| 13 | **Renown & Open-World PvP** | systemic (spans everything) — PvE gains it, PvP kills drain it, low Renown locks out every vendor | `docs/design/renown_and_pvp.md` |

`docs/design/starting_zone_overview.md` ties all of the above into one
suggested map layout (hub town, wilds, dungeon entrances) — read that one
first if you're about to start building. `docs/design/progression_and_balance.md`
pulls every monster's HP/EXP and every quest's reward into one reference
table, for pacing and rebalancing.

Each design doc contains the full story, NPC dialogue tree, encounter
mechanics for every boss, loot table and a suggested map layout — read it
alongside the scripts, since a lot of "what does this script assume about
the map" lives there rather than in code comments. The design docs
themselves are engine-agnostic (lore, numbers, map layout don't change
between TFS and Canary) — only the "Files" table paths and the odd
implementation note that mentions "the map editor's actionid field" reflect
Canary's structure now.

## Installing this pack

1. **Merge folders.** Copy everything under `data/` into your server's
   `data/` directory (e.g. into `data-otservbr-global/` or `data-canary/`,
   whichever datapack you're extending), keeping the sub-paths - e.g.
   `data/npc/ranger_elyndra.lua` goes to
   `<your-datapack>/npc/ranger_elyndra.lua`.
2. **Nothing to register separately.** Unlike a classic TFS XML+fragment
   pack, every script here is self-contained and self-registering
   (`Action():register()`, `CreatureEvent("Name"):register()`, etc.) - just
   dropping the files in is enough for the engine to pick them up. The one
   exception is the Renown PvP hook, see step 5.
3. **Register the new items before merging `items.xml`.** A server id here
   only does anything once it exists in your server's *core* `items.xml`
   (in `data/items/`, alongside `appearances.dat` — not this pack's own
   `data/items/quest_items.xml`, which is a merge-in fragment) **and** has
   an appearance registered against `appearances.dat`. `quest_items.xml`
   reserves server ids **20001–20033**:
   - Use your item/appearance tooling to add ids 20001–20033 with an
     appearance each. Each entry's comment names what kind of object it is
     (a small trinket, a book, a key, a piece of jewellery, a one-handed
     sword, a piece of armor) — point it at the appearance of any existing
     similar item rather than commissioning new art.
   - Then merge the contents of `data/items/quest_items.xml` into your
     real `items.xml`.
   - Two entries (the Sunken Vault Ledger and the Scarlet Prayer Book)
     carry a `text` attribute — make sure those two ids are flagged
     readable so it displays on use.
   - If ids 20001–20033 collide with something you already use, renumber
     them consistently across `quest_items.xml` and every script that
     references an item id by name via the constants in
     `data/lib/quest_log.lua` (`QuestLog.items`) — every script pulls ids
     from that table, so it's a one-place edit.
4. **Reserved storage ranges.**
   - Quest/dungeon progress: **45000–45099** (`QuestLog.storage` in
     `data/lib/quest_log.lua`).
   - Faction reputation: **45100–45109** (`ReputationLog.storage` in
     `data/lib/reputation_log.lua`).
   - Achievements: **45110–45119** (`AchievementLog.storage` in
     `data/lib/achievement_log.lua`).
   - Daily bounties: **45120–45129** (`BountyLog.storage` in
     `data/lib/bounty_log.lua`).
   - Proving Grounds cooldown: **45050** (`TrialLog.storage.lastAttempt` in
     `data/lib/trial_log.lua` - carved out of the quest/dungeon block above
     since it's a separate lib, but still inside that same 45000–45099
     range).
   - Renown: **45102** (`RenownLog.storage.value` in
     `data/lib/renown_log.lua` - the next free slot inside the reputation
     block above; Harbor Trade Concern/Order of the Ember use 45100/45101).

   Make sure nothing else on your server writes into those ranges.
5. **Renown's PvP penalty needs one manual step.** Unlike everything else
   in this pack, `data/scripts/creaturescripts/pvp/renown_penalty.lua`
   can't self-register onto players - it has to be attached via your
   server's *existing* login script. Find wherever it calls
   `player:registerEvent(...)` (typically a `login.lua`) and add
   `player:registerEvent('RenownPvpPenalty')` alongside whatever else it
   already registers. See "Installing this piece specifically" in
   `docs/design/renown_and_pvp.md` for more detail and a parameter-shape
   compatibility note.
6. **Place the map pieces.** This pack ships no map file — you still need
   to build the actual rooms/caves/dungeon in the map editor. Each design
   doc describes what needs to exist (a wolf-infested clearing, a small
   cave with a chest, a sunken pirate vault, a cathedral with four wings)
   and calls out every action id/unique id a placed object needs (set the
   same way as ever in the map editor - actions carry their id via
   `:aid()`/`:uid()` in the script now instead of an XML attribute, but the
   map-editor side of tagging an object with that id is unchanged) so the
   scripts fire. `docs/design/starting_zone_overview.md` shows how all the
   pieces relate to each other on one map.
7. **Update Fenrir the Alpha's spawn position.** `FENRIR_SPAWN_POSITION` in
   `data/scripts/globalevents/fenrir_respawn.lua` is a placeholder — point
   it at the real position once you've built the Timber Wolf forest (see
   `docs/design/fenrir_the_alpha.md`).

## Verifying the pack

`tools/verify_pack.sh` runs static sanity checks over the whole `data/`
tree - no live Canary server needed, which matters since this pack was
converted without one to test against. It catches Lua syntax errors,
malformed XML, duplicate `:aid()`/`:id()`/`CreatureEvent`/`TalkAction`/
`GlobalEvent` registrations that would silently shadow one another, item
ids used in Lua but undefined in `quest_items.xml` (or vice versa), storage
values reused across different libs, and monster names referenced in
scripts that don't exactly match any defined monster's `Game.createMonsterType(...)`
name (a typo there fails silently at runtime - `Game.createMonster`/
`Game.getSpectators` just won't find anything).

Requires `luac` (any Lua 5.x) and `xmllint` on `PATH`. Run it after making
any change to this pack:

```sh
tools/verify_pack.sh
```

Exits 0 and prints "All checks passed." when clean; otherwise prints one
or more `FAIL:` lines and exits 1. This was run clean against every file
in this pack as of the last commit that touched `data/`.

## Testing

- `/questreset <player name>, <quest>` (GM-only talkaction, see
  `data/scripts/talkactions/questreset.lua`) resets one player's progress
  on a given quest (`bootcamp`, `wolves`, `locket`, `signal`, `vault`,
  `cathedral`, `raid`, `all`, or `renown`) so you can replay it while
  iterating on the map.
- `!quests`, `!achievements`, `!reputation` and `!renown` (player-facing)
  let anyone check their own progress — across every quest/dungeon/raid,
  achievements, faction standing, and general Renown respectively —
  without needing a GM.
