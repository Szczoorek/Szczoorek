--[[
	Starts a Proving Grounds run. See data/lib/trial_log.lua and
	docs/design/the_proving_grounds.md.
]]

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if TrialLog.isRunning() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The Proving Grounds are already in use - wait for the current run to finish.')
		return true
	end

	local remaining = player:getTrialCooldownRemaining()
	if remaining > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You must wait ' .. math.ceil(remaining / 60) ..
			' more minute(s) before trying again.')
		return true
	end

	TrialLog.start(player)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The gates seal. Survive five waves.')
	item:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end
