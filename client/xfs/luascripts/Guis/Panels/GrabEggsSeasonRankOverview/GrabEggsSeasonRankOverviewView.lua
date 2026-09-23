-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankOverview\\GrabEggsSeasonRankOverviewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsSeasonRankOverviewView = Class.LightClass("GrabEggsSeasonRankOverviewView", UIView)

function GrabEggsSeasonRankOverviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBack")
	self.rankUList = self.objectReference:GetRefValue("lvList")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function GrabEggsSeasonRankOverviewView:registerObjects()
	return
end

function GrabEggsSeasonRankOverviewView:initView()
	return
end

return GrabEggsSeasonRankOverviewView
