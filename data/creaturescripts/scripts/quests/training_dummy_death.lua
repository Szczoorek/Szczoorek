--[[
	Marks the Training Dummy as defeated for anyone nearby - used by Quest 0
	(Boot Camp). Doesn't check quest state; harmless to fire even if no one
	nearby has the quest active.
]]

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	DungeonLib.markNearbyPlayers(monster:getPosition(), QuestLog.storage.bootcamp.dummyDefeated, 6)
	monster:getPosition():sendMagicEffect(CONST_ME_POFF)
	return true
end
