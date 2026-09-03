#!/usr/bin/env bash
#
# verify_pack.sh - static sanity checks for this content pack.
#
# There's no live TFS server to test against here, so this is the next
# best thing: catches Lua syntax errors, malformed XML, broken
# cross-references (a monster's <script><event name="X"/></script> with
# no matching registration, a registered event/action/talkaction whose
# script file doesn't exist), item ids used in Lua but never defined in
# quest_items.xml (or vice versa), duplicate registrations that would
# silently shadow one another, and monster names referenced in scripts
# that don't match any defined monster's name= attribute exactly (Lua
# string, case-sensitive - Game.createMonster fails silently on a typo).
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

note "Monster <script><event name=X/></script> refs vs creaturescripts.xml registrations"
grep -rhoP '(?<=<event name=")[^"]+(?=")' data/monster/*/*.xml 2>/dev/null | sort -u > /tmp/verify_monster_events.$$
grep -oP '(?<=<event name=")[^"]+(?=")' data/creaturescripts/creaturescripts.xml | sort -u > /tmp/verify_registered_events.$$
missing=$(comm -23 /tmp/verify_monster_events.$$ /tmp/verify_registered_events.$$)
[ -n "$missing" ] && problem "monster script event(s) not registered in creaturescripts.xml:\n$missing"

note "Registered event/action/talkaction/globalevent script paths exist on disk"
check_scripts_exist() {
	local xmlfile="$1" basedir="$2"
	grep -oP '(?<=script=")[^"]+(?=")' "$xmlfile" | while read -r p; do
		[ -f "$basedir/$p" ] || echo "MISSING: $basedir/$p (registered in $xmlfile)"
	done
}
out=$(check_scripts_exist data/creaturescripts/creaturescripts.xml data/creaturescripts/scripts)
[ -n "$out" ] && { problem "creaturescripts.xml"; echo "$out"; }
out=$(check_scripts_exist data/actions/actions.xml data/actions/scripts)
[ -n "$out" ] && { problem "actions.xml"; echo "$out"; }
out=$(check_scripts_exist data/talkactions/talkactions.xml data/talkactions/scripts)
[ -n "$out" ] && { problem "talkactions.xml"; echo "$out"; }
out=$(check_scripts_exist data/globalevents/globalevents.xml data/globalevents/scripts)
[ -n "$out" ] && { problem "globalevents.xml"; echo "$out"; }
grep -hoP '(?<=script=")[^"]+(?=")' data/npc/*.xml | while read -r p; do
	[ -f "data/npc/scripts/$p" ] || echo "MISSING: data/npc/scripts/$p"
done > /tmp/verify_npc_missing.$$
if [ -s /tmp/verify_npc_missing.$$ ]; then problem "npc *.xml"; cat /tmp/verify_npc_missing.$$; fi

note "Duplicate registrations (actionid / itemid / event name / talkaction words / globalevent name)"
dup() { sort | uniq -d; }
d=$(grep -oP '(?<=actionid=")\d+' data/actions/actions.xml | dup); [ -n "$d" ] && problem "duplicate actionid(s) in actions.xml: $d"
d=$(grep -oP '(?<=itemid=")\d+' data/actions/actions.xml | dup); [ -n "$d" ] && problem "duplicate itemid(s) in actions.xml: $d"
d=$(grep -oP '(?<=<event name=")[^"]+' data/creaturescripts/creaturescripts.xml | dup); [ -n "$d" ] && problem "duplicate event name(s) in creaturescripts.xml: $d"
d=$(grep -oP '(?<=words=")[^"]+' data/talkactions/talkactions.xml | dup); [ -n "$d" ] && problem "duplicate talkaction words: $d"
d=$(grep -oP '(?<=<globalevent name=")[^"]+' data/globalevents/globalevents.xml | dup); [ -n "$d" ] && problem "duplicate globalevent name(s): $d"

note "Item ids: QuestLog.items (data/lib/quest_log.lua) vs quest_items.xml definitions"
sed -n '/^QuestLog.items = {/,/^}/p' data/lib/quest_log.lua | grep -oP '2\d{4}' | sort -un > /tmp/verify_lua_items.$$
grep -oP '(?<=<item id=")\d+' data/items/quest_items.xml | sort -un > /tmp/verify_xml_items.$$
missing=$(comm -23 /tmp/verify_lua_items.$$ /tmp/verify_xml_items.$$)
[ -n "$missing" ] && problem "item id(s) in QuestLog.items with no quest_items.xml entry: $missing"
orphan=$(comm -13 /tmp/verify_lua_items.$$ /tmp/verify_xml_items.$$)
[ -n "$orphan" ] && echo "NOTE (not a failure): quest_items.xml id(s) not in QuestLog.items table: $orphan"
d=$(grep -oP '(?<=<item id=")\d+' data/items/quest_items.xml | dup); [ -n "$d" ] && problem "duplicate item id(s) in quest_items.xml: $d"

note "Storage value collisions across QuestLog/ReputationLog/AchievementLog/BountyLog/TrialLog"
{
	sed -n '/^QuestLog.storage = {/,/^}/p' data/lib/quest_log.lua | grep -oP '4\d{4}'
	sed -n '/^ReputationLog.storage = {/,/^}/p' data/lib/reputation_log.lua | grep -oP '4\d{4}'
	sed -n '/^AchievementLog.storage = {/,/^}/p' data/lib/achievement_log.lua | grep -oP '4\d{4}'
	sed -n '/^BountyLog.storage = {/,/^}/p' data/lib/bounty_log.lua | grep -oP '4\d{4}'
	sed -n '/^TrialLog.storage = {/,/^}/p' data/lib/trial_log.lua | grep -oP '4\d{4}'
} > /tmp/verify_all_storage.$$
d=$(sort /tmp/verify_all_storage.$$ | uniq -d)
[ -n "$d" ] && problem "storage value(s) reused across different libs: $d"

note "Monster names referenced in scripts (summonMonster / isMonsterAliveNearby / SIBLING_NAME / ALLY_NAMES / TrialLog.waves) vs defined monster name= attributes"
grep -rhoP '(?<=<monster name=")[^"]+' data/monster | sort -u > /tmp/verify_defined_monsters.$$
{
	grep -rhoP "(?<=summonMonster\(monster:getPosition\(\), ')[^']+" data/creaturescripts/scripts
	grep -rhoP "(?<=isMonsterAliveNearby\(monster:getPosition\(\), )[a-zA-Z]+" data/creaturescripts/scripts | sort -u | grep -v siblingName
	grep -rhoP "(?<=\[')[^']+(?='\] = ')" data/creaturescripts/scripts/raid/twins_ai.lua
	grep -rhoP "(?<= = ')[^']+(?='\])" data/creaturescripts/scripts/raid/twins_ai.lua
	grep -rhoP "(?<=')[A-Z][a-zA-Z ]+(?=')" data/creaturescripts/scripts/dungeons/ophelia_ai.lua | grep -v "^Be \|^None \|kin$"
	grep -rhoP "(?<=name = ')[^']+" data/lib/trial_log.lua
} | sort -u > /tmp/verify_referenced_monsters.$$
missing=$(comm -23 /tmp/verify_referenced_monsters.$$ /tmp/verify_defined_monsters.$$)
[ -n "$missing" ] && problem "monster name(s) referenced in scripts with no matching <monster name=\"...\"> definition: $missing"

rm -f /tmp/verify_*.$$

if [ "$fail" -eq 0 ]; then
	echo ""
	echo "All checks passed."
else
	echo ""
	echo "One or more checks failed - see FAIL lines above."
fi
exit "$fail"
