--[[
	!quests - status overview across every quest, dungeon and the raid at
	once. Complements !achievements and !reputation. Player-facing, no
	access restriction.
]]

local quests = TalkAction('!quests')

local STATUS_LABEL = {
	[QuestLog.status.NOT_STARTED] = 'Not Started',
	[QuestLog.status.STARTED] = 'In Progress',
	[QuestLog.status.COMPLETED] = 'Completed',
}

-- Ordered list of (display name, storage key) pairs - storage keys for
-- multi-part quests (vault/cathedral/raid) use their top-level `.quest`
-- status, same as their NPCs check.
local ENTRIES = {
	{ 'Boot Camp', QuestLog.storage.bootcamp.quest },
	{ 'Wolves at the Doorstep', QuestLog.storage.wolves },
	{ 'The Lost Locket', QuestLog.storage.locket },
	{ 'Signal the Watch', QuestLog.storage.signal.quest },
	{ 'The Sunken Vault', QuestLog.storage.vault.quest },
	{ 'The Crimson Cathedral', QuestLog.storage.cathedral.quest },
	{ 'The Cinderforge Depths', QuestLog.storage.raid.quest },
}

function quests.onSay(player, words, param)
	local lines = {}
	for _, entry in ipairs(ENTRIES) do
		local name, storageKey = entry[1], entry[2]
		local status = STATUS_LABEL[player:getQuestStatus(storageKey)]
		table.insert(lines, name .. ': ' .. status)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, table.concat(lines, '\n'))
	return false
end

quests:register()
