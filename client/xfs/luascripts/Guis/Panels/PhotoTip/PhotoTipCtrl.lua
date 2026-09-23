-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoTip\\PhotoTipCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PhotoTipCtrl = Class.LightClass("PhotoTipCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

PhotoTipCtrl.messages = {}

function PhotoTipCtrl:onCreate(info)
	self.photoResId = info.resId
	self.petTemplateIds = info.templateIds

	UICtrl.onCreate(self, info)
end

function PhotoTipCtrl:addListener()
	function self.view.pbReplaceTipUButton.luaClick()
		pg.global.ui.albumPhoto:open({
			photoInfo = self:getCurPhotoSprite()
		})
	end

	local replaceTipBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.pbReplaceTipUButton.gameObject, "replaceTipBind")

	replaceTipBind.actionPath = "Hud/VlogShowPhoto"
	replaceTipBind.isVirtual = true

	function replaceTipBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.pbReplaceTipUButton.luaClick()
		end
	end

	self.view.replaceHotKeyContent:SetHotKeyPaths("Hud/VlogShowPhoto")
end

function PhotoTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PhotoTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PhotoTipCtrl:savePhotoGameInfo()
	local _ppx, _ppy, _ppz = pg.me.eModel:GetPositionAgentPosEx()
	local playerPos = Vector3.New(_ppx, _ppy, _ppz)
	local photoInfo = pg.global.mobileCameraMgr:GetPetPhotoInfo(os.time(), playerPos, pg.me.space.sceneId, self.petTemplateIds)

	photoInfo.path = self.photoResId
	self.photoInfo = photoInfo

	pg.global.mobileCameraMgr:SaveResImageInfo(photoInfo)
end

function PhotoTipCtrl:onShow()
	self.view.photoUImage:SetUrlWithCallback(self.photoResId, function()
		self:savePhotoGameInfo()
	end)
	self:startTimer(function()
		self:dismiss()
	end, 3)
end

function PhotoTipCtrl:getCurPhotoSprite()
	local item = {}

	item.sprite = self.view.photoUImage
	item.timeStamp = self.photoInfo.ts
	item.position = self.photoInfo.pos
	item.sceneId = self.photoInfo.sceneId
	item.isInRes = self.photoInfo.isInRes
	item.resId = self.photoInfo.path

	return item
end

function PhotoTipCtrl:onHide()
	return
end

function PhotoTipCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return PhotoTipCtrl
