--[[
	!achievements - lists the achievements the speaking player has earned.
	Player-facing, no access restriction.
]]

local achievements = TalkAction('!achievements')

function achievements.onSay(player, words, param)
	local earned = player:listAchievements()

	if #earned == 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You haven\'t earned any achievements yet.')
		return false
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Achievements earned: ' .. table.concat(earned, ', ') .. '.')
	return false
end

achievements:register()
