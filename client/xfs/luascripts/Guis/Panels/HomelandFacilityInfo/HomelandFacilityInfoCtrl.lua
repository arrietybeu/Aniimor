-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfo\\HomelandFacilityInfoCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandFacilityInfoCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local HomeObjectData = require("Data.home_object_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local ItemData = require("Data.item_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local InteractData = require("Data.interact_data")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotKeyConst = require("Const.HotkeyConst")
local PetProtoTypeData = require("Data.pet_prototype_data")
local HomeAbilityData = require("Data.home_ability_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local PetTalentData = require("Data.pet_talent_data")
local HomelandConfigData = require("Data.homeland_config_data")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")
local PetData = require("Data.pet_data")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local HomelandFacilityInfoCtrl = Class.LightClass("HomelandFacilityInfoCtrl", UICtrl)

HomelandFacilityInfoCtrl.messages = {
	[MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED] = {
		"onFacilityAllocateChanged",
		true
	},
	[MessageName.HOMELAND_HATCH_UPDATE_SINGLEINFO] = {
		"refreshStateInfo",
		true
	}
}

local WorkState = {
	Normal = 0,
	High = 3,
	Low = 2,
	Stop = 1
}

function HomelandFacilityInfoCtrl:onCreate(info)
	HomelandFacilityInfoCtrl.super.onCreate(self, info)

	self.view = self.view
	self.entity = info.entity
	self.ornamentId = info.ornamentId
	self.homeTemplateId = info.homeTemplateId
	self.facilityType = Utils.getHomeFacilityType(self.homeTemplateId)
	self.isExpand = false
	self.lastConsumeFormulaId = nil
	self.consumeList = {}
	self.outputList = {}
	self.petList = {}
	self.tempBuffData = {}
	self.lightWorkRatio, self.lightRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
	self.tempWorkRatio, self.tempRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)
	self.updateTimer = self:startTimer(function()
		self:onTick()
	end, 0.5, true)
	self.isHatchBox = info.isHatchBox or false
	self.facilityInfo = self:getFacilityInfo()
	self.ornamentInfo = self:getOrnamentInfo()

	self:initFacilityInfo()
	self:refreshFacilityInfo()
	self:refreshRecommend()
	self:refreshHomeAbilityRecommend()
	self:postInit()
end

function HomelandFacilityInfoCtrl:onDestroy()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end

	HomelandFacilityInfoCtrl.super.onDestroy(self)
end

function HomelandFacilityInfoCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:close()
	end

	function self.view.listPet.luaRenderItem(button, index, subData)
		self:renderPetItem(button, index, subData)
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.closeBtn.gameObject, "closeBind")

	closeBind.priority = 10
	closeBind.actionPath = HotKeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function self.view.accessList.luaRenderItem(button, _, itemData)
		local talentTemplateId = itemData.templateId

		LuaUIUtils.renderTalentItem(button, talentTemplateId)

		local objectReference = button:GetComponent("ObjectReference")
		local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

		rayBoxUWidget.gameObject:SetActiveEx(true)

		function button.luaClick()
			local talentData = {}
			local name = PetTalentData[talentTemplateId].talentName
			local icon = PetTalentData[talentTemplateId].talentIcon
			local quality = PetTalentData[talentTemplateId].rarity
			local id = talentTemplateId
			local group = PetTalentData[talentTemplateId].group
			local homeDesc = PetTalentData[talentTemplateId].homeDesc
			local breedTalent = {}

			breedTalent[#breedTalent + 1] = {
				name = name,
				icon = icon,
				quality = quality,
				id = id,
				group = group,
				homeDesc = homeDesc
			}
			talentData.targetRect = self.view.recommendUWidget
			talentData.autoHor = true
			talentData.type = UIConst.GIFT_TYPE.HOME
			talentData.breedTalent = breedTalent
			talentData.title = pg.getGameString("HOME_PERSONALITY_RECOMMEND")

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS_RECOMMEND, talentData)
		end
	end
end

function HomelandFacilityInfoCtrl:getOrnamentInfo()
	return pg.me.space.ornament[self.ornamentId]
end

function HomelandFacilityInfoCtrl:getFacilityInfo()
	return pg.me.space.facility[self.ornamentId]
end

function HomelandFacilityInfoCtrl:getHomeLinkInfo()
	return pg.me.space.homeLinkMap[self.ornamentId]
end

function HomelandFacilityInfoCtrl:getOrnamentEnvInfo()
	return pg.me.space.ornamentEnvMap[self.ornamentId]
end

function HomelandFacilityInfoCtrl:initFacilityInfo()
	self:initType1Info()
	self:initType2Info()
	self:initType3Info()
end

function HomelandFacilityInfoCtrl:postInit()
	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self:setExpand(true)
	end
end

