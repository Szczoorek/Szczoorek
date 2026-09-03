--[[
	!reputation - shows the speaking player's standing with both starter
	factions. Player-facing, no access restriction.
]]

function onSay(player, words, param)
	local harborRank = player:getReputationRank(ReputationLog.storage.harborTradeConcern)
	local harborValue = player:getReputation(ReputationLog.storage.harborTradeConcern)
	local emberRank = player:getReputationRank(ReputationLog.storage.orderOfTheEmber)
	local emberValue = player:getReputation(ReputationLog.storage.orderOfTheEmber)

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
		'Harbor Trade Concern: ' .. harborRank.name .. ' (' .. harborValue .. ')\n' ..
		'Order of the Ember: ' .. emberRank.name .. ' (' .. emberValue .. ')')
	return false
end
