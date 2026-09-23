-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialEnergyBar\\SpecialEnergyBarCtrl.lua

local AttributeConst = require("Common.Const.AttributeConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaTopLogoUtils = require("Utils.LuaTopLogoUtils")
local SpecialEnergyBarCtrl = Class.LightClass("SpecialEnergyBarCtrl", UICtrl)
local FADE_DELAY_TIME = 3
local MAX_CUT_LINE_CNT = 9
local TOTAL_ARC_DEGREES = 37.5

SpecialEnergyBarCtrl.messages = {
	[MessageName.ON_CAMERA_TARGET_CHANGE] = {
		"refreshEnergyStateOnEntChange",
		true
	},
	[MessageName.ON_PASSIVE_ENERGY_CHANGED] = {
		"refreshEnergyStateOnValueChange",
		true
	},
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onCombatStatusChange",
		true
	},
	[MessageName.NOTIFY_PASSIVE_ENERGY_SUPER_BOOSTED] = {
		"onSuperBoostedStateChange",
		true
	}
}

function SpecialEnergyBarCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.view.rootUIFollowTrans:SetUseCameraScaleLogic(false)
	self.view.rootUIFollowTrans:SetSameAsTopLogoMidExtraHeight(true)
	self.view.rootUIFollowTrans:SmoothHeightTo(0, 0)

	self.barVisible = true

	self.view.rootUIFollowTrans:SetVisible(self:getUIVisible() == true)

	self.curPawnActorId = nil

	self:initCutLine()
	self:refreshEnergyStateOnEntChange()
end

function SpecialEnergyBarCtrl:clearState()
	self.curPawnActorId = nil
	self.curRate = 0

	self:setSpEnergyBarValue(0, true)

	self.normalIconUrl = nil

	self.view.rootUComponent:TryChangePage("Icon", 0)
	self.view.rootUComponent:TryChangePage("Stage", 0)
	self.view.rootUIFollowTrans:SetUIOffset(0, 0)
	self:refreshSpEnergyBarVisible(true)
	self:refreshCutLinesLayout()
end

function SpecialEnergyBarCtrl:refreshEnergyStateOnEntChange()
	local curPawn = pg.pawn

	if curPawn == nil or curPawn.spEnergyInfo == nil then
		self:clearState()

		return
	end

	if curPawn.actorId == self.curPawnActorId then
		return
	end

	self.curPawnActorId = curPawn.actorId

	local curRate = 0
	local curSpEnergy = curPawn.actorCombatAttribute:getRawAttribValue(AttributeConst.passive_energy_cur)
	local maxSpEnergy = curPawn.actorCombatAttribute:getRawAttribValue(AttributeConst.passive_energy_max)

	if maxSpEnergy > 0 then
		curRate = curSpEnergy / maxSpEnergy
	end

	if self.curRate ~= curRate then
		self.curRate = curRate

		self:setSpEnergyBarValue(curRate, true)
	end

	local curIconUrl = curPawn.spEnergyInfo.normalIcon

	if curIconUrl ~= self.normalIconUrl then
		self.normalIconUrl = curIconUrl
		self.view.imgNmlUImage.url = curIconUrl
		self.view.imgFullUImage.url = curPawn.spEnergyInfo.fullEnergyIcon
	end

	self.view.rootUIFollowTrans:AttachToEntityPositionAgent(curPawn.eModel)
	self:m_applyFollowAnchorOffset(curPawn)

	local uiOffset = curPawn.spEnergyInfo.uiOffsetXYZ

	if uiOffset ~= nil then
		self.view.rootUIFollowTrans:SetUIOffset(uiOffset.x, uiOffset.y)
	else
		self.view.rootUIFollowTrans:SetUIOffset(0, 0)
	end

	self:refreshBarBoostState(curPawn)
	self:refreshSpEnergyBarVisible(true)
	self:refreshCutLinesLayout()
end

function SpecialEnergyBarCtrl:m_applyFollowAnchorOffset(curPawn)
	if curPawn == nil or self.view == nil or IsNil(self.view.rootUIFollowTrans) then
		return
	end

	self.view.rootUIFollowTrans:SetWorldOffset(0, LuaTopLogoUtils.getAgentToCapsuleCenterY(curPawn), 0)
