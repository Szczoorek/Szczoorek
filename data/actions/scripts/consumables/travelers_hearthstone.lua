--[[
	Traveler's Hearthstone (itemid 20033) - a WoW Hearthstone homage. NOT
	consumed on use; teleports the player back to a fixed home point,
	gated by a 30-minute per-player cooldown. See
	docs/design/general_goods.md.
]]

local COOLDOWN_SECONDS = 30 * 60

-- TODO: placeholder - update to the real village hub bind spot once it
-- exists on your map.
local HOME_POSITION = Position(1000, 1000, 7)

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local last = player:getStorageValue(QuestLog.storage.hearthstoneCooldown)
	if last > 0 and os.time() - last < COOLDOWN_SECONDS then
		local remaining = COOLDOWN_SECONDS - (os.time() - last)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The hearthstone is still cooling down. ' ..
			math.ceil(remaining / 60) .. ' more minute(s).')
		return true
	end

	player:setStorageValue(QuestLog.storage.hearthstoneCooldown, os.time())
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(HOME_POSITION)
	HOME_POSITION:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The hearthstone hums, and the world blurs around you...')
	return true
end
