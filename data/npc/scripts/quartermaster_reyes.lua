--[[
	Quartermaster Reyes - Harbor Trade Concern reputation vendor.

	Say 'shop' for the catalog and your current standing; say an item's
	keyword to buy it (fails politely if you're under-ranked or under-gold).
	Standing is earned by killing bosses in The Sunken Vault - see
	data/creaturescripts/scripts/dungeons/{rustbeard,grix,blackscale}_ai.lua
	and docs/design/factions_and_achievements.md.
]]

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local SHOP_ITEMS = {
	{ keyword = 'boots', name = "Corsair's Boots", itemId = QuestLog.items.corsairsBoots, rank = 'Friendly', price = 5000 },
	{ keyword = 'plate', name = 'Harbor Guard Plate', itemId = QuestLog.items.harborGuardPlate, rank = 'Honored', price = 15000 },
	{ keyword = 'shield', name = 'Tidebreaker Shield', itemId = QuestLog.items.tidebreakerShield, rank = 'Revered', price = 35000 },
	{ keyword = 'signet', name = "Blackscale's Signet", itemId = QuestLog.items.blackscalesSignet, rank = 'Exalted', price = 75000 },
}

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT,
	VendorLib.buildShopCallback(npcHandler, ReputationLog.storage.harborTradeConcern, SHOP_ITEMS))
npcHandler:addModule(FocusModule:new())
