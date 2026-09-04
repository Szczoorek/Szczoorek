#!/usr/bin/env bash
#
# verify_pack.sh - static sanity checks for this content pack (Canary /
# protocol 15.25 target).
#
# There's no live Canary server to test against here, so this is the next
# best thing: catches Lua syntax errors, malformed XML, duplicate
# :aid()/:id()/CreatureEvent/TalkAction/GlobalEvent registrations that
# would silently shadow one another, a monster's mType:registerEvent(...)
# call with no matching CreatureEvent defined anywhere, item ids used in
# Lua but never defined in quest_items.xml (or vice versa), and monster
# names referenced in scripts that don't match any defined
# Game.createMonsterType(...) name exactly (Lua string, case-sensitive -
# Game.createMonster/Game.getSpectators fail silently on a typo).
#
# Requires `luac` (any 5.x) and `xmllint` on PATH. Run from anywhere; it
# locates the repo root from its own location.
#
# Usage: tools/verify_pack.sh
# Exit code is 0 if everything passes, 1 if anything failed.

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail=0
note() { echo "-- $1"; }
problem() { echo "FAIL: $1"; fail=1; }

LUAC="$(command -v luac || command -v luac5.1 || command -v luac5.3 || true)"
if [ -z "$LUAC" ]; then
	echo "luac not found on PATH - install lua5.1 (or any lua5.x) to run this check." >&2
	exit 2
fi
if ! command -v xmllint >/dev/null; then
	echo "xmllint not found on PATH - install libxml2-utils to run this check." >&2
	exit 2
fi

note "Lua syntax (luac -p) over all *.lua files"
while IFS= read -r f; do
	out=$("$LUAC" -p "$f" 2>&1) || { problem "$f"; echo "$out"; }
done < <(find data -name '*.lua')

note "XML well-formedness (xmllint --noout) over all *.xml files"
while IFS= read -r f; do
	out=$(xmllint --noout "$f" 2>&1) || { problem "$f"; echo "$out"; }
done < <(find data -name '*.xml')

note "Duplicate registrations (:aid / :id / CreatureEvent / TalkAction / GlobalEvent names)"
dup() { sort | uniq -d; }
d=$(grep -rhoP '(?<=:aid\()[0-9, ]+(?=\))' data/scripts/actions | tr ',' '\n' | tr -d ' ' | dup)
[ -n "$d" ] && problem "duplicate action :aid() value(s): $d"
d=$(grep -rhoP '(?<=:id\()[0-9, ]+(?=\))' data/scripts/actions | tr ',' '\n' | tr -d ' ' | dup)
[ -n "$d" ] && problem "duplicate action :id() (itemid) value(s): $d"
d=$(grep -rhoP "(?<=CreatureEvent\(')[^']+" data/scripts/creaturescripts | dup)
[ -n "$d" ] && problem "duplicate CreatureEvent name(s): $d"
d=$(grep -rhoP "(?<=TalkAction\(')[^']+" data/scripts/talkactions | dup)
[ -n "$d" ] && problem "duplicate TalkAction words: $d"
d=$(grep -rhoP "(?<=GlobalEvent\(')[^']+" data/scripts/globalevents | dup)
[ -n "$d" ] && problem "duplicate GlobalEvent name(s): $d"

note "Monster mType:registerEvent(...) calls vs CreatureEvent(...) definitions"
grep -rhoP "(?<=CreatureEvent\(')[^']+" data/scripts/creaturescripts | sort -u > /tmp/verify_defined_events.$$
grep -rhoP "(?<=registerEvent\(\")[^\"]+" data/monster | sort -u > /tmp/verify_used_events.$$
missing=$(comm -23 /tmp/verify_used_events.$$ /tmp/verify_defined_events.$$)
[ -n "$missing" ] && problem "monster registerEvent(...) name(s) with no matching CreatureEvent('...') definition: $missing"

