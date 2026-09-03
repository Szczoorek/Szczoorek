--[[
	Armsmaster Cael - Order of the Ember reputation vendor.

	Say 'shop' for the catalog and your current standing; say an item's
	keyword to buy it. Standing is earned by killing bosses in The Crimson
	Cathedral - see
	data/creaturescripts/scripts/dungeons/{malachar,ophelia,varek,flameseer}_ai.lua
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
	{ keyword = 'gloves', name = 'Ember-Touched Gloves', itemId = QuestLog.items.emberTouchedGloves, rank = 'Friendly', price = 5000 },
	{ keyword = 'helm', name = "Cathedral Warden's Helm", itemId = QuestLog.items.cathedralWardensHelm, rank = 'Honored', price = 15000 },
	{ keyword = 'legguards', name = "Zealot's Legguards", itemId = QuestLog.items.zealotsLegguards, rank = 'Revered', price = 35000 },
	{ keyword = 'crown', name = 'Flamewrought Crown', itemId = QuestLog.items.flamewroughtCrown, rank = 'Exalted', price = 75000 },
}

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT,
	VendorLib.buildShopCallback(npcHandler, ReputationLog.storage.orderOfTheEmber, SHOP_ITEMS))
npcHandler:addModule(FocusModule:new())
