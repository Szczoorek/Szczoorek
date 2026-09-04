--[[
	Rolls a chance every 30 minutes to spawn Fenrir the Alpha in the Wolves
	at the Doorstep forest, if he isn't already up. Keeps him a "rare",
	not a guaranteed camp - see docs/design/fenrir_the_alpha.md.

	TODO: FENRIR_SPAWN_POSITION is a placeholder. Update it to the real
	position once the forest area exists on your map.
]]

local fenrirRespawnCheck = GlobalEvent('FenrirRespawnCheck')

local FENRIR_SPAWN_POSITION = Position(1000, 1000, 7)
local SPAWN_CHANCE_PERCENT = 15
local CHECK_RADIUS = 15

function fenrirRespawnCheck.onThink(interval)
	local spectators = Game.getSpectators(FENRIR_SPAWN_POSITION, false, false, CHECK_RADIUS, CHECK_RADIUS, CHECK_RADIUS, CHECK_RADIUS)
	for _, creature in ipairs(spectators) do
		local monster = creature:getMonster()
		if monster and monster:getName() == 'Fenrir the Alpha' then
			return true -- already up, nothing to do
		end
	end

	if math.random(100) <= SPAWN_CHANCE_PERCENT then
		local fenrir = Game.createMonster('Fenrir the Alpha', FENRIR_SPAWN_POSITION, true, true)
		if fenrir then
			DungeonLib.broadcast('A massive wolf howl echoes from the forest...')
		end
	end

	return true
end

fenrirRespawnCheck:interval(1800000)
fenrirRespawnCheck:register()
