--[[
	Healing Draught (itemid 20031). Consumes one on use, heals a flat
	amount. No cooldown - the price and the modest heal are the balance.
]]

local healingDraught = Action()

local HEAL_AMOUNT = 150

function healingDraught.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getHealth() >= player:getMaxHealth() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You are already at full health.')
		return true
	end

	player:addHealth(HEAL_AMOUNT)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	item:remove(1)
	return true
end

healingDraught:id(20031)
healingDraught:register()
