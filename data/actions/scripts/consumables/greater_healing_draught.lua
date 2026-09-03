--[[
	Greater Healing Draught (itemid 20032). Same shape as the basic
	Healing Draught, bigger heal, higher price.
]]

local HEAL_AMOUNT = 300

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getHealth() >= player:getMaxHealth() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You are already at full health.')
		return true
	end

	player:addHealth(HEAL_AMOUNT)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	item:remove(1)
	return true
end
