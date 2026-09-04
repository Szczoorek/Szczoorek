--[[
	Rustbeard the Mad - mini-boss #1 of The Sunken Vault.

	- Intro yell the first think tick after spawning.
	- At 50% health (once): enrages (speed up) and summons 2 Bilge Rats.
	- onDeath: credits every nearby player for QuestLog.storage.vault.rustbeard.

	Self-registers as two CreatureEvents ("RustbeardAIThink"/"RustbeardAIDeath");
	attached to the monster via mType:registerEvent(...) calls at the bottom
	of data/monster/sunken_vault/rustbeard_the_mad.lua.
]]

local FLAG_INTRO = 1
local FLAG_ENRAGED = 2

local rustbeardAIThink = CreatureEvent('RustbeardAIThink')

function rustbeardAIThink.onThink(creature, interval)
	local monster = creature

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

rustbeardAIThink:register()

local rustbeardAIDeath = CreatureEvent('RustbeardAIDeath')

function rustbeardAIDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.vault.rustbeard, 10)
	DungeonLib.grantReputationToNearby(position, ReputationLog.storage.harborTradeConcern, 150, 10)
	DungeonLib.grantRenownToNearby(position, 30, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end

rustbeardAIDeath:register()
