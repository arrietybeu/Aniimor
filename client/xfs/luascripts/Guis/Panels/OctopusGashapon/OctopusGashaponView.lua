-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\OctopusGashapon\\OctopusGashaponView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SysConfigData = require("Data.sys_config_data")
local OctopusGashaponView = Class.LightClass("OctopusGashaponView", UIView)

function OctopusGashaponView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.enduranceFollowParentUIFollowTrans = self.objectReference:GetRefValue("enduranceFollowParentUIFollowTrans")
	self.rootAim = self.objectReference:GetRefValue("rootAim")
	self.panelAnim = self.objectReference:GetRefValue("panelAnim")
	self.ball_1 = self.objectReference:GetRefValue("ball_1")
	self.ball_2 = self.objectReference:GetRefValue("ball_2")
	self.ball_3 = self.objectReference:GetRefValue("ball_3")
	self.ball_4 = self.objectReference:GetRefValue("ball_4")
	self.ball_5 = self.objectReference:GetRefValue("ball_5")
	self.ball_fake = self.objectReference:GetRefValue("ball_fake")
end

function OctopusGashaponView:registerObjects()
	return
end

function OctopusGashaponView:initView()
	return
end

return OctopusGashaponView
