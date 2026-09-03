--[[
	Highlord Varek - boss #3 of The Crimson Cathedral (Armory wing).

	- Intro yell.
	- Every 12s: "Whirlwind", a tight AoE around himself.
	- At 30% health (once): enrages - faster, and Whirlwind cooldown shortens.
	- onDeath: credits QuestLog.storage.cathedral.varek.
]]

local FLAG_INTRO = 1
local FLAG_ENRAGED = 2
local LAST_WHIRLWIND = 3
local WHIRLWIND_COOLDOWN = 12 -- seconds, 7 while enraged
local WHIRLWIND_MIN, WHIRLWIND_MAX = 50, 90

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('FEEL MY FURY!', TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 30, FLAG_ENRAGED) then
		monster:say('ENOUGH! NO MORE HOLDING BACK!', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(180)
	end

	local isEnraged = monster:getStorageValue(FLAG_ENRAGED) == 1
	local cooldown = isEnraged and (WHIRLWIND_COOLDOWN - 5) or WHIRLWIND_COOLDOWN
	local lastWhirlwind = monster:getStorageValue(LAST_WHIRLWIND)
	if lastWhirlwind <= 0 or os.time() - lastWhirlwind >= cooldown then
		monster:setStorageValue(LAST_WHIRLWIND, os.time())
		monster:say('Whirlwind!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 2, WHIRLWIND_MIN, WHIRLWIND_MAX, CONST_ME_HITAREA,
			'Highlord Varek spins into a whirlwind of steel!')
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.cathedral.varek, 10)
	DungeonLib.grantReputationToNearby(position, ReputationLog.storage.orderOfTheEmber, 150, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
