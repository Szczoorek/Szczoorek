--[[
	Fenrir the Alpha - open-world rare spawn in the Wolves at the Doorstep
	forest.

	- Intro howl.
	- At 50% health (once): howls again and calls in 2 regular Timber
	  Wolves to back him up.
	- onDeath: grants the "Fenrir's Bane" achievement to everyone nearby and
	  broadcasts a server message (rares are meant to be noticed).
]]

local FLAG_INTRO = 1
local FLAG_CALLED_PACK = 2

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('*a bone-deep howl echoes through the trees*', TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 50, FLAG_CALLED_PACK) then
		monster:say('*howls again, louder*', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(100)
		DungeonLib.summonMonster(monster:getPosition(), 'Timber Wolf', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Timber Wolf', monster)
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	local spectators = Game.getSpectators(position, false, false, 10, 10, 10, 10)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			player:grantAchievement(AchievementLog.storage.fenrirsBane)
			player:addRenown(40)
		end
	end

	DungeonLib.broadcast('Fenrir the Alpha has fallen in the forest.')
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
