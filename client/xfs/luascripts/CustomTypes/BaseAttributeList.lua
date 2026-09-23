-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BaseAttributeList.lua

local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local BaseAttributeList = class.LiteClass("BaseAttributeList", CustomList)

function BaseAttributeList:init(dict)
	BaseAttributeList.super.init(self, dict)

	if pg.component == "game" then
		for id = #self + 1, AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN - 1 do
			self:insert(id, 0)
		end
	end

	return true
end

return BaseAttributeList
