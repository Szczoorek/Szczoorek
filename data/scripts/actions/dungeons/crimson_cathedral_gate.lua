--[[
	Gate into the inner cathedral, where The Flameseer waits.

	Map setup:
	  - Place a door/gate item that blocks movement on a walkable tile and
	    give it uniqueid 10020.
	  - Place a usable object (altar, door handle, whatever fits the scene)
	    with actionid 10021 next to it - that's what this script is bound to.
	  - Requires the Cathedral Sigil (dropped rarely by Cathedral Guards) to
	    open on the first attempt, OR all three outer bosses (Malachar,
	    Ophelia, Varek) dead, whichever comes first - so a very unlucky
	    group can still progress by clearing the outer wings.

	Unlike the Sunken Vault gate, the sigil is consumed (it's a one-time
	unlock, not a proof-of-completion item players hand back to an NPC).
]]

local crimsonCathedralGate = Action()

local GATE_UNIQUE_ID = 10020

function crimsonCathedralGate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local gate = Item(GATE_UNIQUE_ID)
	if not gate then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The inner cathedral already lies open.')
		return true
	end

	if player:getItemCount(QuestLog.items.cathedralSigil) > 0 then
		player:removeItem(QuestLog.items.cathedralSigil, 1)
		gate:remove()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The sigil flares and crumbles to ash. The inner gate swings open.')
		item:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
		return true
	end

	local outerWingsCleared = player:hasDefeated(QuestLog.storage.cathedral.malachar)
		and player:hasDefeated(QuestLog.storage.cathedral.ophelia)
		and player:hasDefeated(QuestLog.storage.cathedral.varek)

	if outerWingsCleared then
		gate:remove()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'With the outer wings silenced, the wards on the gate fail. It opens.')
		item:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
		return true
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Warded shut. You\'ll need a Cathedral Sigil, or to clear the outer wings first: Brother Malachar, Sister Ophelia and Highlord Varek.')
	return true
end

crimsonCathedralGate:aid(10021)
crimsonCathedralGate:register()