function HomelandFacilityInfoCtrl:initType1Info()
	local objectReference = self.view.workInfo:GetComponent("ObjectReference")

	self.type1workText = objectReference:GetRefValue("workText")
	self.type1buffList = objectReference:GetRefValue("buffList")
	self.type1rateText = objectReference:GetRefValue("rateText")
	self.type1warnIcon = objectReference:GetRefValue("warnIcon")
	self.type1warnText = objectReference:GetRefValue("warnText")
	self.type1disableBtn = objectReference:GetRefValue("disableBtn")
	objectReference = self.view.itemInfo01UWidget:GetComponent("ObjectReference")
	self.type1stateName = objectReference:GetRefValue("stateName")
	self.type1timeText = objectReference:GetRefValue("timeText")
	self.type1countText = objectReference:GetRefValue("countText")
	self.type1icon = objectReference:GetRefValue("icon")
	self.type1progress = objectReference:GetRefValue("progress")
	self.type1timeText2 = objectReference:GetRefValue("timeText2")
	self.type1FormulaInfoUWidget = objectReference:GetRefValue("formulaInfoUWidget")
	self.type1FormulaTimeText = objectReference:GetRefValue("formulaTimeText")
	self.type1IconWorkUImage = objectReference:GetRefValue("iconWorkUImage")
	self.type1PetIconWorkUImage = objectReference:GetRefValue("petIconWorkUImage")
	self.type1ConsumeList = objectReference:GetRefValue("consumeList")
	self.type1OutputList = objectReference:GetRefValue("outputList")
	self.type1KeepWorkText = objectReference:GetRefValue("keepWorkText")
	self.type1PetInfoUWidget = objectReference:GetRefValue("petInfoUWidget")
	self.type1PetOutputList = objectReference:GetRefValue("petOutputList")
	self.type1PetWorkLoadText = objectReference:GetRefValue("petWorkLoadText")
	self.type1PetHeadUButton = objectReference:GetRefValue("petHeadUButton")
	self.type1timeUWidget = objectReference:GetRefValue("timeUWidget")
	self.type1expandBtn = objectReference:GetRefValue("expandBtn")
	self.type1unExpandBtn = objectReference:GetRefValue("unExpandBtn")
	self.type1numBgUWidget = objectReference:GetRefValue("numBgUWidget")
	self.type1HighImage = objectReference:GetRefValue("highImage")
	self.type1WidgetUWidget = objectReference:GetRefValue("widgetUWidget")
	self.type1BtnPauseUButton = objectReference:GetRefValue("btnPauseUButton")

	function self.type1expandBtn.luaClick()
		self:setExpand(true)
	end

	function self.type1unExpandBtn.luaClick()
		self:setExpand(false)
	end

	function self.type1buffList.luaRenderItem(button, index, data)
		self:renderBuffItem(button, index, data)
	end

	function self.type1disableBtn.luaClick()
		self:switchFacilityDisable()
	end

	function self.type1ConsumeList.luaRenderItem(button, index, subData)
		local numOverrideText = subData.num .. "/" .. tostring(subData.numConsume)

		LuaUIUtils.renderRewardItem(button, subData, numOverrideText)
	end

	function self.type1OutputList.luaRenderItem(button, index, subData)
		local numOverrideText = subData.num

		LuaUIUtils.renderRewardItem(button, subData, numOverrideText)
	end

	function self.type1PetOutputList.luaRenderItem(button, index, subData)
		local numOverrideText = subData.num

		LuaUIUtils.renderRewardItem(button, subData, numOverrideText)
	end

	function self.view.workInfo.luaClick()
		if not self.isHatchBox and self.facilityInfo == nil then
			return
		end

		pg.global.ui.homelandFacilityInfoDetail:open({
			padding = 100,
			autoHor = true,
			isHatchBox = self.isHatchBox,
			ornamentId = self.ornamentId,
			homeTemplateId = self.homeTemplateId,
			facilityInfo = self:getFacilityInfo(),
			ornamentInfo = self:getOrnamentInfo(),
			entity = self.entity,
			targetRect = self.view.detailInfoPopupRectRectTransform,
			petList = self.petList,
			statePaused = self.statePaused,
			extraInfo = self:getTipExtraInfo(),
			extra = {
				closeFun = function()
					if self.view then
						self.view.workInfo.isSelected = false
					end
				end
			}
		})
	end

	ClientTextUtils.setText(self.type1KeepWorkText, pg.getGameString("HOMELAND_TIPS_KEEP_WORK"))
end

function HomelandFacilityInfoCtrl:initType3Info()
	local objectReference = self.view.itemInfo03UWidget:GetComponent("ObjectReference")

	self.type3Level1Text = objectReference:GetRefValue("level1Text")
	self.type3Level2Text = objectReference:GetRefValue("level2Text")
	self.type3btnTabUButton = objectReference:GetRefValue("btnTabUButton")

	function self.type3btnTabUButton.luaClick()
		self:switchFacilityState()
	end

	local btnLTrans = self.type3btnTabUButton.transform:Find("BtnL")
	local btnRTrans = self.type3btnTabUButton.transform:Find("BtnR")

	self.type3btnL = btnLTrans and btnLTrans:GetComponent("UButton") or nil
	self.type3btnR = btnRTrans and btnRTrans:GetComponent("UButton") or nil

	if self.type3btnL then
		function self.type3btnL.luaClick()
			self:setFacilityEnvParam(1)
		end

		self:bindHotKeyPerform(HotKeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftTrigger, function()
			self.type3btnL:OnClickSimulate()
		end, self.type3btnL.gameObject)
	end

	if self.type3btnR then
		function self.type3btnR.luaClick()
			self:setFacilityEnvParam(2)
		end

		self:bindHotKeyPerform(HotKeyConst.INPUT_MAP_ACTION_KEY.GamepadRightTrigger, function()
			self.type3btnR:OnClickSimulate()
		end, self.type3btnR.gameObject)
	end
end

function HomelandFacilityInfoCtrl:setFacilityEnvParam(envParam)
	if not self.facilityInfo then
		return
	end

	if self.facilityInfo.envParam == envParam then
		return
	end

	pg.space:setProduceEnvParam(self.ornamentId, envParam)
end

function HomelandFacilityInfoCtrl:initType2Info()
	local objectReference = self.view.itemInfo02UWidget:GetComponent("ObjectReference")

	self.type2expandBtn = objectReference:GetRefValue("btnExpandUButton")
	self.type2unExpandBtn = objectReference:GetRefValue("btnUnExpandUButton")
	self.type2NameUSDFText = objectReference:GetRefValue("nameUSDFText")
	self.type2itemDescText = objectReference:GetRefValue("descText")
	self.type2workRateText = objectReference:GetRefValue("workRateText")
	self.type2produceText = objectReference:GetRefValue("produceText")
	self.type2produceTitle = objectReference:GetRefValue("produceTitle")
	self.type2costText = objectReference:GetRefValue("costText")
	self.type2costTitle = objectReference:GetRefValue("costTitle")
	self.type2ElectricInfoTipBtn = objectReference:GetRefValue("electricInfoTip")
	self.type2realProduceText = objectReference:GetRefValue("realProduceText")
	self.type2realProduceTitle = objectReference:GetRefValue("realProduceTitle")

	function self.type2expandBtn.luaClick()
		self:setExpand(true)
	end

	function self.type2unExpandBtn.luaClick()
		self:setExpand(false)
	end

	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
		self.type2expandBtn:SetActive(false)
	end

	function self.type2ElectricInfoTipBtn.luaRenderTooltip(button, popup)
		self:rendererElectricInfoTip(button, popup)
	end
end

function HomelandFacilityInfoCtrl:refreshFacilityInfo()
	local configData = HomeObjectData[self.homeTemplateId] or {}

	self.view.facilityIcon.url = configData.plotIconId or AddressDataConst.UI_HOME_PLOT_NORMAL_ICON

	local name = pg.getLocalizationText(configData.name)
	local upgradeData = RevertHomeUpgradeData[self.homeTemplateId]

	if upgradeData then
		local levelText = " Lv." .. upgradeData[2]

		ClientTextUtils.setText(self.view.levelText, levelText)
	else
		self.view.levelUWidget:SetActive(false)
	end

	ClientTextUtils.setText(self.view.titleText, name)
	self:refreshStateInfo()
	self:refreshPetList()
end

