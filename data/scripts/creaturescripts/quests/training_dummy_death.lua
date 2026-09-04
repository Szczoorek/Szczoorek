--[[
	Marks the Training Dummy as defeated for anyone nearby - used by Quest 0
	(Boot Camp). Doesn't check quest state; harmless to fire even if no one
	nearby has the quest active.
]]

local trainingDummyDeath = CreatureEvent('TrainingDummyDeath')

function trainingDummyDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	DungeonLib.markNearbyPlayers(monster:getPosition(), QuestLog.storage.bootcamp.dummyDefeated, 6)
	monster:getPosition():sendMagicEffect(CONST_ME_POFF)
	return true
end

trainingDummyDeath:register()
