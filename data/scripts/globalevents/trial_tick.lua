--[[
	Polls the Proving Grounds every 5 seconds while a run is active, to
	advance waves / complete the run. See data/lib/trial_log.lua.
]]

local provingGroundsTick = GlobalEvent('ProvingGroundsTick')

function provingGroundsTick.onThink(interval)
	TrialLog.tick()
	return true
end

provingGroundsTick:interval(5000)
provingGroundsTick:register()
