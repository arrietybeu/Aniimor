-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushRoute\\BossRushRouteView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushRouteView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushRouteView = Class.LightClass("BossRushRouteView", UIView)

function BossRushRouteView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bgCloseUButton = self.objectReference:GetRefValue("bgCloseUButton")
	self.boss1UButton = self.objectReference:GetRefValue("boss1UButton")
	self.boss2UButton = self.objectReference:GetRefValue("boss2UButton")
	self.boss3UButton = self.objectReference:GetRefValue("boss3UButton")
	self.point1UButton = self.objectReference:GetRefValue("point1UButton")
	self.point2UButton = self.objectReference:GetRefValue("point2UButton")
	self.line1UButton = self.objectReference:GetRefValue("line1UButton")
	self.line2UButton = self.objectReference:GetRefValue("line2UButton")
	self.line3UButton = self.objectReference:GetRefValue("line3UButton")
	self.line11UButton = self.objectReference:GetRefValue("line11UButton")
	self.line21UButton = self.objectReference:GetRefValue("line21UButton")
	self.btnBuff1UButton = self.objectReference:GetRefValue("btnBuff1UButton")
	self.buff1UList = self.objectReference:GetRefValue("buff1UList")
	self.btnBuff2UButton = self.objectReference:GetRefValue("btnBuff2UButton")
	self.buff2UList = self.objectReference:GetRefValue("buff2UList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.keyListUList = self.objectReference:GetRefValue("keyListUList")
end

function BossRushRouteView:registerObjects()
	return
end

function BossRushRouteView:initView()
	return
end

return BossRushRouteView