function HomelandFacilityInfoCtrl:setExpand(expand)
	if self.isHatchBox then
		local hatchBoxInfo = pg.me.space:getHatchBoxInfo(self.ornamentId)
		local hatchBoxEggItem = hatchBoxInfo and hatchBoxInfo.item
		local itemId = hatchBoxEggItem and hatchBoxEggItem.id
		local itemCfg = itemId and ItemData[itemId]

		if hatchBoxEggItem and itemCfg then
			LuaUIUtils.popupPropTip({
				num = 1,
				id = itemId,
				targetRect = self.view.contentUWidget,
				itemId = itemId,
				genID = hatchBoxEggItem.genID
			})
		end
	else
		self.isExpand = expand
		self.lastConsumeFormulaId = nil

		self:refreshStateInfo()
	end
end

function HomelandFacilityInfoCtrl:setConsumableAndOutputList(formulaId, isPet)
	if self.lastConsumeFormulaId ~= formulaId then
		self.lastConsumeFormulaId = formulaId

		table.clear(self.consumeList)

		local formulaData = HomelandFormulaData[formulaId] or {}

		for i = 1, 3 do
			local itemId = formulaData["consumable" .. i]

			if itemId then
				local itemData = ItemData[itemId]

				if itemData then
					local num = ClientUtils.getHomelandItemCountById(itemId)
					local numText = ""

					if num < formulaData["consumableNum" .. i] then
						numText = pg.getFormatText("<style=Debuff>{0}</style>", num)
					else
						numText = num
					end

					self.consumeList[#self.consumeList + 1] = {
						tIndex = 0,
						id = itemId,
						num = numText,
						numConsume = formulaData["consumableNum" .. i]
					}
				end
			end
		end

		self.type1ConsumeList:SetList(self.consumeList)

		local outputList = HomeLandUtils.getFormulaOutputList(formulaData)

		table.clear(self.outputList)

		for _, outputInfo in ipairs(outputList) do
			self.outputList[#self.outputList + 1] = {
				tIndex = 0,
				id = outputInfo[1],
				num = outputInfo[2]
			}
		end

		if isPet then
			self.type1PetOutputList:SetList(self.outputList)
		else
			self.type1OutputList:SetList(self.outputList)
		end

		local useTime = formulaData.time
		local useWork = formulaData.workload

		if isPet then
			if useTime then
				ClientTextUtils.setText(self.type1PetWorkLoadText, LuaUIUtils.getCountDownString(useTime, nil, true))

				self.type1PetIconWorkUImage.url = AddressDataConst.HOME_TIPS_TIME_ICON
			elseif useWork then
				ClientTextUtils.setText(self.type1PetWorkLoadText, tostring(useWork))

				self.type1PetIconWorkUImage.url = AddressDataConst.HOME_TIPS_WORK_ICON
			end
		elseif useTime then
			ClientTextUtils.setText(self.type1FormulaTimeText, LuaUIUtils.getCountDownString(useTime, nil, true))

			self.type1IconWorkUImage.url = AddressDataConst.HOME_TIPS_TIME_ICON
		elseif useWork then
			ClientTextUtils.setText(self.type1FormulaTimeText, tostring(useWork))

			self.type1IconWorkUImage.url = AddressDataConst.HOME_TIPS_WORK_ICON
		end
	end
end

function HomelandFacilityInfoCtrl:checkFadeOutHud()
	return false
end

function HomelandFacilityInfoCtrl:refreshStateInfo()
	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self:refreshElectricStateInfo()
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		self:refreshElectricStateInfo()
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		self:refreshTemperatureStateInfo()
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		self:refreshTemperatureStateInfo()
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
		self:refreshLightStateInfo()
	else
		self:refreshNormalStateInfo()
	end

	self:refreshDisableState()
end

function HomelandFacilityInfoCtrl:refreshDisableState()
	local showPauseBtn = false

	if self.facilityInfo and self.facilityInfo.formulaId ~= 0 then
		showPauseBtn = true
	end

	if HomeLandUtils.isFieldOrWoodland(self.homeTemplateId) then
		showPauseBtn = false
	end

	if showPauseBtn then
		if self.facilityInfo.disable then
			self.view.workInfo:TryChangePage("WorkState", 2)
			self.type1disableBtn:TryChangePage("Play", 0)
		else
			self.view.workInfo:TryChangePage("WorkState", self.statePaused and 1 or 0)
			self.type1disableBtn:TryChangePage("Play", 1)
		end
	else
		self.view.workInfo:TryChangePage("WorkState", self.statePaused and 1 or 3)
	end
end

function HomelandFacilityInfoCtrl:switchFacilityDisable()
	if self.facilityInfo then
		if self.facilityInfo.disable then
			pg.space:setProduceDisable(self.ornamentId, false)
		else
			pg.space:setProduceDisable(self.ornamentId, true)
		end
	end
end

function HomelandFacilityInfoCtrl:getTipExtraInfo()
	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric or self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		return {
			electricProduce = self.electricProduce,
			realProduce = self.realProduce,
			maxProduce = self.maxProduce,
			totalCost = self.totalCost
		}
	end

	return nil
end

function HomelandFacilityInfoCtrl:refreshElectricStateInfo()
	if self.isExpand then
		self.view.widget:TryChangePage("expand", 1)
	else
		self.view.widget:TryChangePage("expand", 0)
	end

	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		self.view.widget:TryChangePage("facilityType", 1)
	else
		self.view.widget:TryChangePage("facilityType", 5)
	end

	self:refreshElectricWorkState()
	self:refreshElectricGroupDetail()
end

function HomelandFacilityInfoCtrl:calcElectricMaxProduce(linkGroupInfo)
	local mainOrnaments = linkGroupInfo.mainOrnaments
	local maxProduce = 0

	for _, ornamentId in ipairs(mainOrnaments) do
		local facilityInfo = pg.space.facility[ornamentId]

		if facilityInfo and facilityInfo.formulaId ~= 0 then
			maxProduce = maxProduce + HomelandFormulaData[facilityInfo.formulaId].electricProduce
		end
	end

	return maxProduce
end

function HomelandFacilityInfoCtrl:refreshElectricGroupDetail()
	local workRate = 0

	if self.realProduce > 0 then
		workRate = self.realProduce / self.totalCost
	end

	local workRateText = pg.getFormatText(pg.getGameString("ELECT_PRODUCE_RATE"), string.format("%s%%", math.floor(workRate * 100)))

	ClientTextUtils.setText(self.type2itemDescText, workRateText)
	ClientTextUtils.setText(self.type2workRateText, string.format("%s%%", math.floor(workRate * 100)))
end

