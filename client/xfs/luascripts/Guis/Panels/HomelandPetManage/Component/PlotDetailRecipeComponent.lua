-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotDetailRecipeComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlotDetailRecipeComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotDetailRecipeComponent = Class.LightClass("PlotDetailRecipeComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local ItemData = require("Data.item_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandUpgradeData = require("Data.home_upgrade_data")

function PlotDetailRecipeComponent:findObjects()
	return
end

function PlotDetailRecipeComponent:initView()
	self.selectFormulaId = nil
	self.formulaId = nil
	self.ornamentInfo = nil
	self.isMultipleMode = false

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:updatePlotDetailRecipe(self.ornamentInfo)
		self:resetRecipeState()
	end)
end

function PlotDetailRecipeComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.iconProductUImage = objectReference:GetRefValue("iconProductUImage")
	self.productUComponent = objectReference:GetRefValue("productUComponent")
	self.progressUComponent = objectReference:GetRefValue("progressUComponent")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	self.listRecipeUList = objectReference:GetRefValue("listRecipeUList")
	self.txtInfoUSDFText = objectReference:GetRefValue("txtInfoUSDFText")
	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.txtSelectAllUSDFText = objectReference:GetRefValue("txtSelectAllUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnCleanUButton = objectReference:GetRefValue("btnCleanUButton")
	self.btnBatchUButton = objectReference:GetRefValue("btnBatchUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtChooseUSDFText = objectReference:GetRefValue("txtChooseUSDFText")
	self.txtAcceptUSDFText = objectReference:GetRefValue("txtAcceptUSDFText")
	self.btnExitUButton = objectReference:GetRefValue("btnExitUButton")
	self.txtExitUSDFText = objectReference:GetRefValue("txtExitUSDFText")
	self.txtFinishUSDFText = objectReference:GetRefValue("txtFinishUSDFText")
end

function PlotDetailRecipeComponent:addListener()
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("HOMELAND_PLOT_NOT_FORMULA"))
	ClientTextUtils.setText(self.txtAcceptUSDFText, pg.getGameString("HOMELAND_PLOT_CONFIRM_CHANGES"))
	ClientTextUtils.setText(self.txtChooseUSDFText, pg.getGameString("HOMELAND_PLOT_BATCH_COVERAGE"))
	ClientTextUtils.setText(self.txtExitUSDFText, pg.getGameString("HOMELAND_PLOT_EXIT_BATCH"))
	ClientTextUtils.setText(self.txtSelectAllUSDFText, pg.getGameString("HOMELAND_PLOT_SELECT_ALL"))

	function self.btnCleanUButton.luaClick()
		if not pg.game.home:tryShowChangeFormulaConfirm(self.ornamentInfo.ornamentId, function()
			pg.me.space:removeHomelandProduce(self.ornamentInfo.ornamentId, self.formulaId)
		end) then
			pg.me.space:removeHomelandProduce(self.ornamentInfo.ornamentId, self.formulaId)
		end
	end

	function self.btnConfirmUButton.luaClick()
		if not self.selectFormulaId or self.unlockLocked or self.levelLocked or not HomeLandUtils.isHomelandFormulaTimeValid(self.selectFormulaId) then
			return
		end

		if self.isMultipleMode then
			self:confirmMultipleMode()
		else
			local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
			local facilityData = HomelandFacilityData[facilityId]

			if self.selectFormulaId == self.formulaId then
				-- block empty
			elseif not pg.game.home:tryShowChangeFormulaConfirm(self.ornamentInfo.ornamentId, function()
				pg.me.space:setHomelandProduce(self.ornamentInfo.ornamentId, self.selectFormulaId)
			end) then
				pg.me.space:setHomelandProduce(self.ornamentInfo.ornamentId, self.selectFormulaId)
			end
		end
	end

	function self.listRecipeUList.luaRenderItem(button, index, data)
		self:refreshLevelFormulaInfo(button, data)
	end

	function self.btnAllSelectedUButton.luaClick()
		local selectAll = self.btnAllSelectedUButton.isSelected

		self.ctrl:selectAllMultiple(not selectAll, true)
	end

	function self.btnExitUButton.luaClick()
		self:resetRecipeState()
		self.ctrl:exitMultipleMode()
		self:changeUseButtonMode()
	end

	function self.btnBatchUButton.luaClick()
		local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
		local facilityData = HomelandFacilityData[facilityId]

		if not self.selectFormulaId then
			-- block empty
		else
			local formulaData = HomelandFormulaData[self.selectFormulaId]
			local formulaItemId = formulaData.previewItemId or HomeLandUtils.getDisplayOutputItemId(formulaData)
			local formulaName = pg.getLocalizationText(ItemData[formulaItemId].itemName)

			ClientTextUtils.setText(self.txtInfoUSDFText, pg.getFormatText(pg.getGameString("HOMELAND_PLOT_BATCH_TIPS"), formulaName))

			self.isMultipleMode = true

			self.uWidget.content:TryChangePage("BatchCover", 1)
			self.btnCleanUButton:SetActive(false)
			self.ctrl:startMultipleMode(self.selectFormulaId)
		end

		self:changeUseButtonMode()
	end

	function self.levelFormulaRenderFunc(item, index, data)
		self:rendererFormulaItem(item, index, data)
	end
end

function PlotDetailRecipeComponent:changeUseButtonMode(num)
	if not self.ornamentInfo or not self.uWidget:CheckURLLoaded() then
		return
	end

	local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
	local facilityData = HomelandFacilityData[facilityId]
	local formulaList = self.model:getFinalFormulaList(self.ornamentInfo.ornamentId, facilityData)
	local canUseBatchBtn = true
	local canConfirmBtn = true

	if not self.selectFormulaId then
		canUseBatchBtn = false
	elseif self.unlockLocked or self.levelLocked or not table.contains(formulaList, self.selectFormulaId) or not HomeLandUtils.isHomelandFormulaTimeValid(self.selectFormulaId) then
		canUseBatchBtn = false
	end

	num = num or 1

	if self.isMultipleMode then
		if num <= 0 then
			canConfirmBtn = false
		end
	elseif self.selectFormulaId == self.formulaId then
		canConfirmBtn = false
	end

	self.btnConfirmUButton.interactable = canUseBatchBtn and canConfirmBtn
	self.btnBatchUButton.interactable = canUseBatchBtn
end

function PlotDetailRecipeComponent:confirmMultipleMode()
	local multipleTable, multipleCount = self.ctrl:getMultipleOrnamentTableAndCount()

	if multipleCount <= 0 or not multipleTable then
		-- block empty
	else
		local needShow = false
		local newMultipleTable = {}

		for ornamentId, _ in pairs(multipleTable) do
			newMultipleTable[ornamentId] = true

			local multipleFacilityInfo = pg.space.facility[ornamentId]

			if multipleFacilityInfo then
				if multipleFacilityInfo.formulaId == self.selectFormulaId then
					newMultipleTable[ornamentId] = nil
				elseif Utils.checkReturnHomeProduceCost(multipleFacilityInfo) then
					needShow = true
				end
			end
		end

		if needShow then
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_RET_CONFIRM_DESC1"), function()
				self:confirmMultipleRPC(newMultipleTable)
			end)
		else
			self:confirmMultipleRPC(newMultipleTable)
		end
	end
