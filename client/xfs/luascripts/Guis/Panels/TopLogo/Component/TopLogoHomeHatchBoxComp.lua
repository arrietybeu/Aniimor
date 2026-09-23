-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoHomeHatchBoxComp.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandOperateData = require("Data.homeland_operate_data")
local Const = require("Common.Const.Const")
local InteractData = require("Data.interact_data")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local HomelandFormulaData = require("Data.homeland_formula_data")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoHomeHatchBoxComp = Class.LightClass("TopLogoHomeHatchBoxComp", TopLogoItemComponent)
local DEFAULT_HATCHBOX_ICON = "$TopLogo/HomeHatchBoxIcon.png"
local DistanceState = {
	Far = 2,
	Mid = 1,
	Near = 0
}
local WorkState = {
	High = 3,
	Low = 2,
	Stop = 1,
	Normal = 0
}

function TopLogoHomeHatchBoxComp:ctor(refUContainer, topLogoItem)
	TopLogoHomeHatchBoxComp.super.ctor(self, refUContainer, topLogoItem)
	pg.game.topLogo.homeFacilityLimiter:register(self.entity.actorId, self)

	self.ignoreCompVisibleCheck = true
	self.m_cbLoadedHatchFunc = nil
end

function TopLogoHomeHatchBoxComp:onDestroy()
	pg.game.topLogo.homeFacilityLimiter:unregister(self.entity.actorId)
	TopLogoHomeHatchBoxComp.super.onDestroy(self)

	self.m_cbLoadedHatchFunc = nil
end

function TopLogoHomeHatchBoxComp:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.widget = self.objectReference:GetComponent("UWidget")
	self.debuffText = self.objectReference:GetRefValue("debuffText")
	self.warnRoot = self.objectReference:GetRefValue("warnRoot")
	self.warnIcon = self.objectReference:GetRefValue("warnIcon")
	self.warnText = self.objectReference:GetRefValue("warnText")
	self.buffList = self.objectReference:GetRefValue("buffList")
	self.numText = self.objectReference:GetRefValue("numText")
	self.numBox = self.objectReference:GetRefValue("numBox")
	self.progress = self.objectReference:GetRefValue("progress")
	self.icon = self.objectReference:GetRefValue("icon")
	self.requireWidget = self.objectReference:GetRefValue("requireWidget")
	self.requireText = self.objectReference:GetRefValue("requireText")
	self.requireAbilityUButton = self.objectReference:GetRefValue("requireAbilityUButton")
	self.lackWater = self.objectReference:GetRefValue("lackWaterUWidget")
	self.envContainerUContainer = self.objectReference:GetRefValue("envContainerUContainer")
	self.farUContainer = self.objectReference:GetRefValue("farUContainer")
	self.tipsUContainer = self.objectReference:GetRefValue("tipsUContainer")
	self.progressHighImg = self.objectReference:GetRefValue("progressHighImg")
	self.buffData = {}
	self.tempBuffData = {}

	function self.buffList.luaRenderItem(button, index, data)
		button:TryChangePage("BuffType", data.buffType)

		local icon = button.transform:Find("Icon"):GetComponent("UImage")

		icon.url = data.iconUrl
	end

	self.workloadRate = 0
	self.nearDistance = HomelandConfigData.facilityTopLogoNearDistance or 3
	self.midDistance = HomelandConfigData.facilityTopLogoMidDistance or 8
	self.farDistance = HomelandConfigData.facilityTopLogoFarDistance or 10
	self.warnTextStr = ""

	self.numBox:SetActive(false)
	self.warnIcon:SetActive(false)
end

