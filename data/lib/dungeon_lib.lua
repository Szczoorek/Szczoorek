--[[
	dungeon_lib.lua

	Small helper library used by boss AI creaturescripts (see
	data/creaturescripts/scripts/dungeons/*.lua). Keeps the individual boss
	scripts short and readable by centralising the "hit everyone nearby",
	"heal an ally" and "summon an add" boilerplate.

	Loaded automatically alongside quest_log.lua from data/lib/.
]]

DungeonLib = {}

--- Deals random(minDamage, maxDamage) health damage to every player within
--- `radius` tiles of centerPosition (square radius, same floor only).
--- Bypasses armor/resistances on purpose — this represents a scripted boss
--- ability "hitting" the raid, not a normal attack roll.
function DungeonLib.aoeDamage(centerPosition, radius, minDamage, maxDamage, effect, message)
	local spectators = Game.getSpectators(centerPosition, false, false, radius, radius, radius, radius)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			local damage = math.random(minDamage, maxDamage)
			player:addHealth(-damage)
			player:getPosition():sendMagicEffect(effect or CONST_ME_FIREAREA)
			if message then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
			end
		end
	end
end

--- Heals `target` for `amount`, capped at its max health, with a magic
--- effect at its position.
function DungeonLib.healOther(target, amount, effect)
	if not target or target:getHealth() <= 0 then
		return
	end
	local newHealth = math.min(target:getHealth() + amount, target:getMaxHealth())
	target:addHealth(newHealth - target:getHealth())
	target:getPosition():sendMagicEffect(effect or CONST_ME_MAGIC_BLUE)
end

--- Finds the lowest-health monster of a given name near `position`
--- (excludes `ignoreCreature`, typically the caster itself). Used by
--- Sister Ophelia to decide who to heal.
function DungeonLib.findWoundedAlly(position, monsterName, radius, ignoreCreature)
	local best, bestRatio = nil, 1.0
	local spectators = Game.getSpectators(position, false, false, radius, radius, radius, radius)
	for _, creature in ipairs(spectators) do
		local monster = creature:getMonster()
		if monster and creature ~= ignoreCreature and monster:getName() == monsterName then
			local ratio = monster:getHealth() / monster:getMaxHealth()
			if ratio < 1.0 and ratio < bestRatio then
				best, bestRatio = monster, ratio
			end
		end
	end
	return best
end

--- Spawns a monster near `position` (small random offset so adds don't all
--- stack on one tile) and optionally binds it to `master` so it despawns
--- when the master dies and doesn't count as a separate "boss".
function DungeonLib.summonMonster(position, name, master)
	local spawnPosition = Position(position.x + math.random(-1, 1), position.y + math.random(-1, 1), position.z)
	local monster = Game.createMonster(name, spawnPosition, true, true)
	if monster then
		monster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		if master then
			monster:setMaster(master)
		end
	end
	return monster
end

--- Counts currently-alive summons belonging to `master` on the same floor,
--- so a boss's onThink can cap how many adds it keeps out at once.
function DungeonLib.countSummons(master)
	if not master then
		return 0
	end
	local summons = master:getSummons()
	return summons and #summons or 0
end

--- One-shot flag helper: returns true (and marks the flag) the first time
--- health drops to/under `percent` of max health, false every other time.
--- Boss scripts use this to gate "enrage at 50%" style triggers so they only
--- fire once per fight. flagStorageKey should be a small negative-safe
--- integer local to that boss's own storage usage (monsters have their own
--- storage space, so re-using e.g. 1 across different boss scripts is fine).
function DungeonLib.crossedHealthThreshold(monster, percent, flagStorageKey)
	if monster:getStorageValue(flagStorageKey) == 1 then
		return false
	end
	if (monster:getHealth() / monster:getMaxHealth()) * 100 <= percent then
		monster:setStorageValue(flagStorageKey, 1)
		return true
	end
	return false
end

--- Broadcasts a server-wide message, used for boss-kill announcements.
function DungeonLib.broadcast(message)
	Game.broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
end

--- Marks every player within `radius` tiles of `position` as having
--- defeated the given quest-log storage flag. Used from boss onDeath
--- handlers so the whole party gets credit, not just whoever landed the
--- killing blow.
function DungeonLib.markNearbyPlayers(position, storageKey, radius)
	radius = radius or 10
	local spectators = Game.getSpectators(position, false, false, radius, radius, radius, radius)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			player:markDefeated(storageKey)
		end
	end
end

--- Grants `amount` reputation with `factionKey` (see reputation_log.lua) to
--- every player within `radius` tiles of `position`. Used from boss
--- onDeath handlers alongside markNearbyPlayers.
function DungeonLib.grantReputationToNearby(position, factionKey, amount, radius)
	radius = radius or 10
	local spectators = Game.getSpectators(position, false, false, radius, radius, radius, radius)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			player:addReputation(factionKey, amount)
		end
	end
end
