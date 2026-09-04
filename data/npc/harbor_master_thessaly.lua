--[[
	Harbor Master Thessaly - quest giver for "Secrets of the Sunken Vault"
	(Dungeon 1: The Sunken Vault).

	Flow:
	  say "vault"  -> starts the quest / gives a status update on the three
	                  named bosses (Rustbeard, Grix, Blackscale)
	  say "ledger" -> if carrying the Sunken Vault Ledger (guaranteed drop
	                  from Captain Blackscale), hands in the quest
]]

local internalNpcName = "Harbor Master Thessaly"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 137,
	lookHead = 95,
	lookBody = 113,
	lookLegs = 76,
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

local REWARD_EXPERIENCE = 4000
local REWARD_GOLD = 1500

local function bossStatusLine(player)
	local names = {}
	if not player:hasDefeated(QuestLog.storage.vault.rustbeard) then
		table.insert(names, 'Rustbeard the Mad')
	end
	if not player:hasDefeated(QuestLog.storage.vault.grix) then
		table.insert(names, 'Foreman Grix')
	end
	if not player:hasDefeated(QuestLog.storage.vault.blackscale) then
		table.insert(names, 'Captain Blackscale')
	end

	if #names == 0 then
		return 'You\'ve cleared everyone down there worth mentioning. Bring me the ledger when you find it.'
	end
	return 'Last I heard, ' .. table.concat(names, ', ') .. ' still holds the Vault. Come back when that\'s changed.'
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)
	local status = player:getQuestStatus(QuestLog.storage.vault.quest)

	if MsgContains(message, 'vault') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Vault is quiet these days, thanks to you.', npc, creature)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), npc, creature)
		else
			player:setQuestStatus(QuestLog.storage.vault.quest, QuestLog.status.STARTED)
			npcHandler:say('Pirates flooded the old harbor vault and made it their own - Rustbeard, Foreman Grix, ' ..
				'and their captain, Blackscale. Clear them out and bring me proof from the captain\'s own hand: ' ..
				'his ledger. Ask me about the \'ledger\' once you have it.', npc, creature)
		end
		return true
	end

	if MsgContains(message, 'ledger') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('You already brought me that ledger - good reading, if grim.', npc, creature)
			return true
		end

		if player:getItemCount(QuestLog.items.sunkenVaultLedger) > 0 then
			player:removeItem(QuestLog.items.sunkenVaultLedger, 1)
			player:addItem(QuestLog.items.vaultCaptainsCutlass, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:setQuestStatus(QuestLog.storage.vault.quest, QuestLog.status.COMPLETED)
			player:grantAchievement(AchievementLog.storage.vaultCleaner)
			npcHandler:say('Blackscale\'s own hand... it\'s over, then. Take his blade - you\'ve earned it, ' ..
				'and the harbor\'s trade routes are safe again.', npc, creature)
		else
			npcHandler:say('You don\'t have it yet. It\'ll be on Captain Blackscale himself, at the bottom of the Vault.', npc, creature)
		end
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. If you're heading down into the Sunken Vault, ask me about the 'vault' first - and about the 'ledger' once you're out again.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Fair winds.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Careful down there.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
