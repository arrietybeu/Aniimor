-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\SchoolGuideView.lua

local logger = require("Core.Log.LoggerManager").getLogger("SchoolGuideView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SchoolGuideView = Class.LightClass("SchoolGuideView", UIView)

function SchoolGuideView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.firstLevelTabUList = objectReference:GetRefValue("firstLevelTabUList")
	self.guideUWidget = objectReference:GetRefValue("guideUWidget")
	self.webFrameUWidget = objectReference:GetRefValue("webFrameUWidget")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.infoBtn = objectReference:GetRefValue("infoBtn")
	self.infoBtnConsole = objectReference:GetRefValue("infoBtnConsole")
	self.medalUContainer = objectReference:GetRefValue("medalUContainer")
	self.dailyActiveUContainer = objectReference:GetRefValue("dailyActiveUContainer")
	self.itemCraftUContainer = objectReference:GetRefValue("itemCraftUContainer")
	self.rulesUWidget = objectReference:GetRefValue("rulesUWidget")
	self.holographicTrainingUWidget = objectReference:GetRefValue("holographicTrainingUWidget")
end

function SchoolGuideView:registerObjects()
	return
end

function SchoolGuideView:initView()
	return
end

return SchoolGuideView
