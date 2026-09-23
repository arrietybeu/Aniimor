-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\ChargeQteComponent.lua

local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteComponent = require("GameApp.Qte.QteComponent")
local Time = require("Core.Common.Time")
local ChargeQteComponent = Class.LightClass("ChargeQteClip", QteComponent)

function ChargeQteComponent:ctor(actorId, componentData)
	self.isChargeQte = true

	ChargeQteComponent.super.ctor(self, actorId, componentData)
end

function ChargeQteComponent:onPrefabLoaded()
	ChargeQteComponent.super.onPrefabLoaded(self)

	if self.gameObject then
		self.uComponent = self.gameObject:GetComponent("UComponent")
		self.objectReference = self.gameObject:GetComponent("ObjectReference")
		self.countDown = self.objectReference:GetRefValue("CD")
		self.goodFrame = self.objectReference:GetRefValue("goodFrame")
		self.perfectFrame = self.objectReference:GetRefValue("perfectFrame")
		self.vxGlowUImage = self.objectReference:GetRefValue("vxGlowUImage")
		self.vxGlowDiangBGUImage = self.objectReference:GetRefValue("vxGlowDiangBGUImage")
		self.vxGlowHuXiUImage = self.objectReference:GetRefValue("vxGlowHuXiUImage")
		self.perfectFrameLianUImage = self.objectReference:GetRefValue("perfectFrameLianUImage")

		self:startCharge()

		if self.hasPendingResult then
			self:applyResult(self.pendingResult)

			self.pendingResult = nil
			self.hasPendingResult = nil
		end
	end
end

function ChargeQteComponent:startCharge()
	local duration = self.context.duration
	local goodStartTime = self.context.goodStartTime
	local goodDuration = self.context.goodDuration
	local perfectStartTime = self.context.perfectStartTime
	local perfectDuration = self.context.perfectDuration
	local goodFrameRot = 0
	local goodFrameFill = 0
	local perfectFrameRot = 0
	local perfectFrameFill = 0

	if duration > 0 then
		goodFrameRot = -goodStartTime * 360 / duration
		goodFrameFill = goodDuration / duration
		perfectFrameRot = -perfectStartTime * 360 / duration
		perfectFrameFill = perfectDuration / duration
	end

	self.goodFrame.transform.localRotation = Quaternion.Euler(0, 0, goodFrameRot)
	self.goodFrame.fillAmount = goodFrameFill
	self.perfectFrame.transform.localRotation = Quaternion.Euler(0, 0, perfectFrameRot)
	self.perfectFrame.fillAmount = perfectFrameFill

	self:setFillAndRotation(self.vxGlowUImage, perfectFrameFill, perfectFrameRot)
	self:setFillAndRotation(self.vxGlowDiangBGUImage, perfectFrameFill, perfectFrameRot)
	self:setFillAndRotation(self.vxGlowHuXiUImage, perfectFrameFill, perfectFrameRot)
	self:setFillAndRotation(self.perfectFrameLianUImage, perfectFrameFill, perfectFrameRot)
	self.countDown:Play(self.curTime, duration)
end

function ChargeQteComponent:setFillAndRotation(uImage, fill, rotation)
	if IsNil(uImage) then
		return
	end

	uImage.transform.localRotation = Quaternion.Euler(0, 0, rotation)
	uImage.fillAmount = fill
end

function ChargeQteComponent:isFinish()
	return self.destroyed == true or self.destroyTime and self.curTime >= self.destroyTime
end

function ChargeQteComponent:initPrefabPosition()
	return
end

function ChargeQteComponent:onStart()
	local duration = self.context.duration

	self.destroyTime = duration + 0.1
end

function ChargeQteComponent:pushResult(result)
	if not self.uComponent or not self.countDown then
		self.pendingResult = result
		self.hasPendingResult = true
		self.destroyTime = self.curTime + 1.2

		return
	end

	self:applyResult(result)
end

function ChargeQteComponent:applyResult(result)
	self.uComponent:TryChangePage("Result", result)
	self.countDown:Stop(true)

	self.destroyTime = self.curTime + 1.2
end

return ChargeQteComponent
