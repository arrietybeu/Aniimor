-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CampScanMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local CampScanEffect = require("CustomTypes.CampScanEffect")
local CampScanMap = class.LiteClass("CampScanMap", CustomDict)

function CampScanMap:addScanEffect(owner, camp, duration)
	local oldInfo = self[camp]

	if oldInfo then
		if oldInfo.timerId ~= 0 then
			owner:removeTimer(oldInfo.timerId)
		end
	else
		oldInfo = CampScanEffect({})
		self[camp] = oldInfo
	end

	oldInfo.timerId = owner:addTimer(duration, function()
		self[camp] = nil
	end)
end

return CampScanMap