function HomelandFacilityInfoCtrl:rendererElectricInfoTip(button, popup)
	local objectReference = popup:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtNum = objectReference:GetRefValue("txtNum")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	ClientTextUtils.setText(txtTitle, pg.getGameString("ELECTRIC_TIP_TITLE"))
	ClientTextUtils.setText(txtDesc, pg.getLocalizationText(HomelandConfigData.electricTip))
end

function HomelandFacilityInfoCtrl:refreshElectricWorkState()
	local linkInfo = self:getHomeLinkInfo()
	local linkGroupInfo = {}

	ClientTextUtils.setText(self.type2produceTitle, pg.getGameString("ELECTRIC_MAX_PRODUCE"))
	ClientTextUtils.setText(self.type2realProduceTitle, pg.getGameString("ELECTRIC_CUR_PRODUCE"))
	ClientTextUtils.setText(self.type2costTitle, pg.getGameString("ELECTRIC_COST"))

	if linkInfo.groupId ~= 0 then
		linkGroupInfo = pg.space.homeLinkGroupMap[linkInfo.groupId]

		local electricProduce = linkGroupInfo.totalProduce or 0
		local totalCost = linkGroupInfo.totalCost or 0
		local maxProduce = self:calcElectricMaxProduce(linkGroupInfo)
		local realProduce = math.min((HomelandConfigData.electricMaxWorkRate or 1) * totalCost, electricProduce)

		self.electricProduce = math.floor(electricProduce)
		self.realProduce = math.floor(realProduce)
		self.maxProduce = maxProduce
		self.totalCost = totalCost

		ClientTextUtils.setText(self.type2produceText, maxProduce .. "W")
		ClientTextUtils.setText(self.type2costText, totalCost .. "W")
		ClientTextUtils.setText(self.type2realProduceText, self.electricProduce .. "W")
	else
		self.electricProduce = 0
		self.realProduce = 0
		self.maxProduce = 0
		self.totalCost = 0

		ClientTextUtils.setText(self.type2produceText, "0W")
		ClientTextUtils.setText(self.type2costText, "0W")
		ClientTextUtils.setText(self.type2realProduceText, "0W")
	end

	local envFacilityInfo = self.entity:getEnvFacilityInfo()

	self.selfEnvProduce = 0
	self.selfEnvMaxProduce = 0
	self.statePaused = false
	self.electricWorkRatio = nil

	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		local facilityInfo = self.facilityInfo
		local formulaData = HomelandFormulaData[facilityInfo.formulaId]

		self.selfEnvProduce = envFacilityInfo.envProduce
		self.selfEnvMaxProduce = formulaData.electricProduce

		local facilityStateInfo = facilityInfo.facilityStateInfo
		local facilityState = facilityInfo.facilityState

		if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
			if facilityInfo.disable then
				ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_PAUSING"))

				self.type1warnIcon.url = AddressDataConst.HOME_FACILITY_PAUSE_ICON
				self.statePaused = true
			elseif not self:checkHasEntDoingOper(self.ornamentId, facilityState) then
				ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))

				self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.NO_WORKLOAD]
				self.statePaused = true
			end
		end

		self.view.workInfo:TryChangePage("TextType", 0)

		local workloadRate = self.selfEnvProduce / self.selfEnvMaxProduce

		self.electricWorkRatio = workloadRate

		self:refreshBuffList(facilityInfo, self.type1buffList)
		ClientTextUtils.setText(self.type1rateText, string.format("%s%%", math.floor(workloadRate * 100)))
	else
		self.view.workInfo:TryChangePage("TextType", 3)

		if linkInfo.groupId == 0 then
			self.statePaused = true

			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_ELECTRIC_LINK"))

			self.type1warnIcon.url = AddressDataConst.HOME_WARN_ICON_NO_ELECTRIC
		elseif self.electricProduce <= 0 then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_ELECTRIC"))

			self.type1warnIcon.url = AddressDataConst.HOME_WARN_ICON_NO_ELECTRIC
			self.statePaused = true
		end
	end

	self.view.workInfo:TryChangePage("Buff", self.electricWorkRatio and not self.statePaused and 0 or 1)

	if self.electricProduce > 0 then
		self.view.widget:TryChangePage("WorkState", 0)
	else
		self.view.widget:TryChangePage("WorkState", 1)
	end

	if self.statePaused then
		self.view.workInfo:TryChangePage("WorkState", 1)
	else
		self.view.workInfo:TryChangePage("WorkState", 0)
	end
end

function HomelandFacilityInfoCtrl:refreshTemperatureStateInfo()
	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		self.view.widget:TryChangePage("facilityType", 2)
		ClientTextUtils.setText(self.type3Level1Text, pg.getGameString("TEMPERATURE_WARM"))
		ClientTextUtils.setText(self.type3Level2Text, pg.getGameString("TEMPERATURE_HOT"))
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		self.view.widget:TryChangePage("facilityType", 3)
		ClientTextUtils.setText(self.type3Level1Text, pg.getGameString("TEMPERATURE_COLD"))
		ClientTextUtils.setText(self.type3Level2Text, pg.getGameString("TEMPERATURE_FROZEN"))
	end

	local facilityInfo = self.facilityInfo

	if facilityInfo.envParam == 2 then
		self.view.itemInfo03UWidget:TryChangePage("StateTab", 1)
	else
		self.view.itemInfo03UWidget:TryChangePage("StateTab", 0)
	end

	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityState = facilityInfo.facilityState

	self.statePaused = false

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		if facilityInfo.disable then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_PAUSING"))

			self.type1warnIcon.url = AddressDataConst.HOME_FACILITY_PAUSE_ICON
			self.statePaused = true
		elseif not self:checkHasEntDoingOper(self.ornamentId, facilityState) then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))

			self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.NO_WORKLOAD]
			self.statePaused = true
		end
	end

	self.view.workInfo:TryChangePage("TextType", 0)
	self.view.workInfo:TryChangePage("Buff", 1)

	if self.statePaused then
		self.view.widget:TryChangePage("WorkState", 1)
		self.view.workInfo:TryChangePage("WorkState", 1)
		ClientTextUtils.setText(self.type1rateText, "0%")
	else
		self.view.widget:TryChangePage("WorkState", 0)
		self.view.workInfo:TryChangePage("WorkState", 0)
		ClientTextUtils.setText(self.type1rateText, "100%")
	end
end

function HomelandFacilityInfoCtrl:switchFacilityState()
	local envParam = 1

	if self.facilityInfo.envParam == 1 then
		envParam = 2
	end

	pg.space:setProduceEnvParam(self.ornamentId, envParam)
