-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PausePanel\\PausePanelCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PausePanelCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PausePanelCtrl = Class.LightClass("PausePanelCtrl", UICtrl)
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

PausePanelCtrl.messages = {}

function PausePanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.params = info or {}

	self:initUI()
end

function PausePanelCtrl:addListener()
	function self.view.btnContinueUButton.luaClick()
		if self.params.btn1Action then
			self.params.btn1Action()
		end

		self:close()
	end

	function self.view.btnSuspendUButton.luaClick()
		if self.params.btn2Action then
			self.params.btn2Action()
		end

		self:close()
	end

	function self.view.btnSettlementUButton.luaClick()
		if self.params.btn3Action then
			self.params.btn3Action()
		end

		self:close()
	end
end

function PausePanelCtrl:initUI()
	if self.params.btn1Text then
		ClientTextUtils.setText(self.view.btnContinueText, self.params.btn1Text)
	end

	if self.params.btn2Text then
		ClientTextUtils.setText(self.view.btnSuspendText, self.params.btn2Text)
	end

	if self.params.btn3Text then
		ClientTextUtils.setText(self.view.btnSettlementText, self.params.btn3Text)
	end

	if self.params.hideSuspend then
		self.view.btnSuspendUButton:SetActive(false)
	end
end

function PausePanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PausePanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PausePanelCtrl:onShow()
	return
end

function PausePanelCtrl:onHide()
	return
end

return PausePanelCtrl
