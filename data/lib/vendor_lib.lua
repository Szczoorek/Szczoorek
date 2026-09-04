--[[
	vendor_lib.lua

	Shared logic for reputation-gated "quartermaster" vendor NPCs (see
	data/npc/quartermaster_reyes.lua and armsmaster_cael.lua).
	Dialogue-driven rather than the native trade window, so standing can
	gate individual items and stay consistent with the rest of this pack's
	keyword-based NPCs.

	Also gated on Renown (see renown_log.lua / docs/design/renown_and_pvp.md):
	regardless of faction standing, a player whose Renown has dropped below
	Neutral (from unprovoked open-world player kills) is refused service
	entirely. Provisioner Nadia (data/npc/provisioner_nadia.lua) enforces
	the same minimum independently, since she doesn't use this lib.
]]

VendorLib = {}

VendorLib.minimumRenownRank = 'Neutral'

--- Builds a CALLBACK_MESSAGE_DEFAULT function for a vendor NPC.
---   npcHandler - that NPC's NpcHandler instance
---   factionKey - a ReputationLog.storage key
---   items      - array of { keyword, name, itemId, rank, price }, where
---                 `rank` is a ReputationLog rank name (e.g. 'Honored') and
---                 `price` is in gold coins
function VendorLib.buildShopCallback(npcHandler, factionKey, items)
	local function catalogLine(player, entry)
		local locked = player:hasReputationRank(factionKey, entry.rank) and '' or ' (locked)'
		return entry.name .. ' [' .. entry.rank .. ' - ' .. entry.price .. ' gold]' .. locked .. ", say '" .. entry.keyword .. "'"
	end

	return function(npc, creature, type, message)
		if not npcHandler:checkInteraction(npc, creature) then
			return false
		end

		local player = Player(creature)

		if not player:hasRenownRank(VendorLib.minimumRenownRank) then
			if MsgContains(message, 'shop') or MsgContains(message, 'trade') or MsgContains(message, 'buy') then
				npcHandler:say('I know what you\'ve done out there. I won\'t deal with you.', npc, creature)
				return true
			end
			for _, entry in ipairs(items) do
				if MsgContains(message, entry.keyword) then
					npcHandler:say('I know what you\'ve done out there. I won\'t deal with you.', npc, creature)
					return true
				end
			end
			return false
		end

		if MsgContains(message, 'shop') or MsgContains(message, 'trade') or MsgContains(message, 'buy') then
			local lines = {}
			for _, entry in ipairs(items) do
				table.insert(lines, catalogLine(player, entry))
			end
			npcHandler:say('Your standing with us: ' .. player:getReputationRank(factionKey).name ..
				'. ' .. table.concat(lines, ' | '), npc, creature)
			return true
		end

		for _, entry in ipairs(items) do
			if MsgContains(message, entry.keyword) then
				if not player:hasReputationRank(factionKey, entry.rank) then
					npcHandler:say('You need ' .. entry.rank .. ' standing with us before I part with that.', npc, creature)
					return true
				end

				if not player:removeMoney(entry.price) then
					npcHandler:say('That\'s ' .. entry.price .. ' gold - come back when you have it.', npc, creature)
					return true
				end

				player:addItem(entry.itemId, 1)
				npcHandler:say('Pleasure doing business.', npc, creature)
				return true
			end
		end

		return false
	end
end
