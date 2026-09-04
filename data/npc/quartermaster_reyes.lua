--[[
	Quartermaster Reyes - Harbor Trade Concern reputation vendor.

	Say 'shop' for the catalog and your current standing; say an item's
	keyword to buy it (fails politely if you're under-ranked or under-gold).
	Standing is earned by killing bosses in The Sunken Vault - see
	data/scripts/creaturescripts/dungeons/{rustbeard,grix,blackscale}_ai.lua
	and docs/design/factions_and_achievements.md.
]]

local internalNpcName = "Quartermaster Reyes"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 120
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 137,
	lookHead = 95,
	lookBody = 76,
	lookLegs = 76,
	lookFeet = 76,
	lookAddons = 3,
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
	{ keyword = 'boots', name = "Corsair's Boots", itemId = QuestLog.items.corsairsBoots, rank = 'Friendly', price = 5000 },
	{ keyword = 'plate', name = 'Harbor Guard Plate', itemId = QuestLog.items.harborGuardPlate, rank = 'Honored', price = 15000 },
	{ keyword = 'shield', name = 'Tidebreaker Shield', itemId = QuestLog.items.tidebreakerShield, rank = 'Revered', price = 35000 },
	{ keyword = 'signet', name = "Blackscale's Signet", itemId = QuestLog.items.blackscalesSignet, rank = 'Exalted', price = 75000 },
}

local creatureSayCallback = VendorLib.buildShopCallback(npcHandler, ReputationLog.storage.harborTradeConcern, SHOP_ITEMS)

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Ask me about the 'shop' if the Harbor Trade Concern thinks well enough of you yet.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Mind the gangplank.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back when you've earned more standing.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
