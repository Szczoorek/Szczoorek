--[[
	Attached to every Crimson Cathedral trash monster (Crimson Zealot,
	Cathedral Guard, Flame Acolyte - not the named bosses, which have their
	own AI scripts). Credits nearby players toward today's cathedral
	bounty. See data/lib/bounty_log.lua and docs/design/daily_bounties.md.
]]

local cathedralTrashDeath = CreatureEvent('CathedralTrashDeath')

function cathedralTrashDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature

	local spectators = Game.getSpectators(monster:getPosition(), false, false, 6, 6, 6, 6)
	for _, spectator in ipairs(spectators) do
		local player = spectator:getPlayer()
		if player then
			player:addBountyKill('cathedral')
		end
	end
	return true
end

cathedralTrashDeath:register()
