-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBuffSelect\\BossRushBuffSelectView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushBuffSelectView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushBuffSelectView = Class.LightClass("BossRushBuffSelectView", UIView)

function BossRushBuffSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listBuffUList = objectReference:GetRefValue("listBuffUList")
	self.buffSpecialTabUButton = objectReference:GetRefValue("buffSpecialTabUButton")
	self.buffNormalTabUButton = objectReference:GetRefValue("buffNormalTabUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.listTabCheckUList = objectReference:GetRefValue("listTabCheckUList")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.specialBuffUBaseText = objectReference:GetRefValue("specialBuffUBaseText")
	self.specialBuffUImage = objectReference:GetRefValue("specialBuffUImage")
	self.normalBuffUBaseText = objectReference:GetRefValue("normalBuffUBaseText")
	self.normalBuffUImage = objectReference:GetRefValue("normalBuffUImage")
	self.supportBuff1ObjectReference = objectReference:GetRefValue("supportBuff1ObjectReference")
	self.supportBuff2ObjectReference = objectReference:GetRefValue("supportBuff2ObjectReference")
	self.windowAnimation = objectReference:GetRefValue("windowAnimation")
	self.consoleBarConsoleBar = objectReference:GetRefValue("consoleBarConsoleBar")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
end

function BossRushBuffSelectView:registerObjects()
	return
end

function BossRushBuffSelectView:initView()
	return
end

return BossRushBuffSelectView
