-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPetWaterStorageComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AbilityConst = require("Common.Const.AbilityConst")
local TopLogoConst = require("Const.TopLogoConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local RecoveryState = {
	None = 0,
	Full = 3,
	Recovering = 2,
	Start = 1
}
local MAX_LINE_CNT = 10
local TOTAL_ARC_DEGREES = 360
local CLOSE_TIME = 1
local ANIM_HIDE = "VX_Node_Hud_Water_Storage_Bar_Out"
local ANIM_SHOW = "VX_Node_Hud_Water_Storage_Bar_In"
local TopLogoPetWaterStorageComponent = Class.LightClass("TopLogoPetWaterStorageComponent", TopLogoItemComponent)

function TopLogoPetWaterStorageComponent:ctor(refUContainer, topLogoItem)
	TopLogoPetWaterStorageComponent.super.ctor(self, refUContainer, topLogoItem)

	local entity = self.entity
	local waterConfigData = entity:getWaterConfigData()

	self.totalVal = waterConfigData.maxWater or 0
	self.baseRecoveryVal = waterConfigData.addVal or 0
	self.canUseVal = waterConfigData.costVal or 0
	self.curState = RecoveryState.None
	self.isHideAnimPlaying = false
end

function TopLogoPetWaterStorageComponent:onCtor()
	return
end

function TopLogoPetWaterStorageComponent:initUI()
	TopLogoPetWaterStorageComponent.super.initUI(self)
	self:buildLines()
end

function TopLogoPetWaterStorageComponent:buildLines()
	local template = self.lineRectTransform

	if IsNil(template) then
		return
	end

	if self.lineCache then
		return
	end

	self.lineCache = {}
	self.lineAsyncTaskMap = {}

	table.insert(self.lineCache, template)

	for i = 1, MAX_LINE_CNT - 1 do
		local asyncTaskId = pg.global.resMgr:ResInstantiateAsync(template.gameObject, function(gameObj, userData)
			if self.lineAsyncTaskMap == nil then
				if NotNil(gameObj) then
					pg.global.resMgr:ResDestroyObject(gameObj)
				end

				return
			end

			self.lineAsyncTaskMap[i] = nil

			if IsNil(gameObj) then
				return
			end

			local lineRt = gameObj.transform:GetComponent("RectTransform")

			lineRt:SetAnchoredPositionEx(0, 0)
			table.insert(self.lineCache, lineRt)
			self:refreshLinesLayout()
		end, template.position, Quaternion.identity, template.parent)

		self.lineAsyncTaskMap[i] = asyncTaskId
	end

	self:refreshLinesLayout()
end

function TopLogoPetWaterStorageComponent:refreshLinesLayout()
	if not self.lineCache then
		return
	end

	local angleStep = TOTAL_ARC_DEGREES / MAX_LINE_CNT

	for i, lineRt in ipairs(self.lineCache) do
		if NotNil(lineRt) then
			lineRt:SetLocalEulerAnglesEx(0, 0, angleStep * (i - 1))
		end
	end

	local lineRt = self.imgMinimumRectTransform

	if NotNil(lineRt) then
		local total = self.totalVal > 0 and self.totalVal or 100

		lineRt:SetLocalEulerAnglesEx(0, 0, self.canUseVal / total * 360)
	end
end

function TopLogoPetWaterStorageComponent:findObjects()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")

	self.barAnimation = objectReference:GetRefValue("barAnimation")
	self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.lineRectTransform = objectReference:GetRefValue("lineRectTransform")
	self.imgMinimumRectTransform = objectReference:GetRefValue("imgMinimumRectTransform")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.lineParentRectTransform = objectReference:GetRefValue("lineParentRectTransform")
	self.objectReference = objectReference
end

function TopLogoPetWaterStorageComponent:shouldBeActive()
	if not self:isActive() then
		return false
	end

	if not self:getVisible() then
		return false
	end

	return true
end

function TopLogoPetWaterStorageComponent:refreshSelfVisible()
	local visible = self:getVisible()

	self:setVisible(visible, UIConst.TOPLOGO_VISIBLE_KEY.MAIN_PET)
end

function TopLogoPetWaterStorageComponent:clearTimer()
	if self.waitAnimHideTimer then
		self:killTimer(self.waitAnimHideTimer)
	end

	if self.waitHideTimer then
		self:killTimer(self.waitHideTimer)
	end

	self.waitAnimHideTimer = nil
	self.waitHideTimer = nil
end

function TopLogoPetWaterStorageComponent:refreshBarProgress()
	local entity = self.entity
	local curVal = entity:getCurWaterVal() or 0
	local recoveryVal = entity:getCurWaterRecoveryVal()

	self.sliderUSlider.value = curVal / self.totalVal

	if curVal < self.canUseVal then
		self.rootComponent:TryChangePage("Stage", 2)
	elseif curVal >= self.totalVal then
		self.rootComponent:TryChangePage("Stage", 0)
	else
		self.rootComponent:TryChangePage("Stage", 1)
	end

	if recoveryVal > self.baseRecoveryVal then
		self.rootComponent:TryChangePage("SpeedUp", 1)
	else
		self.rootComponent:TryChangePage("SpeedUp", 0)
	end

	local lineVisible = curVal >= self.canUseVal

	LuaUIUtils.setUIViewVisible(self.lineParentRectTransform, lineVisible)
end

