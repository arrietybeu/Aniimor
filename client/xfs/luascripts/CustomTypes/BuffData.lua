-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BuffData.lua

local Class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local Time = require("Core.Common.Time")
local AbilityConst = require("Common.Const.AbilityConst")
local CommonSwitch = require("Common.CommonSwitch")
local BuffData = Class.LiteClass("BuffData", CustomDict)

function BuffData:tostring(mode)
	local buffInfo = "{\n"
	local communalList = {
		"templateId",
		"layer"
	}
	local detailList = {
		"duration",
		"srcEntityId",
		"srcAbilityId",
		"level"
	}
	local paramsMap = self._properties

	for _, key in ipairs(communalList) do
		if paramsMap[key] then
			buffInfo = buffInfo .. "\t\t" .. key .. ": " .. paramsMap[key] .. "\n"
		end
	end

	if paramsMap.expiredTime and self.owner then
		local remainTtime = paramsMap.expiredTime - self.owner.space:getGameTime()

		buffInfo = buffInfo .. "\t\t" .. "remainTtime" .. ": " .. remainTtime .. "s\n"
	end

	if mode == 1 then
		for _, key in ipairs(detailList) do
			if paramsMap[key] then
				buffInfo = buffInfo .. "\t\t" .. key .. ": " .. paramsMap[key] .. "\n"
			end
		end
	end

	buffInfo = buffInfo .. "\t}"

	return buffInfo
end

function BuffData:isInherit()
	return self.destroyReason == AbilityConst.BUFF_DESTROY_REASON_INHERIT
end

return BuffData
