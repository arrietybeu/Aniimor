-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossFreezeHpComp.lua

local Class = require("Core.Framework.Class")
local BossFreezeHpComp = Class.LightClass("BossFreezeHpComp")

function BossFreezeHpComp:ctor(owner)
	self.owner = owner
end

function BossFreezeHpComp:onBind(objectReference)
	self.bloodUComponent = objectReference:GetRefValue("bloodUComponent")
	self.vXBarPaoPaoUContainer = objectReference:GetRefValue("vXBarPaoPaoUContainer")
end

function BossFreezeHpComp:refresh(info)
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	if owner.curTarget and owner.curTarget:FREEZE_HP_ST() then
		if not self.vXBarPaoPaoUContainer:CheckURLLoaded() then
			self.vXBarPaoPaoUContainer:LoadDefaultUrlManually(function(content)
				local objectReference = content:GetComponent("ObjectReference")

				self.waringPaopaoUImage = objectReference:GetRefValue("waringPaopaoUImage")
			end)
		end

		self.bloodUComponent:TryChangePage("PaopaoHit", 1)
	else
		self.bloodUComponent:TryChangePage("PaopaoHit", 0)
	end
end

function BossFreezeHpComp:onHit()
	local owner = self.owner

	if owner.curTarget and owner.curTarget:FREEZE_HP_ST() then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function BossFreezeHpComp:onOutTime(info)
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	local isOutTime = info[1]
	local alpha = info[2]

	if owner.curTarget and owner.curTarget:FREEZE_HP_ST() and self.waringPaopaoUImage then
		self.waringPaopaoUImage.gameObject:SetActiveEx(isOutTime)

		if isOutTime then
			self.waringPaopaoUImage.renderOpacity = alpha or 1
		else
			self.waringPaopaoUImage.renderOpacity = 1
		end
	end
end

function BossFreezeHpComp:reset()
	if self.bloodUComponent then
		self.bloodUComponent:TryChangePage("PaopaoHit", 0)
	end

	if self.waringPaopaoUImage then
		self.waringPaopaoUImage.gameObject:SetActiveEx(false)

		self.waringPaopaoUImage.renderOpacity = 1
	end
end

function BossFreezeHpComp:destroy()
	self:reset()
end

return BossFreezeHpComp
