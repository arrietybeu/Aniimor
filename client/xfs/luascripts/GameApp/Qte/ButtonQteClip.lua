-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\ButtonQteClip.lua

local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteClip = require("GameApp.Qte.QteClip")
local ElementPropData = require("Data.element_prop_data")
local ButtonQteClip = Class.LightClass("ButtonQteClip", QteClip)

function ButtonQteClip:onPrefabLoaded()
	ButtonQteClip.super.onPrefabLoaded(self)

	self.isStart = false

	if self.gameObject then
		local objectReference = self.gameObject.transform:GetComponent("ObjectReference")

		self.uComponent = objectReference:GetRefValue("rootComponent")
		self.qteBtn = objectReference:GetRefValue("btnQTEClickUButton")
		self.animPlayer = objectReference:GetRefValue("uIPrefabQteBtnAnimationPlayExtend")
		self.icon = objectReference:GetRefValue("iconSkillUImage")
		self.keyBind = objectReference:GetRefValue("btnQTEClickKeyBindingPro")

		self:initView()
		self:initButtonHotKey()
		self:refreshView()
		self:initPrefabPosition()
	end
end

function ButtonQteClip:initView()
	if self.icon then
		local skillIcon = self:getQteIcon()

		if skillIcon then
			self.icon.url = skillIcon
		end
	end

	local elementType = self:getQteElementType()

	if elementType then
		local pageName = ElementPropData[elementType] and ElementPropData[elementType].name or "null"

		self.uComponent:TryChangePage("type", pageName)
	else
		self.uComponent:TryChangePage("type", "null")
	end
end

function ButtonQteClip:initButtonHotKey()
	if self.qteBtn then
		function self.qteBtn.luaPress()
			self:operate()
		end
	end

	if self.keyBind then
		self.keyBind.priority = 1000 - self.clipIndex
		self.keyBind.actionPath = self:getQteActionPath()
	end
end

function ButtonQteClip:refreshView()
	if not self.uComponent then
		return
	end

	local phaseStr = ""
	local animSpeed = 1
	local canInteract = false
	local playFadeoutAnim = false

	if self.phase == QteDef.CLIP_PHASE.LOAD then
		phaseStr = "load"

		local qteType = 0

		self.uComponent:TryChangePage("QTE_Type", qteType)
		self.uComponent:TryChangePage("qteState", phaseStr)

		if self.loadTime > 0 then
			animSpeed = 0.5 / self.loadTime
		end

		if self.animPlayer then
			self.animPlayer:PlayAnimExtend("VX_Prefab_Hud_QTE_In", true, animSpeed)
		end
	elseif self.phase == QteDef.CLIP_PHASE.FAIL_RANGE then
		canInteract = true
		phaseStr = "failRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.GOOD_RANGE or self.phase == QteDef.CLIP_PHASE.GOOD_RANGE2 then
		canInteract = true
		phaseStr = "goodRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.PERFECT_RANGE then
		canInteract = true
		phaseStr = "perfectRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_TIMEOUT then
		phaseStr = "timeout"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_FAIL then
		phaseStr = "fail"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_GOOD then
		phaseStr = "good"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_PERFECT then
		phaseStr = "perfect"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.DESTROY then
		phaseStr = "none"

		self.uComponent:TryChangePage("qteState", phaseStr)
	end

	if canInteract and not self.isStart then
		self.isStart = true

		if self.operateTime > 0 then
			local animCut = self.clipData.animCut or 1

			animSpeed = 2 * animCut / self.operateTime
		end

		if self.animPlayer then
			self.animPlayer:PlayAnimExtend("VX_Prefab_Hud_QTE_Processing", true, animSpeed)
		end
	end

	if playFadeoutAnim then
		if self.unloadTime > 0 then
			animSpeed = 0.5 / self.unloadTime
		end

		if self.animPlayer then
			self.animPlayer:PlayAnimExtend("VX_Prefab_Hud_QTE_Out", true, animSpeed)
		end
	end

	if canInteract then
		self.uComponent.visibility = CS.XGUI.EVisibility.Visible
	else
		self.uComponent.visibility = CS.XGUI.EVisibility.SelfHitTestInvisible
	end
end

function ButtonQteClip:onPhaseChange(oldPhase, phaseTime)
	if phaseTime == 0 then
		return
	end

	self:refreshView()
end

return ButtonQteClip
