--[[
	The Twin Forgesmiths - boss #2 of The Cinderforge Depths: Kex Ironhide
	and Dross Cinderhand, fought simultaneously. One shared script,
	attached to both monsters' XML.

	- The moment either twin notices the other is dead (checked every
	  think tick), it enrages once - "Vengeance for my kin!", faster.
	  Effectively: killing one twin without immediately finishing the
	  other means fighting an enraged version of whoever's left.
	- onDeath: whichever twin dies LAST (the one whose onDeath fires while
	  its sibling is already gone) credits QuestLog.storage.raid.twins -
	  see the comment inline for why this can't double-fire.
]]

local FLAG_INTRO = 1
local FLAG_AVENGED = 2

local SIBLING_NAME = {
	['Kex Ironhide'] = 'Dross Cinderhand',
	['Dross Cinderhand'] = 'Kex Ironhide',
}

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
	end

	if monster:getStorageValue(FLAG_AVENGED) ~= 1 then
		local siblingName = SIBLING_NAME[monster:getName()]
		if siblingName and not DungeonLib.isMonsterAliveNearby(monster:getPosition(), siblingName, 15) then
			monster:setStorageValue(FLAG_AVENGED, 1)
			monster:say('Vengeance for my kin!', TALKTYPE_MONSTER_SAY)
			monster:changeSpeed(200)
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
	local siblingName = SIBLING_NAME[monster:getName()]

	-- Only the second twin to die sees its sibling already gone here - the
	-- first twin's onDeath still finds the other alive and skips crediting,
	-- so this fires exactly once per encounter regardless of kill order.
	if not siblingName or not DungeonLib.isMonsterAliveNearby(position, siblingName, 15) then
		DungeonLib.markNearbyPlayers(position, QuestLog.storage.raid.twins, 10)
		DungeonLib.grantRenownToNearby(position, 60, 10)
	end

	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
