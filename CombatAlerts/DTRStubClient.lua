--[[
This is a rudimentary stub client for the Dungeon and Trial Instance Reset Tool,
to auto-accept invites from a group leader who had recently disbanded the group.

The code here is active only if DTR is not installed.
]]--

LibCodesCommonCode.RunAfterInitialLoadscreen(function( )
	local DTR = DungeonTrialReset
	if (type(DTR) == "table" and type(DTR.version) == "number" and DTR.version >= 1) then return end

	local RCR = Raidificator
	if (type(RCR) == "table" and type(RCR.DTR) == "table") then return end

	local name = "CCA_DTRStubClient"
	local disbandLeader = ""
	local disbandTime = 0

	EVENT_MANAGER:RegisterForEvent(name, EVENT_GROUP_MEMBER_LEFT, function( _, _, reason, isLocalPlayer, isLeader, memberDisplayName )
		if (not isLocalPlayer and isLeader and reason == GROUP_LEAVE_REASON_DISBAND) then
			disbandLeader = memberDisplayName
			disbandTime = GetGameTimeMilliseconds()
		end
	end)

	EVENT_MANAGER:RegisterForEvent(name, EVENT_GROUP_INVITE_RECEIVED, function( _, _, inviterDisplayName )
		if (inviterDisplayName == disbandLeader and GetGameTimeMilliseconds() - disbandTime < 5000) then
			AcceptGroupInvite()
		end
	end)
end)
