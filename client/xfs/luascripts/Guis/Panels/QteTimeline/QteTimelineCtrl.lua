-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QteTimeline\\QteTimelineCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local QteTimelineCtrl = Class.LightClass("QteTimelineCtrl", UICtrl)

function QteTimelineCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.callback = info.callback
	self.clickCount = info.clickCount or 5
	self.curClickCount = 0
end

function QteTimelineCtrl:addListener()
	local btnBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.rapidClickObjRef.gameObject, "qteC")

	btnBind.isVirtual = false
	btnBind.priority = 10
	btnBind.actionPath = "Hud/QteC"

	function btnBind.luaTrigger(inputInfo)
		self.view.clickBtn.luaClick()
	end

	local keyHotKeyContent = self.view.rapidClickObjRef:GetRefValue("keyHotKeyContent")

	keyHotKeyContent:SetHotKeyPaths("Hud/QteC")

	function self.view.clickBtn.luaClick()
		self.curClickCount = self.curClickCount + 1

		if self.clickCount ~= 1 then
			self.view.progress.value = self.curClickCount / self.clickCount or 0

			UIUtils.PlayAnimation(self.view.rapidClickAnim, "VX_Pb_RapidClick_Click")
		end

		if self.curClickCount == self.clickCount then
			self.curClickCount = 0

			self.view.clickBtn:TryChangePage("State", 1)
			self.view.widget:SetActive(true)
			pg.game.audio:triggerEvent("SFX_UI_Qte_Success")
			UIUtils.PlayAnimation(self.view.rapidClickAnim, "VX_Pb_RapidClick_Out", function()
				self:dismiss()
			end)

			if self.callback then
				self.callback()
			end
		end
	end
end

function QteTimelineCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self.delayTimer ~= nil then
		self:killTimer(self.delayTimer)
	end

	if info ~= nil and info.closeImmediately ~= nil then
		if info.closeImmediately then
			self:dismiss()
		else
			self.view.clickBtn:OnClickSimulate()

			self.delayTimer = self:startTimer(function()
				self:dismiss()
			end, 1)
		end
	end
end

function QteTimelineCtrl:onShow()
	self.view.progress.value = 0

	self.view.widget:SetActive(false)
	self.view.clickBtn:TryChangePage("State", 0)
	UIUtils.PlayAnimation(self.view.rapidClickAnim, "VX_Pb_RapidClick_In", function()
		self.view.rapidClickAnim:Play("VX_Pb_RapidClick_Click_Loop")
	end)
	pg.game.audio:playEvent("SFX_UI_Qte_Continued")
end

function QteTimelineCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return QteTimelineCtrl
