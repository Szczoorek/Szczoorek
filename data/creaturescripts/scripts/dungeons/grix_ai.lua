--[[
	Foreman Grix - mini-boss #2 of The Sunken Vault.

	- Intro yell.
	- Every 8s: "Overcharged Blast", an AoE hit around himself. Players need
	  to spread out / step away when he yells "Take cover!".
	- onDeath: credits every nearby player for QuestLog.storage.vault.grix.
]]

local FLAG_INTRO = 1
local LAST_BLAST = 3
local BLAST_COOLDOWN = 8 -- seconds
local BLAST_MIN, BLAST_MAX = 45, 75

function onThink(cid, interval)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	if monster:getStorageValue(FLAG_INTRO) ~= 1 then
		monster:setStorageValue(FLAG_INTRO, 1)
		monster:say('Behold my contraption!', TALKTYPE_MONSTER_SAY)
	end

	local lastBlast = monster:getStorageValue(LAST_BLAST)
	if lastBlast <= 0 or os.time() - lastBlast >= BLAST_COOLDOWN then
		monster:setStorageValue(LAST_BLAST, os.time())
		monster:say('Take cover!', TALKTYPE_MONSTER_SAY)
		DungeonLib.aoeDamage(monster:getPosition(), 3, BLAST_MIN, BLAST_MAX, CONST_ME_EXPLOSIONAREA,
			'The contraption detonates!')
	end

	return true
end

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local position = monster:getPosition()
	DungeonLib.markNearbyPlayers(position, QuestLog.storage.vault.grix, 10)
	position:sendMagicEffect(CONST_ME_EXPLOSIONAREA)
	return true
end
