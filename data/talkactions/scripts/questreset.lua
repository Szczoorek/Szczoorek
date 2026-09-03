--[[
	GM utility: /questreset <player name>, <quest>

	<quest> is one of: wolves, locket, vault, cathedral, all
	Resets that player's storage(s) back to NOT_STARTED so the quest/dungeon
	can be replayed while you're testing map placement and scripts.

	Example: /questreset GM Tester, vault
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

local RESETTERS = {
	wolves = function(player) player:setQuestStatus(QuestLog.storage.wolves, QuestLog.status.NOT_STARTED) end,
	locket = function(player) player:setQuestStatus(QuestLog.storage.locket, QuestLog.status.NOT_STARTED) end,
	vault = resetVault,
	cathedral = resetCathedral,
}

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local commaPos = param:find(',')
	if not commaPos then
		player:sendCancelMessage('Usage: /questreset <player name>, <wolves|locket|vault|cathedral|all>')
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

	if questKey == 'all' then
		for _, resetter in pairs(RESETTERS) do
			resetter(target)
		end
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Reset all quests for ' .. target:getName() .. '.')
		return false
	end

	local resetter = RESETTERS[questKey]
	if not resetter then
		player:sendCancelMessage('Unknown quest "' .. questKey .. '". Use wolves, locket, vault, cathedral or all.')
		return false
	end

	resetter(target)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Reset "' .. questKey .. '" for ' .. target:getName() .. '.')
	return false
end
