--[[
	Old Man Corwin - quest giver for "The Lost Locket" (Quest 2).

	Flow:
	  say "locket" -> not started: explains the quest, points at the cave.
	                  started, no item: reminder.
	                  carrying the locket: hands in automatically, pays reward.
]]

local internalNpcName = "Old Man Corwin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 45
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 19,
	lookBody = 20,
	lookLegs = 19,
	lookFeet = 0,
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

local REWARD_EXPERIENCE = 300
local REWARD_GOLD = 100

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)
	local status = player:getQuestStatus(QuestLog.storage.locket)

	if not MsgContains(message, 'locket') then
		return false
	end

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('Thank you again for finding my locket. It means more to me than gold ever could.', npc, creature)
		return true
	end

	if player:getItemCount(QuestLog.items.tarnishedLocket) > 0 then
		player:removeItem(QuestLog.items.tarnishedLocket, 1)
		player:addItem(QuestLog.items.corwinsLuckyRing, 1)
		player:addExperience(REWARD_EXPERIENCE)
		player:addMoney(REWARD_GOLD)
		player:addRenown(15)
		player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.COMPLETED)
		npcHandler:say('You found it! Thank you, truly. Please, take this ring - it was going to be hers.', npc, creature)
		return true
	end

	if status == QuestLog.status.STARTED then
		npcHandler:say('It should still be in the old chest, deep in the cave north of here. Please, keep looking.', npc, creature)
		return true
	end

	player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.STARTED)
	npcHandler:say('I lost my late wife\'s locket in the cave north of the village, years ago. My knees won\'t ' ..
		'let me climb down there anymore. If you find it in an old chest, I would be forever grateful.', npc, creature)
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Oh, hello |PLAYERNAME|. Have you seen an old locket lying around? Ask me about 'locket' if you have a moment.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Mind the roots on the cave floor.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "...my locket...")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
