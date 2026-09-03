--[[
	Signal beacons for Quest 3 (Signal the Watch). One script handles all
	three - which beacon fired is read off the used item's Action ID.

	Map setup: place three existing brazier/torch-stand-looking items
	around the outskirts and give them actionids 10003 (north), 10004
	(east) and 10005 (south). No new item id needed - these reuse whatever
	decorative torch/brazier graphic your items.otb already has.
]]

local BEACONS = {
	[10003] = { key = QuestLog.storage.signal.beaconNorth, label = 'northern' },
	[10004] = { key = QuestLog.storage.signal.beaconEast, label = 'eastern' },
	[10005] = { key = QuestLog.storage.signal.beaconSouth, label = 'southern' },
}

local function litCount(player)
	local count = 0
	for _, beacon in pairs(BEACONS) do
		if player:hasFlag(beacon.key) then
			count = count + 1
		end
	end
	return count
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local beacon = BEACONS[item:getActionId()]
	if not beacon then
		return false
	end

	local status = player:getQuestStatus(QuestLog.storage.signal.quest)
	if status == QuestLog.status.NOT_STARTED then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Nothing happens - perhaps the watch should know about this first.')
		return true
	end

	if player:hasFlag(beacon.key) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The ' .. beacon.label .. ' beacon is already lit.')
		return true
	end

	player:setFlag(beacon.key)
	item:getPosition():sendMagicEffect(CONST_ME_FIREAREA)

	local remaining = 3 - litCount(player)
	if remaining > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The ' .. beacon.label .. ' beacon roars to life. ' ..
			remaining .. ' more to go.')
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The last beacon catches. Report back to Watchman Farro.')
	end

	return true
end
