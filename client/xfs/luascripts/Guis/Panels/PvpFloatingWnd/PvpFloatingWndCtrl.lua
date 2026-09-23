-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpFloatingWnd\\PvpFloatingWndCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpFloatingWndCtrl = Class.LightClass("PvpFloatingWndCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpFloatingWndCtrl.messages = {}

function PvpFloatingWndCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PvpFloatingWndCtrl:addListener()
	function self.view.btnMatch.luaClick()
		self:onClickFloating()
	end

	function self.view.btnMatch.luaDrag()
		self.view.btnMatch:TryChangePage("State", 0)

		self.isInMiniMode = false
	end

	function self.view.btnMatch.luaEndDrag(_, _)
		local dRect = self.view.selfRect.rect
		local cRect = pg.global.ui.uiMgr.fixedTop.rect
		local dPos = self.view.selfRect.anchoredPosition + cRect.size / 2
		local xMin = dPos.x - dRect.width / 2
		local xMax = dPos.x + dRect.width / 2
		local yMin = dPos.y - dRect.height / 2
		local yMax = dPos.y + dRect.height / 2
		local xLDis = math.abs(xMin - cRect.xMin)
		local xRDis = math.abs(xMax - cRect.xMax)
		local yLDis = math.abs(yMin - cRect.yMin)
		local yRDis = math.abs(yMax - cRect.yMax)
		local AdsorptionMinDis = 0.1

		self.isInMiniMode = true

		if xLDis < AdsorptionMinDis then
			self.view.btnMatch:TryChangePage("State", 3)
		elseif xRDis < AdsorptionMinDis then
			self.view.btnMatch:TryChangePage("State", 4)
		elseif yLDis < AdsorptionMinDis then
			self.view.btnMatch:TryChangePage("State", 2)
		elseif yRDis < AdsorptionMinDis then
			self.view.btnMatch:TryChangePage("State", 1)
		else
			self.view.btnMatch:TryChangePage("State", 0)

			self.isInMiniMode = false
		end
	end
end

function PvpFloatingWndCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpFloatingWndCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.isInMiniMode = false
end

function PvpFloatingWndCtrl:onShow()
	return
end

function PvpFloatingWndCtrl:refreshTime(timeStr)
	ClientTextUtils.setText(self.view.timeCenter, timeStr)
	ClientTextUtils.setText(self.view.timeTop, timeStr)
	ClientTextUtils.setText(self.view.timeBottom, timeStr)
	ClientTextUtils.setText(self.view.timeLeft, timeStr)
	ClientTextUtils.setText(self.view.timeRight, timeStr)
end

function PvpFloatingWndCtrl:onClickFloating()
	if self.isInMiniMode then
		self.view.btnMatch:TryChangePage("State", 0)

		self.isInMiniMode = false
	else
		local LuaUIUtils = require("Utils.LuaUIUtils")

		LuaUIUtils.openPVPMenu()
		self:hide()
	end
end

function PvpFloatingWndCtrl:onHide()
	return
end

return PvpFloatingWndCtrl