note "Item ids: QuestLog.items (data/lib/quest_log.lua) vs quest_items.xml definitions"
sed -n '/^QuestLog.items = {/,/^}/p' data/lib/quest_log.lua | grep -oP '2\d{4}' | sort -un > /tmp/verify_lua_items.$$
grep -oP '(?<=<item id=")\d+' data/items/quest_items.xml | sort -un > /tmp/verify_xml_items.$$
missing=$(comm -23 /tmp/verify_lua_items.$$ /tmp/verify_xml_items.$$)
[ -n "$missing" ] && problem "item id(s) in QuestLog.items with no quest_items.xml entry: $missing"
orphan=$(comm -13 /tmp/verify_lua_items.$$ /tmp/verify_xml_items.$$)
[ -n "$orphan" ] && echo "NOTE (not a failure): quest_items.xml id(s) not in QuestLog.items table: $orphan"
d=$(grep -oP '(?<=<item id=")\d+' data/items/quest_items.xml | dup)
[ -n "$d" ] && problem "duplicate item id(s) in quest_items.xml: $d"

note "Storage value collisions across QuestLog/ReputationLog/AchievementLog/BountyLog/TrialLog/RenownLog"
{
	sed -n '/^QuestLog.storage = {/,/^}/p' data/lib/quest_log.lua | grep -oP '4\d{4}'
	sed -n '/^ReputationLog.storage = {/,/^}/p' data/lib/reputation_log.lua | grep -oP '4\d{4}'
	sed -n '/^AchievementLog.storage = {/,/^}/p' data/lib/achievement_log.lua | grep -oP '4\d{4}'
	sed -n '/^BountyLog.storage = {/,/^}/p' data/lib/bounty_log.lua | grep -oP '4\d{4}'
	sed -n '/^TrialLog.storage = {/,/^}/p' data/lib/trial_log.lua | grep -oP '4\d{4}'
	sed -n '/^RenownLog.storage = {/,/^}/p' data/lib/renown_log.lua | grep -oP '4\d{4}'
} > /tmp/verify_all_storage.$$
d=$(sort /tmp/verify_all_storage.$$ | uniq -d)
[ -n "$d" ] && problem "storage value(s) reused across different libs: $d"

note "Monster names referenced in scripts (summonMonster / isMonsterAliveNearby / SIBLING_NAME / ALLY_NAMES / TrialLog.waves) vs Game.createMonsterType(...) names"
grep -rhoP '(?<=Game\.createMonsterType\(")[^"]+' data/monster | sort -u > /tmp/verify_defined_monsters.$$
{
	grep -rhoP "(?<=summonMonster\(monster:getPosition\(\), ')[^']+" data/scripts/creaturescripts
	grep -rhoP "(?<=isMonsterAliveNearby\(monster:getPosition\(\), )[a-zA-Z]+" data/scripts/creaturescripts | sort -u | grep -v siblingName
	grep -rhoP "(?<=\[')[^']+(?='\] = ')" data/scripts/creaturescripts/raid/twins_ai.lua
	grep -rhoP "(?<= = ')[^']+(?='\])" data/scripts/creaturescripts/raid/twins_ai.lua
	grep -P "ALLY_NAMES" data/scripts/creaturescripts/dungeons/ophelia_ai.lua | grep -oP "(?<=')[A-Z][a-zA-Z ]+(?=')"
	grep -rhoP "(?<=name = ')[^']+" data/lib/trial_log.lua
} | sort -u > /tmp/verify_referenced_monsters.$$
missing=$(comm -23 /tmp/verify_referenced_monsters.$$ /tmp/verify_defined_monsters.$$)
[ -n "$missing" ] && problem "monster name(s) referenced in scripts with no matching Game.createMonsterType(\"...\") definition: $missing"

note "Every NPC file ends with npcType:register(npcConfig)"
for f in data/npc/*.lua; do
	tail -3 "$f" | grep -q 'npcType:register(npcConfig)' || problem "$f does not end with npcType:register(npcConfig)"
done

rm -f /tmp/verify_*.$$

if [ "$fail" -eq 0 ]; then
	echo ""
	echo "All checks passed."
else
	echo ""
	echo "One or more checks failed - see FAIL lines above."
fi
exit "$fail"
