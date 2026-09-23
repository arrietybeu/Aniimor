-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelect\\GrowthGiftSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrowthGiftSelectView = Class.LightClass("GrowthGiftSelectView", UIView)

function GrowthGiftSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBack = objectReference:GetRefValue("btnBack")
	self.txtBack = objectReference:GetRefValue("txtBack")
	self.txtListTitle = objectReference:GetRefValue("txtListTitle")
	self.txtGetCondition = objectReference:GetRefValue("txtGetCondition")
	self.txtChoose = objectReference:GetRefValue("txtChoose")
	self.txtGot = objectReference:GetRefValue("txtGot")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnChoose = objectReference:GetRefValue("btnChoose")
	self.btnSearch = objectReference:GetRefValue("btnSearch")
	self.txtPetName = objectReference:GetRefValue("txtPetName")
	self.txtQuality = objectReference:GetRefValue("txtQuality")
	self.listBuff = objectReference:GetRefValue("listBuff")
	self.btnPrismana = objectReference:GetRefValue("btnPrismana")
	self.btnShine = objectReference:GetRefValue("btnShine")
	self.imgPrismanaIcon = objectReference:GetRefValue("imgPrismanaIcon")
	self.imgShineIcon = objectReference:GetRefValue("imgShineIcon")
	self.txtPrismana = objectReference:GetRefValue("txtPrismana")
	self.txtShine = objectReference:GetRefValue("txtShine")
	self.btnFilter = objectReference:GetRefValue("btnFilter")
	self.btnFilter2 = objectReference:GetRefValue("btnFilter2")
	self.btnCleanFilter = objectReference:GetRefValue("btnCleanFilter")
	self.btnDice = objectReference:GetRefValue("btnDice")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.listPrismanaUList = objectReference:GetRefValue("listPrismanaUList")
	self.maskRayBoxTrans = objectReference:GetRefValue("maskRayBoxTrans")
	self.btnRandomPet = objectReference:GetRefValue("btnRandomPet")
	self.typeImage = objectReference:GetRefValue("typeImage")
	self.typeDesc = objectReference:GetRefValue("typeDesc")
	self.txtVideo = objectReference:GetRefValue("txtVideo")
	self.btnOpen = objectReference:GetRefValue("btnOpen")
	self.videoPlayer = objectReference:GetRefValue("videoPlayer")
	self.btnVideoBack = objectReference:GetRefValue("btnVideoBack")
	self.maxUVideoPlayerX = objectReference:GetRefValue("maxUVideoPlayerX")
	self.videoUWidget = objectReference:GetRefValue("videoUWidget")
	self.listTipsUList = objectReference:GetRefValue("listTipsUList")
end

function GrowthGiftSelectView:registerObjects()
	return
end

function GrowthGiftSelectView:initView()
	return
end

return GrowthGiftSelectView
