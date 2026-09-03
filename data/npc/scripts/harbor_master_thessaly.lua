--[[
	Harbor Master Thessaly - quest giver for "Secrets of the Sunken Vault"
	(Dungeon 1: The Sunken Vault).

	Flow:
	  say "vault"  -> starts the quest / gives a status update on the three
	                  named bosses (Rustbeard, Grix, Blackscale)
	  say "ledger" -> if carrying the Sunken Vault Ledger (guaranteed drop
	                  from Captain Blackscale), hands in the quest
]]

local REWARD_EXPERIENCE = 4000
local REWARD_GOLD = 1500

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

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

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	local status = player:getQuestStatus(QuestLog.storage.vault.quest)

	if msg:find('vault') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Vault is quiet these days, thanks to you.', cid)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), cid)
		else
			player:setQuestStatus(QuestLog.storage.vault.quest, QuestLog.status.STARTED)
			npcHandler:say('Pirates flooded the old harbor vault and made it their own - Rustbeard, Foreman Grix, ' ..
				'and their captain, Blackscale. Clear them out and bring me proof from the captain\'s own hand: ' ..
				'his ledger. Ask me about the \'ledger\' once you have it.', cid)
		end
		return true
	end

	if msg:find('ledger') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('You already brought me that ledger - good reading, if grim.', cid)
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
				'and the harbor\'s trade routes are safe again.', cid)
		else
			npcHandler:say('You don\'t have it yet. It\'ll be on Captain Blackscale himself, at the bottom of the Vault.', cid)
		end
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
