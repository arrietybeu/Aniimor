-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VipJumpScanCode\\VipJumpScanCodeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local VipJumpScanCodeCtrl = Class.LightClass("VipJumpScanCodeCtrl", UICtrl)

function VipJumpScanCodeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function VipJumpScanCodeCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end
end

function VipJumpScanCodeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self.qrCodeTex then
		CS.UnityEngine.Object.Destroy(self.qrCodeTex)

		self.qrCodeTex = nil
	end

	self.qrCodeTex = pg.global.qrCodeMgr:DrawQRCode(self.view.qrCodeURawImage, info.url)

	self.view.qrCodeURawImage.gameObject:SetActiveEx(true)
	self.view.bgUTransform.gameObject:SetActiveEx(false)
	self.view.rootUComponent:TryChangePage("State", 1)
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getGameString("POLARIS_HUB_ENTRANCE1"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("POLARIS_HUB_ENTRANCE2"))
end

function VipJumpScanCodeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return VipJumpScanCodeCtrl