end

function SpecialEnergyBarCtrl:refreshFollowAnchorOffset()
	local curPawn = pg.pawn

	if curPawn == nil or curPawn.actorId ~= self.curPawnActorId then
		return
	end

	self:m_applyFollowAnchorOffset(curPawn)
end

function SpecialEnergyBarCtrl:refreshEnergyStateOnValueChange()
	local curPawn = pg.pawn

	if not curPawn or curPawn.actorId ~= self.curPawnActorId then
		return
	end

	local curRate = 0
	local curSpEnergy = curPawn.actorCombatAttribute:getRawAttribValue(AttributeConst.passive_energy_cur)
	local maxSpEnergy = curPawn.actorCombatAttribute:getRawAttribValue(AttributeConst.passive_energy_max)

	if maxSpEnergy > 0 then
		curRate = curSpEnergy / maxSpEnergy
	end

	if self.curRate ~= curRate then
		self.curRate = curRate

		self:setSpEnergyBarValue(curRate, false)
	end

	self:refreshBarBoostState(curPawn)
	self:refreshSpEnergyBarVisible(false)
end

function SpecialEnergyBarCtrl:setSpEnergyBarValue(value, immediate)
	if immediate then
		self.view.energyUSlider.value = value
	else
		self.view.energyUSlider:ProgressToValue(value, nil)
	end
end

function SpecialEnergyBarCtrl:getSpEnergyBarVisible()
	if self.curPawnActorId == nil then
		return false
	end

	if self.curRate == 0 then
		return false
	end

	local curPawn = pg.pawn

	if not curPawn or not curPawn:isInCombat() then
		return false
	end

	return true
end

function SpecialEnergyBarCtrl:refreshSpEnergyBarVisible(immediate, delayHide)
	local curVisible = self:getSpEnergyBarVisible()

	if curVisible == self.barVisible then
		return
	end

	self.barVisible = curVisible

	if curVisible then
		self:show()
		self.view.rootUIFollowTrans:SetVisible(self:checkUIVisible() == true)

		local needPlayInAnim = not immediate and self.delayHideTimer == nil

		self:clearDelayHideTimer()

		if needPlayInAnim then
			self.view.rootAnimation:Play("VX_Common_Normal_In")
		else
			self.view.rootAnimation:Stop()
			self.view.rootUComponent:SetActiveQuickly(true)
		end
	else
		self:clearDelayHideTimer()

		if immediate then
			self:hide()
			self.view.rootUIFollowTrans:SetVisible(false)
		elseif delayHide then
			self.delayHideTimer = self:startTimer(function()
				self.view.rootAnimation:Play("VX_Common_Normal_Out")
				self:clearDelayHideTimer()
			end, FADE_DELAY_TIME)
		else
			self.view.rootAnimation:Play("VX_Common_Normal_Out")
		end
	end
end

function SpecialEnergyBarCtrl:onVisibleChange(visible)
	if self.view and self.view.rootUIFollowTrans then
		self.view.rootUIFollowTrans:SetVisible(visible and self.barVisible == true)
	end
end

function SpecialEnergyBarCtrl:refreshBarBoostState(pawn)
	local triggeredFull = pawn.spEnergyInfo.triggeredFull
	local hasSuperBoosted = pawn.spEnergyInfo.superBoosted
	local triggeredSuperBoosted = pawn.spEnergyInfo.triggeredSuperBoosted

	self.view.rootUComponent:TryChangePage("Stage", triggeredFull and 1 or 0)

	if triggeredFull and triggeredSuperBoosted then
		self.view.rootUComponent:TryChangePage("Icon", 2)
	else
		self.view.rootUComponent:TryChangePage("Icon", hasSuperBoosted and 1 or 0)
	end
end

function SpecialEnergyBarCtrl:onCombatStatusChange()
	self:refreshSpEnergyBarVisible(false, true)
end

function SpecialEnergyBarCtrl:onSuperBoostedStateChange()
	local curPawn = pg.pawn

	if not curPawn or curPawn.actorId ~= self.curPawnActorId then
		return
	end

	self:refreshBarBoostState(curPawn)
