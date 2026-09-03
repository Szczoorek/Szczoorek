--[[
	GM utility: /questreset <player name>, <quest>

	<quest> is one of: bootcamp, wolves, locket, signal, vault, cathedral,
	raid, all, renown
	Resets that player's storage(s) back to NOT_STARTED so the quest/dungeon
	can be replayed while you're testing map placement and scripts. "renown"
	is separate from "all" - it's not a quest, and resetting quest progress
	shouldn't silently wipe Renown earned from other activities (bounties,
	Proving Grounds, PvP penalties) too.

	Example: /questreset GM Tester, vault
	Example: /questreset GM Tester, renown
]]

local function resetVault(player)
	player:setQuestStatus(QuestLog.storage.vault.quest, QuestLog.status.NOT_STARTED)
	player:setStorageValue(QuestLog.storage.vault.rustbeard, -1)
	player:setStorageValue(QuestLog.storage.vault.grix, -1)
	player:setStorageValue(QuestLog.storage.vault.blackscale, -1)
end

local function resetCathedral(player)
	player:setQuestStatus(QuestLog.storage.cathedral.quest, QuestLog.status.NOT_STARTED)
	player:setStorageValue(QuestLog.storage.cathedral.malachar, -1)
	player:setStorageValue(QuestLog.storage.cathedral.ophelia, -1)
	player:setStorageValue(QuestLog.storage.cathedral.varek, -1)
	player:setStorageValue(QuestLog.storage.cathedral.flameseer, -1)
end

local function resetRaid(player)
	player:setQuestStatus(QuestLog.storage.raid.quest, QuestLog.status.NOT_STARTED)
	player:setStorageValue(QuestLog.storage.raid.grimtooth, -1)
	player:setStorageValue(QuestLog.storage.raid.twins, -1)
	player:setStorageValue(QuestLog.storage.raid.slagmaw, -1)
	player:setStorageValue(QuestLog.storage.raid.ashgrave, -1)
	player:setStorageValue(QuestLog.storage.raid.ignareth, -1)
end

local function resetSignal(player)
	player:setQuestStatus(QuestLog.storage.signal.quest, QuestLog.status.NOT_STARTED)
	player:setStorageValue(QuestLog.storage.signal.beaconNorth, -1)
	player:setStorageValue(QuestLog.storage.signal.beaconEast, -1)
	player:setStorageValue(QuestLog.storage.signal.beaconSouth, -1)
end

local function resetBootcamp(player)
	player:setQuestStatus(QuestLog.storage.bootcamp.quest, QuestLog.status.NOT_STARTED)
	player:setStorageValue(QuestLog.storage.bootcamp.dummyDefeated, -1)
end

local RESETTERS = {
	bootcamp = resetBootcamp,
	wolves = function(player) player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.NOT_STARTED) end,
	locket = function(player) player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.NOT_STARTED) end,
	signal = resetSignal,
	vault = resetVault,
	cathedral = resetCathedral,
	raid = resetRaid,
}

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local commaPos = param:find(',')
	if not commaPos then
		player:sendCancelMessage('Usage: /questreset <player name>, <bootcamp|wolves|locket|signal|vault|cathedral|raid|all|renown>')
		return false
	end

	local function trim(s)
		return s:match('^%s*(.-)%s*$')
	end

	local targetName = trim(param:sub(1, commaPos - 1))
	local questKey = trim(param:sub(commaPos + 1)):lower()

	local target = Player(targetName)
	if not target then
		player:sendCancelMessage('Player "' .. targetName .. '" is not online.')
		return false
	end

	if questKey == 'renown' then
		target:setRenown(0)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Reset Renown to Neutral (0) for ' .. target:getName() .. '.')
		return false
	end

	if questKey == 'all' then
		for _, resetter in pairs(RESETTERS) do
			resetter(target)
		end
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Reset all quests for ' .. target:getName() .. '.')
		return false
	end

	local resetter = RESETTERS[questKey]
	if not resetter then
		player:sendCancelMessage('Unknown quest "' .. questKey .. '". Use bootcamp, wolves, locket, signal, vault, cathedral, raid, all, or renown.')
		return false
	end

	resetter(target)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Reset "' .. questKey .. '" for ' .. target:getName() .. '.')
	return false
end
