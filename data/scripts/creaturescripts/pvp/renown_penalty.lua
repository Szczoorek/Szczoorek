--[[
	renown_penalty.lua

	Docks Renown from a player who kills another player in the open world.
	See docs/design/renown_and_pvp.md for the full writeup - READ IT before
	wiring this in, because unlike everything else in this pack this one
	script needs a manual registration step your server's *existing*
	login script has to make (see "Installing" in that doc).

	Signature confirmed against Canary's revscriptsys CreatureEvent onDeath
	convention: onDeath(creature, corpse, killer, mostDamageKiller,
	unjustified, mostDamageUnjustified) - `unjustified` is Canary's own
	naming for what some docs call `lastHitUnjustified`; same value either
	way. If a future Canary version changes this shape, the logic below
	(find the killer, check whether it was unjustified, dock Renown) ports
	over unchanged - only the parameter list would need to match.
]]

-- Only unjustified kills cost Renown by default - i.e. this leans on
-- Tibia's own built-in skull/frag system to decide "was this a
-- legitimate PvP kill (self-defense, a returned attack, a sanctioned
-- war) or an unprovoked one". Set this to true if you'd rather penalize
-- every open-world player kill regardless of the game's own
-- justification logic.
local PENALIZE_ALL_PVP_KILLS = false

local RENOWN_LOSS_PER_KILL = 50

local renownPvpPenalty = CreatureEvent('RenownPvpPenalty')

function renownPvpPenalty.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if not killer then
		return true
	end

	local killingPlayer = killer:getPlayer()
	if not killingPlayer then
		return true
	end

	local victim = creature:getPlayer()
	if not victim or killingPlayer == victim then
		return true
	end

	if not (PENALIZE_ALL_PVP_KILLS or unjustified) then
		return true
	end

	killingPlayer:addRenown(-RENOWN_LOSS_PER_KILL)
	killingPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE,
		'Word spreads of what you did. Your renown suffers for it.')

	return true
end

renownPvpPenalty:register()