end

function SpecialEnergyBarCtrl:clearDelayHideTimer()
	if self.delayHideTimer ~= nil then
		self:killTimer(self.delayHideTimer)

		self.delayHideTimer = nil
	end
end

function SpecialEnergyBarCtrl:close()
	if self.view then
		self.view.rootUIFollowTrans:SetVisible(self:checkUIVisible() == true and self.barVisible == true)
	end

	UICtrl.close(self)
end

function SpecialEnergyBarCtrl:onDestroy()
	for _, asyncTaskId in pairs(self.cutLineAsyncTaskMap) do
		pg.global.resMgr:ResStopInstantiateAsync(asyncTaskId)
	end

	for i = 2, #self.cutLineCache do
		local cutLineRt = self.cutLineCache[i]

		if NotNil(cutLineRt) then
			pg.global.resMgr:ResDestroyObject(cutLineRt.gameObject)
		end
	end

	self.cutLineAsyncTaskMap = nil
	self.cutLineCache = nil

	self:clearDelayHideTimer()

	self.normalIconUrl = nil
	self.curPawnActorId = nil
	self.curRate = 0
	self.curGridCount = 0

	UICtrl.onDestroy(self)
end

function SpecialEnergyBarCtrl:initCutLine()
	self.cutLineCache = {}
	self.cutLineAsyncTaskMap = {}

	local originPos = self.view.cutLineRectTransform.localPosition

	self.cutLineRefX = originPos.x
	self.cutLineRefY = originPos.y

	self.view.cutLineRectTransform:SetLocalPositionEx(-9999, -9999, 0)
	table.insert(self.cutLineCache, self.view.cutLineRectTransform)

	for i = 1, MAX_CUT_LINE_CNT - 1 do
		local asyncTaskId = pg.global.resMgr:ResInstantiateAsync(self.view.cutLineRectTransform.gameObject, function(gameObj, userData)
			if self.cutLineAsyncTaskMap == nil then
				if NotNil(gameObj) then
					pg.global.resMgr:ResDestroyObject(gameObj)
				end

				return
			end

			self.cutLineAsyncTaskMap[i] = nil

			if IsNil(gameObj) then
				return
			end

			local cutLineRt = gameObj.transform:GetComponent("RectTransform")

			table.insert(self.cutLineCache, cutLineRt)
			cutLineRt:SetLocalPositionEx(-9999, -9999, 0)
			self:refreshCutLinesLayout()
		end, self.view.cutLineRectTransform.position, Quaternion.identity, self.view.cutLineRectTransform.parent)

		self.cutLineAsyncTaskMap[i] = asyncTaskId
	end
end

function SpecialEnergyBarCtrl:refreshCutLinesLayout()
	if #self.cutLineCache < MAX_CUT_LINE_CNT then
		return
	end

	local curShowPawn = self.curPawnActorId and pg.getEntityByActorId(self.curPawnActorId)

	if not curShowPawn then
		self:refreshCutLinesLayoutInternal(1)

		return
	end

	local gridCount = curShowPawn.spEnergyInfo.gridCount

	gridCount = math.max(1, math.min(gridCount or 1, MAX_CUT_LINE_CNT + 1))

	if self.curGridCount == gridCount then
		return
	end

	self:refreshCutLinesLayoutInternal(gridCount)
end

function SpecialEnergyBarCtrl:refreshCutLinesLayoutInternal(gridCount)
	self.curGridCount = gridCount

	local lineCount = gridCount - 1

	for i, cutLineRt in ipairs(self.cutLineCache) do
		if i <= lineCount then
			local angleZ = (i / gridCount - 0.5) * TOTAL_ARC_DEGREES

			cutLineRt:SetLocalPositionEx(self.cutLineRefX, self.cutLineRefY, 0)
			cutLineRt:SetLocalEulerAnglesEx(0, 0, angleZ)
		else
			cutLineRt:SetLocalPositionEx(-9999, -9999, 0)
		end
	end
end

return SpecialEnergyBarCtrl
