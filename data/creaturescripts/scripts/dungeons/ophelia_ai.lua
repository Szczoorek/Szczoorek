--[[
	Sister Ophelia - boss #2 of The Crimson Cathedral (Infirmary wing).

	- Intro yell.
	- Every 6s: heals the most wounded nearby Crimson Cathedral trash
	  monster (Crimson Zealot / Cathedral Guard / Flame Acolyte) if one is
	  hurt and in range - so leaving her guards alive nearby lets her
	  sustain them indefinitely. If no ally needs healing, and she herself
	  is below 90% health, she tops herself up instead.
	- onDeath: credits QuestLog.storage.cathedral.ophelia.
]]

local FLAG_INTRO = 1
local LAST_HEAL = 3
local HEAL_COOLDOWN = 6 -- seconds
local ALLY_HEAL_AMOUNT = 250
local SELF_HEAL_AMOUNT = 200
local SELF_HEAL_THRESHOLD = 0.9

local ALLY_NAMES = { 'Crimson Zealot', 'Cathedral Guard', 'Flame Acolyte' }

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('None of my kin will fall today!', TALKTYPE_MONSTER_SAY)
	end

	local lastHeal = monster:getStorageValue(LAST_HEAL)
	if lastHeal <= 0 or os.time() - lastHeal >= HEAL_COOLDOWN then
		monster:setStorageValue(LAST_HEAL, os.time())

		local healedAlly = false
		for _, name in ipairs(ALLY_NAMES) do
			local ally = DungeonLib.findWoundedAlly(monster:getPosition(), name, 8, monster)
			if ally then
				monster:say('Be whole again!', TALKTYPE_MONSTER_SAY)
				DungeonLib.healOther(ally, ALLY_HEAL_AMOUNT, CONST_ME_MAGIC_BLUE)
				healedAlly = true
				break
			end
		end

		if not healedAlly and monster:getHealth() < monster:getMaxHealth() * SELF_HEAL_THRESHOLD then
			DungeonLib.healOther(monster, SELF_HEAL_AMOUNT, CONST_ME_MAGIC_BLUE)
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
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.cathedral.ophelia, 10)
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
