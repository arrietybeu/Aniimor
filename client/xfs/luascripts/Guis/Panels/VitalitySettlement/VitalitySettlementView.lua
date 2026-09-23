-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalitySettlement\\VitalitySettlementView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local VitalitySettlementView = Class.LightClass("VitalitySettlementView", UIView)
local ToBool = ToBool

function VitalitySettlementView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.animationUWidget = objectReference:GetRefValue("animationUWidget")
	self.settlementUWidget = objectReference:GetRefValue("settlementUWidget")
	self.btnSettlementUButton = objectReference:GetRefValue("btnSettlementUButton")
	self.btnSkipUButton = objectReference:GetRefValue("btnSkipUButton")
	self.sumScoreText = objectReference:GetRefValue("sumScoreText")
	self.petScoreText = objectReference:GetRefValue("petScoreText")
	self.accessoryScoreText = objectReference:GetRefValue("accessoryScoreText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.processScore = objectReference:GetRefValue("processScore")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.animationRectTransform = objectReference:GetRefValue("animationRectTransform")
	self.btnPhotoUButton = objectReference:GetRefValue("btnPhotoUButton")
	self.stageTextUBaseText = objectReference:GetRefValue("stageTextUBaseText")
	self.stageScoreUBaseText = objectReference:GetRefValue("stageScoreUBaseText")
	self.vXEventSettlementAnimation = objectReference:GetRefValue("vXEventSettlementAnimation")
	self.sumScoreTitle = objectReference:GetRefValue("sumScoreTitle")
	self.petScoreTitle = objectReference:GetRefValue("petScoreTitle")
	self.accessoryScoreTitle = objectReference:GetRefValue("accessoryScoreTitle")
	self.txtRank = objectReference:GetRefValue("txtRank")
end

function VitalitySettlementView:registerObjects()
	return
end

function VitalitySettlementView:initView()
	ClientTextUtils.setText(self.sumScoreTitle, pg.getGameString("GLAMOUR_EVENT_SCORE_TOTAL"))
	ClientTextUtils.setText(self.petScoreTitle, pg.getGameString("GLAMOUR_EVENT_SCORE_PET"))
	ClientTextUtils.setText(self.accessoryScoreTitle, pg.getGameString("GLAMOUR_EVENT_SCORE_ACC"))
end

return VitalitySettlementView
