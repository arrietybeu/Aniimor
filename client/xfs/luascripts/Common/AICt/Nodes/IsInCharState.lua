-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\IsInCharState.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local IsInCharState = Class.LightClass("IsInCharState", CTRNode)
local CheckStateType = {
	StateList = 2,
	State = 1
}

function IsInCharState:registerPorts()
	self.valueInput_tgtId = self:addValueInput("targetEntityActorId")
	self.valueInput_stateList = self:addValueInput("stateList")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
end

function IsInCharState:Get_out_Value(flow)
	local targetId = self:getInputValue(self.valueInput_tgtId, flow)

	if targetId == 0 then
		targetId = flow.context._entActorId
	end

	local ent = pg.getEntityByActorId(targetId)

	if ent == nil then
		return false
	end

	local currentAnimationState = AIControllerUtils.getCurrentAnimationState(ent)

	if self.nodeData.checkStateType == CheckStateType.State then
		return CharacterStateConst.isChildOfState(currentAnimationState, self.nodeData.state) or self.nodeData.state == currentAnimationState
	else
		local stateList = self:getInputValue(self.valueInput_stateList, flow)

		if not stateList then
			return false
		end

		for i = 1, #stateList do
			local stateConstInt = CharacterStateConst[stateList[i]]

			if CharacterStateConst.isChildOfState(currentAnimationState, stateConstInt) or currentAnimationState == stateConstInt then
				return true
			end
		end

		return false
	end
end

return IsInCharState
