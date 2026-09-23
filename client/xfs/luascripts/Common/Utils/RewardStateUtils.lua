-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\RewardStateUtils.lua

local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local RewardState = ClientConst.RewardState
local RewardStateUtils = {
	State = RewardState
}

function RewardStateUtils.resolveState(data)
	data = data or {}

	if data.state ~= nil then
		return data.state
	end

	if data.hasGet then
		return RewardState.Claimed
	end

	if data.canGet then
		return RewardState.ReadyToClaim
	end

	return RewardState.NotAchieved
end

function RewardStateUtils.applyItemState(widget, data, pageName)
	local state = RewardStateUtils.resolveState(data)

	widget:TryChangePage(pageName or "State", state)

	if data and data.showRedDot ~= nil then
		widget:ShowRedDot(data.showRedDot)
	end

	return state
end

function RewardStateUtils.applyStatus(widget, status, claimableStatus, claimedStatus, pageName)
	local state = RewardState.NotAchieved

	if status == claimedStatus then
		state = RewardState.Claimed
	elseif status == claimableStatus then
		state = RewardState.ReadyToClaim
	end

	widget:TryChangePage(pageName or "State", state)

	return state
end

function RewardStateUtils.buildRedDotPath(rootPath, ...)
	return table.concat({
		rootPath,
		...
	}, ".")
end

function RewardStateUtils.applyClaimButton(button, canClaim, redDotRoot, updateInteractable, ...)
	if updateInteractable then
		button.interactable = canClaim
	end

	local redDotPath = RewardStateUtils.buildRedDotPath(redDotRoot, ...)

	pg.global.setRedDot(redDotPath, button, canClaim, RedDotConst.RedDotStyle.REWARD)

	return canClaim
end

return RewardStateUtils
