--[[
	Entrance to The Cinderforge Depths. Locked behind both starter
	dungeons' completion achievements - see docs/design/dungeon_cinderforge_depths.md.

	Map setup: same pattern as the two dungeon gates - a movement-blocking
	gate item with uniqueid 10030 on a walkable tile, opened (removed) by
	whichever qualifying player uses this action object (actionid 10022)
	first. Once open, it stays open for everyone, same as the other gates.
]]

local GATE_UNIQUE_ID = 10030

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local gate = Item(GATE_UNIQUE_ID)
	if not gate then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The way into the Cinderforge Depths already lies open.')
		return true
	end

	local qualified = player:hasAchievement(AchievementLog.storage.vaultCleaner)
		and player:hasAchievement(AchievementLog.storage.cathedralsBane)

	if not qualified then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The Forge Wardens bar the way. Only those who have proven ' ..
			'themselves in both the Sunken Vault and the Crimson Cathedral may enter.')
		return true
	end

	gate:remove()
	player:setQuestStatus(QuestLog.storage.raid.quest, QuestLog.status.STARTED)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The Forge Wardens recognize your deeds and stand aside. ' ..
		'The way into the Cinderforge Depths opens.')
	item:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
	return true
end