end

function HomelandFacilityInfoCtrl:refreshLightStateInfo()
	self.view.widget:TryChangePage("facilityType", 4)
	ClientTextUtils.setText(self.type2itemDescText, 0)

	local facilityInfo = self.facilityInfo
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityState = facilityInfo.facilityState

	self.statePaused = false

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		if facilityInfo.disable then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_PAUSING"))

			self.type1warnIcon.url = AddressDataConst.HOME_FACILITY_PAUSE_ICON
			self.statePaused = true
		elseif not self:checkHasEntDoingOper(self.ornamentId, facilityState) then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))

			self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.NO_WORKLOAD]
			self.statePaused = true
		end
	end

	self.view.workInfo:TryChangePage("TextType", 0)
	self.view.workInfo:TryChangePage("Buff", 1)
	ClientTextUtils.setText(self.type2itemDescText, "")

	if self.statePaused then
		self.view.widget:TryChangePage("WorkState", 1)
		self.view.workInfo:TryChangePage("WorkState", 1)
		ClientTextUtils.setText(self.type1rateText, "0%")
	else
		self.view.widget:TryChangePage("WorkState", 0)
		self.view.workInfo:TryChangePage("WorkState", 0)
		ClientTextUtils.setText(self.type1rateText, "100%")
	end
end

function HomelandFacilityInfoCtrl:refreshEnvStateWarning()
	local isElectricType = self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq

	if self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		isElectricType = self.ornamentInfo.electricMode
	end

	if isElectricType then
		local ornamentEnvInfo = self:getOrnamentEnvInfo()
		local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo or {}
		local linkValid = false

		for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
			local linkInfo = pg.space.homeLinkMap[refEnvOrnamentId]

			if linkInfo and linkInfo.groupId ~= 0 then
				linkValid = true
			end
		end

		if linkValid then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_ELECTRIC"))

			self.type1warnIcon.url = AddressDataConst.HOME_WARN_ICON_NO_ELECTRIC
		else
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_ELECTRIC_LINK"))

			self.type1warnIcon.url = AddressDataConst.HOME_WARN_ICON_NO_ELECTRIC
		end
	elseif self.facilityType == Const.HOMELAND_FACILITY_TYPE.ENV then
		-- block empty
	end
end

function HomelandFacilityInfoCtrl:refreshNormalStateInfo()
	self.view.widget:TryChangePage("facilityType", 0)

	if self.isHatchBox then
		self:refreshNormalStateInfo_IsHatchBox()
	else
		self.type1BtnPauseUButton:SetActive(false)
		self:refreshNormalStateInfo_NotHatchBox()
	end
end

function HomelandFacilityInfoCtrl:refreshNormalStateInfo_IsHatchBox()
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(self.ornamentId)
	local eggItemId = hatchBoxInfo and hatchBoxInfo.item and hatchBoxInfo.item.id or 0

	if eggItemId <= 0 then
		self:close()

		return
	end

	function self.type1BtnPauseUButton.luaClick()
		HomeLandUtils.showPauseHatchConfirm(function()
			HomeLandUtils.tryPauseCurHatch(self.ornamentId)
		end)
	end

	local eggCfg = PetHatchEggData[eggItemId]
	local eggItemCfg = ItemData[eggItemId]

	ClientTextUtils.setText(self.type1stateName, pg.getLocalizationText(eggItemCfg and eggItemCfg.itemName or ""))

	self.type1icon.url = eggItemCfg and eggItemCfg.icon or ""

	self.type1WidgetUWidget:SetActive(false)
	self:updateProgress(hatchBoxInfo)

	local hatchBoxWorkloadRate = HomeLandUtils.getHatchBoxRealWorkRatio(self.ornamentId)

	ClientTextUtils.setText(self.type1rateText, string.format("%s%%", math.floor(hatchBoxWorkloadRate * 100)))
	self.view.workInfo:TryChangePage("WorkState", hatchBoxWorkloadRate > 0 and 0 or 1)
	ClientTextUtils.setText(self.type1warnText, pg.getGameString("HATCH_HOME_INFO_ENV_DISAGREE"))

	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.ornamentId)

	self.type1BtnPauseUButton:SetActive(hatchBoxStatus ~= Const.HOME_HATCHBOX_STATUS.HATCHED)

	if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		ClientTextUtils.setText(self.type1workText, pg.getGameString("ECOLOGICAL_RESARCH_FINISH"))
	end
end

