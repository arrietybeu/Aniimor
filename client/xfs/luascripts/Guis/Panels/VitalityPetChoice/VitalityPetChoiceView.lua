-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityPetChoice\\VitalityPetChoiceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local VitalityPetChoiceView = Class.LightClass("VitalityPetChoiceView", UIView)

function VitalityPetChoiceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.currencyList = self.objectReference:GetRefValue("currencyList")
	self.btnWorkshop = self.objectReference:GetRefValue("btnWorkshop")
	self.listFilterUList = self.objectReference:GetRefValue("listFilterUList")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.btnFilterUButton = self.objectReference:GetRefValue("btnFilterUButton")
	self.btnCleanFilterUButton = self.objectReference:GetRefValue("btnCleanFilterUButton")
	self.txtCurScore = self.objectReference:GetRefValue("txtCurScore")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.scoreUList = self.objectReference:GetRefValue("scoreUList")
	self.suggestUList = self.objectReference:GetRefValue("suggestUList")
	self.backgroundUImage = self.objectReference:GetRefValue("backgroundUImage")
	self.txtStarTitle = self.objectReference:GetRefValue("txtStarTitle")
	self.txtStarDes = self.objectReference:GetRefValue("txtStarDes")
	self.txtScoreTitle = self.objectReference:GetRefValue("txtScoreTitle")
	self.fill1ImagePro = self.objectReference:GetRefValue("fill1ImagePro")
	self.fill2ImagePro = self.objectReference:GetRefValue("fill2ImagePro")
	self.fill3ImagePro = self.objectReference:GetRefValue("fill3ImagePro")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.root = self.objectReference:GetRefValue("root")
	self.textNameUSDFText = self.objectReference:GetRefValue("textNameUSDFText")
end

function VitalityPetChoiceView:registerObjects()
	return
end

function VitalityPetChoiceView:initView()
	ClientTextUtils.setText(self.txtStarTitle, pg.getGameString("GLAMOUR_EVENT_NEW_TITLE"))
	ClientTextUtils.setText(self.txtStarDes, pg.getGameString("GLAMOUR_EVENT_NEW_DESC"))
	ClientTextUtils.setText(self.txtScoreTitle, pg.getGameString("GLAMOUR_EVENT_SCORE_STAR"))
end

return VitalityPetChoiceView
