--[[
	reputation_log.lua

	Simple WoW-style faction reputation, gated vendor unlocks. Two factions
	tied to the two starter dungeons: killing bosses in each raises standing
	with the faction that dungeon belongs to, which unlocks tiers of gear at
	that faction's quartermaster NPC.

	Reserved storage range: 45100-45109.
]]

ReputationLog = {}

ReputationLog.storage = {
	harborTradeConcern = 45100, -- The Sunken Vault
	orderOfTheEmber = 45101,    -- The Crimson Cathedral
}

-- Ordered ascending; rankForValue() walks this to find the highest rank the
-- player qualifies for.
ReputationLog.ranks = {
	{ name = 'Neutral', threshold = 0 },
	{ name = 'Friendly', threshold = 500 },
	{ name = 'Honored', threshold = 1500 },
	{ name = 'Revered', threshold = 3000 },
	{ name = 'Exalted', threshold = 6000 },
}

function ReputationLog.rankForValue(value)
	local current = ReputationLog.ranks[1]
	for _, rank in ipairs(ReputationLog.ranks) do
		if value >= rank.threshold then
			current = rank
		end
	end
	return current
end

-- ===========================================================================
-- Player helpers
-- ===========================================================================

function Player.getReputation(self, factionKey)
	local value = self:getStorageValue(factionKey)
	if value <= 0 then
		return 0
	end
	return value
end

--- Adds (or subtracts, with a negative amount) reputation, floored at 0.
function Player.addReputation(self, factionKey, amount)
	local newValue = math.max(0, self:getReputation(factionKey) + amount)
	self:setStorageValue(factionKey, newValue)
	return newValue
end

function Player.getReputationRank(self, factionKey)
	return ReputationLog.rankForValue(self:getReputation(factionKey))
end

--- True if the player's current standing meets or exceeds `rankName`
--- (e.g. Player.hasReputationRank(player, faction, 'Honored')).
function Player.hasReputationRank(self, factionKey, rankName)
	local playerValue = self:getReputation(factionKey)
	for _, rank in ipairs(ReputationLog.ranks) do
		if rank.name == rankName then
			return playerValue >= rank.threshold
		end
	end
	return false
end
