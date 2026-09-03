--[[
	bounty_log.lua

	Repeatable daily bounties: kill a set number of a dungeon's trash
	monsters, turn in at the Bounty Clerk for gold + reputation. Resets
	once per real-world day. WoW-style daily-quest-hub filler content that
	gives a reason to revisit the two starter dungeons after their main
	quests are done.

	Reserved storage range: 45120-45129.
]]

BountyLog = {}

BountyLog.storage = {
	vault = { progress = 45120, day = 45121, completed = 45122 },
	cathedral = { progress = 45123, day = 45124, completed = 45125 },
}

BountyLog.requiredKills = {
	vault = 15,
	cathedral = 15,
}

BountyLog.rewardGold = {
	vault = 800,
	cathedral = 800,
}

BountyLog.rewardReputation = {
	vault = 100,
	cathedral = 100,
}

BountyLog.factionKey = {
	vault = 'harborTradeConcern',   -- key into ReputationLog.storage
	cathedral = 'orderOfTheEmber',
}

local function today()
	-- Year*1000 + day-of-year: strictly increasing, wraps cleanly at New Year's.
	return tonumber(os.date('%Y')) * 1000 + tonumber(os.date('%j'))
end

local function ensureFreshDay(player, track)
	local storage = BountyLog.storage[track]
	if player:getStorageValue(storage.day) ~= today() then
		player:setStorageValue(storage.day, today())
		player:setStorageValue(storage.progress, 0)
		player:setStorageValue(storage.completed, 0)
	end
end

-- ===========================================================================
-- Player helpers
-- ===========================================================================

--- Called from trash-monster onDeath handlers. No-ops once today's bounty
--- is already turned in, so lingering hits after completion don't matter.
function Player.addBountyKill(self, track)
	ensureFreshDay(self, track)
	local storage = BountyLog.storage[track]
	if self:getStorageValue(storage.completed) == 1 then
		return
	end

	local progress = math.max(0, self:getStorageValue(storage.progress)) + 1
	self:setStorageValue(storage.progress, progress)
	if progress == BountyLog.requiredKills[track] then
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Bounty complete - report back to the Bounty Clerk.')
	end
end

function Player.getBountyProgress(self, track)
	ensureFreshDay(self, track)
	return math.max(0, self:getStorageValue(BountyLog.storage[track].progress))
end

function Player.isBountyCompletedToday(self, track)
	ensureFreshDay(self, track)
	return self:getStorageValue(BountyLog.storage[track].completed) == 1
end

function Player.isBountyReadyToTurnIn(self, track)
	return not self:isBountyCompletedToday(track)
		and self:getBountyProgress(track) >= BountyLog.requiredKills[track]
end

--- Pays out gold + reputation and marks today's bounty done. Caller is
--- responsible for having checked isBountyReadyToTurnIn() first.
function Player.completeBounty(self, track)
	self:setStorageValue(BountyLog.storage[track].completed, 1)
	self:addMoney(BountyLog.rewardGold[track])
	self:addReputation(ReputationLog.storage[BountyLog.factionKey[track]], BountyLog.rewardReputation[track])
	self:addRenown(10)
end