function HomelandFacilityInfoCtrl:refreshNormalStateInfo_NotHatchBox()
	self.workloadRate = 0
	self.workloadState = WorkState.Stop

	local facilityInfo = self.facilityInfo

	if not facilityInfo or facilityInfo.facilityState == 0 then
		ClientTextUtils.setText(self.type1stateName, "")
		self.type1timeUWidget:SetActive(false)
		self.type1numBgUWidget:SetActive(false)
		self.view.widget:TryChangePage("expand", 0)
		self.type1expandBtn:SetActive(false)

		self.type1icon.url = ""

		self.type1WidgetUWidget:SetActive(false)
		self.view.widget:TryChangePage("WorkState", 1)
		self.view.workInfo:TryChangePage("WorkState", 1)
		ClientTextUtils.setText(self.type1rateText, "0%")
		ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_FORMULA"))

		self.statePaused = true
	else
		local formulaId = facilityInfo.formulaId
		local formulaData = HomelandFormulaData[formulaId] or {}
		local isPet = false

		if formulaData.pet then
			isPet = true

			LuaUIUtils.renderPetItemSimple(self.type1PetHeadUButton, {
				label = 0,
				petId = formulaData.pet
			})

			self.type1PetHeadUButton.draggable = false

			local petCfg = PetData[formulaData.pet]
			local petName = petCfg and pg.getLocalizationText(petCfg.name) or ""

			self.type1PetHeadUButton.enabledTooltip = true

			function self.type1PetHeadUButton.luaRenderTooltip(btn, cmp)
				local ref = cmp:GetComponent("ObjectReference")
				local txtNameUSDFText = ref:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("HOME_PET_FAMILY_WORK_TIPS"), petName))
			end

			self.type1PetInfoUWidget:SetActive(true)
			self.type1FormulaInfoUWidget:SetActive(false)
		else
			self.type1PetInfoUWidget:SetActive(false)
			self.type1FormulaInfoUWidget:SetActive(true)
		end

		if not formulaData.consumable1 and not isPet then
			self.type1expandBtn:SetActive(false)
			self.view.widget:TryChangePage("expand", 0)
		else
			self.type1expandBtn:SetActive(true)

			if self.isExpand then
				self.view.widget:TryChangePage("expand", 1)
				self:setConsumableAndOutputList(formulaId, isPet)
			else
				self.view.widget:TryChangePage("expand", 0)
			end
		end

		local outputItemId, outputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		if outputItemId then
			local itemData = ItemData[outputItemId]

			ClientTextUtils.setText(self.type1stateName, pg.getLocalizationText(itemData.itemName))
		else
			ClientTextUtils.setText(self.type1stateName, "")
		end

		local facilityState = facilityInfo.facilityState
		local operateInfo = HomelandOperateData[facilityState] or {}

		self.type1icon.url = self:getOperateIcon(operateInfo, facilityInfo)

		self.type1WidgetUWidget:SetActive(true)

		local outputNum = self:getOutputNum(facilityInfo)

		if outputNum > 0 then
			self.type1numBgUWidget:SetActive(true)
			ClientTextUtils.setText(self.type1countText, outputNum)
		else
			self.type1numBgUWidget:SetActive(false)
		end

		self:refreshEnvRequireInfo()

		local facilityStateInfo = facilityInfo.facilityStateInfo

		self.statePaused = false

		local isElectricType = self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq

		if self.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
			isElectricType = self.ornamentInfo.electricMode
		end

		if facilityInfo.disable then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_PAUSING"))

			self.type1warnIcon.url = AddressDataConst.HOME_FACILITY_PAUSE_ICON
			self.statePaused = true
		elseif facilityInfo.envWorkRatio <= 0 and isElectricType then
			self:refreshEnvStateWarning()

			self.statePaused = true
		elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH"))

			self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.UNDER_CONSUME]
			self.statePaused = true
		elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_ITEM_NEED_TRANSPORT"))

			self.statePaused = true
		elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD and not self:checkHasEntDoingOper(self.ornamentId, facilityState) then
			ClientTextUtils.setText(self.type1warnText, pg.getGameString("HOMELAND_NO_WORKLOAD"))

			self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.NO_WORKLOAD]
			self.statePaused = true
		end

		self.view.workInfo:TryChangePage("TextType", 0)

		if self.statePaused then
			self.type1timeUWidget:SetActive(false)
			self.view.widget:TryChangePage("WorkState", 1)
			self.view.workInfo:TryChangePage("WorkState", 1)
			ClientTextUtils.setText(self.type1rateText, "0%")
		else
			self.view.widget:TryChangePage("WorkState", 0)
			self.view.workInfo:TryChangePage("WorkState", 0)
			self:updateTotalWorkRate(facilityInfo)
		end

		self:updateProgress(facilityInfo)
	end

	local ornamentEnvInfo = self.entity:getOrnamentEnvInfo()
	local envNotSatisfied = false

	if Utils.checkNeedEnvRequire(facilityInfo) then
		if HomelandFormulaData[facilityInfo.formulaId].forceEnvRequire then
			envNotSatisfied = self.tempRequireType and ornamentEnvInfo.temperature ~= self.tempRequireType or self.lightRequireType and ornamentEnvInfo.light ~= self.lightRequireType
		else
			local tempNotSatisfied = self.tempRequireType and math.abs(ornamentEnvInfo.temperature - self.tempRequireType) > 2
			local lightNotSatisfied = self.lightRequireType and math.abs(ornamentEnvInfo.light - self.lightRequireType) > 2

			envNotSatisfied = tempNotSatisfied or lightNotSatisfied
		end
	end

	if envNotSatisfied then
		ClientTextUtils.setText(self.type1warnText, pg.getGameString("ENV_NOT_VALID"))

		self.type1warnIcon.url = ClientConst.HomelandWarnIcon[ClientConst.HOMELAND_EXTRA_STATES.ENV_INVALID]
	end

	self.view.workInfo:TryChangePage("Buff", (not self.statePaused or envNotSatisfied) and 0 or 1)
	self:refreshBuffList(facilityInfo, self.type1buffList)
end

function HomelandFacilityInfoCtrl:refreshEnvRequireInfo()
	self.electricWorkRatio = nil
	self.lightWorkRatio = nil
	self.lightRequireType = nil
	self.tempWorkRatio = nil
	self.tempRequireType = nil

	if Utils.checkIsElectricReqType(self.entity.homeFacilityType, self.ornamentInfo.electricMode) then
		self.electricWorkRatio = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Electric)
	elseif self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
		self.lightWorkRatio, self.lightRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
		self.tempWorkRatio, self.tempRequireType = self.entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)
	end
end

function HomelandFacilityInfoCtrl:checkHasEntDoingOper(ornamentId, operId)
	for playerId, playerOperInfo in pairs(pg.space.playerAllocation) do
		if playerOperInfo.ornamentId == self.ornamentId and playerOperInfo.opId == operId then
			return true
		end
	end

	local relatedPets = pg.space.facilityAllocationInfo[ornamentId]

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if allocation and allocation.opId == operId then
				return true
			end
		end
	end

	return false
end

function HomelandFacilityInfoCtrl:getOutputNum(facilityInfo)
	local outputNum = 0

	for itemId, num in pairs(facilityInfo.outputMap) do
		outputNum = outputNum + num
	end

	outputNum = outputNum + HomeLandUtils.sumSpecialOutput(facilityInfo)

	return outputNum
end

function HomelandFacilityInfoCtrl:getOperateIcon(operateInfo, facilityInfo)
	local topLogoIconType = operateInfo.topLogoIconType or ClientConst.HomelandTopLogoIconType.Default

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Default then
		return operateInfo.topLogoIcon or ""
	end

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Output or topLogoIconType == ClientConst.HomelandTopLogoIconType.OutputSpecial then
		local formulaId = facilityInfo.formulaId
		local formulaData = HomelandFormulaData[formulaId] or {}
		local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		return LuaUIUtils.getIconByItemId(defaultOutputItem)
	end

	return nil
end

function HomelandFacilityInfoCtrl:onTick()
	if not pg.me or not pg.me.space then
		return
	end

	self.facilityInfo = self:getFacilityInfo()
	self.ornamentInfo = self:getOrnamentInfo()

	self:refreshStateInfo()
	self:updatePetListVisible()
	self:refreshHomeAbilityRecommend()
end

function HomelandFacilityInfoCtrl:updateProgress(updateInfo)
	if self.isHatchBox then
		self:updateProgress_IsHatchBox(updateInfo)
	else
		self:updateProgress_NotHatchBox(updateInfo)
	end
end