function TopLogoHomeHatchBoxComp:resetRender()
	self.objectReference = nil
	self.widget = nil
	self.debuffText = nil
	self.warnRoot = nil
	self.warnIcon = nil
	self.warnText = nil
	self.buffList = nil
	self.numText = nil
	self.numBox = nil
	self.progress = nil
	self.icon = nil
	self.requireWidget = nil
	self.requireText = nil
	self.requireAbilityUButton = nil
	self.lackWater = nil
	self.envContainerUContainer = nil
	self.farUContainer = nil
	self.tipsUContainer = nil
	self.progressHighImg = nil
	self.tipsInfoComponent = nil
	self.tipsRequireTitleText = nil
	self.tipsRequireList = nil
	self.timeText = nil
	self.demandUComponent = nil
	self.farHomeItem = nil
	self.distanceState = nil

	TopLogoHomeHatchBoxComp.super.resetRender(self)
end

function TopLogoHomeHatchBoxComp:addEntityListener()
	return
end

function TopLogoHomeHatchBoxComp:innerGetVisible()
	if not TopLogoHomeHatchBoxComp.super.innerGetVisible(self) then
		return false
	end

	if not pg.me or not pg.me.space then
		return false
	end

	return true
end

function TopLogoHomeHatchBoxComp:getEntOrnamentId()
	return self.entity and self.entity.ornamentId or 0
end

function TopLogoHomeHatchBoxComp:getOrnamentEnvInfoTL()
	local ornamentId = self:getEntOrnamentId()

	if not ornamentId then
		return 0, 0
	end

	local info = self.entity:getOrnamentEnvInfo()

	return info.temperature or 0, info.light
end

function TopLogoHomeHatchBoxComp:getEggIcon()
	local hatchBoxItemInfo = HomeLandUtils.getHatchBoxItemInfo(self.entity.ornamentId)

	if not hatchBoxItemInfo then
		return ""
	end

	return hatchBoxItemInfo.itemIcon or DEFAULT_HATCHBOX_ICON
end

function TopLogoHomeHatchBoxComp:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	self:tickRefreshHatchBoxEggInfo()
end

function TopLogoHomeHatchBoxComp:refreshTopLogoInfo(callFromUpdate)
	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:tickRefreshHatchBoxEggInfo()

			return
		end

		if not self.m_cbLoadedHatchFunc then
			function self.m_cbLoadedHatchFunc()
				self:tickRefreshHatchBoxEggInfo()
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(self.m_cbLoadedHatchFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end
end

function TopLogoHomeHatchBoxComp:tickRefreshHatchBoxEggInfo()
	if not self.widget then
		return
	end

	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self:getEntOrnamentId())

	if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.INIT then
		LuaUIUtils.setUIVisible(self.refUContainer.content, false)

		return
	end

	if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.CAN_PLACE then
		self.widget:TryChangePage("MainState", 0)
	elseif hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
		self.icon.url = self:getEggIcon()

		self.widget:TryChangePage("MainState", 1)
	elseif hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		self.icon.url = self:getEggIcon()

		self.widget:TryChangePage("MainState", 2)
	end

	self:refreshFacilityProgress()
	self:refreshInfoStateByDistance(self.compDistance)
end

function TopLogoHomeHatchBoxComp:refreshFacilityProgress()
	self.workloadState = WorkState.Normal

	self.progress:TryChangePage("State", 0)

	local curValue = HomeLandUtils.getHatchBoxProgressRatioByOrnamentId(self:getEntOrnamentId())

	self.progress.value = math.min(curValue, 1)
	self.progress.maxValue = 1

	local leftTs = math.max(HomeLandUtils.getHatchBoxHatchedLeftSecondByOrnamentId(self:getEntOrnamentId()), 0)
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self:getEntOrnamentId())

	if hatchBoxStatus <= Const.HOME_HATCHBOX_STATUS.CAN_PLACE then
		self.tipTextStr = pg.getGameString("INCUBATOR_EMPTY_HATCH_DESC")
		self.warnTextStr = pg.getGameString("INCUBATOR_EMPTY_HATCH_DESC")
		self.leftTimeStr = ""
	elseif hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		self.tipTextStr = pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
		self.warnTextStr = pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
		self.leftTimeStr = ""
	elseif leftTs > 0 then
		local timeStr = LuaUIUtils.getCountDownString(leftTs, UIConst.TimeType.Short, true)

		self.tipTextStr = pg.getGameString("INCUBATOR_FINITH_TIME_TIP")
		self.warnTextStr = string.format("<style=Nml_L>%s</style>", timeStr)
		self.leftTimeStr = timeStr
	else
		self.tipTextStr = pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
		self.warnTextStr = pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
		self.leftTimeStr = ""
	end

	ClientTextUtils.setText(self.warnText, self.warnTextStr)
