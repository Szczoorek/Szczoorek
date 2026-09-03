--[[
	Ignareth, the Cinderlord - final boss of The Cinderforge Depths.

	- Intro yell.
	- "Cinderfall": a wide AoE around himself, base cooldown 9s.
	- At 50% health (once, phase 2): summons 3 Sons of Cinder and Cinderfall
	  cooldown drops to 6s.
	- At 20% health (once, enrage): +150 speed and Cinderfall cooldown drops
	  further to 4s.
	- onDeath: credits QuestLog.storage.raid.ignareth and broadcasts a
	  server message.
]]

local FLAG_INTRO = 1
local FLAG_PHASE2 = 2
local FLAG_ENRAGED = 3
local LAST_NOVA = 4
local NOVA_COOLDOWN = 9 -- seconds; -3 in phase 2, further -2 enraged
local NOVA_MIN, NOVA_MAX = 90, 140

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say("I AM THE FORGE'S WILL MADE FLAME!", TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 50, FLAG_PHASE2) then
		monster:say('BURN WITH ME!', TALKTYPE_MONSTER_SAY)
		DungeonLib.summonMonster(monster:getPosition(), 'Son of Cinder', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Son of Cinder', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Son of Cinder', monster)
	end

	if DungeonLib.crossedHealthThreshold(monster, 20, FLAG_ENRAGED) then
		monster:say('THE FORGE CONSUMES ALL!', TALKTYPE_MONSTER_SAY)
		monster:changeSpeed(150)
	end

	local cooldown = NOVA_COOLDOWN
	if monster:getStorageValue(FLAG_PHASE2) == 1 then
		cooldown = cooldown - 3
	end
	if monster:getStorageValue(FLAG_ENRAGED) == 1 then
		cooldown = cooldown - 2
	end

	local lastNova = monster:getStorageValue(LAST_NOVA)
	if lastNova <= 0 or os.time() - lastNova >= cooldown then
		monster:setStorageValue(LAST_NOVA, os.time())
		monster:say('Cinderfall!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 5, NOVA_MIN, NOVA_MAX, CONST_ME_FIREAREA,
			'Molten cinders rain across the chamber!')
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.raid.ignareth, 10)
	DungeonLib.broadcast('Ignareth, the Cinderlord has been extinguished! The Cinderforge Depths lie silent.')
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
