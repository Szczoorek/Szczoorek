--[[
	Sergeant Coleman - Quest 0 (Boot Camp), a brand-new character's very
	first quest. Teaches "walk up to a monster and attack it" with zero
	risk (the Training Dummy never fights back) before pointing the player
	at Ranger Elyndra and Old Man Corwin for their first real quests.

	Flow:
	  say 'training' -> not started: explains, starts the quest, points at
	                     the Training Dummy.
	                     started, dummy still alive: reminder.
	                     started, dummy defeated: hands in immediately.
]]

local internalNpcName = "Sergeant Coleman"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 200
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 0,
	lookBody = 20,
	lookLegs = 20,
	lookFeet = 20,
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

local REWARD_EXPERIENCE = 50
local REWARD_GOLD = 50

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if not MsgContains(message, 'training') then
		return false
	end

	local player = Player(creature)
	local status = player:getQuestStatus(QuestLog.storage.bootcamp.quest)

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('You\'ve got the basics. Ranger Elyndra and Old Man Corwin both have work for someone ' ..
			'ready to prove it - ask around the village.', npc, creature)
		return true
	end

	if status == QuestLog.status.STARTED then
		if player:hasDefeated(QuestLog.storage.bootcamp.dummyDefeated) then
			player:addItem(QuestLog.items.recruitsTrainingBlade, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:addRenown(10)
			player:setQuestStatus(QuestLog.storage.bootcamp.quest, QuestLog.status.COMPLETED)
			npcHandler:say('Good enough. Take this blade - it\'s not much, but it\'ll do until you find better. ' ..
				'Ranger Elyndra and Old Man Corwin both have real work if you\'re looking for it.', npc, creature)
		else
			npcHandler:say('The dummy\'s right there. It won\'t hit back - go on.', npc, creature)
		end
		return true
	end

	player:setQuestStatus(QuestLog.storage.bootcamp.quest, QuestLog.status.STARTED)
	npcHandler:say('Simple enough: walk up to that training dummy and hit it until it breaks. Come back when it\'s done.', npc, creature)
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "New around here, |PLAYERNAME|? Ask me about 'training' before you go picking fights you can't win.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Stay sharp.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Suit yourself, recruit.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
