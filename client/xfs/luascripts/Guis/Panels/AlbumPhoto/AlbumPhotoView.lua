-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AlbumPhoto\\AlbumPhotoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AlbumPhotoView = Class.LightClass("AlbumPhotoView", UIView)

function AlbumPhotoView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnHideUIUButton = objectReference:GetRefValue("btnHideUIUButton")
	self.btnScaleUButton = objectReference:GetRefValue("btnScaleUButton")
	self.btnFolderUButton = objectReference:GetRefValue("btnFolderUButton")
	self.textUText = objectReference:GetRefValue("textUText")
	self.timeUText = objectReference:GetRefValue("timeUText")
	self.traitItemIcon = objectReference:GetRefValue("traitItemIcon")
	self.detailUText = objectReference:GetRefValue("detailUText")
	self.titleUText = objectReference:GetRefValue("titleUText")
	self.skillIcon = objectReference:GetRefValue("skillIcon")
	self.photoUImage = objectReference:GetRefValue("photoUImage")
	self.infoWidgetUWidget = objectReference:GetRefValue("infoWidgetUWidget")
	self.skillIconWidgetUWidget = objectReference:GetRefValue("skillIconWidgetUWidget")
	self.levelUList = objectReference:GetRefValue("levelUList")
	self.exploreIconUImage = objectReference:GetRefValue("exploreIconUImage")
	self.exploreBtnUComponent = objectReference:GetRefValue("exploreBtnUComponent")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.btnPreUButton = objectReference:GetRefValue("btnPreUButton")
	self.btnNextUButton = objectReference:GetRefValue("btnNextUButton")
	self.adaptationBoxUXAdaptionRect = objectReference:GetRefValue("adaptationBoxUXAdaptionRect")
	self.btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")
	self.btnShareUButton = objectReference:GetRefValue("btnShareUButton")
	self.btnUploadUButton = objectReference:GetRefValue("btnUploadUButton")
	self.btnTemplateUButton = objectReference:GetRefValue("btnTemplateUButton")
	self.btnRoadUButton = objectReference:GetRefValue("btnRoadUButton")
	self.btnSaveUButton = objectReference:GetRefValue("btnSaveUButton")
	self.btnWidgetUWidget = objectReference:GetRefValue("btnWidgetUWidget")
	self.txtSaveUSDFText = objectReference:GetRefValue("txtSaveUSDFText")
	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
end

function AlbumPhotoView:registerObjects()
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function AlbumPhotoView:initView()
	if pg.global.platform:isPS() then
		self.btnFolderUButton.gameObject:SetActiveEx(false)
		self.btnScaleUButton.gameObject:SetActiveEx(false)
	end
end

return AlbumPhotoView
