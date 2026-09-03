--[[
	Trial Marshal Vex - explains the Proving Grounds. Doesn't start the run
	itself (the lever does that, see
	data/actions/scripts/trial/proving_grounds_lever.lua) - purely
	dialogue/status.
]]

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if not (msg:find('trial') or msg:find('proving')) then
		return false
	end

	local player = Player(cid)

	if TrialLog.isRunning() then
		npcHandler:say('Someone\'s already in there. Wait for the gate to open again.', cid)
		return true
	end

	local remaining = player:getTrialCooldownRemaining()
	if remaining > 0 then
		npcHandler:say('You just went. Give it ' .. math.ceil(remaining / 60) .. ' more minute(s).', cid)
		return true
	end

	npcHandler:say('Five waves, back to back - wolves, bandits, forge slaves, smelters, and a pack of molten ' ..
		'hounds to finish. Pull the lever when you\'re ready. Clear it inside 5 minutes for a little extra.', cid)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
