-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubateResult\\PetFertilityIncubateResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityIncubateResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityIncubateResultView = Class.LightClass("PetFertilityIncubateResultView", UIView)

function PetFertilityIncubateResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnHaveitUButton = objectReference:GetRefValue("btnHaveitUButton")
	self.btnFertilityUButton = objectReference:GetRefValue("btnFertilityUButton")
	self.btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")
	self.careerIcon = objectReference:GetRefValue("careerIcon")
	self.nameText = objectReference:GetRefValue("nameText")
	self.maleUWidget = objectReference:GetRefValue("maleUWidget")
	self.femaleUWidget = objectReference:GetRefValue("femaleUWidget")
	self.accessListUList = objectReference:GetRefValue("accessListUList")
	self.featuresUButton = objectReference:GetRefValue("featuresUButton")
	self.petDemensionTransform = objectReference:GetRefValue("petDemensionTransform")
	self.featureTxtName = objectReference:GetRefValue("featureTxtName")
	self.petInfoUComponent = objectReference:GetRefValue("petInfoUComponent")
	self.charUList = objectReference:GetRefValue("charUList")
	self.nameShineText = objectReference:GetRefValue("nameShineText")
	self.iconNewUWidget = objectReference:GetRefValue("iconNewUWidget")
	self.formItemUButton = objectReference:GetRefValue("formItemUButton")
	self.flashItemUButton = objectReference:GetRefValue("flashItemUButton")
	self.qualityItemUComponent = objectReference:GetRefValue("qualityItemUComponent")
	self.qualityNameTxt = objectReference:GetRefValue("qualityNameTxt")
	self.careerName = objectReference:GetRefValue("careerName")
	self.formName = objectReference:GetRefValue("formName")
	self.ballGetUWidget = objectReference:GetRefValue("ballGetUWidget")
	self.iconBallUImage = objectReference:GetRefValue("iconBallUImage")
	self.btnAccessListUButton = objectReference:GetRefValue("btnAccessListUButton")
	self.umbralItemUButton = objectReference:GetRefValue("umbralItemUButton")
	self.txtUmbralUSDFText = objectReference:GetRefValue("txtUmbralUSDFText")
	self.physiqueItemUButton = objectReference:GetRefValue("physiqueItemUButton")
end

function PetFertilityIncubateResultView:registerObjects()
	return
end

function PetFertilityIncubateResultView:initView()
	return
end

return PetFertilityIncubateResultView