function HomelandFacilityInfoCtrl:updateProgress_IsHatchBox(hatchBoxInfo)
	if hatchBoxInfo and hatchBoxInfo.item then
		self.type1progress:SetActive(true)
		self.type1progress:TryChangePage("State", 0)

		local proRatio = HomeLandUtils.getHatchBoxProgressRatio(hatchBoxInfo)

		self.type1progress.maxValue = 1
		self.type1progress.value = proRatio

		local leftSecond = HomeLandUtils.getHatchBoxHatchedLeftSecond(hatchBoxInfo)

		self.type1timeUWidget:SetActive(leftSecond > 0)

		if leftSecond > 0 then
			ClientTextUtils.setText(self.type1timeText, LuaUIUtils.getCountDownString(leftSecond, UIConst.TimeType.Short, true))
		end
	else
		self.type1progress:SetActive(false)
		self.type1timeUWidget:SetActive(false)
	end
end

function HomelandFacilityInfoCtrl:updateProgress_NotHatchBox(facilityInfo)
	local facilityStateInfo = facilityInfo.facilityStateInfo

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		local leftWorkload = math.max(facilityStateInfo.totalValue - facilityStateInfo.curValue, 0)

		self.type1progress.maxValue = facilityStateInfo.totalValue
		self.type1progress.value = math.min(facilityStateInfo.curValue, facilityStateInfo.totalValue)

		local curWorkload = self:calcCurrWorkload(facilityInfo)

		if curWorkload > 0 then
			self.type1timeUWidget:SetActive(true)

			local leftTime = leftWorkload / curWorkload * 60
			local timeStr = LuaUIUtils.getCountDownString(leftTime, UIConst.TimeType.Short, true)

			ClientTextUtils.setText(self.type1timeText, timeStr)
		else
			self.type1timeUWidget:SetActive(false)
		end
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		self.type1progress.maxValue = facilityStateInfo.totalValue

		local curValue = facilityStateInfo.curValue

		if facilityStateInfo.startTs ~= 0 then
			curValue = facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)
		end

		local leftTs = math.max(facilityStateInfo.totalValue - curValue, 0)

		self.type1progress.value = math.min(curValue, facilityStateInfo.totalValue)

		local timeStr = LuaUIUtils.getCountDownString(leftTs, UIConst.TimeType.Short, true)

		ClientTextUtils.setText(self.type1timeText, timeStr)
		ClientTextUtils.setText(self.type1FormulaTimeText, timeStr)
	elseif facilityInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		-- block empty
	end

	self.type1progress:SetActive(true)
	self.type1progress:TryChangePage("State", self.workloadState)
	self.type1HighImage:SetImgFillAmount(self.type1progress.value / self.type1progress.maxValue)
end

function HomelandFacilityInfoCtrl:calcCurrWorkload(facilityInfo)
	local facilityState = facilityInfo.facilityState
	local workLoad = 0
	local relatedPets = pg.space.facilityAllocationInfo[self.ornamentId]

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if allocation.opId == facilityState then
				workLoad = workLoad + allocation.workload
			end
		end
	end

	return workLoad
end

function HomelandFacilityInfoCtrl:onFacilityAllocateChanged(ornamentId)
	if not self.view then
		return
	end

	if ornamentId == self.ornamentId then
		self:refreshPetList()
	end
end

function HomelandFacilityInfoCtrl:updatePetListVisible()
	local petListVisible = false
	local petPanelText
	local showRecommend = false

	if not self.isHatchBox then
		local facilityInfo = self:getFacilityInfo()

		if facilityInfo then
			if facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
				showRecommend = true

				if not self:checkHasEntDoingOper(self.ornamentId, facilityInfo.facilityState) then
					petListVisible = false

					if facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
						petPanelText = pg.getGameString("HOME_WAREHOUSE_INSUFFICIENT_ITEM_TIPS")
					elseif HomelandFormulaData[facilityInfo.formulaId].pet == nil then
						local homeAbilityId, homeAbilityLevel = HomelandOperateData[facilityInfo.facilityState].homeAbility[1], HomelandOperateData[facilityInfo.facilityState].homeAbility[2]
						local textColor = HomeAbilityData[homeAbilityId].iconColor
						local homeAbilityName = string.format("<color=%s>%s</color>", textColor, pg.getLocalizationText(HomeAbilityData[homeAbilityId].name))

						homeAbilityLevel = string.format("<color=%s>%s</color>", textColor, homeAbilityLevel)
						petPanelText = string.format(pg.getGameString("HOME_FACILITY_RECOMMEND_PET_ABILITY"), homeAbilityName, homeAbilityLevel)
					else
						local petId = HomelandFormulaData[facilityInfo.formulaId].pet
						local petName = pg.getLocalizationText(PetProtoTypeData[petId].name)

						petPanelText = string.format(pg.getGameString("HOME_FACILITY_RECOMMEND_PET_NAME"), petName)
					end
				else
					petListVisible = true
				end
			else
				petListVisible = false
				petPanelText = pg.getGameString("WORK_NOT_REQUIRED")
			end

			if facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
				petPanelText = pg.getGameString("HOMELAND_ITEM_NEED_TRANSPORT_WARN")
			end
		else
			petListVisible = false
		end
	else
		petPanelText = pg.getGameString("HATCH_PET_CANT_WORK")
	end

	self.petListVisible = petListVisible

	self.view.recommendUWidget:SetActive(showRecommend)
	self.view.petPanelUComponent:TryChangePage("Empty", petListVisible and 0 or 1)
	self.view.listPet:SetActive(petListVisible)
	ClientTextUtils.setText(self.view.petPanelTextUSDFText, petPanelText)
end

function HomelandFacilityInfoCtrl:renderPetItem(button, index, data)
	if data.tIndex == 1 then
		local objectReference = button:GetComponent("ObjectReference")
		local imgAddUImage = objectReference:GetRefValue("imgAddUImage")
		local petCharUComponent = objectReference:GetRefValue("petCharUComponent")

		imgAddUImage:SetActive(false)
		petCharUComponent:SetActive(false)

		return
	end

	LuaUIUtils.renderHomePetHead(button, data)

	button.draggable = false
	button.interactable = false
end

function HomelandFacilityInfoCtrl:getRequireAbilityInfo()
	if not self.facilityInfo then
		return nil
	end

	return Utils.getHomePetTimeWorkloadAbilityLevel(self.facilityInfo.facilityState)
end

