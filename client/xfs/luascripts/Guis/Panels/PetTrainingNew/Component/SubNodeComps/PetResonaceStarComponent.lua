-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\SubNodeComps\\PetResonaceStarComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetResonaceStarComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local PetResonaceStarComponent = Class.LiteClass("PetResonaceStarComponent")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetLevelData = require("Data.pet_level_data")
local math_floor = math.floor
local string_format = string.format
local STAR_STATE = {
	NO_CANUP = 3,
	UPED = 2,
	NORMAL = 1,
	LOCKED = 0
}
local STAR_PART_STATE = {
	UNLIGHT = 0,
	LIGHT = 1
}

function PetResonaceStarComponent:ctor(starUComponent)
	self:init(starUComponent)
end

function PetResonaceStarComponent:init(starUComponent)
	self.starUComponent = starUComponent

	local objectReference = self.starUComponent.transform:GetComponent("ObjectReference")

	self.rootUButton = LuaUIUtils.safeGetRefValue(objectReference, "rootUButton")
	self.imgRingUImage = LuaUIUtils.safeGetRefValue(objectReference, "imgRingUImage")
	self.star1UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star1UComponent")
	self.star2UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star2UComponent")
	self.star3UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star3UComponent")
	self.star4UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star4UComponent")
	self.star5UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star5UComponent")
	self.star6UComponent = LuaUIUtils.safeGetRefValue(objectReference, "star6UComponent")
	self.starUComps = {
		self.star1UComponent,
		self.star2UComponent,
		self.star3UComponent,
		self.star4UComponent,
		self.star5UComponent,
		self.star6UComponent
	}
	self.vXRingNoiseLoopUWidget = LuaUIUtils.safeGetRefValue(objectReference, "vXRingNoiseLoopUWidget")
	self.vXRingNoiseUWidget = LuaUIUtils.safeGetRefValue(objectReference, "vXRingNoiseUWidget")
	self.vXGlowUWidget = LuaUIUtils.safeGetRefValue(objectReference, "vXGlowUWidget")
end

function PetResonaceStarComponent:updateAndRefresh(petId, data, forbidToolTip, popupDirection, forbidCultivateWay)
	local maxStage, maxLv = PetManagementUtils.getResonanceMaxStageLv()

	self.stage = data and data.stage or 0
	self.lv = data and data.lv or 0
	self.pos = data and data.pos or nil
	self.msg = data and data.msg or nil

	if self.stage <= 0 and self.lv <= 0 then
		return
	end

	local curStarStage, curStarLv = PetManagementUtils.getPetCurStarSLv(petId)

	curStarStage = curStarStage or 1
	curStarLv = curStarLv or 0

	if self.rootUButton then
		self.rootUButton.enabledTooltip = not forbidToolTip

		if not forbidToolTip then
			if popupDirection then
				self.rootUButton:SetPopupDirection(popupDirection)
			end

			function self.rootUButton.luaRenderTooltip(_, component)
				PetManagementUtils.refreshPetStarupPopInfo(petId, component, {
					forbidCultivateWay = forbidCultivateWay
				})
			end
		else
			self.rootUButton.luaRenderTooltip = nil
		end

		if forbidToolTip then
			self.rootUButton.navForceNonInteractable = true
		end
	end

	if maxStage <= self.stage and maxLv <= self.lv then
		return
	end

	local isShowRing = self.pos ~= nil

	self.m_starState = isShowRing and curStarStage <= self.stage and STAR_STATE.NORMAL or STAR_STATE.LOCKED

	self.starUComponent:TryChangePage("State", self.m_starState)

	if self.vXRingNoiseLoopUWidget then
		self.vXRingNoiseLoopUWidget:SetActive(false)
	end

	if self.vXRingNoiseUWidget then
		self.vXRingNoiseUWidget:SetActive(false)
	end

	if self.vXGlowUWidget then
		self.vXGlowUWidget:SetActive(false)
	end

	local maxFullFillStarIndex = 0
	local lizUpGosList = {}

	for checkStarLv, starUComp in ipairs(self.starUComps) do
		if starUComp then
			local isGreatherCur = self.lv > 0 and checkStarLv <= self.lv

			starUComp:TryChangePage("Fill", isGreatherCur and STAR_PART_STATE.LIGHT or STAR_PART_STATE.UNLIGHT)

			local lizUpTs = starUComp.transform:Find("Waiting/LizUp")

			if NotNil(lizUpTs) and NotNil(lizUpTs.gameObject) then
				table.insert(lizUpGosList, lizUpTs.gameObject)
				lizUpTs.gameObject:SetActiveEx(false)

				if isGreatherCur then
					maxFullFillStarIndex = #lizUpGosList
				end
			end
		end
	end

	local isPlayNewStarVfx = self.msg and self.pos == UIConst.STARCOMP_POS.BEFORE

	if isPlayNewStarVfx and maxFullFillStarIndex > 0 and lizUpGosList[maxFullFillStarIndex] then
		local LizUpGo = lizUpGosList[maxFullFillStarIndex]

		if NotNil(LizUpGo) then
			LizUpGo:SetActiveEx(true)
		end
	end

	if self.pos == UIConst.STARCOMP_POS.AFTER then
		local curStageMaxLv = PetManagementUtils.getResonanceStageMaxLv(self.stage)

		if curStageMaxLv == self.lv then
			if self.vXRingNoiseLoopUWidget then
				self.vXRingNoiseLoopUWidget:SetActive(true)
			end

			if self.msg then
				local maxStarUComp = self.starUComps[#self.starUComps]

				maxStarUComp:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

				if self.vXRingNoiseUWidget then
					self.vXRingNoiseUWidget:SetActive(true)
				end

				if self.vXGlowUWidget then
					self.vXGlowUWidget:SetActive(true)
				end
			end
		end
	end
end

return PetResonaceStarComponent
