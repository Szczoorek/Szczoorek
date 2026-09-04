--[[
	Watchman Farro - quest giver for "Signal the Watch" (Quest 3).

	Flow:
	  say 'watch'/'signal'/'beacon' ->
	    not started: explains, starts the quest.
	    started, <3 beacons lit: status update.
	    started, all 3 beacons lit: hands in immediately (no separate item
	    to carry back - the beacon flags themselves are the proof).
	    completed: flavor line.
]]

local internalNpcName = "Watchman Farro"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 130
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 0,
	lookBody = 20,
	lookLegs = 20,
	lookFeet = 20,
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

local REWARD_EXPERIENCE = 700
local REWARD_GOLD = 250

local function litCount(player)
	local count = 0
	if player:hasFlag(QuestLog.storage.signal.beaconNorth) then count = count + 1 end
	if player:hasFlag(QuestLog.storage.signal.beaconEast) then count = count + 1 end
	if player:hasFlag(QuestLog.storage.signal.beaconSouth) then count = count + 1 end
	return count
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if not (MsgContains(message, 'watch') or MsgContains(message, 'signal') or MsgContains(message, 'beacon')) then
		return false
	end

	local player = Player(creature)
	local status = player:getQuestStatus(QuestLog.storage.signal.quest)

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('The road\'s been quiet since the beacons went up. My thanks again.', npc, creature)
		return true
	end

	if status == QuestLog.status.STARTED then
		local lit = litCount(player)
		if lit >= 3 then
			player:addItem(QuestLog.items.watchmansBadge, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:addRenown(25)
			player:setQuestStatus(QuestLog.storage.signal.quest, QuestLog.status.COMPLETED)
			npcHandler:say('All three lit - I saw them from here. Take this badge, and my thanks. The watch owes you.', npc, creature)
		else
			npcHandler:say('Still ' .. (3 - lit) .. ' beacon(s) dark. Watch for whoever\'s been guarding them.', npc, creature)
		end
		return true
	end

	player:setQuestStatus(QuestLog.storage.signal.quest, QuestLog.status.STARTED)
	npcHandler:say('Bandits doused our three signal beacons around the outskirts - north, east and south. Light ' ..
		'all three and the watch will know to move on the road again. They\'ve left guards on them, so go armed.', npc, creature)
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Ask me about the 'watch' - something's not right on the roads out of town.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Keep your eyes open out there.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The road won't watch itself.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
