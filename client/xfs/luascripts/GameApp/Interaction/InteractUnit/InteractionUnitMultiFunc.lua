-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitMultiFunc.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local Utils = require("Common.Utils.Utils")
local InteractionUnitMultiFunc = Class.LightClass("InteractionUnitMultiFunc", InteractionUnitBase)

function InteractionUnitMultiFunc:ctor(info, interactId)
	InteractionUnitMultiFunc.super.ctor(self, info, interactId)

	self.canInteractiveFunc = info.canInteractiveFunc
	self.multiInfo = info.multiData
end

function InteractionUnitMultiFunc:interactive(idx)
	local interactFunc = self.multiInfo[idx].interactFunc

	if interactFunc then
		interactFunc(self)
	end
end

function InteractionUnitMultiFunc:canInteractive()
	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	return InteractionUnitMultiFunc.super.canInteractive(self)
end

function InteractionUnitMultiFunc:getInteractBtnStyle()
	return self.multiInfo
end

function InteractionUnitMultiFunc:needCheckPetEthnicGroup(idx)
	return self.multiInfo[idx].handlePetEthnicGroup
end

return InteractionUnitMultiFunc
