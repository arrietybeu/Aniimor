-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WhiteScreen\\WhiteScreenView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local WhiteScreenView = Class.LightClass("WhiteScreenView", UIView)

function WhiteScreenView:findObjects()
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
	self.consoleBar = self.transform:Find("ConsoleBar"):GetComponent("UWidget")
	self.bgImage = self.objectReference:GetRefValue("bgImage")

	if self.bgImage then
		self.bgImage.forceSyncLoad = true
	end

	self.bg2Image = self.objectReference:GetRefValue("bg2Image")

	if self.bg2Image then
		self.bg2Image.forceSyncLoad = true
	end
end

function WhiteScreenView:registerObjects()
	return
end

function WhiteScreenView:initView()
	return
end

return WhiteScreenView
