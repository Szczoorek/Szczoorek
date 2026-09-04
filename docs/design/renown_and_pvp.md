# Renown & Open-World PvP

A general-purpose reputation score, separate from the two dungeon-tied
factions (`docs/design/factions_and_achievements.md`): **Renown** rises
from PvE progress across the *whole* pack - every quest, every dungeon and
raid completion, every boss kill, every bounty and Proving Grounds clear -
and falls when a player kills another player out in the open world. Unlike
the faction reputations, it can go negative, and going far enough negative
has a real consequence: the pack's vendors refuse to deal with you.

## Why a third reputation track, not the existing two factions

Harbor Trade Concern and Order of the Ember are deliberately *narrow* -
they represent standing with the specific faction tied to one dungeon's
storyline, which is why only that dungeon's bosses feed them. Killing
Timber Wolves for Ranger Elyndra has nothing to do with the Harbor Trade
Concern, so it shouldn't move that number. Renown is the opposite: a
single, general "how well-regarded are you" score that everything PvE-ish
feeds into, and that PvP behavior can drain. Both systems coexist
unchanged - Renown doesn't replace or interact with the faction ranks
except at the vendors (see below).

## Gaining Renown

| Source | Renown |
|---|---:|
| Boot Camp | +10 |
| Wolves at the Doorstep | +20 |
| The Lost Locket | +15 |
| Signal the Watch | +25 |
| Sunken Vault: Rustbeard / Grix (each) | +30 |
| Sunken Vault: Captain Blackscale | +60 |
| Crimson Cathedral: Malachar / Ophelia / Varek (each) | +40 |
| Crimson Cathedral: The Flameseer | +90 |
| Cinderforge Depths: Grimtooth / Twins / Slagmaw / Ashgrave (each) | +60 |
| Cinderforge Depths: Ignareth | +150 |
| Fenrir the Alpha | +40 |
| Daily bounty (either dungeon) | +10 |
| Proving Grounds clear | +15 |

Boss kills grant Renown to every player credited for the kill (same
`DungeonLib.grantRenownToNearby` pattern already used for faction
reputation and quest-storage credit) - see each boss AI script. The four
simple quests grant it once, at their NPC hand-in.

## Losing Renown: open-world PvP

`data/scripts/creaturescripts/pvp/renown_penalty.lua` docks **50 Renown**
from a player who kills another player, by default only when the kill was
**unjustified** - i.e. it leans on Tibia's own built-in skull/frag system
to tell an unprovoked gank apart from a legitimate PvP kill (retaliation,
a returned attack, a sanctioned war), rather than this pack re-implementing
that judgment call itself. Set `PENALIZE_ALL_PVP_KILLS = true` at the top
of that script if you'd rather penalize every open-world player kill
regardless of the game's own justification logic.

50 Renown is a real cost - roughly a Wolves-at-the-Doorstep-and-a-half -
but a deliberately recoverable one: the four starter quests alone (10 + 20
+ 15 + 25 = 70) more than cover digging out of a single kill. This is a
soft consequence meant to make PKing cost something, not a death spiral
that locks a character out of the game.

### ⚠️ Installing this piece specifically

Every other script in this pack self-registers just by dropping the file
in - no XML, no separate registration step. This one is different:
**a `CreatureEvent` has to be attached to every player**, and unlike a
monster (which attaches its own events via `mType:registerEvent(...)` at
the bottom of its own file) there's no per-player file in this pack to do
that from. It has to happen through your server's *existing* login script
(every real Canary server already has one - it's core functionality, not
something this pack provides). Find wherever it calls
`player:registerEvent(...)` at login and add:

```lua
player:registerEvent('RenownPvpPenalty')
```

alongside whatever other events it already registers. Don't skip this -
without it, `renown_penalty.lua` defines and registers the
`RenownPvpPenalty` `CreatureEvent` itself, but it never actually attaches
to any player and so never fires.

### The onDeath signature

`renown_penalty.lua` is written against Canary's `CreatureEvent` onDeath
shape:

```lua
onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
```

(Some Canary docs/examples call the fifth parameter `lastHitUnjustified`
instead of `unjustified` - same value, just a naming difference between
sources; the script uses `unjustified`.) If a future Canary version changes
this shape - e.g. to a `deathList` table for multi-assist credit - the
actual logic (find the killer, check whether it was unjustified, dock
Renown) ports over unchanged; only the parameter list would need to
change. The script itself carries this same note at the top.

## Renown gates the vendors

This is what makes Renown matter beyond a number on a status screen: every
vendor in the pack - Quartermaster Reyes, Armsmaster Cael
(`data/lib/vendor_lib.lua`, shared by both) and Provisioner Nadia
(`data/npc/provisioner_nadia.lua`, checked independently since she
doesn't use that shared lib) - refuses to trade at all once a player's
Renown drops below **Neutral** (0). This is on top of, not instead of,
each vendor's own faction-rank gating - a player could be Exalted with the
Harbor Trade Concern and still get turned away at the door if their Renown
has tanked from PKing.

If you want other NPCs (quest givers, etc.) to also refuse a
Renown-negative player, the pattern is a one-line copy from
`vendor_lib.lua`:

```lua
if not player:hasRenownRank('Neutral') then
	-- refuse, same as the vendors do
end
```

This pack doesn't apply that to quest-giver NPCs itself - locking a
recovering PKer out of the very quests that would rebuild their Renown
would be the death-spiral this design explicitly avoids.

## Ranks

| Rank | Threshold |
|---|---:|
| Outlaw | -2,000 (floor) |
| Reviled | -500 |
| Suspicious | -100 |
| Neutral | 0 |
| Respected | 250 |
| Renowned | 750 |
| Champion | 2,000 (soft ceiling at 50,000) |

Check your own Renown any time with `!renown`.

## Files

| Piece | Path |
|---|---|
| Lib | `data/lib/renown_log.lua` |
| PvP penalty hook | `data/scripts/creaturescripts/pvp/renown_penalty.lua` (self-registers as `CreatureEvent('RenownPvpPenalty')` - **needs the login.lua line above to actually fire**) |
| Vendor gate | `data/lib/vendor_lib.lua` (Reyes/Cael) + `data/npc/provisioner_nadia.lua` |
| Player command | `data/scripts/talkactions/renown.lua` (`!renown`) |
| GM reset | `data/scripts/talkactions/questreset.lua` - `renown` is its own key, separate from `all` (see the script's header comment for why) |
| Storage | `RenownLog.storage.value` = 45102 (inside the 45100-45109 block `reputation_log.lua` already reserves) |

## Map checklist

- [ ] Nothing new to place on the map - Renown is pure systemic logic
      layered on content that already exists.
- [ ] Do the login.lua registration above before relying on the PvP
      penalty - it's the one step in this whole pack that isn't a simple
      file drop.
