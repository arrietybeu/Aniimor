-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerMmoItemComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local ArkMmoitemConditionIndex = require("Data.ark_mmoitem_condition_index")
local TimerManager = require("Core.Timer.TimerManager")
local ClientPlayerMmoItemComponent = Class.Component("ClientPlayerMmoItemComponent")

function ClientPlayerMmoItemComponent:ctor()
	return
end

function ClientPlayerMmoItemComponent:on_mmoItemCoolDownMap_cdTime_changed(oldVal, newVal, id, state)
	local levelItem = appFacade.sandboxManager.globalSandbox:GetLevelItem(id)

	if not levelItem then
		return
	end

	local arkBridgeSB = levelItem.gameObject:GetComponent("ArkBridgeSB")

	if not arkBridgeSB then
		return
	end

	if self.resetTimer then
		TimerManager.removeTimer(self.resetTimer)
	end

	local conditionData = ArkMmoitemConditionIndex[arkBridgeSB.arkConditionId]
	local isServer = conditionData.isServer[state]

	if type(isServer) == "table" then
		isServer = isServer[1]
	end

	if isServer == 0 then
		arkBridgeSB:PlayWithState(state)

		local duration = conditionData.durations[state]

		if duration and duration > 0 then
			self.resetTimer = TimerManager.addTimer(duration, function()
				arkBridgeSB:PlayWithState(0)
			end)
		end
	end
end

function ClientPlayerMmoItemComponent:on_mmoItemCoolDownMap_cdTime_added(state, cdTime, id)
	self:on_mmoItemCoolDownMap_cdTime_changed(nil, cdTime, id, state)
end

return ClientPlayerMmoItemComponent