end

function PlotDetailRecipeComponent:confirmMultipleRPC(newMultipleTable)
	for ornamentId, _ in pairs(newMultipleTable) do
		pg.me.space:setHomelandProduce(ornamentId, self.selectFormulaId)
	end

	self:resetRecipeState()
	self.ctrl:exitMultipleMode()
	self:changeUseButtonMode()
end

function PlotDetailRecipeComponent:refreshMultipleNumText(num, maxCount)
	num = num or 0

	ClientTextUtils.setText(self.txtTipsUSDFText, ClientTextUtils.concatByLanguage(pg.getGameString("PET_MANAGEMENT_CHOOSE"), num))
	self:changeUseButtonMode(num)

	if maxCount then
		self.btnAllSelectedUButton.isSelected = maxCount <= num
	end
end

function PlotDetailRecipeComponent:setSelectFormula(data)
	self.selectFormulaId = data.formulaId
	self.unlockLocked = data.unlockLocked
	self.levelLocked = data.isLocked

	self.listRecipeUList:RefreshList()
	self:changeUseButtonMode()
end

function PlotDetailRecipeComponent:refreshLevelFormulaInfo(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local textLockUSDFText = objectReference:GetRefValue("textLockUSDFText")
	local countDown = objectReference:GetRefValue("countDownUCountDown")

	countDown:Stop()

	if data.periodType then
		button:TryChangePage("Type", data.periodType)
	else
		button:TryChangePage("Type", 0)
	end

	if data.timePeriodId then
		local formulaItem = data.formulaList and data.formulaList[1]
		local _, endTime = HomeLandUtils.getHomelandFormulaValidTimeRange(formulaItem.formulaId)
		local remainTime = endTime and endTime - Time.getSecond() or 0

		if remainTime > 0 then
			local d = ClientTextUtils.getGameString("DAY")
			local h = ClientTextUtils.getGameString("HOUR")
			local m = ClientTextUtils.getGameString("MINUTE")

			if remainTime > Const.SECONDS_ONE_DAY then
				countDown.formatText = string.format("{0}%s{1}%s", d, h)
			else
				countDown.formatText = string.format("{1}%s{2}%s", h, m)
			end

			countDown:Play(remainTime)
		end

		button.name = "TimePeriod" .. data.timePeriodId

		ClientTextUtils.setText(textUSDFText, data.name and pg.getLocalizationText(data.name) or "")
	else
		button.name = "Level" .. data.level

		local levelTextInfo = pg.getFormatText(pg.getGameString("HOME_FORMULA_LEVEL"), data.level)

		ClientTextUtils.setText(textUSDFText, levelTextInfo)
	end

	if data.isLocked then
		button:TryChangePage("Locked", 1)

		local facilityType = Utils.getHomeOrnamentCurLevelInfo(self.ornamentInfo.homeId)
		local upgradeInfo = facilityType and HomelandUpgradeData[facilityType]
		local homeLevel = 1

		if upgradeInfo then
			local levelInfo = upgradeInfo[data.level]

			if levelInfo then
				homeLevel = levelInfo.homeLevel or 1
			end
		end

		local lockTextInfo = pg.getFormatText(pg.getGameString("HOME_LEVEL_LOCK_INFO"), homeLevel, data.level)

		ClientTextUtils.setText(textLockUSDFText, lockTextInfo)
	else
		button:TryChangePage("Locked", 0)
	end

	listUList.luaRenderItem = self.levelFormulaRenderFunc

	listUList:SetList(data.formulaList)
end

function PlotDetailRecipeComponent:initFormulaListInfo(ornamentInfo)
	if not ornamentInfo then
		return
	end

	self.formulaListInfo = self.model:getFormulaListInfo(ornamentInfo.ornamentId, ornamentInfo.homeId)

	self.listRecipeUList:SetList(self.formulaListInfo)
	self:changeUseButtonMode()
end

function PlotDetailRecipeComponent:updatePlotDetailRecipe(ornamentInfo, forceRefresh)
	if not ornamentInfo then
		return
	end

	local oldOrnamentInfo = self.ornamentInfo

	self.ornamentInfo = ornamentInfo

	if not self.uWidget:CheckURLLoaded() then
		return
	end

	local facilityInfo = pg.me.space.facility[self.ornamentInfo.ornamentId]

	if not facilityInfo or facilityInfo.facilityState == 0 then
		self.productUComponent:TryChangePage("MainState", 0)
	else
		self.productUComponent:TryChangePage("MainState", 1)

		local formulaId = facilityInfo.formulaId
		local formulaData = HomelandFormulaData[formulaId] or {}
		local outputItemId, outputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		if outputItemId then
			local itemData = ItemData[outputItemId]

			ClientTextUtils.setText(self.txtNameUSDFText, pg.getLocalizationText(itemData.itemName))
		else
			ClientTextUtils.setText(self.txtNameUSDFText, "")
		end

		local facilityState = facilityInfo.facilityState
		local operateInfo = HomelandOperateData[facilityState] or {}

		self.iconProductUImage.url = self.model:getOperateIcon(operateInfo, facilityInfo)

		self:updateRecipeProgress(self.ornamentInfo)
	end

	local facilityData = GlobalData.Space.facility[self.ornamentInfo.ornamentId] or {}

	self.formulaId = facilityData.formulaId

	if not self.formulaListInfo or self.ornamentInfo ~= oldOrnamentInfo or forceRefresh then
		self.selectFormulaId = self.formulaId
		self.unlockLocked = false
		self.levelLocked = false

		self:initFormulaListInfo(self.ornamentInfo)
	end
end

function PlotDetailRecipeComponent:refreshPlotDetailRecipe(ornamentInfo, forceRefresh)
	self:updatePlotDetailRecipe(ornamentInfo, forceRefresh)
	self:changeUseButtonMode()
end

function PlotDetailRecipeComponent:updateRecipeProgress(ornamentInfo)
	if not ornamentInfo then
		return
	end

	local facilityInfo = pg.me.space.facility[ornamentInfo.ornamentId]
	local facilityStateInfo = facilityInfo.facilityStateInfo

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		local leftWorkload = math.max(facilityStateInfo.totalValue - facilityStateInfo.curValue, 0)

		self.progressUComponent.maxValue = facilityStateInfo.totalValue
		self.progressUComponent.value = math.min(facilityStateInfo.curValue, facilityStateInfo.totalValue)

		local curWorkload = self.model:calcCurrWorkload(ornamentInfo.ornamentId)

		if curWorkload > 0 then
			local leftTime = leftWorkload / curWorkload * 60

			ClientTextUtils.setText(self.txtTimeUSDFText, LuaUIUtils.getCountDownString(leftTime, UIConst.TimeType.Short, true))
		end
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		self.progressUComponent.maxValue = facilityStateInfo.totalValue

		local curValue = facilityStateInfo.curValue

		if facilityStateInfo.startTs ~= 0 then
			curValue = facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)
		end

		local leftTs = math.max(facilityStateInfo.totalValue - curValue, 0)

		self.progressUComponent.value = math.min(curValue, facilityStateInfo.totalValue)

		ClientTextUtils.setText(self.txtTimeUSDFText, LuaUIUtils.getCountDownString(leftTs, UIConst.TimeType.Short, true))
	elseif facilityInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		-- block empty
	end

	self.progressUComponent:SetActive(true)

	local hasEntDoingOper = self.model:checkHasEntDoingOper(ornamentInfo.ornamentId)
	local statePaused = self.model:getStatePaused(facilityInfo, ornamentInfo.ornamentId)
	local workloadRate = Utils.getFacilityCurWorkRate(facilityInfo, ornamentInfo.homeId, ornamentInfo.ornamentId, statePaused)
	local workloadState = self.model:getProgressWorkloadState(hasEntDoingOper, workloadRate)

	self.progressUComponent:TryChangePage("State", workloadState)

	if workloadState == 1 then
		self.productUComponent:TryChangePage("MainState", 2)

		local warningText = self:getWarningText(ornamentInfo)
		local text = pg.getFormatText("<style=Debuff>{0}</style>", warningText)

		ClientTextUtils.setText(self.txtFinishUSDFText, text)
	end
