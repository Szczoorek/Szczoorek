--[[
	High Templar Ashgrave - boss #4 of The Cinderforge Depths.

	- Intro yell.
	- Every 25s, if no Ember Sentinel is currently alive, summons one
	  ("Rise, and shield me!"). While a sentinel is alive, it channels a
	  heal into Ashgrave every 4s - the "shield" here is really "kill the
	  add fast or Ashgrave keeps topping himself up."
	- onDeath: credits QuestLog.storage.raid.ashgrave.
]]

local FLAG_INTRO = 1
local LAST_SUMMON = 3
local SUMMON_COOLDOWN = 25 -- seconds
local MAX_SENTINELS = 1
local LAST_SENTINEL_HEAL = 4
local SENTINEL_HEAL_COOLDOWN = 4 -- seconds
local SENTINEL_HEAL_AMOUNT = 400

local ashgraveAIThink = CreatureEvent('AshgraveAIThink')

function ashgraveAIThink.onThink(creature, interval)
	local monster = creature

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('The forge grants no mercy, and neither do I.', TALKTYPE_MONSTER_SAY)
	end

	local lastSummon = monster:getStorageValue(LAST_SUMMON)
	if (lastSummon <= 0 or os.time() - lastSummon >= SUMMON_COOLDOWN) and DungeonLib.countSummons(monster) < MAX_SENTINELS then
		monster:setStorageValue(LAST_SUMMON, os.time())
		monster:say('Rise, and shield me!', TALKTYPE_MONSTER_SAY)
		DungeonLib.summonMonster(monster:getPosition(), 'Ember Sentinel', monster)
	end

	local lastHeal = monster:getStorageValue(LAST_SENTINEL_HEAL)
	if DungeonLib.countSummons(monster) > 0 and (lastHeal <= 0 or os.time() - lastHeal >= SENTINEL_HEAL_COOLDOWN) then
		monster:setStorageValue(LAST_SENTINEL_HEAL, os.time())
		if monster:getHealth() < monster:getMaxHealth() then
			DungeonLib.healOther(monster, SENTINEL_HEAL_AMOUNT, CONST_ME_MAGIC_RED)
		end
	end

	return true
end

ashgraveAIThink:register()

local ashgraveAIDeath = CreatureEvent('AshgraveAIDeath')

function ashgraveAIDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.raid.ashgrave, 10)
	DungeonLib.grantRenownToNearby(position, 60, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end

ashgraveAIDeath:register()
