--[[
	Attached to every Sunken Vault trash monster (Vault Goblin, Vault
	Corsair, Bilge Rat - not the named bosses, which have their own AI
	scripts). Credits nearby players toward today's vault bounty.
	See data/lib/bounty_log.lua and docs/design/daily_bounties.md.
]]

function onDeath(cid)
	local monster = Monster(cid)
	if not monster then
		return true
	end

	local spectators = Game.getSpectators(monster:getPosition(), false, false, 6, 6, 6, 6)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			player:addBountyKill('vault')
		end
	end
	return true
end
