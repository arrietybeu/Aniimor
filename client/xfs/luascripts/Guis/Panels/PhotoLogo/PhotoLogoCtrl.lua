-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoLogo\\PhotoLogoCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoLogoCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local PhotoLogoCtrl = Class.LightClass("PhotoLogoCtrl", UICtrl)

PhotoLogoCtrl.messages = {}

function PhotoLogoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PhotoLogoCtrl:showLogo()
	if (pg.languageType or 0) == ClientConst.LANGUAGE_TYPE_MAP.zh_CN then
		self.view.zhUWidget:SetActiveQuickly(true)
	elseif (pg.languageType or 0) == ClientConst.LANGUAGE_TYPE_MAP.en then
		self.view.enUWidget:SetActiveQuickly(true)
	end
end

function PhotoLogoCtrl:hideLogo()
	self.view.zhUWidget:SetActiveQuickly(false)
	self.view.enUWidget:SetActiveQuickly(false)
end

function PhotoLogoCtrl:addListener()
	return
end

function PhotoLogoCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PhotoLogoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.zhUWidget:SetActive(true)
	self.view.enUWidget:SetActive(true)
	self:hideLogo()
end

function PhotoLogoCtrl:onShow()
	return
end

function PhotoLogoCtrl:onHide()
	return
end

return PhotoLogoCtrl
