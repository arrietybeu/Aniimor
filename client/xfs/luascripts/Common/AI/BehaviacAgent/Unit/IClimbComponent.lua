-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IClimbComponent.lua

local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local IClimbComponent = Class.Component("IClimbComponent")

function IClimbComponent:switchToClimbOn__resetState(resetStateType)
	self.x_switchToClimbOn_init = nil

	AIControllerUtils.clearStateMotionWarpingSyncPoint(self.ent, CharacterStateConst.CLIMBON)
	self:switchToState__resetState(resetStateType)
end

function IClimbComponent:switchToClimbOn(climbOnPos, climbOnRot)
	if not self.x_switchToClimbOn_init then
		AIControllerUtils.setStateMotionWarpingSyncPoint(self.ent, CharacterStateConst.CLIMBON, PlayableConst.JumpOnWall, climbOnPos, climbOnRot)

		self.x_switchToClimbOn_init = true
	end

	return self:switchToState(CharacterStateConst[CharacterStateConst.CLIMBIDLE].name)
end

return IClimbComponent
