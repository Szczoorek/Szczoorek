--[[
	Bounty Clerk Sarna - daily repeatable bounties for both starter
	dungeons' trash mobs. No "accept" step needed - kills always count
	(see data/creaturescripts/scripts/bounties/*.lua); she just reports
	progress and pays out once a track is finished.

	Flow:
	  say 'bounty'          -> status line for both tracks
	  say 'vault bounty'     -> turn in the Sunken Vault bounty if ready
	  say 'cathedral bounty' -> turn in the Crimson Cathedral bounty if ready
]]

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

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

local function turnIn(npcHandler, player, cid, track)
	if not player:isBountyReadyToTurnIn(track) then
		npcHandler:say(statusLine(player, track), cid)
		return
	end

	player:completeBounty(track)
	npcHandler:say('Good work. That\'s ' .. BountyLog.rewardGold[track] .. ' gold, and word of it will reach the right ears.', cid)
end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msg:find('vault bounty') then
		turnIn(npcHandler, player, cid, 'vault')
		return true
	end

	if msg:find('cathedral bounty') then
		turnIn(npcHandler, player, cid, 'cathedral')
		return true
	end

	if msg:find('bounty') then
		npcHandler:say(statusLine(player, 'vault') .. ' ' .. statusLine(player, 'cathedral') ..
			' Kill ' .. BountyLog.requiredKills.vault .. ' trash in either dungeon, then say \'vault bounty\' or \'cathedral bounty\' to collect.', cid)
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
