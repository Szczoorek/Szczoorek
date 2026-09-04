--[[
	The chest inside the cave for "The Lost Locket" (Quest 2).

	Map setup: place a chest/container-looking item somewhere in the cave
	and give it actionid 10001 (registered by this script's own aid call
	at the bottom - no separate XML registration needed).
	Using it grants the Tarnished Locket once, only while the quest is
	STARTED and only if the player isn't already carrying/hasn't already
	turned in one.
]]

local lostLocketChest = Action()

function lostLocketChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local status = player:getQuestStatus(QuestLog.storage.locket)

	if status == QuestLog.status.COMPLETED then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The chest is empty - you already found what you needed here.')
		return true
	end

	if status ~= QuestLog.status.STARTED then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The chest is locked. Perhaps someone in the village knows more about it.')
		return true
	end

	if player:getItemCount(QuestLog.items.tarnishedLocket) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You already have the locket - go show it to Old Man Corwin.')
		return true
	end

	player:addItem(QuestLog.items.tarnishedLocket, 1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Digging through the dust, you find a tarnished locket.')
	item:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

lostLocketChest:aid(10001)
lostLocketChest:register()
