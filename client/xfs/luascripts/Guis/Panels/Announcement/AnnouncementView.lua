-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Announcement\\AnnouncementView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AnnouncementView = Class.LightClass("AnnouncementView", UIView)

function AnnouncementView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.tabListUList = self.objectReference:GetRefValue("tabListUList")
	self.contentListUList = self.objectReference:GetRefValue("contentListUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
	self.openServerObj = self.objectReference:GetRefValue("openServerObj")
	self.btnTranslateUButton = self.objectReference:GetRefValue("btnTranslateUButton")
	self.txtTranslateNameUSDFText = self.objectReference:GetRefValue("txtTranslateNameUSDFText")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
end

function AnnouncementView:registerObjects()
	return
end

function AnnouncementView:GetOpenServerObj(openObjRef)
	local openObj = {}

	openObj.objectReference = openObjRef.transform:GetComponent("ObjectReference")
	openObj.listUList = openObjRef:GetRefValue("listUList")
	openObj.openServerTime = openObjRef:GetRefValue("openServerTime")
	openObj.leftTimeText = openObjRef:GetRefValue("leftTimeText")
	openObj.announcementCmp = openObjRef:GetRefValue("announcementCmp")
	openObj.btnCloseUButton = openObjRef:GetRefValue("btnCloseUButton")
	openObj.mediaListUList = openObjRef:GetRefValue("mediaListUList")

	return openObj
end

function AnnouncementView:initView()
	return
end

function AnnouncementView:setSpritesForRelease(sprites)
	self.spritesForRelease = sprites
end

function AnnouncementView:delayDestroyUIView()
	UIView.delayDestroyUIView(self)

	if self.spritesForRelease then
		for _, sprite in pairs(self.spritesForRelease) do
			if sprite then
				pg.global.uiMgr:ReleaseTexture2D(sprite.texture)
			end
		end

		self.spritesForRelease = nil
	end
end

return AnnouncementView
