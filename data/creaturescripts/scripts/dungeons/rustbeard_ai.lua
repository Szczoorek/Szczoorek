--[[
	Rustbeard the Mad - mini-boss #1 of The Sunken Vault.

	- Intro yell the first think tick after spawning.
	- At 50% health (once): enrages (speed up) and summons 2 Bilge Rats.
	- onDeath: credits every nearby player for QuestLog.storage.vault.rustbeard.

	Registered as "RustbeardAI" in data/creaturescripts/creaturescripts.xml
	and attached via <script><event name="RustbeardAI"/></script> in
	data/monster/sunken_vault/rustbeard_the_mad.xml.
]]

local FLAG_INTRO = 1
local FLAG_ENRAGED = 2

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('Who dares enter the Vault?!', TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 50, FLAG_ENRAGED) then
		monster:say('RAAAGH! Kill them all!', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(150)
		DungeonLib.summonMonster(monster:getPosition(), 'Bilge Rat', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Bilge Rat', monster)
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.vault.rustbeard, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
