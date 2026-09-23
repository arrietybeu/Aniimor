-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Picture\\PictureCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CameraConst = require("GameApp.Camera.CameraConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PictureCtrl = Class.LightClass("PictureCtrl", UICtrl)

function PictureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.imageUImage.url = nil

	LuaUIUtils.setUIVisible(self.view.imageUImage, false)

	self.lastUrl = nil
	self.lastFade = nil
end

function PictureCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.view.imageUImage.forceSyncLoad = true
	self.view.imageUImage.url = info.url

	LuaUIUtils.setUIVisible(self.view.imageUImage, true)

	self.view.imageUImage2.forceSyncLoad = true

	if info.fade then
		if self.lastUrl then
			self.view.imageUImage2.renderOpacity = 1
			self.view.imageUImage2.url = self.lastUrl
		else
			self.view.imageUImage2.renderOpacity = 0
		end

		self.view.animation.enabled = true

		self.view.animation:Play("VX_Pb_BlackScreen_In")
	else
		self.view.animation.enabled = false
	end

	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Picture, true)

	self.lastFade = info.fade
	self.lastUrl = info.url
end

function PictureCtrl:onDestroy()
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Picture, false)
	UICtrl.onDestroy(self)

	self.lastUrl = nil
end

function PictureCtrl:close()
	if self.view then
		self.view.imageUImage2.renderOpacity = 0

		if not self.lastFade then
			self.view.imageUImage.renderOpacity = 0
		end
	end

	UICtrl.close(self)
end

return PictureCtrl
