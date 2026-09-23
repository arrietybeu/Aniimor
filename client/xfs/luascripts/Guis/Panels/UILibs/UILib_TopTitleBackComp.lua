-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\UILibs\\UILib_TopTitleBackComp.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("UILib_TopTitleBackComp")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UILib_TopTitleBackComp = Class.LiteClass("UILib_TopTitleBackComp")

function UILib_TopTitleBackComp:ctor(rootUComponent, parentCtrl)
	self:resetData()

	local objectReference = rootUComponent:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.parentCtrl = parentCtrl
	self.isCreated = true
end

function UILib_TopTitleBackComp:setTitle(textOrTextId, isRawText)
	if not self.tMPUSDFText then
		return
	end

	if isRawText then
		ClientTextUtils.setText(self.tMPUSDFText, textOrTextId)
	else
		ClientTextUtils.setText(self.tMPUSDFText, pg.getGameString(textOrTextId))
	end
end

function UILib_TopTitleBackComp:setOnBack(onClick)
	if not self.btnBackUButton then
		return
	end

	self.btnBackUButton.luaClick = onClick
end

function UILib_TopTitleBackComp:setOnInfo(onClick)
	return
end

function UILib_TopTitleBackComp:hideInfo()
	return
end

function UILib_TopTitleBackComp:onDestroy()
	self.btnBackUButton = nil
	self.tMPUSDFText = nil
	self.parentCtrl = nil
	self.isCreated = false
end

function UILib_TopTitleBackComp:resetData()
	return
end

return UILib_TopTitleBackComp
