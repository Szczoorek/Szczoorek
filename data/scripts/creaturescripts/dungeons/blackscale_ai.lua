--[[
	Captain Blackscale - final boss of The Sunken Vault.

	Phases:
	  100-60%: plain melee, plus periodic "Tidal Wave" AoE.
	  <=60% (once): calls in reinforcements - 2 Vault Corsairs.
	  <=25% (once): enrages - faster, and his Tidal Wave cooldown shortens.

	onDeath: credits every nearby player for QuestLog.storage.vault.blackscale
	and broadcasts a server message.
]]

local FLAG_INTRO = 1
local FLAG_PHASE2 = 2
local FLAG_ENRAGED = 3
local LAST_WAVE = 4
local WAVE_COOLDOWN = 10 -- seconds, 6 while enraged
local WAVE_MIN, WAVE_MAX = 60, 100

local blackscaleAIThink = CreatureEvent('BlackscaleAIThink')

function blackscaleAIThink.onThink(creature, interval)
	local monster = creature

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say("You've sailed into your grave!", TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 60, FLAG_PHASE2) then
		monster:say('Reinforcements, on deck!', TALKTYPE_MONSTER_SAY)
		DungeonLib.summonMonster(monster:getPosition(), 'Vault Corsair', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Vault Corsair', monster)
	end

	if DungeonLib.crossedHealthThreshold(monster, 25, FLAG_ENRAGED) then
		monster:say('The sea itself answers me!', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(200)
	end

	local isEnraged = monster:getStorageValue(FLAG_ENRAGED) == 1
	local cooldown = isEnraged and (WAVE_COOLDOWN - 4) or WAVE_COOLDOWN
	local lastWave = monster:getStorageValue(LAST_WAVE)
	if lastWave <= 0 or os.time() - lastWave >= cooldown then
		monster:setStorageValue(LAST_WAVE, os.time())
		monster:say('Tidal wave!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 4, WAVE_MIN, WAVE_MAX, CONST_ME_BIGCLOUDS,
			'A wave of water crashes over the room!')
	end

	return true
end

blackscaleAIThink:register()

local blackscaleAIDeath = CreatureEvent('BlackscaleAIDeath')

function blackscaleAIDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.vault.blackscale, 10)
	DungeonLib.grantReputationToNearby(position, ReputationLog.storage.harborTradeConcern, 300, 10)
	DungeonLib.grantRenownToNearby(position, 60, 10)
	DungeonLib.broadcast('Captain Blackscale has been slain! The Sunken Vault is clear.')
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end

blackscaleAIDeath:register()
