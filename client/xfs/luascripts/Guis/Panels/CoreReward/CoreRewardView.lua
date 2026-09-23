-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CoreReward\\CoreRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CoreRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CoreRewardView = Class.LightClass("CoreRewardView", UIView)

function CoreRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtName = objectReference:GetRefValue("txtName")
	self.itemListUList = objectReference:GetRefValue("itemListUList")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.txtGoBtnName = objectReference:GetRefValue("txtGoBtnName")
	self.txtPetName = objectReference:GetRefValue("txtPetName")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnGo = objectReference:GetRefValue("btnGo")
	self.btnPetEgg = objectReference:GetRefValue("btnPetEgg")
	self.txtSpecialNum = objectReference:GetRefValue("txtSpecialNum")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.petQualityUComponent = objectReference:GetRefValue("petQualityUComponent")
end

function CoreRewardView:registerObjects()
	return
end

function CoreRewardView:initView()
	return
end

return CoreRewardView
