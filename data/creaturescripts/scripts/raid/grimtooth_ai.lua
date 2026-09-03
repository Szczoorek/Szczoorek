--[[
	Warden Grimtooth - boss #1 of The Cinderforge Depths.

	- Intro yell.
	- Every 12s (7s once enraged): "Molten Slam", an AoE around himself.
	- Hard berserk timer: 180 seconds after the fight starts (tracked from
	  this script's first onThink tick, i.e. roughly when he's engaged), he
	  permanently enrages - faster and hits harder. A DPS check, not a
	  health-based one: dawdling costs the group regardless of how much HP
	  is left.
	- onDeath: credits QuestLog.storage.raid.grimtooth.
]]

local FLAG_INTRO = 1
local ENGAGE_TIME = 2
local FLAG_ENRAGED = 3
local LAST_SLAM = 4
local BERSERK_SECONDS = 180
local SLAM_COOLDOWN = 12 -- seconds, 7 while enraged
local SLAM_MIN, SLAM_MAX = 60, 100

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('The forge does not tire. Neither do I.', TALKTYPE_MONSTER_SAY)
	end

	local elapsed = DungeonLib.secondsSinceEngaged(monster, ENGAGE_TIME)
	if elapsed >= BERSERK_SECONDS and monster:getStorageValue(FLAG_ENRAGED) ~= 1 then
		monster:setStorageValue(FLAG_ENRAGED, 1)
		monster:say('ENOUGH STALLING!', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(150)
	end

	local isEnraged = monster:getStorageValue(FLAG_ENRAGED) == 1
	local cooldown = isEnraged and (SLAM_COOLDOWN - 5) or SLAM_COOLDOWN
	local lastSlam = monster:getStorageValue(LAST_SLAM)
	if lastSlam <= 0 or os.time() - lastSlam >= cooldown then
		monster:setStorageValue(LAST_SLAM, os.time())
		monster:say('Molten Slam!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 3, SLAM_MIN, SLAM_MAX, CONST_ME_EXPLOSIONAREA,
			"The ground erupts beneath Warden Grimtooth's hammer!")
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.raid.grimtooth, 10)
	DungeonLib.grantRenownToNearby(position, 60, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
