--[[
	renown_log.lua

	A single, PvE-wide "Renown" score - distinct from the two dungeon-tied
	factions in reputation_log.lua (Harbor Trade Concern / Order of the
	Ember only track standing with *that* dungeon's storyline). Renown is
	general: every quest, every dungeon/raid completion, every boss kill,
	and every repeatable (bounty/Proving Grounds) payout raises it a little.

	Killing another player out in the open world - see
	data/creaturescripts/scripts/pvp/renown_penalty.lua - lowers it. That's
	the whole point: unlike the faction reputations, Renown can go
	negative, and going far enough negative has a real consequence (see
	"Renown gates the vendors" below).

	Reserved storage: 45102 (inside the reputation block, 45100-45109,
	that reputation_log.lua already reserves - Harbor Trade Concern and
	Order of the Ember use 45100/45101, this is the next free slot in that
	same decade rather than a whole new range).

	Storage encoding: TFS storage values return -1 for "never set", which
	would be indistinguishable from a legitimate Renown of -1. To avoid
	that collision, the raw storage value is always (renown + storageOffset)
	- see getRenown/setRenown below. Never read/write the raw storage value
	directly from other scripts; always go through those two functions (or
	addRenown).
]]

RenownLog = {}

RenownLog.storage = {
	value = 45102,
}

RenownLog.storageOffset = 100000

-- Floor/ceiling on the *effective* (decoded) renown value - not the raw
-- storage number. Adjust to taste; these are generous on both ends.
RenownLog.minValue = -2000
RenownLog.maxValue = 50000

-- Ordered ascending. Unlike ReputationLog's ranks (which never go below
-- Neutral/0), this includes negative tiers - going PvP-happy in the open
-- world is meant to visibly cost you standing, not just cap out at
-- "Neutral".
RenownLog.ranks = {
	{ name = 'Outlaw', threshold = RenownLog.minValue },
	{ name = 'Reviled', threshold = -500 },
	{ name = 'Suspicious', threshold = -100 },
	{ name = 'Neutral', threshold = 0 },
	{ name = 'Respected', threshold = 250 },
	{ name = 'Renowned', threshold = 750 },
	{ name = 'Champion', threshold = 2000 },
}

function RenownLog.rankForValue(value)
	local current = RenownLog.ranks[1]
	for _, rank in ipairs(RenownLog.ranks) do
		if value >= rank.threshold then
			current = rank
		end
	end
	return current
end

-- ===========================================================================
-- Player helpers
-- ===========================================================================

function Player.getRenown(self)
	local raw = self:getStorageValue(RenownLog.storage.value)
	if raw <= 0 then
		return 0 -- never set - start at Neutral
	end
	return raw - RenownLog.storageOffset
end

function Player.setRenown(self, value)
	value = math.max(RenownLog.minValue, math.min(RenownLog.maxValue, value))
	self:setStorageValue(RenownLog.storage.value, value + RenownLog.storageOffset)
end

--- Adds (or, with a negative amount, subtracts) Renown, clamped to
--- [minValue, maxValue]. Returns the new effective value.
function Player.addRenown(self, amount)
	local newValue = self:getRenown() + amount
	self:setRenown(newValue)
	return newValue
end

function Player.getRenownRank(self)
	return RenownLog.rankForValue(self:getRenown())
end

--- True if the player's Renown rank is at least `rankName` in the ranks
--- table above (by list position, same convention as
--- Player.hasReputationRank in reputation_log.lua).
function Player.hasRenownRank(self, rankName)
	local playerValue = self:getRenown()
	for _, rank in ipairs(RenownLog.ranks) do
		if rank.name == rankName then
			return playerValue >= rank.threshold
		end
	end
	return false
end
