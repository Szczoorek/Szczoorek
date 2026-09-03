--[[
	Slagmaw the Devourer - boss #3 of The Cinderforge Depths.

	- Intro rumble.
	- Every 20s: swallows the lowest-health-percentage player within 8
	  tiles for a heavy burst hit - punishes letting anyone (not just the
	  tank) sit low on health.
	- onDeath: credits QuestLog.storage.raid.slagmaw.
]]

local FLAG_INTRO = 1
local LAST_SWALLOW = 3
local SWALLOW_COOLDOWN = 20 -- seconds
local SWALLOW_MIN, SWALLOW_MAX = 80, 130

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('*a bottomless, rumbling hunger*', TALKTYPE_MONSTER_SAY)
	end

	local lastSwallow = monster:getStorageValue(LAST_SWALLOW)
	if lastSwallow <= 0 or os.time() - lastSwallow >= SWALLOW_COOLDOWN then
		local target = DungeonLib.findLowestHealthPlayer(monster:getPosition(), 8, monster)
		if target then
			monster:setStorageValue(LAST_SWALLOW, os.time())
			monster:say('Slagmaw swallows ' .. target:getName() .. ' whole!', TALKTYPE_MONSTER_SAY)
			local damage = math.random(SWALLOW_MIN, SWALLOW_MAX)
			target:addHealth(-damage)
			target:getPosition():sendMagicEffect(CONST_ME_HITBYFIRE)
			target:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Slagmaw crushes you before spitting you back out!')
		end
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.raid.slagmaw, 10)
	DungeonLib.grantRenownToNearby(position, 60, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