function HomelandFacilityInfoCtrl:updateTotalWorkRate(facilityInfo)
	local facilityState = facilityInfo.facilityState
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local relatedPets = pg.space.facilityAllocationInfo[self.ornamentId]
	local workloadRate = 0

	if self.statePaused then
		workloadRate = 0
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		local curWorkload = 0

		if relatedPets then
			for _, petId in ipairs(relatedPets) do
				local allocation = pg.me.space.allocation[petId]

				if allocation.opId == facilityState then
					curWorkload = curWorkload + allocation.workload
				end
			end
		end

		local homeEntInfo = HomeObjectData[self.homeTemplateId] or {}
		local maxPetCount = homeEntInfo.maxPetCount or 0

		workloadRate = curWorkload / (Utils.calcDefaultHomePetTimeWorkload(facilityState) * maxPetCount)
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		-- block empty
	else
		workloadRate = 1
	end

	workloadRate = workloadRate * facilityInfo.envWorkRatio

	ClientTextUtils.setText(self.type1rateText, string.format("%s%%", math.floor(workloadRate * 100)))

	self.workloadRate = workloadRate

	if workloadRate == 0 then
		self.workloadState = WorkState.Stop
	elseif workloadRate > 0 and workloadRate < 1 then
		self.workloadState = WorkState.Low
	elseif workloadRate == 1 then
		self.workloadState = WorkState.Normal
	elseif workloadRate > 1 then
		self.workloadState = WorkState.High
	end
end

function HomelandFacilityInfoCtrl:refreshRecommend()
	local facilityId = Utils.getHomeObjectFacilityId(self.homeTemplateId)

	self.hasAccessRecommend = false

	if not facilityId then
		self.view.accessList:SetList({})
	else
		local facilityInfo = HomelandFacilityData[facilityId] or {}

		if facilityInfo.personalityDes then
			self.hasAccessRecommend = true

			local personalityList = {}

			table.insert(personalityList, {
				templateId = facilityInfo.personalityDes
			})
			self.view.accessList:SetList(personalityList)
		else
			self.view.accessList:SetList({})
		end
	end
end

function HomelandFacilityInfoCtrl:refreshHomeAbilityRecommend()
	self.hasAbilityRecommend = false

	local requireAbilityId, petAbilityLevel = self:getRequireAbilityInfo()

	if requireAbilityId then
		self.hasAbilityRecommend = true

		self.view.homeAbilityUWidget:SetActive(true)
		LuaUIUtils.renderHomeAbility(self.view.homeAbilityItem, requireAbilityId, petAbilityLevel, true)
	else
		self.view.homeAbilityUWidget:SetActive(false)
	end

	self.view.recommendText:SetActive(self.hasAbilityRecommend or self.hasAccessRecommend)
end

function HomelandFacilityInfoCtrl:refreshPetList()
	self:updatePetListVisible()

	if not self.petListVisible then
		return
	end

	local relatedPets = pg.space.facilityAllocationInfo[self.ornamentId]

	table.clear(self.petList)

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if not Const.HOMELAND_IGNORE_WORK_TYPE[allocation.opId] then
				local pet = pg.me.pets[petId]
				local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

				petInfo.opId = allocation.opId
				petInfo.facilityType = self.facilityType
				petInfo.facilityInfo = self.facilityInfo
				petInfo.fitPersonality = allocation.fitTalent
				petInfo.petId = petId
				petInfo.workload = allocation.workload
				petInfo.isWorking = true
				petInfo.tIndex = 0

				table.insert(self.petList, petInfo)
			end
		end
	end

	local homeEntInfo = HomeObjectData[self.homeTemplateId] or {}
	local maxPetCount = homeEntInfo.maxPetCount or 0
	local curCount = #self.petList

	for i = curCount + 1, maxPetCount do
		table.insert(self.petList, {
			tIndex = 1
		})
	end

	self.view.listPet:SetList(self.petList)
end

function HomelandFacilityInfoCtrl:renderBuffItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")

	ClientTextUtils.setText(numLevelUSDFText, data.requireRate and math.abs(data.requireRate) or "")

	if data.isElectric then
		button:TryChangePage("Type", 0)

		if data.electricWorkRatio == 0 then
			button:TryChangePage("Condition", 2)
		elseif data.electricWorkRatio > 0 and data.electricWorkRatio < 1 then
			button:TryChangePage("Condition", 0)
		elseif data.electricWorkRatio >= 1 then
			button:TryChangePage("Condition", 1)
		end
	elseif data.isLight then
		button:TryChangePage("Type", 2)

		if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
			if HomelandFormulaData[self.facilityInfo.formulaId].forceEnvRequire then
				button:TryChangePage("Condition", self.lightWorkRatio == 0 and 2 or 3)
			elseif self.lightWorkRatio == 0 then
				button:TryChangePage("Condition", 2)
			elseif self.lightWorkRatio > 0 and self.lightWorkRatio < 1 then
				button:TryChangePage("Condition", 0)
			elseif self.lightWorkRatio >= 1 then
				button:TryChangePage("Condition", 1)
			end
		end
	elseif data.isTemperature then
		button:TryChangePage("Type", data.requireRate > 0 and 1 or 3)

		if self.entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
			if HomelandFormulaData[self.facilityInfo.formulaId].forceEnvRequire then
				button:TryChangePage("Condition", self.tempWorkRatio == 0 and 2 or 3)
			elseif self.tempWorkRatio == 0 then
				button:TryChangePage("Condition", 2)
			elseif self.tempWorkRatio > 0 and self.tempWorkRatio < 1 then
				button:TryChangePage("Condition", 0)
			elseif self.tempWorkRatio >= 1 then
				button:TryChangePage("Condition", 1)
			end
		end
	end
end

function HomelandFacilityInfoCtrl:refreshBuffList(facilityInfo, buffList)
	if not self.buffDataList then
		self.buffDataList = {}
	else
		table.clear(self.buffDataList)
	end

	if Utils.checkNeedEnvRequire(facilityInfo) then
		if self.electricWorkRatio then
			local requireInfo = {
				isElectric = true,
				electricWorkRatio = self.electricWorkRatio
			}

			table.insert(self.buffDataList, requireInfo)
		end

		local temperatureRequire = HomelandFormulaData[facilityInfo.formulaId].temperatureRequire
		local lightRequire = HomelandFormulaData[facilityInfo.formulaId].lightRequire

		if temperatureRequire then
			local requireInfo = {
				isTemperature = true,
				tIndex = 0,
				requireRate = temperatureRequire
			}

			table.insert(self.buffDataList, requireInfo)
		end

		if lightRequire then
			local requireInfo = {
				isLight = true,
				tIndex = 0,
				requireRate = lightRequire
			}

			table.insert(self.buffDataList, requireInfo)
		end
	end

	buffList:SetList(self.buffDataList)
end

return HomelandFacilityInfoCtrl
