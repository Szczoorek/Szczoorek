--[[
	Lever that opens the path to Captain Blackscale in The Sunken Vault.

	Map setup:
	  - Place the lever with actionid 10002 (see data/actions/actions.xml).
	  - Place a barred-gate item (any item that blocks movement, e.g. a
	    "not walkable" grille/gate) on a walkable floor tile, and give that
	    gate item uniqueid 10010. Do NOT give the lever itself that uid -
	    they're two different objects.
	  - Once both Rustbeard the Mad and Foreman Grix are dead, pulling the
	    lever removes the gate item, opening the way to Blackscale's room.
	    (Removing rather than "opening" the item is deliberate: it works
	    regardless of which gate/grille graphic your client has, no matter
	    the exact item id you picked for it.)

	Alternative/shortcut: a player carrying a Rusty Vault Key
	(QuestLog.items.rustyVaultKey) can open the gate immediately, skipping
	the requirement to have downed both mini-bosses first - hand that key
	out via a rare trash drop or a side objective if you want a shortcut
	route through the dungeon.
]]

local GATE_UNIQUE_ID = 10010

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local gate = Item(GATE_UNIQUE_ID)
	if not gate then
		-- Already open (or the gate hasn't been placed on the map yet).
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The way ahead is already open.')
		return true
	end

	if player:getItemCount(QuestLog.items.rustyVaultKey) > 0 then
		gate:remove()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The rusty key grinds in the lock. The gate swings open.')
		item:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local rustbeardDown = player:hasDefeated(QuestLog.storage.vault.rustbeard)
	local grixDown = player:hasDefeated(QuestLog.storage.vault.grix)

	if rustbeardDown and grixDown then
		gate:remove()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'With both of the Vault\'s lieutenants dealt with, the lever gives way. The gate opens.')
		item:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'The lever won\'t budge - something down here is still holding the gate shut. (Deal with Rustbeard the Mad and Foreman Grix first, or find a key.)')
	return true
end
