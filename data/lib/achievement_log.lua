--[[
	achievement_log.lua

	Minimal WoW-style achievement tracking: a one-time storage flag per
	achievement, a server-wide announcement the first time someone earns
	one, and a helper to list what a player has unlocked (used by the
	player-facing !achievements talkaction).

	Reserved storage range: 45110-45119.
]]

AchievementLog = {}

AchievementLog.storage = {
	vaultCleaner = 45110,        -- complete "Secrets of the Sunken Vault"
	cathedralsBane = 45111,      -- complete "Purge the Crimson Cathedral"
	fenrirsBane = 45112,         -- slay Fenrir the Alpha (see fenrir_the_alpha.xml)
	cinderforgeConqueror = 45113,    -- complete "The Cinderforge Depths" raid
	provingGroundsChampion = 45114,  -- clear all 5 waves of the Proving Grounds
}

AchievementLog.names = {
	[AchievementLog.storage.vaultCleaner] = 'Vault Cleaner',
	[AchievementLog.storage.cathedralsBane] = "Cathedral's Bane",
	[AchievementLog.storage.fenrirsBane] = "Fenrir's Bane",
	[AchievementLog.storage.cinderforgeConqueror] = 'Cinderforge Conqueror',
	[AchievementLog.storage.provingGroundsChampion] = 'Proving Grounds Champion',
}

-- Order to display achievements in for !achievements, since pairs() over
-- AchievementLog.names has no guaranteed order.
AchievementLog.order = {
	AchievementLog.storage.vaultCleaner,
	AchievementLog.storage.cathedralsBane,
	AchievementLog.storage.fenrirsBane,
	AchievementLog.storage.cinderforgeConqueror,
	AchievementLog.storage.provingGroundsChampion,
}

-- ===========================================================================
-- Player helpers
-- ===========================================================================

function Player.hasAchievement(self, key)
	return self:getStorageValue(key) == 1
end

--- Grants the achievement once. Returns false (no-op) if the player already
--- has it. Sends the player a message and broadcasts a server-wide
--- announcement the first time - same as it not re-announcing on repeat
--- calls (e.g. from a repeatable boss kill) is handled by the early return.
function Player.grantAchievement(self, key)
	if self:hasAchievement(key) then
		return false
	end

	self:setStorageValue(key, 1)
	local name = AchievementLog.names[key] or 'Unknown Achievement'
	self:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Achievement earned: ' .. name .. '!')
	Game.broadcastMessage(self:getName() .. ' has earned the achievement "' .. name .. '"!', MESSAGE_EVENT_ADVANCE)
	self:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return true
end

--- Returns an ordered array of achievement names the player has earned.
function Player.listAchievements(self)
	local earned = {}
	for _, key in ipairs(AchievementLog.order) do
		if self:hasAchievement(key) then
			table.insert(earned, AchievementLog.names[key])
		end
	end
	return earned
end
