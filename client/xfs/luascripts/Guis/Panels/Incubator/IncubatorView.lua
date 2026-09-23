-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Incubator\\IncubatorView.lua

local logger = require("Core.Log.LoggerManager").getLogger("IncubatorView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local IncubatorView = Class.LightClass("IncubatorView", UIView)

function IncubatorView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.root = objectReference:GetRefValue("uIPopHomeIncubatorUComponent")
	self.contentUWidget = objectReference:GetRefValue("contentUWidget")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.contentTransform = objectReference:GetRefValue("contentTransform")
	self.panelRectTransform = objectReference:GetRefValue("panelRectTransform")
	self.speedUpUWidget = objectReference:GetRefValue("speedUpUWidget")
	self.txtSpeedUp = objectReference:GetRefValue("txtSpeedUp")
	self.activityUButton = objectReference:GetRefValue("activityUButton")
	self.txtActivityUp = objectReference:GetRefValue("txtActivityUp")
	self.speedTipsUButton = objectReference:GetRefValue("speedTipsUButton")
	self.txtSpeedTips = objectReference:GetRefValue("txtSpeedTips")
end

function IncubatorView:registerObjects()
	local objectReference = self.contentTransform:GetComponent("ObjectReference")

	self.nmlUWidget = objectReference:GetRefValue("nmlUWidget")
	self.nullUWidget = objectReference:GetRefValue("nullUWidget")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.iconProductUImage = objectReference:GetRefValue("iconProductUImage")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.txtReduceUSDFText = objectReference:GetRefValue("txtReduceUSDFText")
	self.btnPasueUButton = objectReference:GetRefValue("btnPasueUButton")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.btnSortUButton = objectReference:GetRefValue("btnSortUButton")
	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.listPropUList = objectReference:GetRefValue("listPropUList")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.sortUWidget = objectReference:GetRefValue("sortUWidget")
	self.listPropUWidget = objectReference:GetRefValue("listPropUWidget")
	self.bottomUWidget = objectReference:GetRefValue("bottomUWidget")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.layouHatchingUWidget = objectReference:GetRefValue("layouHatchingUWidget")
	self.tipsUWidget = objectReference:GetRefValue("tipsUWidget")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.txtTiitleUSDFText = objectReference:GetRefValue("txtTiitleUSDFText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.selectorTxtNameUBaseText = objectReference:GetRefValue("selectorTxtNameUBaseText")
	self.txtListContEmptyUSDFtext = objectReference:GetRefValue("txtListContEmptyUSDFtext")
	self.txtBtnConfirmNameUSDFText = objectReference:GetRefValue("txtBtnConfirmNameUSDFText")
end

function IncubatorView:initView()
	return
end

return IncubatorView
