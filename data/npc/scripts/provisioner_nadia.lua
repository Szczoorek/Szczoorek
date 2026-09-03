--[[
	Provisioner Nadia - ungated general goods vendor. No FACTION gate,
	unlike Quartermaster Reyes/Armsmaster Cael (data/lib/vendor_lib.lua) -
	just gold, available from the very start. See docs/design/general_goods.md.

	She does still enforce the same Renown floor those two do (see
	docs/design/renown_and_pvp.md) - refuses service below Neutral. Kept
	as a manual check here rather than pulling in vendor_lib.lua, since
	she has no faction/rank catalog to build.

	Say 'goods' (or 'shop') for the catalog; say an item's keyword to buy
	one.
]]

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local GOODS = {
	{ keyword = 'draught', name = 'Healing Draught', itemId = QuestLog.items.healingDraught, price = 100 },
	{ keyword = 'greater', name = 'Greater Healing Draught', itemId = QuestLog.items.greaterHealingDraught, price = 300 },
	{ keyword = 'hearthstone', name = "Traveler's Hearthstone", itemId = QuestLog.items.travelersHearthstone, price = 2500 },
}

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if not player:hasRenownRank(VendorLib.minimumRenownRank) then
		if msg:find('goods') or msg:find('shop') then
			npcHandler:say('I\'ve heard about you. Find somewhere else to spend your gold.', cid)
			return true
		end
		for _, entry in ipairs(GOODS) do
			if msg:find(entry.keyword) then
				npcHandler:say('I\'ve heard about you. Find somewhere else to spend your gold.', cid)
				return true
			end
		end
		return false
	end

	if msg:find('goods') or msg:find('shop') then
		local lines = {}
		for _, entry in ipairs(GOODS) do
			table.insert(lines, entry.name .. ' [' .. entry.price .. ' gold], say \'' .. entry.keyword .. '\'')
		end
		npcHandler:say(table.concat(lines, ' | '), cid)
		return true
	end

	for _, entry in ipairs(GOODS) do
		if msg:find(entry.keyword) then
			if not player:removeMoney(entry.price) then
				npcHandler:say('That\'s ' .. entry.price .. ' gold - come back when you have it.', cid)
				return true
			end

			player:addItem(entry.itemId, 1)
			npcHandler:say('There you go.', cid)
			return true
		end
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
