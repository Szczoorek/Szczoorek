--[[
	Forge Marshal Aldric - quest giver for "The Cinderforge Depths" raid.
	Entry itself is gated by data/actions/scripts/raid/cinderforge_gate.lua
	(requires the Vault Cleaner and Cathedral's Bane achievements); this
	NPC explains that gate, reports boss status once inside, and hands in
	the run.

	Flow:
	  say 'depths'/'cinderforge'/'raid' -> gating explanation / status
	  say 'emblem' -> turn in if carrying the Cinderforge Emblem
]]

local REWARD_EXPERIENCE = 15000
local REWARD_GOLD = 6000

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

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

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msg:find('depths') or msg:find('cinderforge') or msg:find('raid') then
		local status = player:getQuestStatus(QuestLog.storage.raid.quest)

		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Depths lie silent. That was no small thing you did.', cid)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), cid)
		else
			local qualified = player:hasAchievement(AchievementLog.storage.vaultCleaner)
				and player:hasAchievement(AchievementLog.storage.cathedralsBane)
			if qualified then
				npcHandler:say('The gate below will open for you. Five guardians wait in the dark: Warden ' ..
					'Grimtooth, the Twin Forgesmiths, Slagmaw the Devourer, High Templar Ashgrave, and at the ' ..
					'heart of it, Ignareth. Bring back proof of the last, and I\'ll see you rewarded.', cid)
			else
				npcHandler:say('You\'re not ready. Prove yourself in the Sunken Vault and the Crimson Cathedral first.', cid)
			end
		end
		return true
	end

	if msg:find('emblem') then
		local status = player:getQuestStatus(QuestLog.storage.raid.quest)
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('Already delivered. It\'s cold ash now, same as the rest of him.', cid)
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
				'ounce of it.', cid)
		else
			npcHandler:say('You don\'t have it. Ignareth himself would have kept it close, at the heart of the Depths.', cid)
		end
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