end

function TopLogoHomeHatchBoxComp:refreshInfoStateByDistance(distance)
	if not distance or self.widget == nil then
		return
	end

	if distance >= 0 and distance < self.nearDistance then
		if self.distanceState ~= DistanceState.Near then
			self.distanceState = DistanceState.Near

			self.widget:TryChangePage("Distance", 0)
		end

		if self.entity.id == pg.game.home.curInteractEntId then
			self.widget:TryChangePage("ShowDetail", 1)

			if NotNil(self.tipsUContainer) and not self.tipsUContainer:CheckURLLoaded() then
				self.tipsUContainer:LoadDefaultUrlManually(function()
					if IsNil(self.tipsUContainer) or not self.tipsUContainer.content then
						return
					end

					self.tipsInfoComponent = self.tipsUContainer.content:GetComponent("UComponent")

					local objectReference = self.tipsInfoComponent:GetComponent("ObjectReference")

					self.tipsRequireTitleText = objectReference:GetRefValue("requireTitleText")
					self.tipsRequireList = objectReference:GetRefValue("requireList")
					self.timeText = objectReference:GetRefValue("timeText")
					self.demandUComponent = objectReference:GetRefValue("demandUComponent")

					function self.tipsRequireList.luaRenderItem(button, index, data)
						self:renderRequireList(button, index, data)
					end

					self:refreshDetailInfos()
					self.tipsInfoComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				end)
			end

			if self.tipsInfoComponent then
				self:refreshDetailInfos()
			end
		else
			self.widget:TryChangePage("ShowDetail", 0)
		end
	elseif distance >= self.nearDistance and distance < self.midDistance then
		if self.distanceState == DistanceState.Mid then
			return
		end

		self.widget:TryChangePage("ShowDetail", 0)

		self.distanceState = DistanceState.Mid

		self.widget:TryChangePage("Distance", 1)
	elseif distance >= self.midDistance and self.farHomeItem then
		self.farHomeItem:SetActive(false)
	end
end

function TopLogoHomeHatchBoxComp:refreshDetailInfos()
	local recommendInfos, recommendEnvRatio = HomeLandUtils.getHatchEggRecommendEnvInfos(self:getEntOrnamentId())

	self.showDemand = #recommendInfos > 0

	self.tipsInfoComponent:TryChangePage("ShowDemand", self.showDemand and 0 or 1)
	self.tipsRequireList:SetList(recommendInfos)
	ClientTextUtils.setText(self.tipsRequireTitleText, self.tipTextStr)
	ClientTextUtils.setText(self.timeText, self.leftTimeStr or "")
	self.tipsInfoComponent:TryChangePage("State", self.workloadState)
	self.demandUComponent:SetActive(self.showDemand)

	if self.showDemand then
		self.demandUComponent:TryChangePage("Condition", recommendEnvRatio > 0 and 1 or 0)
	end
end

function TopLogoHomeHatchBoxComp:renderRequireList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")

	ClientTextUtils.setText(numLevelUSDFText, data.requireRate and math.abs(data.requireRate) or "")

	if data.isLight then
		button:TryChangePage("Type", 2)
		button:TryChangePage("Condition", data.lightWorkRatio <= 0 and 0 or 1)
	elseif data.isTemperature then
		button:TryChangePage("Type", data.requireRate > 0 and 1 or 3)
		button:TryChangePage("Condition", data.tempWorkRatio <= 0 and 0 or 1)
	end
end

return TopLogoHomeHatchBoxComp
