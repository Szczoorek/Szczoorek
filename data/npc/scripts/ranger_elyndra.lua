--[[
	Ranger Elyndra - quest giver for "Wolves at the Doorstep" (Quest 1).

	Flow:
	  say "quest"/"wolves" -> not started: explains the quest, waits for yes/no
	  say "yes"            -> starts the quest (STARTED)
	  say "pelts"           -> if the player is carrying 5+ Wolf Pelts and the
	                            quest is STARTED, hands in the quest and pays
	                            out the reward
]]

local WOLF_PELTS_REQUIRED = 5
local REWARD_EXPERIENCE = 500
local REWARD_GOLD = 150

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
	local status = player:getQuestStatus(QuestLog.storage.wolves)

	if msg:find('quest') or msg:find('wolves') or msg:find('mission') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The wolves have been quiet since you dealt with them. Thank you again.', cid)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say('Bring me ' .. WOLF_PELTS_REQUIRED .. ' wolf pelts and say \'pelts\' when you have them.', cid)
		else
			npcHandler:say('Timber wolves have been raiding the outskirts. Kill ' .. WOLF_PELTS_REQUIRED ..
				' of them and bring me their pelts as proof - I\'ll make it worth your while. Will you help? (yes/no)', cid)
			npcHandler:setTopic(cid, 1)
		end
		return true
	end

	if npcHandler:getTopic(cid) == 1 then
		if msg:find('yes') then
			player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.STARTED)
			npcHandler:say('Good. Watch yourself out there - they hunt in packs.', cid)
		elseif msg:find('no') then
			npcHandler:say('Suit yourself. The offer stands if you change your mind.', cid)
		end
		npcHandler:setTopic(cid, 0)
		return true
	end

	if msg:find('pelts') then
		if status ~= QuestLog.status.STARTED then
			npcHandler:say('I haven\'t asked you for pelts yet - ask me about the \'quest\' first.', cid)
			return true
		end

		if player:getItemCount(QuestLog.items.wolfPelt) < WOLF_PELTS_REQUIRED then
			npcHandler:say('That\'s not enough pelts yet. I need ' .. WOLF_PELTS_REQUIRED .. '.', cid)
			return true
		end

		player:removeItem(QuestLog.items.wolfPelt, WOLF_PELTS_REQUIRED)
		player:addItem(QuestLog.items.rangersCharm, 1)
		player:addExperience(REWARD_EXPERIENCE)
		player:addMoney(REWARD_GOLD)
		player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.COMPLETED)
		npcHandler:say('That\'ll do. Take this charm, and my thanks - the woods are a little safer today.', cid)
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
