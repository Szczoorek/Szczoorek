--[[
	Armsmaster Cael - Order of the Ember reputation vendor.

	Say 'shop' for the catalog and your current standing; say an item's
	keyword to buy it. Standing is earned by killing bosses in The Crimson
	Cathedral - see
	data/scripts/creaturescripts/dungeons/{malachar,ophelia,varek,flameseer}_ai.lua
	and docs/design/factions_and_achievements.md.
]]

local internalNpcName = "Armsmaster Cael"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 140
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 0,
	lookBody = 76,
	lookLegs = 76,
	lookFeet = 76,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
	profession = "normal",
}
npcConfig.speechBubble = SPEECHBUBBLE_NORMAL

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local SHOP_ITEMS = {
	{ keyword = 'gloves', name = 'Ember-Touched Gloves', itemId = QuestLog.items.emberTouchedGloves, rank = 'Friendly', price = 5000 },
	{ keyword = 'helm', name = "Cathedral Warden's Helm", itemId = QuestLog.items.cathedralWardensHelm, rank = 'Honored', price = 15000 },
	{ keyword = 'legguards', name = "Zealot's Legguards", itemId = QuestLog.items.zealotsLegguards, rank = 'Revered', price = 35000 },
	{ keyword = 'crown', name = 'Flamewrought Crown', itemId = QuestLog.items.flamewroughtCrown, rank = 'Exalted', price = 75000 },
}

local creatureSayCallback = VendorLib.buildShopCallback(npcHandler, ReputationLog.storage.orderOfTheEmber, SHOP_ITEMS)

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. The Order of the Ember rewards its friends. Ask about the 'shop' - if you've earned the standing for it.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Stay warded.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The Order remembers who stands with it.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
