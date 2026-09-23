-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoadProgress\\LoadProgressView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local LoadProgressView = Class.LightClass("LoadProgressView", UIView)
local TipsData = require("Data.load_tips_data")
local sysConfig = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function LoadProgressView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.progressNum = self.objectReference:GetRefValue("progressNum")
	self.background = self.objectReference:GetRefValue("background")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.detailText = self.objectReference:GetRefValue("detailText")
	self.teamUWidget = self.objectReference:GetRefValue("teamUWidget")
	self.listUList = self.objectReference:GetRefValue("listUList")

	local progressLoad = self.objectReference:GetRefValue("progressLoad")

	if progressLoad then
		self.progressLoad = progressLoad:GetComponent("UProgress")
	end
end

function LoadProgressView:initView()
	self.background.forceSyncLoad = true
end

function LoadProgressView:onHide()
	UIView.onHide(self)
end

function LoadProgressView:progressValue(val)
	self.progressBar.value = val
end

return LoadProgressView
