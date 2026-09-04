--[[
	Brother Malachar - boss #1 of The Crimson Cathedral (Library wing).

	- Intro yell.
	- Every 12s, while fewer than 4 Animated Tomes are alive: summons 2 more.
	  Killing the tomes fast keeps the fight manageable; ignoring them lets
	  the pile grow.
	- onDeath: credits QuestLog.storage.cathedral.malachar.
]]

local FLAG_INTRO = 1
local LAST_SUMMON = 3
local SUMMON_COOLDOWN = 12 -- seconds
local MAX_TOMES = 4

local malacharAIThink = CreatureEvent('MalacharAIThink')

function malacharAIThink.onThink(creature, interval)
	local monster = creature

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('The archives will not be desecrated!', TALKTYPE_MONSTER_SAY)
	end

	local lastSummon = monster:getStorageValue(LAST_SUMMON)
	if (lastSummon <= 0 or os.time() - lastSummon >= SUMMON_COOLDOWN) and DungeonLib.countSummons(monster) < MAX_TOMES then
		monster:setStorageValue(LAST_SUMMON, os.time())
		monster:say('Rise and defend the archive!', TALKTYPE_MONSTER_SAY)
		DungeonLib.summonMonster(monster:getPosition(), 'Animated Tome', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Animated Tome', monster)
	end

	return true
end

malacharAIThink:register()

local malacharAIDeath = CreatureEvent('MalacharAIDeath')

function malacharAIDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.cathedral.malachar, 10)
	DungeonLib.grantReputationToNearby(position, ReputationLog.storage.orderOfTheEmber, 150, 10)
	DungeonLib.grantRenownToNearby(position, 40, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end

malacharAIDeath:register()
