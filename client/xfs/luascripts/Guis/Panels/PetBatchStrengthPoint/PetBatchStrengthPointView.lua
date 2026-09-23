-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchStrengthPoint\\PetBatchStrengthPointView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetBatchStrengthPointView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetBatchStrengthPointView = Class.LightClass("PetBatchStrengthPointView", UIView)

function PetBatchStrengthPointView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnClose1UButton = objectReference:GetRefValue("btnClose1UButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnRulesUButton")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.txtNowUSDFText = objectReference:GetRefValue("txtNowUSDFText")
	self.txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
	self.btnRecommendUButton = objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnRulesUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listPreviewUList = objectReference:GetRefValue("listPreviewUList")
	self.listUList = objectReference:GetRefValue("listUList")
end

function PetBatchStrengthPointView:registerObjects()
	return
end

function PetBatchStrengthPointView:initView()
	return
end

return PetBatchStrengthPointView
