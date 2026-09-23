-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossShieldComp.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossShieldComp = Class.LightClass("BossShieldComp")

function BossShieldComp:ctor(owner)
	self.owner = owner
	self.m_reseted = false
	self.delayHideTimer = nil
end

function BossShieldComp:onBind(objectReference)
	self.barShield = objectReference:GetRefValue("barShield")
end

function BossShieldComp:refresh(entity)
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	if not owner.curTarget or not entity or owner.curTarget.id ~= entity.id then
		return
	end

	self:clearHideTimer()
	LuaUIUtils.setShieldBar(owner.curTarget, nil, self.barShield)
end

function BossShieldComp:onBreak(entity)
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	if owner.curTarget and owner.curTarget.id ~= entity.id then
		return
	end

	self.barShield:InvokeCallback(CS.XGUI.EInvokeTime.Custom6)
	self:clearHideTimer()

	self.delayHideTimer = TimerManager.addTimer(1, function()
		self.delayHideTimer = nil

		self.barShield:SetActive(false)
	end)
end

function BossShieldComp:resetUI()
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	if not self.m_reseted then
		self.barShield:SetActive(false)

		self.m_reseted = true
	end
end

function BossShieldComp:clearHideTimer()
	if self.delayHideTimer then
		TimerManager.removeTimer(self.delayHideTimer)

		self.delayHideTimer = nil
	end
end

function BossShieldComp:destroy()
	self:reset()

	self.m_reseted = false
end

function BossShieldComp:reset()
	self:clearHideTimer()

	if self.barShield then
		self.barShield:SetActive(false)
	end
end

return BossShieldComp
