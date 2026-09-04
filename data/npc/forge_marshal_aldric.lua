--[[
	Forge Marshal Aldric - quest giver for "The Cinderforge Depths" raid.
	Entry itself is gated by data/scripts/actions/raid/cinderforge_gate.lua
	(requires the Vault Cleaner and Cathedral's Bane achievements); this
	NPC explains that gate, reports boss status once inside, and hands in
	the run.

	Flow:
	  say 'depths'/'cinderforge'/'raid' -> gating explanation / status
	  say 'emblem' -> turn in if carrying the Cinderforge Emblem
]]

local internalNpcName = "Forge Marshal Aldric"
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
	lookFeet = 0,
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

local REWARD_EXPERIENCE = 15000
local REWARD_GOLD = 6000

local function bossStatusLine(player)
	local names = {}
	if not player:hasDefeated(QuestLog.storage.raid.grimtooth) then
		table.insert(names, 'Warden Grimtooth')
	end
	if not player:hasDefeated(QuestLog.storage.raid.twins) then
		table.insert(names, 'the Twin Forgesmiths')
	end
	if not player:hasDefeated(QuestLog.storage.raid.slagmaw) then
		table.insert(names, 'Slagmaw the Devourer')
	end
	if not player:hasDefeated(QuestLog.storage.raid.ashgrave) then
		table.insert(names, 'High Templar Ashgrave')
	end
	if not player:hasDefeated(QuestLog.storage.raid.ignareth) then
		table.insert(names, 'Ignareth, the Cinderlord')
	end

	if #names == 0 then
		return 'Every forge-guardian has fallen. Bring me the emblem when you have it.'
	end
	return table.concat(names, ', ') .. ' still stand in the Depths.'
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)

	if MsgContains(message, 'depths') or MsgContains(message, 'cinderforge') or MsgContains(message, 'raid') then
		local status = player:getQuestStatus(QuestLog.storage.raid.quest)

		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Depths lie silent. That was no small thing you did.', npc, creature)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), npc, creature)
		else
			local qualified = player:hasAchievement(AchievementLog.storage.vaultCleaner)
				and player:hasAchievement(AchievementLog.storage.cathedralsBane)
			if qualified then
				npcHandler:say('The gate below will open for you. Five guardians wait in the dark: Warden ' ..
					'Grimtooth, the Twin Forgesmiths, Slagmaw the Devourer, High Templar Ashgrave, and at the ' ..
					'heart of it, Ignareth. Bring back proof of the last, and I\'ll see you rewarded.', npc, creature)
			else
				npcHandler:say('You\'re not ready. Prove yourself in the Sunken Vault and the Crimson Cathedral first.', npc, creature)
			end
		end
		return true
	end

	if MsgContains(message, 'emblem') then
		local status = player:getQuestStatus(QuestLog.storage.raid.quest)
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('Already delivered. It\'s cold ash now, same as the rest of him.', npc, creature)
			return true
		end

		if player:getItemCount(QuestLog.items.cinderforgeEmblem) > 0 then
			player:removeItem(QuestLog.items.cinderforgeEmblem, 1)
			player:addItem(QuestLog.items.emberlordsSignet, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:setQuestStatus(QuestLog.storage.raid.quest, QuestLog.status.COMPLETED)
			player:grantAchievement(AchievementLog.storage.cinderforgeConqueror)
			npcHandler:say('Ignareth\'s own emblem... it\'s truly done. Take this signet - you\'ve earned every ' ..
				'ounce of it.', npc, creature)
		else
			npcHandler:say('You don\'t have it. Ignareth himself would have kept it close, at the heart of the Depths.', npc, creature)
		end
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Few earn the right to enter the Cinderforge Depths. Ask about the 'depths' if you think you have.")
npcHandler:setMessage(MESSAGE_FAREWELL, "The forge remembers everything.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back when you've proven more.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
