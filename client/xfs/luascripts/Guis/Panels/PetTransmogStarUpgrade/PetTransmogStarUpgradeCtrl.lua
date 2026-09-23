-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogStarUpgrade\\PetTransmogStarUpgradeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local NEWLY_UNLOCK_DELAY = 0.2
local PetTransmogStarUpgradeCtrl = Class.LightClass("PetTransmogStarUpgradeCtrl", UICtrl)

PetTransmogStarUpgradeCtrl.messages = {}

function PetTransmogStarUpgradeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setContext(info and info.petId or nil, info and info.newlyUnlocked or nil)
end

function PetTransmogStarUpgradeCtrl:addListener()
	if self.view.backGroundClose then
		function self.view.backGroundClose.luaClick()
			self:onBtnBackGroundClose()
		end
	end

	if self.view.listStar then
		function self.view.listStar.luaRenderItem(button, index, data)
			self:onRenderStarItem(button, data)
		end
	end
end

function PetTransmogStarUpgradeCtrl:onBtnBackGroundClose()
	if self.isCanClose then
		self:dismiss()
	end
end

function PetTransmogStarUpgradeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info then
		self.model:setContext(info.petId or self.model:getPetId(), info.newlyUnlocked)

		self.isCanClose = false
	end
end

function PetTransmogStarUpgradeCtrl:onShow()
	self:refreshTitle()
	self:refreshSubText()
	self:refreshList()
end

function PetTransmogStarUpgradeCtrl:onDestroy()
	self:clearStarAnimTimers()
	UICtrl.onDestroy(self)
end

function PetTransmogStarUpgradeCtrl:refreshTitle()
	if not self.view.txtName then
		return
	end

	local title = self.model:isAllUnlocked() and pg.getGameString("PETTRANSMOGRIFY_ALL_UNLOCK") or pg.getGameString("PETTRANSMOGRIFY_BREAKTHROUGH")

	ClientTextUtils.setText(self.view.txtName, title)
end

function PetTransmogStarUpgradeCtrl:refreshSubText()
	if not self.view.textSub then
		return
	end

	if self.model:isFlashNewlyUnlocked() then
		self.view.textSub:SetActive(false)

		return
	end

	self.view.textSub:SetActive(true)

	local text = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_PART_OPEN"), self.model:getNewlyUnlockedName())

	ClientTextUtils.setText(self.view.textSub, text)
end

function PetTransmogStarUpgradeCtrl:refreshList()
	if not self.view.listStar then
		return
	end

	self.view.listStar:SetList(self.model:getStarList())
end

function PetTransmogStarUpgradeCtrl:onRenderStarItem(button, data)
	if not data then
		return
	end

	button:TryChangePage("Quality", data.quality or 0)

	if data.isNewlyUnlocked then
		self.starAnimTimers = self.starAnimTimers or {}

		local timerId

		timerId = TimerManager.addTimer(NEWLY_UNLOCK_DELAY, function()
			pg.game.audio:playEvent("SFX_PETTRANSMOGRIFY_OPEN_NEW")

			if self.starAnimTimers then
				self.starAnimTimers[timerId] = nil
			end

			button:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
				if self.view.rootComponent then
					self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
				end

				self.isCanClose = true
			end)
		end)
		self.starAnimTimers[timerId] = true
	else
		button:TryChangePage("Emtpy", data.unlocked and 0 or 1)
	end
end

function PetTransmogStarUpgradeCtrl:clearStarAnimTimers()
	if not self.starAnimTimers then
		return
	end

	for id in pairs(self.starAnimTimers) do
		TimerManager.removeTimer(id)
	end

	self.starAnimTimers = nil
end

return PetTransmogStarUpgradeCtrl
