--[[
	Ranger Elyndra - quest giver for "Wolves at the Doorstep" (Quest 1).

	Flow:
	  say "quest"/"wolves" -> not started: explains the quest, waits for yes/no
	  say "yes"            -> starts the quest (STARTED)
	  say "pelts"           -> if the player is carrying 5+ Wolf Pelts and the
	                            quest is STARTED, hands in the quest and pays
	                            out the reward
]]

local internalNpcName = "Ranger Elyndra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 78,
	lookBody = 39,
	lookLegs = 87,
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

local WOLF_PELTS_REQUIRED = 5
local REWARD_EXPERIENCE = 500
local REWARD_GOLD = 150

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)
	local playerId = player:getId()
	local status = player:getQuestStatus(QuestLog.storage.wolves)

	if MsgContains(message, 'quest') or MsgContains(message, 'wolves') or MsgContains(message, 'mission') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The wolves have been quiet since you dealt with them. Thank you again.', npc, creature)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say('Bring me ' .. WOLF_PELTS_REQUIRED .. ' wolf pelts and say \'pelts\' when you have them.', npc, creature)
		else
			npcHandler:say('Timber wolves have been raiding the outskirts. Kill ' .. WOLF_PELTS_REQUIRED ..
				' of them and bring me their pelts as proof - I\'ll make it worth your while. Will you help? (yes/no)', npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
		return true
	end

	if npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, 'yes') then
			player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.STARTED)
			npcHandler:say('Good. Watch yourself out there - they hunt in packs.', npc, creature)
		elseif MsgContains(message, 'no') then
			npcHandler:say('Suit yourself. The offer stands if you change your mind.', npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
	end

	if MsgContains(message, 'pelts') then
		if status ~= QuestLog.status.STARTED then
			npcHandler:say('I haven\'t asked you for pelts yet - ask me about the \'quest\' first.', npc, creature)
			return true
		end

		if player:getItemCount(QuestLog.items.wolfPelt) < WOLF_PELTS_REQUIRED then
			npcHandler:say('That\'s not enough pelts yet. I need ' .. WOLF_PELTS_REQUIRED .. '.', npc, creature)
			return true
		end

		player:removeItem(QuestLog.items.wolfPelt, WOLF_PELTS_REQUIRED)
		player:addItem(QuestLog.items.rangersCharm, 1)
		player:addExperience(REWARD_EXPERIENCE)
		player:addMoney(REWARD_GOLD)
		player:addRenown(20)
		player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.COMPLETED)
		npcHandler:say('That\'ll do. Take this charm, and my thanks - the woods are a little safer today.', npc, creature)
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|. The forest wolves have been bolder than usual lately. Ask me about 'quest' if you're willing to help.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Watch the treeline.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Hmph. Suit yourself.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