end

function PlotDetailRecipeComponent:getWarningText(ornamentInfo)
	if not ornamentInfo then
		return
	end

	local facilityInfo = pg.me.space.facility[ornamentInfo.ornamentId]
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityType = Utils.getHomeFacilityType(ornamentInfo.homeId)
	local isElectricType = Utils.checkIsElectricReqType(facilityType, ornamentInfo.electricMode)
	local warningText = ""

	if facilityInfo.disable then
		warningText = pg.getGameString("HOMELAND_PAUSING")
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
		warningText = pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH")
	elseif facilityInfo.envWorkRatio <= 0 and isElectricType then
		local ornamentEnvInfo = pg.me.space.ornamentEnvMap[ornamentInfo.ornamentId]
		local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo or {}
		local linkValid = false

		for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
			local linkInfo = pg.space.homeLinkMap[refEnvOrnamentId]

			if linkInfo and linkInfo.groupId ~= 0 then
				linkValid = true
			end
		end

		if linkValid then
			warningText = pg.getGameString("HOMELAND_NO_ELECTRIC")
		else
			warningText = pg.getGameString("HOMELAND_NO_ELECTRIC_LINK")
		end
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
		warningText = pg.getGameString("HOMELAND_ITEM_NEED_TRANSPORT")
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD and not self.model:checkHasEntDoingOper(ornamentInfo.ornamentId) then
		warningText = pg.getGameString("HOMELAND_NO_WORKLOAD")
	end

	local ornamentEnvInfo = pg.space.ornamentEnvMap[ornamentInfo.ornamentId]
	local envNotSatisfied = false

	if Utils.checkNeedEnvRequire(facilityInfo) then
		local entity = pg.game.home:getHomeEntity(ornamentInfo.ornamentId)

		if entity then
			local lightWorkRatio, lightRequireType = entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light)
			local tempWorkRatio, tempRequireType = entity:getEnvRequireWorkRatio(ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature)
			local formulaInfo = HomelandFormulaData[facilityInfo.formulaId]

			if formulaInfo and formulaInfo.forceEnvRequire then
				envNotSatisfied = tempRequireType and ornamentEnvInfo.temperature ~= tempRequireType or lightRequireType and ornamentEnvInfo.light ~= lightRequireType
			else
				local tempNotSatisfied = tempRequireType and math.abs(ornamentEnvInfo.temperature - tempRequireType) > 2
				local lightNotSatisfied = lightRequireType and math.abs(ornamentEnvInfo.light - lightRequireType) > 2

				envNotSatisfied = tempNotSatisfied or lightNotSatisfied
			end
		end
	end

	if envNotSatisfied then
		warningText = pg.getGameString("ENV_NOT_VALID")
	end

	return warningText
