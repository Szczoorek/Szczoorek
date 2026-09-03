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

local REWARD_EXPERIENCE = 700
local REWARD_GOLD = 250

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function litCount(player)
	local count = 0
	if player:hasFlag(QuestLog.storage.signal.beaconNorth) then count = count + 1 end
	if player:hasFlag(QuestLog.storage.signal.beaconEast) then count = count + 1 end
	if player:hasFlag(QuestLog.storage.signal.beaconSouth) then count = count + 1 end
	return count
end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if not (msg:find('watch') or msg:find('signal') or msg:find('beacon')) then
		return false
	end

	local player = Player(cid)
	local status = player:getQuestStatus(QuestLog.storage.signal.quest)

	if status == QuestLog.status.COMPLETED then
		npcHandler:say('The road\'s been quiet since the beacons went up. My thanks again.', cid)
		return true
	end

	if status == QuestLog.status.STARTED then
		local lit = litCount(player)
		if lit >= 3 then
			player:addItem(QuestLog.items.watchmansBadge, 1)
			player:addExperience(REWARD_EXPERIENCE)
			player:addMoney(REWARD_GOLD)
			player:setQuestStatus(QuestLog.storage.signal.quest, QuestLog.status.COMPLETED)
			npcHandler:say('All three lit - I saw them from here. Take this badge, and my thanks. The watch owes you.', cid)
		else
			npcHandler:say('Still ' .. (3 - lit) .. ' beacon(s) dark. Watch for whoever\'s been guarding them.', cid)
		end
		return true
	end

	player:setQuestStatus(QuestLog.storage.signal.quest, QuestLog.status.STARTED)
	npcHandler:say('Bandits doused our three signal beacons around the outskirts - north, east and south. Light ' ..
		'all three and the watch will know to move on the road again. They\'ve left guards on them, so go armed.', cid)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
