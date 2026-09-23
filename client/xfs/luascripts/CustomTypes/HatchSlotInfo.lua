-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HatchSlotInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HatchSlotInfo = class.LiteClass("HatchSlotInfo", CustomDict)

function HatchSlotInfo:getHatchProgress()
	if self.status == Const.PET_BALL.HATCH_STATUS_INIT then
		return 0
	end

	local hatchTime = Utils.getHatchTime(self.item.id)
	local seepTime = 0

	for _, v in pairs(self.speedUpTime) do
		seepTime = seepTime + v
	end

	hatchTime = hatchTime - seepTime

	if self.status == Const.PET_BALL.HATCH_STATUS_START then
		local remainTime = self.endTs - Time.secondCache

		return lume.clamp(1 - remainTime / hatchTime, 0, 1)
	elseif self.status == Const.PET_BALL.HATCH_STATUS_PAUSE then
		return lume.clamp(1 - self.endTs / hatchTime, 0, 1)
	else
		return 0
	end
end

return HatchSlotInfo
