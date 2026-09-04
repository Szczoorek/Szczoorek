--[[
	Inquisitor Dane - quest giver for "Purge the Crimson Cathedral"
	(Dungeon 2: The Crimson Cathedral).

	Flow:
	  say "cathedral" -> starts the quest / status update on the four named
	                     bosses (Malachar, Ophelia, Varek, The Flameseer)
	  say "ember"      -> if carrying the Flameseer's Ember (guaranteed drop
	                      from the final boss), hands in the quest
]]

local internalNpcName = "Inquisitor Dane"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 180
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
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

local REWARD_EXPERIENCE = 9000
local REWARD_GOLD = 3000

local function bossStatusLine(player)
	local names = {}
	if not player:hasDefeated(QuestLog.storage.cathedral.malachar) then
		table.insert(names, 'Brother Malachar')
	end
	if not player:hasDefeated(QuestLog.storage.cathedral.ophelia) then
		table.insert(names, 'Sister Ophelia')
	end
	if not player:hasDefeated(QuestLog.storage.cathedral.varek) then
		table.insert(names, 'Highlord Varek')
	end
	if not player:hasDefeated(QuestLog.storage.cathedral.flameseer) then
		table.insert(names, 'the Flameseer')
	end

	if #names == 0 then
		return 'Every wing has fallen quiet. Bring me the ember when you have it.'
	end
	return 'The cathedral still burns. ' .. table.concat(names, ', ') .. ' yet stand against you.'
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)
	local status = player:getQuestStatus(QuestLog.storage.cathedral.quest)

	if MsgContains(message, 'cathedral') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Crimson Cathedral is ash and silence now. You saw to that.', npc, creature)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), npc, creature)
		else
			player:setQuestStatus(QuestLog.storage.cathedral.quest, QuestLog.status.STARTED)
			npcHandler:say('A cult of fanatics has taken the old cathedral - a librarian binding forbidden ' ..
				'tomes to servitude, a healer who won\'t let her kin die easy, a highlord drunk on his own ' ..
				'fury, and at the heart of it, the Flameseer. Bring all four down and return here with ' ..
				'proof - ask me about the \'ember\' once you have it.', npc, creature)
		end
		return true
	end

	if MsgContains(message, 'ember') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The ember has long since gone cold in my keeping. Rest easy - it\'s done.', npc, creature)
			return true
		end

		if player:getItemCount(QuestLog.items.flameseersEmber) > 0 then
			player:removeItem(QuestLog.items.flameseersEmber, 1)
			player:addItem(QuestLog.items.emberWardedAmulet, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:setQuestStatus(QuestLog.storage.cathedral.quest, QuestLog.status.COMPLETED)
			player:grantAchievement(AchievementLog.storage.cathedralsBane)
			npcHandler:say('The Flameseer\'s own ember, cold at last. Wear this amulet - it was warded against ' ..
				'exactly this kind of fire. You have my thanks, and the order\'s.', npc, creature)
		else
			npcHandler:say('You don\'t carry it. The Flameseer alone would have kept it close, at the heart of the cathedral.', npc, creature)
		end
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. The Crimson Cathedral still burns with heresy. Ask about the 'cathedral' if you mean to end it, or about the 'ember' once you have.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Go with the Light.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The fire spreads while you dawdle.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
