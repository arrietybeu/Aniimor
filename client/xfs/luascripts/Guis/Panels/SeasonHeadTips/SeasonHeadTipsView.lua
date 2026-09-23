-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonHeadTips\\SeasonHeadTipsView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SeasonHeadTipsView = Class.LightClass("SeasonHeadTipsView", UIView)

function SeasonHeadTipsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnUButton = objectReference:GetRefValue("btnUButton")
	self.mainTitleUSDFText = objectReference:GetRefValue("mainTitleUSDFText")
	self.subTitleUSDFText = objectReference:GetRefValue("subTitleUSDFText")
	self.txtBtnNameUSDFText = objectReference:GetRefValue("txtBtnNameUSDFText")
end

function SeasonHeadTipsView:registerObjects()
	return
end

function SeasonHeadTipsView:initView()
	return
end

return SeasonHeadTipsView
