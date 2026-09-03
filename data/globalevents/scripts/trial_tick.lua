--[[
	Polls the Proving Grounds every 5 seconds while a run is active, to
	advance waves / complete the run. See data/lib/trial_log.lua.
]]

function onThink(interval)
	TrialLog.tick()
	return true
end
