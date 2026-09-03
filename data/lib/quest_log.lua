--[[
	quest_log.lua

	Central quest-state and item-id table for the WoW-inspired content pack.
	Load this before any npc/action/creaturescript that references QuestLog
	(files under data/lib/ are auto-loaded before other scripts on every TFS
	1.x server, so no extra require/dofile should be needed — if your server
	does not auto-load data/lib, add a dofile() for this file at the top of
	your global startup script).
]]

QuestLog = {}

-- ===========================================================================
-- Status enum
-- ===========================================================================
QuestLog.status = {
	NOT_STARTED = 0,
	STARTED = 1,
	COMPLETED = 2,
}

-- ===========================================================================
-- Storage values (reserved range: 45000-45099)
-- ===========================================================================
QuestLog.storage = {
	-- Quest 1: Wolves at the Doorstep
	wolves = 45001,

	-- Quest 2: The Lost Locket
	locket = 45010,

	-- Dungeon 1: The Sunken Vault
	vault = {
		quest = 45020,      -- overall quest status (NPC-facing)
		rustbeard = 45021,  -- 1 once Rustbeard the Mad is dead
		grix = 45022,       -- 1 once Foreman Grix is dead
		blackscale = 45023, -- 1 once Captain Blackscale is dead
	},

	-- Dungeon 2: The Crimson Cathedral
	cathedral = {
		quest = 45030,     -- overall quest status (NPC-facing)
		malachar = 45031,  -- 1 once Brother Malachar is dead
		ophelia = 45032,   -- 1 once Sister Ophelia is dead
		varek = 45033,     -- 1 once Highlord Varek is dead
		flameseer = 45034, -- 1 once The Flameseer is dead
	},
}

-- ===========================================================================
-- Item ids (reserved range: 20001-20012 — see README.md for how to register
-- these in items.otb before merging data/items/quest_items.xml)
-- ===========================================================================
QuestLog.items = {
	-- Quest 1
	wolfPelt = 20001,
	rangersCharm = 20002,

	-- Quest 2
	tarnishedLocket = 20003,
	corwinsLuckyRing = 20004,

	-- Dungeon 1: The Sunken Vault
	sunkenVaultLedger = 20005,
	vaultCaptainsCutlass = 20006,
	rustyVaultKey = 20007,
	corsairsTrophy = 20008,

	-- Dungeon 2: The Crimson Cathedral
	flameseersEmber = 20009,
	cathedralSigil = 20010,
	emberWardedAmulet = 20011,
	scarletPrayerBook = 20012,
}

-- ===========================================================================
-- Player helpers
-- ===========================================================================

--- Returns QuestLog.status for the given storage key (defaults to NOT_STARTED
--- for any value <= 0, matching how storage values behave when never set).
function Player.getQuestStatus(self, storageKey)
	local value = self:getStorageValue(storageKey)
	if value <= 0 then
		return QuestLog.status.NOT_STARTED
	end
	return value
end

function Player.setQuestStatus(self, storageKey, status)
	self:setStorageValue(storageKey, status)
end

--- Convenience check used by dungeon gate/lever scripts.
function Player.hasDefeated(self, storageKey)
	return self:getStorageValue(storageKey) == 1
end

--- Marks a boss as defeated. Boss "defeated" flags are pack-wide (not
--- per-player) in the sense that the creaturescript sets them on every
--- party member present at the kill; call this once per player in the
--- onDeath handler.
function Player.markDefeated(self, storageKey)
	self:setStorageValue(storageKey, 1)
end
