-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QRCode\\QRCodeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("QRCodeCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventOfficialGroupData = require("Data.event_official_group_data")
local QRCodeCtrl = Class.LightClass("QRCodeCtrl", UICtrl)

QRCodeCtrl.messages = {}

function QRCodeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QRCodeCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end
end

function QRCodeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function QRCodeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info and info.codeUrl then
		self.view.codeUImage.url = info.codeUrl
	end

	if info and info.id then
		local officialData = EventOfficialGroupData[info.id]

		if officialData then
			ClientTextUtils.setText(self.view.text1UBaseText, pg.getLocalizationText(officialData.qrcodeDesc))
		end
	end
end

function QRCodeCtrl:onShow()
	return
end

function QRCodeCtrl:onHide()
	return
end

return QRCodeCtrl
