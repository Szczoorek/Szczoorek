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

local REWARD_EXPERIENCE = 50
local REWARD_GOLD = 50

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if not msg:find('training') then
		return false
	end

	local player = Player(cid)
	local status = player:getQuestStatus(QuestLog.storage.bootcamp.quest)

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('You\'ve got the basics. Ranger Elyndra and Old Man Corwin both have work for someone ' ..
			'ready to prove it - ask around the village.', cid)
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
				'Ranger Elyndra and Old Man Corwin both have real work if you\'re looking for it.', cid)
		else
			npcHandler:say('The dummy\'s right there. It won\'t hit back - go on.', cid)
		end
		return true
	end

	player:setQuestStatus(QuestLog.storage.bootcamp.quest, QuestLog.status.STARTED)
	npcHandler:say('Simple enough: walk up to that training dummy and hit it until it breaks. Come back when it\'s done.', cid)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
