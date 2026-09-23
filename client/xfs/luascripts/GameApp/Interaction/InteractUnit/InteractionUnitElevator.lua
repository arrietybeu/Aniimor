-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitElevator.lua

local InteractionConst = require("Common.Const.InteractionConst")
local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractionUnitElevator = Class.LightClass("InteractionUnitElevator", InteractionUnitBase)

function InteractionUnitElevator:ctor(info, interactId)
	InteractionUnitElevator.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.elevatorList = self:initMulInteractData(info.choices)
end

function InteractionUnitElevator:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	return true
end

function InteractionUnitElevator:interactive(idx)
	if self.interactFunc then
		InteractionUnitElevator.super.interactive(self)
		self.interactFunc(idx)
	end
end

function InteractionUnitElevator:getInteractBtnStyle()
	return self.elevatorList
end

function InteractionUnitElevator:initMulInteractData(descList)
	local ret = {}

	for i = 0, descList.Length - 1 do
		ret[#ret + 1] = {
			styleId = tonumber(descList[i]),
			index = i + 1
		}
	end

	return ret
end

return InteractionUnitElevator
