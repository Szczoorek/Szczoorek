--[[
	The Flameseer - final boss of The Crimson Cathedral.

	- Intro yell.
	- Every 10s: "Fire Nova", a wide AoE around himself.
	- At 30% health (once): enrages - summons 2 Lesser Fire Elementals and
	  shortens the Fire Nova cooldown.
	- onDeath: credits QuestLog.storage.cathedral.flameseer and broadcasts a
	  server message.
]]

local FLAG_INTRO = 1
local FLAG_ENRAGED = 2
local LAST_NOVA = 3
local NOVA_COOLDOWN = 10 -- seconds, 6 while enraged
local NOVA_MIN, NOVA_MAX = 70, 110

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('Burn in righteous fire!', TALKTYPE_MONSTER_SAY)
	end

	if DungeonLib.crossedHealthThreshold(monster, 30, FLAG_ENRAGED) then
		monster:say('THE CATHEDRAL BURNS WITH ME!', TALKTYPE_MONSTER_SAY)
		DungeonLib.summonMonster(monster:getPosition(), 'Lesser Fire Elemental', monster)
		DungeonLib.summonMonster(monster:getPosition(), 'Lesser Fire Elemental', monster)
	end

	local isEnraged = monster:getStorageValue(FLAG_ENRAGED) == 1
	local cooldown = isEnraged and (NOVA_COOLDOWN - 4) or NOVA_COOLDOWN
	local lastNova = monster:getStorageValue(LAST_NOVA)
	if lastNova <= 0 or os.time() - lastNova >= cooldown then
		monster:setStorageValue(LAST_NOVA, os.time())
		monster:say('Fire nova!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 4, NOVA_MIN, NOVA_MAX, CONST_ME_FIREAREA,
			'A wave of searing fire rolls out from the Flameseer!')
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.cathedral.flameseer, 10)
	DungeonLib.broadcast('The Flameseer has fallen! The Crimson Cathedral burns no more.')
	position:sendMagicEffect(CONST_ME_MORTAREA)
	return true
end
