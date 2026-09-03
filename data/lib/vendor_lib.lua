--[[
	vendor_lib.lua

	Shared logic for reputation-gated "quartermaster" vendor NPCs (see
	data/npc/scripts/quartermaster_reyes.lua and armsmaster_cael.lua).
	Dialogue-driven rather than the native trade window, so standing can
	gate individual items and stay consistent with the rest of this pack's
	keyword-based NPCs.
]]

VendorLib = {}

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

	return function(cid, type, msg)
		if not npcHandler:isFocused(cid) then
			return false
		end

		local player = Player(cid)

		if msg:find('shop') or msg:find('trade') or msg:find('buy') then
			local lines = {}
			for _, entry in ipairs(items) do
				table.insert(lines, catalogLine(player, entry))
			end
			npcHandler:say('Your standing with us: ' .. player:getReputationRank(factionKey).name ..
				'. ' .. table.concat(lines, ' | '), cid)
			return true
		end

		for _, entry in ipairs(items) do
			if msg:find(entry.keyword) then
				if not player:hasReputationRank(factionKey, entry.rank) then
					npcHandler:say('You need ' .. entry.rank .. ' standing with us before I part with that.', cid)
					return true
				end

				if not player:removeMoney(entry.price) then
					npcHandler:say('That\'s ' .. entry.price .. ' gold - come back when you have it.', cid)
					return true
				end

				player:addItem(entry.itemId, 1)
				npcHandler:say('Pleasure doing business.', cid)
				return true
			end
		end

		return false
	end
end
