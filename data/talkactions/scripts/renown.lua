--[[
	!renown - shows the speaking player's current Renown and rank.
	Player-facing, no access restriction.
]]

function onSay(player, words, param)
	local value = player:getRenown()
	local rank = player:getRenownRank()
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Renown: ' .. rank.name .. ' (' .. value .. ')')
	return false
end
