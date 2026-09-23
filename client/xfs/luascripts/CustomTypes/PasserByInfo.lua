-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PasserByInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PasserByInfo = class.LiteClass("PasserByInfo", CustomDict)

function PasserByInfo:isExited()
	return self.exitMode ~= Const.GamePlay.EXIT_MODE_UNKNOWN
end

function PasserByInfo:updateDisplayInfo(dict)
	if self.displayInfoDict == nil then
		rawset(self, "displayInfoDict", {})
	end

	if pg.component == "game" then
		Utils.updateTableByDefine(self.displayInfoDict, dict, Const.GamePlay.DisplayInfoDef, "PasserByDisplayInfo")

		self.displayInfo = Utils.protoCodec():safeEncodeToStr(self.displayInfoDict)
	else
		self.displayInfoDict = Utils.protoCodec():safeDecodeFromStr(self.displayInfo)
	end
end

function PasserByInfo:getDisplayInfo(forceUpdate)
	if self.displayInfoDict == nil or forceUpdate then
		self:updateDisplayInfo({})
	end

	return self.displayInfoDict
end

return PasserByInfo
