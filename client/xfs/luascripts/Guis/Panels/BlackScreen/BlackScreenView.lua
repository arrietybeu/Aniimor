-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackScreen\\BlackScreenView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BlackScreenView = Class.LightClass("BlackScreenView", UIView)

function BlackScreenView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.btnAuto = self.objectReference:GetRefValue("btnAuto")
	self.keyConsoleOR = self.objectReference:GetRefValue("keyConsoleOR")
	self.keyConsoleULayoutBox = self.objectReference:GetRefValue("keyConsoleULayoutBox")
	self.picImg = self.objectReference:GetRefValue("picImg")
	self.videoPlayer = self.objectReference:GetRefValue("videoPlayer")
	self.layoutBtnRect = self.objectReference:GetRefValue("layoutBtnRect")
	self.mainPanel = self.objectReference:GetRefValue("mainPanel")
	self.mainAni = self.objectReference:GetRefValue("mainAni")
	self.nextConsoleKey = self.keyConsoleOR:GetRefValue("keyHotKeyContent")
	self.bgImage = self.objectReference:GetRefValue("bgImage")
	self.consoleBar = self.transform:Find("ConsoleBar"):GetComponent("UWidget")

	if self.bgImage then
		self.bgImage.forceSyncLoad = true
	end
end

function BlackScreenView:registerObjects()
	return
end

function BlackScreenView:initView()
	return
end

return BlackScreenView
