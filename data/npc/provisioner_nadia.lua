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

local internalNpcName = "Provisioner Nadia"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 80
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 78,
	lookBody = 39,
	lookLegs = 87,
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

local GOODS = {
	{ keyword = 'draught', name = 'Healing Draught', itemId = QuestLog.items.healingDraught, price = 100 },
	{ keyword = 'greater', name = 'Greater Healing Draught', itemId = QuestLog.items.greaterHealingDraught, price = 300 },
	{ keyword = 'hearthstone', name = "Traveler's Hearthstone", itemId = QuestLog.items.travelersHearthstone, price = 2500 },
}

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)

	if not player:hasRenownRank(VendorLib.minimumRenownRank) then
		if MsgContains(message, 'goods') or MsgContains(message, 'shop') then
			npcHandler:say('I\'ve heard about you. Find somewhere else to spend your gold.', npc, creature)
			return true
		end
		for _, entry in ipairs(GOODS) do
			if MsgContains(message, entry.keyword) then
				npcHandler:say('I\'ve heard about you. Find somewhere else to spend your gold.', npc, creature)
				return true
			end
		end
		return false
	end

	if MsgContains(message, 'goods') or MsgContains(message, 'shop') then
		local lines = {}
		for _, entry in ipairs(GOODS) do
			table.insert(lines, entry.name .. ' [' .. entry.price .. ' gold], say \'' .. entry.keyword .. '\'')
		end
		npcHandler:say(table.concat(lines, ' | '), npc, creature)
		return true
	end

	for _, entry in ipairs(GOODS) do
		if MsgContains(message, entry.keyword) then
			if not player:removeMoney(entry.price) then
				npcHandler:say('That\'s ' .. entry.price .. ' gold - come back when you have it.', npc, creature)
				return true
			end

			player:addItem(entry.itemId, 1)
			npcHandler:say('There you go.', npc, creature)
			return true
		end
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|. Ask about my 'goods' if you need supplies before heading out.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Stock up before you go.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Suit yourself.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