function TopLogoPetWaterStorageComponent:onWaterStorageUpdate(state)
	if state and self.curState ~= state then
		self:onWaterStorageValueUpdate()

		self.curState = state
	else
		local visible = self:getVisible()

		if self.visible == nil or self.visible ~= visible then
			if visible then
				self:clearTimer()
				self:playShowHideAnimation(false)
			end

			self.visible = visible
		end

		if self:checkContainerLoaded() then
			self:updateWaterStorageBarUI()
		else
			self:loadAndUpdateWaterStorageBarUI(visible)
		end

		self:refreshSelfVisible()
	end
end

function TopLogoPetWaterStorageComponent:onWaterStorageValueUpdate()
	local entity = self.entity
	local curVal = entity:getCurWaterVal() or 0

	if curVal >= self.totalVal and self.waitHideTimer == nil and self.waitAnimHideTimer == nil then
		if self.waitHideTimer == nil then
			self.waitHideTimer = self:startTimer(function()
				self.waitHideTimer = nil

				self:refreshSelfVisible()
			end, CLOSE_TIME)
		end

		if self.waitAnimHideTimer == nil then
			self.waitAnimHideTimer = self:startTimer(function()
				self:playShowHideAnimation(true)

				self.waitAnimHideTimer = nil

				self:refreshSelfVisible()
			end, CLOSE_TIME - 0.33)
		end
	end

	if curVal < self.totalVal then
		if self.waitHideTimer or self.waitAnimHideTimer then
			self:clearTimer()
		end

		if self.barAnimation ~= nil and self.barAnimation:IsPlaying(ANIM_HIDE) then
			self.barAnimation:Stop(ANIM_HIDE)
		end
	end

	self:onWaterStorageUpdate()
end

function TopLogoPetWaterStorageComponent:onWaterStorageStateUpdate(state)
	self:refreshBarProgress()
end

function TopLogoPetWaterStorageComponent:updateWaterStorageBarUI()
	if not self.entity then
		return
	end

	self:refreshBarProgress()
end

function TopLogoPetWaterStorageComponent:playShowHideAnimation(isHide)
	if self.barAnimation == nil or IsNil(self.barAnimation) then
		return
	end

	local aniName = isHide and ANIM_HIDE or ANIM_SHOW

	if self.barAnimation.IsPlaying ~= nil and self.barAnimation:IsPlaying(aniName) then
		return
	end

	self.barAnimation:Play(aniName)
end

function TopLogoPetWaterStorageComponent:loadAndUpdateWaterStorageBarUI(visible)
	if not self.m_loadedQuestCallBack then
		function self.m_loadedQuestCallBack(isSuccess)
			if isSuccess then
				self:refreshBarProgress()
			end
		end
	end

	if visible then
		self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedQuestCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2)
	end
end

function TopLogoPetWaterStorageComponent:refreshTopLogoInfo(callFromUpdate)
	self:onWaterStorageUpdate()
end

function TopLogoPetWaterStorageComponent:onDestroy()
	self:destroyLines()
	TopLogoPetWaterStorageComponent.super.onDestroy(self)
end

function TopLogoPetWaterStorageComponent:destroyLines()
	if self.lineAsyncTaskMap then
		for _, asyncTaskId in pairs(self.lineAsyncTaskMap) do
			pg.global.resMgr:ResStopInstantiateAsync(asyncTaskId)
		end

		self.lineAsyncTaskMap = nil
	end

	if self.lineCache then
		for i = 2, #self.lineCache do
			local lineRt = self.lineCache[i]

			if NotNil(lineRt) then
				pg.global.resMgr:ResDestroyObject(lineRt.gameObject)
			end
		end

		self.lineCache = nil
	end

	self:clearTimer()
end

function TopLogoPetWaterStorageComponent:getVisible()
	local mainPet = self:isMainPawn()

	if not mainPet then
		return false
	end

	if not self:haveExploreSkill() then
		return false
	end

	if not self:isRecovering() then
		return false
	end

	return true
end

function TopLogoPetWaterStorageComponent:haveExploreSkill()
	local entity = self.entity

	if entity == nil then
		return false
	end

	local petInfo = entity:getBattlePetInfo()

	if petInfo == nil then
		-- block empty
	end

	return AbilityUtils.isShowWaterStorage(entity)
end

function TopLogoPetWaterStorageComponent:isRecovering()
	local entity = self.entity

	if entity == nil then
		return false
	end

	if entity:isFullExploreValue() and (self.waitHideTimer ~= nil or self.waitAnimHideTimer ~= nil) then
		return true
	end

	local curAddVal = entity:getCurWaterRecoveryVal()

	if not entity:isFullExploreValue() and curAddVal > 0 then
		return true
	end

	return false
end

function TopLogoPetWaterStorageComponent:isMainPawn()
	local entity = self.entity

	if entity == nil then
		return false
	end

	local pawn
	local ctrl = pg.global.ui and pg.global.ui.topLogo

	if ctrl and ctrl.getVisualPawn then
		pawn = ctrl:getVisualPawn()
	else
		pawn = pg.pawn
	end

	if entity.isMainPet and pawn == entity then
		return true
	end

	return false
end

function TopLogoPetWaterStorageComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoPetWaterStorageComponent.super.onLanguageChanged(self)
end

function TopLogoPetWaterStorageComponent:getInitMaxDistance()
	return nil
end

return TopLogoPetWaterStorageComponent
