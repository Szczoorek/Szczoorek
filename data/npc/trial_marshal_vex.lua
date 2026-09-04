--[[
	Trial Marshal Vex - explains the Proving Grounds. Doesn't start the run
	itself (the lever does that, see
	data/scripts/actions/trial/proving_grounds_lever.lua) - purely
	dialogue/status.
]]

local internalNpcName = "Trial Marshal Vex"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 137,
	lookHead = 20,
	lookBody = 76,
	lookLegs = 76,
	lookFeet = 76,
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

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if not (MsgContains(message, 'trial') or MsgContains(message, 'proving')) then
		return false
	end

	local player = Player(creature)

	if TrialLog.isRunning() then
		npcHandler:say('Someone\'s already in there. Wait for the gate to open again.', npc, creature)
		return true
	end

	local remaining = player:getTrialCooldownRemaining()
	if remaining > 0 then
		npcHandler:say('You just went. Give it ' .. math.ceil(remaining / 60) .. ' more minute(s).', npc, creature)
		return true
	end

	npcHandler:say('Five waves, back to back - wolves, bandits, forge slaves, smelters, and a pack of molten ' ..
		'hounds to finish. Pull the lever when you\'re ready. Clear it inside 5 minutes for a little extra.', npc, creature)
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "|PLAYERNAME|. Fancy your chances? Ask about the 'trial' and pull the lever behind me when you're ready.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Five waves. Don't blink.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "The lever's right there when you're ready.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
