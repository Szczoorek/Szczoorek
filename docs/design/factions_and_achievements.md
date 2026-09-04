# Factions, Reputation & Achievements

Two systemic, WoW-flavored layers that sit on top of the quests/dungeons
rather than belonging to any single one of them.

## Reputation

Two factions, one per starter dungeon. Killing a dungeon's bosses raises
standing with its faction; standing unlocks tiers of gear at that faction's
quartermaster.

| Faction | Tied to | Vendor NPC |
|---|---|---|
| Harbor Trade Concern | The Sunken Vault | Quartermaster Reyes |
| Order of the Ember | The Crimson Cathedral | Armsmaster Cael |

Ranks (same thresholds for both factions):

| Rank | Threshold |
|---|---|
| Neutral | 0 |
| Friendly | 500 |
| Honored | 1500 |
| Revered | 3000 |
| Exalted | 6000 |

Reputation awarded per boss kill (credited to every player near the kill,
same as quest credit):

**Sunken Vault → Harbor Trade Concern**
- Rustbeard the Mad: +150
- Foreman Grix: +150
- Captain Blackscale: +300

**Crimson Cathedral → Order of the Ember**
- Brother Malachar: +150
- Sister Ophelia: +150
- Highlord Varek: +150
- The Flameseer: +300

A full clear of either dungeon nets 600 reputation, so reaching Friendly
takes about one clear, Honored about three, Revered six, Exalted twelve -
deliberately a medium-term grind rather than a one-run unlock, same shape
as a WoW dungeon faction.

### Vendor catalogs

Bought with gold *and* gated by rank - say `shop` to either NPC for your
current standing and the full catalog; say an item's keyword to buy it.

**Quartermaster Reyes** (Harbor Trade Concern)

| Rank | Item | Slot | Keyword | Price |
|---|---|---|---|---|
| Friendly | Corsair's Boots | feet | `boots` | 5,000g |
| Honored | Harbor Guard Plate | body | `plate` | 15,000g |
| Revered | Tidebreaker Shield | shield | `shield` | 35,000g |
| Exalted | Blackscale's Signet | ring | `signet` | 75,000g |

**Armsmaster Cael** (Order of the Ember)

| Rank | Item | Slot | Keyword | Price |
|---|---|---|---|---|
| Friendly | Ember-Touched Gloves | hands | `gloves` | 5,000g |
| Honored | Cathedral Warden's Helm | head | `helm` | 15,000g |
| Revered | Zealot's Legguards | legs | `legguards` | 35,000g |
| Exalted | Flamewrought Crown | head | `crown` | 75,000g |

Item ids: `data/lib/quest_log.lua` → `QuestLog.items.{corsairsBoots,
harborGuardPlate, tidebreakerShield, blackscalesSignet,
emberTouchedGloves, cathedralWardensHelm, zealotsLegguards,
flamewroughtCrown}` = 20013-20020.

Players can check their own standing any time with `!reputation`.

## Achievements

A minimal one-time-flag achievement system: earning one sends the player a
message, plays an effect, and **broadcasts a server-wide announcement** -
deliberately visible, the way WoW's achievement toasts are meant to be
noticed by more than just the player who earned it.

| Achievement | Earned by |
|---|---|
| Vault Cleaner | Completing "Secrets of the Sunken Vault" |
| Cathedral's Bane | Completing "Purge the Crimson Cathedral" |
| Fenrir's Bane | Landing (or being nearby for) the killing blow on Fenrir the Alpha |

Players check their own list with `!achievements`.

## Files

| Piece | Path |
|---|---|
| Reputation lib | `data/lib/reputation_log.lua` |
| Achievement lib | `data/lib/achievement_log.lua` |
| Vendor dialogue lib | `data/lib/vendor_lib.lua` |
| Vendor NPCs | `data/npc/{quartermaster_reyes,armsmaster_cael}.lua` |
| Player commands | `data/scripts/talkactions/{achievements,reputation}.lua` |
| Storage | `ReputationLog.storage.*` = 45100-45101, `AchievementLog.storage.*` = 45110-45112 |

## Map checklist

- [ ] Place Quartermaster Reyes near Harbor Master Thessaly at the docks.
- [ ] Place Armsmaster Cael near Inquisitor Dane outside the cathedral.
- [ ] No action/unique ids required - both are pure dialogue NPCs.
