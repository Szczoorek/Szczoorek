--[[
	Bounty Clerk Sarna - daily repeatable bounties for both starter
	dungeons' trash mobs. No "accept" step needed - kills always count
	(see data/scripts/creaturescripts/bounties/*.lua); she just reports
	progress and pays out once a track is finished.

	Flow:
	  say 'bounty'          -> status line for both tracks
	  say 'vault bounty'     -> turn in the Sunken Vault bounty if ready
	  say 'cathedral bounty' -> turn in the Crimson Cathedral bounty if ready
]]

local internalNpcName = "Bounty Clerk Sarna"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 90
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 20,
	lookBody = 39,
	lookLegs = 20,
	lookFeet = 20,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
	profession = "normal",
}
npcConfig.speechBubble = SPEECHBUBBLE_NORMAL

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local TRACK_LABEL = {
	vault = 'Sunken Vault',
	cathedral = 'Crimson Cathedral',
}

local function statusLine(player, track)
	local required = BountyLog.requiredKills[track]
	if player:isBountyCompletedToday(track) then
		return TRACK_LABEL[track] .. ' bounty: already claimed today.'
	end
	local progress = player:getBountyProgress(track)
	if progress >= required then
		return TRACK_LABEL[track] .. ' bounty: ' .. progress .. '/' .. required .. ' - ready to turn in!'
	end
	return TRACK_LABEL[track] .. ' bounty: ' .. progress .. '/' .. required .. ' trash cleared.'
end

local function turnIn(npc, creature, player, track)
	if not player:isBountyReadyToTurnIn(track) then
		npcHandler:say(statusLine(player, track), npc, creature)
		return
	end

	player:completeBounty(track)
	npcHandler:say('Good work. That\'s ' .. BountyLog.rewardGold[track] .. ' gold, and word of it will reach the right ears.', npc, creature)
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)

	if MsgContains(message, 'vault bounty') then
		turnIn(npc, creature, player, 'vault')
		return true
	end

	if MsgContains(message, 'cathedral bounty') then
		turnIn(npc, creature, player, 'cathedral')
		return true
	end

	if MsgContains(message, 'bounty') then
		npcHandler:say(statusLine(player, 'vault') .. ' ' .. statusLine(player, 'cathedral') ..
			' Kill ' .. BountyLog.requiredKills.vault .. ' trash in either dungeon, then say \'vault bounty\' or \'cathedral bounty\' to collect.', npc, creature)
		return true
	end

	return false
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Both the Vault and the Cathedral always need more bodies cleared out. Ask about the 'bounty' board.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bring back proof, not stories.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The board resets at midnight, not before.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