end

function PlotDetailRecipeComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PlotDetailRecipeComponent:resetRecipeState()
	self.btnCleanUButton:SetActive(true)

	self.btnAllSelectedUButton.isSelected = false
	self.isMultipleMode = false

	self.uWidget.content:TryChangePage("BatchCover", 0)
end

function PlotDetailRecipeComponent:onEnterPage()
	if not self.uWidget:CheckURLLoaded() then
		return
	end

	self:resetRecipeState()
	self.listRecipeUList:RefreshList()
end

function PlotDetailRecipeComponent:rendererFormulaItem(item, index, data)
	if data.formulaId == self.selectFormulaId then
		item.isSelected = true
	else
		item.isSelected = false
	end

	local objectReference = item:GetComponent("ObjectReference")
	local imgMaskLockUWidget = objectReference:GetRefValue("imgMaskLockUWidget")
	local homeMarketTagUContainer = objectReference:GetRefValue("homeMarketTagUContainer")

	if imgMaskLockUWidget then
		imgMaskLockUWidget:SetActive(data.unlockLocked)
	end

	LuaUIUtils.renderRewardItem(item, data.previewItemInfo)

	local isOrderItem = HomeLandUtils.isHomeOrderItem(data.previewItemInfo.id)

	if isOrderItem and not homeMarketTagUContainer:CheckURLLoaded() then
		homeMarketTagUContainer:LoadDefaultUrlManually()
	end

	homeMarketTagUContainer:SetActive(isOrderItem)

	item.draggable = false
	item.name = data.formulaId

	function item.luaClick()
		self:setSelectFormula(data)

		local formulaData = HomelandFormulaData[data.formulaId]
		local formulaInfo = self.model:getFormulaListDetailInfo(data.formulaId)
		local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			formulaTracking = true,
			autoHor = true,
			padding = 100,
			id = data.previewItemInfo.id,
			countItemId = defaultOutputItem,
			targetRect = self.listRecipeUList,
			showUnopen = data.isLocked and not data.unlockLocked,
			unlockTipType = data.unlockLocked and 1 or 0,
			formulaInfo = formulaInfo,
			conditionLockText = data.conditionLocked and formulaData.unlockDesc,
			lockText = data.drawingLocked and not data.conditionLocked and data.lockText or nil,
			sourceItemId = data.drawingLocked and not data.conditionLocked and data.unlockItemId or nil,
			sourceTitle = data.drawingLocked and not data.conditionLocked and ClientHomelandUtils.getDrawingSourceTitle(false) or nil,
			price = Utils.getHomeItemPrice(defaultOutputItem)
		})
	end
end

return PlotDetailRecipeComponent
