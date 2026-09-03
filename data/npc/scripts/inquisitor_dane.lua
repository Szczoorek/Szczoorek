--[[
	Inquisitor Dane - quest giver for "Purge the Crimson Cathedral"
	(Dungeon 2: The Crimson Cathedral).

	Flow:
	  say "cathedral" -> starts the quest / status update on the four named
	                     bosses (Malachar, Ophelia, Varek, The Flameseer)
	  say "ember"      -> if carrying the Flameseer's Ember (guaranteed drop
	                      from the final boss), hands in the quest
]]

local REWARD_EXPERIENCE = 9000
local REWARD_GOLD = 3000

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

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

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	local status = player:getQuestStatus(QuestLog.storage.cathedral.quest)

	if msg:find('cathedral') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The Crimson Cathedral is ash and silence now. You saw to that.', cid)
		elseif status == QuestLog.status.STARTED then
			npcHandler:say(bossStatusLine(player), cid)
		else
			player:setQuestStatus(QuestLog.storage.cathedral.quest, QuestLog.status.STARTED)
			npcHandler:say('A cult of fanatics has taken the old cathedral - a librarian binding forbidden ' ..
				'tomes to servitude, a healer who won\'t let her kin die easy, a highlord drunk on his own ' ..
				'fury, and at the heart of it, the Flameseer. Bring all four down and return here with ' ..
				'proof - ask me about the \'ember\' once you have it.', cid)
		end
		return true
	end

	if msg:find('ember') then
		if status == QuestLog.status.COMPLETED then
			npcHandler:say('The ember has long since gone cold in my keeping. Rest easy - it\'s done.', cid)
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
				'exactly this kind of fire. You have my thanks, and the order\'s.', cid)
		else
			npcHandler:say('You don\'t carry it. The Flameseer alone would have kept it close, at the heart of the cathedral.', cid)
		end
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
