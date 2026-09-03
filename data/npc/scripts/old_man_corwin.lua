--[[
	Old Man Corwin - quest giver for "The Lost Locket" (Quest 2).

	Flow:
	  say "locket" -> not started: explains the quest, points at the cave.
	                  started, no item: reminder.
	                  carrying the locket: hands in automatically, pays reward.
]]

local REWARD_EXPERIENCE = 300
local REWARD_GOLD = 100

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

	local player = Player(cid)
	local status = player:getQuestStatus(QuestLog.storage.locket)

	if not msg:find('locket') then
		return false
	end

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('Thank you again for finding my locket. It means more to me than gold ever could.', cid)
		return true
	end

	if player:getItemCount(QuestLog.items.tarnishedLocket) > 0 then
		player:removeItem(QuestLog.items.tarnishedLocket, 1)
		player:addItem(QuestLog.items.corwinsLuckyRing, 1)
		player:addExperience(REWARD_EXPERIENCE)
		player:addMoney(REWARD_GOLD)
		player:addRenown(15)
		player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.COMPLETED)
		npcHandler:say('You found it! Thank you, truly. Please, take this ring - it was going to be hers.', cid)
		return true
	end

	if status == QuestLog.status.STARTED then
		npcHandler:say('It should still be in the old chest, deep in the cave north of here. Please, keep looking.', cid)
		return true
	end

	player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.STARTED)
	npcHandler:say('I lost my late wife\'s locket in the cave north of the village, years ago. My knees won\'t ' ..
		'let me climb down there anymore. If you find it in an old chest, I would be forever grateful.', cid)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
