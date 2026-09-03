--[[
	trial_log.lua

	The Proving Grounds: a repeatable 5-wave survival gauntlet run in a
	single shared arena. Session state (which wave is active, whether the
	arena is currently in use) lives in plain Lua globals on this table
	rather than storage values - it's meant to reset if the server
	restarts mid-run, and only one run can be in progress at a time. See
	docs/design/the_proving_grounds.md for why that's an acceptable
	limitation on an engine with no real instancing.

	Waves reuse existing pack monsters that don't carry their own onDeath
	creaturescript (so nothing about their XML needs to change): Timber
	Wolf, Roadside Bandit, Forge Slave, Cinderforge Smelter, Molten Hound.

	Reserved PLAYER storage: 45050 (per-player cooldown between attempts).
]]

TrialLog = {}

TrialLog.storage = {
	lastAttempt = 45050,
}

TrialLog.cooldownSeconds = 15 * 60  -- 15 minutes between attempts, per player
TrialLog.safetyTimeoutSeconds = 20 * 60 -- force-reset an abandoned/stuck run
TrialLog.speedBonusSeconds = 300    -- clear all 5 waves this fast for bonus gold

-- Fixed arena center. TODO: placeholder - update once the arena exists on
-- your map (see docs/design/the_proving_grounds.md).
TrialLog.arenaPosition = Position(1000, 1005, 7)
TrialLog.arenaRadius = 10

TrialLog.waves = {
	{ { name = 'Timber Wolf', count = 4 } },
	{ { name = 'Roadside Bandit', count = 4 } },
	{ { name = 'Forge Slave', count = 3 } },
	{ { name = 'Cinderforge Smelter', count = 3 } },
	{ { name = 'Molten Hound', count = 5 } },
}

-- Session state - NOT persisted, see file header.
TrialLog.wave = 0 -- 0 = no run in progress
TrialLog.waveStartedAt = 0
TrialLog.runStartedAt = 0

function TrialLog.isRunning()
	return TrialLog.wave > 0
end

function TrialLog.spawnWave(index)
	local wave = TrialLog.waves[index]
	if not wave then
		return
	end
	for _, group in ipairs(wave) do
		for i = 1, group.count do
			DungeonLib.summonMonster(TrialLog.arenaPosition, group.name)
		end
	end
end

--- Starts a run for `player`. Caller (the lever script) is responsible for
--- checking isRunning() and the player's cooldown first.
function TrialLog.start(player)
	TrialLog.wave = 1
	TrialLog.waveStartedAt = os.time()
	TrialLog.runStartedAt = os.time()
	player:setStorageValue(TrialLog.storage.lastAttempt, os.time())
	TrialLog.spawnWave(1)
	DungeonLib.broadcast(player:getName() .. ' has entered the Proving Grounds!')
end

--- Called every few seconds by the trial_tick globalevent. Advances the
--- wave once the current wave's monsters are all dead, completes the run
--- after wave 5, and force-resets past the safety timeout.
function TrialLog.tick()
	if not TrialLog.isRunning() then
		return
	end

	if os.time() - TrialLog.runStartedAt > TrialLog.safetyTimeoutSeconds then
		TrialLog.wave = 0
		DungeonLib.broadcast('The Proving Grounds have reset after running too long.')
		return
	end

	local wave = TrialLog.waves[TrialLog.wave]
	for _, group in ipairs(wave) do
		if DungeonLib.isMonsterAliveNearby(TrialLog.arenaPosition, group.name, TrialLog.arenaRadius) then
			return -- this wave isn't clear yet
		end
	end

	if TrialLog.wave >= #TrialLog.waves then
		TrialLog.completeRun()
	else
		TrialLog.wave = TrialLog.wave + 1
		TrialLog.waveStartedAt = os.time()
		TrialLog.spawnWave(TrialLog.wave)
		DungeonLib.broadcast('Wave ' .. TrialLog.wave .. ' begins in the Proving Grounds!')
	end
end

function TrialLog.completeRun()
	local elapsed = os.time() - TrialLog.runStartedAt
	TrialLog.wave = 0
	local bonus = elapsed <= TrialLog.speedBonusSeconds and 500 or 0

	local spectators = Game.getSpectators(TrialLog.arenaPosition, false, false,
		TrialLog.arenaRadius, TrialLog.arenaRadius, TrialLog.arenaRadius, TrialLog.arenaRadius)
	for _, creature in ipairs(spectators) do
		local player = creature:getPlayer()
		if player then
			player:addExperience(2500)
			player:addMoney(1000 + bonus)
			player:grantAchievement(AchievementLog.storage.provingGroundsChampion)
		end
	end

	DungeonLib.broadcast('The Proving Grounds have been cleared in ' .. elapsed .. ' seconds!')
end

-- ===========================================================================
-- Player helpers
-- ===========================================================================

function Player.getTrialCooldownRemaining(self)
	local last = self:getStorageValue(TrialLog.storage.lastAttempt)
	if last <= 0 then
		return 0
	end
	return math.max(0, TrialLog.cooldownSeconds - (os.time() - last))
end
