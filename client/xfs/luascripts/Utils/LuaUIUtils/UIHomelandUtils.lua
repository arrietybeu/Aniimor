-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIHomelandUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeAbilityData = require("Data.home_ability_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFacilityDataReverse = require("Data.homeland_facility_data_reverse")
local HomelandFormulaDataReverse = require("Data.homeland_formula_data_reverse")
local HomeObjectData = require("Data.home_object_data")

return function(LuaUIUtils)
	function LuaUIUtils.refreshHomeOwenedUContainer(itemId, container)
		if not itemId or not container then
			return
		end

		local itemData = ItemData[itemId]

		if not itemData or itemData.isHomeItem ~= 1 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, true)

		local function callbackFunc()
			local objectReference = container.content:GetComponent("ObjectReference")
			local txtBagTitleUSDFText = objectReference:GetRefValue("txtBagTitleUSDFText")
			local txtBagNumUSDFText = objectReference:GetRefValue("txtBagNumUSDFText")
			local txtHomeTitleUSDFText = objectReference:GetRefValue("txtHomeTitleUSDFText")
			local txtHomeNumUSDFText = objectReference:GetRefValue("txtHomeNumUSDFText")

			ClientTextUtils.setText(txtBagTitleUSDFText, pg.getGameString("BAG"))
			ClientTextUtils.setText(txtHomeTitleUSDFText, pg.getGameString("FILTER_HOMELAND"))

			local bagCount = ClientUtils.getItemCountById(itemId, true)

			ClientTextUtils.setText(txtBagNumUSDFText, tostring(bagCount))

			if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
				local homeCount = ClientUtils.getHomelandItemCountById(itemId)

				ClientTextUtils.setText(txtHomeNumUSDFText, tostring(homeCount))
			else
				ClientTextUtils.setText(txtHomeNumUSDFText, "--")
			end
		end

		if not container:CheckURLLoaded() then
			container:LoadDefaultUrlManually(function()
				callbackFunc()
			end)
		else
			callbackFunc()
		end
	end

	function LuaUIUtils.refreshHomeFormulaUContainer(itemId, formulaInfo, container, showSellPrice, validate)
		if validate and not validate() then
			return
		end

		if not itemId or not container then
			return
		end

		local formulaData = HomelandFormulaData[itemId]

		if not formulaData then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		local facilityIds = HomelandFacilityDataReverse[itemId]
		local matchedHomeObjectCfg

		for _, v in ipairs(facilityIds or EMPTY_TABLE) do
			local homeObjectCfg = HomeObjectData[v]

			if homeObjectCfg then
				matchedHomeObjectCfg = homeObjectCfg

				break
			end
		end

		if not matchedHomeObjectCfg then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, true)

		local function callbackFunc()
			if validate and not validate() then
				return
			end

			local objectReference = container.content:GetComponent("ObjectReference")
			local iconPlotUImage = objectReference:GetRefValue("iconPlotUImage")
			local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
			local formulaInfoUWidget = objectReference:GetRefValue("formulaInfoUWidget")
			local petInfoUWidget = objectReference:GetRefValue("petInfoUWidget")
			local listUList = objectReference:GetRefValue("listUList")
			local list2UList = objectReference:GetRefValue("list2UList")
			local petHeadUButton = objectReference:GetRefValue("petHeadUButton")
			local txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
			local listItemUList = objectReference:GetRefValue("listItemUList")
			local txtWorkNameUSDFText = objectReference:GetRefValue("txtWorkNameUSDFText")
			local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
			local iconWorkUImage = objectReference:GetRefValue("iconWorkUImage")
			local arrowUWidget = objectReference:GetRefValue("arrowUWidget")
			local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

			keyHotKeyContent:SetHotKeyPaths("Raw/GamepadLeftStickPress")
			ClientTextUtils.setText(txtStateUSDFText, pg.getGameString("HOMELAND_TIPS_KEEP_WORK"))

			if matchedHomeObjectCfg then
				iconPlotUImage.url = matchedHomeObjectCfg.plotIconId or ""

				ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(matchedHomeObjectCfg.name))
			end

			local resultInfo

			resultInfo = {}

			local outputMap = HomeLandUtils.getFormulaOutputMap(formulaData)

			if next(outputMap) then
				for outputItemId, outputItemNum in pairs(outputMap) do
					table.insert(resultInfo, {
						id = outputItemId,
						num = outputItemNum,
						price = showSellPrice and Utils.getHomeItemPrice(outputItemId) or nil
					})
				end
			end

			if formulaData.pet then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(formulaInfoUWidget, false)
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(petInfoUWidget, true)
				LuaUIUtils.renderPetItemSimple(petHeadUButton, {
					label = 0,
					petId = formulaData.pet
				})

				petHeadUButton.draggable = false

				local petCfg = PetData[formulaData.pet]
				local petName = petCfg and pg.getLocalizationText(petCfg.name) or ""

				petHeadUButton.enabledTooltip = true

				function petHeadUButton.luaRenderTooltip(btn, cmp)
					local ref = cmp:GetComponent("ObjectReference")
					local txtNameUSDFText = ref:GetRefValue("txtNameUSDFText")

					ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("HOME_PET_FAMILY_WORK_TIPS"), petName))
				end

				function listItemUList.luaRenderItem(button, idx, data)
					if data.id == formulaData.previewItemId then
						LuaUIUtils.renderRewardItem(button, data)

						function button.luaClick()
							return
						end
					else
						LuaUIUtils.renderRewardItem(button, data, nil, true)

						button.PopupTool.hierarchy = 2
					end
				end

				listItemUList:SetList(resultInfo)
			else
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(formulaInfoUWidget, true)
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(petInfoUWidget, false)

				local consumableInfo = {}

				for i = 1, 3 do
					local consumableId = formulaData["consumable" .. i]
					local consumableNum = formulaData["consumableNum" .. i]

					if consumableId and consumableNum then
						local itemCount = 0

						if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
							itemCount = itemCount + ClientUtils.getHomelandItemCountById(consumableId)
						end

						local numText = LuaUIUtils.renderConsumeText(nil, itemCount, consumableNum, UIConst.ITEM_STATE.FULL)

						table.insert(consumableInfo, {
							id = consumableId,
							num = numText,
							price = showSellPrice and Utils.getHomeItemPrice(consumableId) or nil
						})
					end
				end

				function listUList.luaRenderItem(button, idx, data)
					data.autoHor = true
					data.padding = 8

					LuaUIUtils.renderRewardItem(button, data, nil, true)

					button.PopupTool.hierarchy = 2
				end

				listUList:SetList(consumableInfo)
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(arrowUWidget, #consumableInfo > 0)

				function list2UList.luaRenderItem(button, idx, data)
					if data.id == formulaData.previewItemId then
						data.autoHor = true
						data.padding = 8

						LuaUIUtils.renderRewardItem(button, data)

						function button.luaClick()
							return
						end
					else
						data.autoHor = true
						data.padding = 8

						LuaUIUtils.renderRewardItem(button, data, nil, true)

						button.PopupTool.hierarchy = 2
					end
				end

				list2UList:SetList(resultInfo)
			end

			local useTime = formulaData.time
			local useWork = formulaData.workload

			if formulaInfo then
				useTime = formulaInfo.time
				useWork = formulaInfo.workload
			end

			if useTime then
				ClientTextUtils.setText(txtWorkNameUSDFText, pg.getGameString("FC_HISTORY_COL_TIME"))
				ClientTextUtils.setText(txtNumUSDFText, LuaUIUtils.getCountDownString(useTime, nil, true))

				iconWorkUImage.url = AddressDataConst.HOME_TIPS_TIME_ICON
			elseif useWork then
				ClientTextUtils.setText(txtWorkNameUSDFText, pg.getGameString("HOMELAND_TIPS_WORKLOAD"))
				ClientTextUtils.setText(txtNumUSDFText, tostring(useWork))

				iconWorkUImage.url = AddressDataConst.HOME_TIPS_WORK_ICON
			end
		end

		if not container:CheckURLLoaded() then
			container:LoadDefaultUrlManually(function()
				callbackFunc()
			end)
		else
			callbackFunc()
		end
	end

	function LuaUIUtils.refreshHomeProvideText(itemId, list)
		if not list then
			return
		end

		if not itemId then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(list, false)
			list:SetList({})

			return
		end

		local provideList = {}
		local formulaData = HomelandFormulaData[itemId]

		if formulaData then
			local envTitleText = formulaData.forceEnvRequire == 1 and pg.getGameString("HOMELAND_TIPS_ENV_REQUIRE") or pg.getGameString("HOMELAND_TIPS_ENV_RECOMMEND")

			if formulaData.temperatureRequire then
				local tempText = HomeLandUtils.getTempLevelText(formulaData.temperatureRequire)

				table.insert(provideList, {
					titleText = envTitleText,
					iconUrl = ClientConst.TemperatureBuffIcon[formulaData.temperatureRequire] or AddressDataConst.HOME_TOPLOGO_ICON_TEMPERATURE,
					nameText = tempText
				})
			end

			if formulaData.lightRequire then
				table.insert(provideList, {
					titleText = envTitleText,
					iconUrl = ClientConst.LightBuffIcon[formulaData.lightRequire] or AddressDataConst.HOME_TOPLOGO_ICON_LIGHT,
					nameText = pg.getGameString("SUFFICIENT")
				})
			end
		end

		local rawItemId = itemId

		if formulaData and formulaData.outputs and formulaData.outputs[1] then
			local useOutPut = formulaData.outputs[1]

			rawItemId = useOutPut[1]
		end

		local itemCfg = ItemData[rawItemId]

		if itemCfg and itemCfg.homeFoodAdd and itemCfg.homeFoodAdd > 0 then
			table.insert(provideList, {
				titleText = pg.getGameString("HOMELAND_TIPS_PROVIDE_ENERGY"),
				iconUrl = AddressDataConst.HOME_TOPLOGO_ICON_ENERGY,
				nameText = tostring(itemCfg.homeFoodAdd)
			})
		end

		if #provideList == 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(list, false)
			list:SetList({})

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(list, true)

		function list.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtTitleUSDFText, data.titleText)

			iconUImage.url = data.iconUrl

			ClientTextUtils.setText(txtNameUSDFText, data.nameText)
		end

		list:SetList(provideList)
	end

	function LuaUIUtils.refreshHomeMachinableUContainer(itemId, container, showSellPrice, validate)
		if validate and not validate() then
			return
		end

		if not itemId or not container then
			return
		end

		local rawFormulaData = HomelandFormulaData[itemId]
		local rawItemId = itemId

		if rawFormulaData and rawFormulaData.outputs and rawFormulaData.outputs[1] then
			local useOutPut = rawFormulaData.outputs[1]

			rawItemId = useOutPut[1]
		end

		local formulaIds = HomelandFormulaDataReverse[rawItemId]

		if not formulaIds or #formulaIds == 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		local outputTable = {}
		local outputList = {}

		for _, formulaId in ipairs(formulaIds) do
			local formulaData = HomelandFormulaData[formulaId]

			if formulaData and not HomeLandUtils.isElectricFormula(formulaId) and HomeLandUtils.isHomelandFormulaTimeValid(formulaId) then
				local outputMap = HomeLandUtils.getFormulaOutputMap(formulaData)

				if next(outputMap) then
					for outputItemId, _ in pairs(outputMap) do
						outputTable[outputItemId] = true
					end
				elseif formulaData.previewItemId then
					outputTable[formulaData.previewItemId] = true
				end
			end
		end

		for outputItemId, _ in pairs(outputTable) do
			table.insert(outputList, {
				id = outputItemId,
				price = showSellPrice and Utils.getHomeItemPrice(outputItemId) or nil
			})
		end

		if #outputList == 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		table.sort(outputList, function(a, b)
			return a.id < b.id
		end)
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, true)

		local function callbackFunc()
			if validate and not validate() then
				return
			end

			local objectReference = container.content:GetComponent("ObjectReference")
			local txtMachinableUSDFText = objectReference:GetRefValue("txtMachinableUSDFText")
			local listMachinableUList = objectReference:GetRefValue("listMachinableUList")
			local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

			if not rawFormulaData then
				keyHotKeyContent:SetHotKeyPaths("Raw/GamepadLeftStickPress")
			end

			ClientTextUtils.setText(txtMachinableUSDFText, pg.getGameString("HOMELAND_TIPS_WORKABLE"))

			function listMachinableUList.luaRenderItem(button, idx, data)
				data.autoHor = true
				data.padding = 8
				button.PopupTool.hierarchy = 2

				button:SetPopupDirection(CS.XGUI.EPopupDirection.Left)
				LuaUIUtils.renderRewardItem(button, data, nil, true)
			end

			listMachinableUList:SetList(outputList)
		end

		if not container:CheckURLLoaded() then
			container:LoadDefaultUrlManually(function()
				callbackFunc()
			end)
		else
			callbackFunc()
		end
	end

	function LuaUIUtils.getHomeAbilityData(templateId)
		local homeAbility = PetData[templateId].homeAbility
		local abilityData = {}

		if not homeAbility then
			return abilityData
		end

		for id, ability in pairs(homeAbility) do
			local data = {}

			data.id = id
			data.level = ability

			table.insert(abilityData, data)
		end

		return abilityData
	end

	function LuaUIUtils.setHomeAbilityButton(button, homeAbilityId)
		local homeAbilityData = HomeAbilityData[homeAbilityId]

		button.customData = homeAbilityId
		button.icon.url = homeAbilityData.icon
		button.background.colorCode = homeAbilityData.iconColor

		ClientTextUtils.setText(button.title, pg.getLocalizationText(homeAbilityData.name))
	end

	function LuaUIUtils.renderHomeAbility(button, homeAbilityId, homeAbilityLevel, useFullLevel)
		if not homeAbilityId or not homeAbilityLevel then
			button:SetActive(false)

			return
		end

		local homeAbilityData = HomeAbilityData[homeAbilityId]

		if not homeAbilityData then
			button:SetActive(false)

			return
		end

		button:SetActive(true)

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local numLevelTextPlus = objectReference:GetRefValue("numLevelTextPlus")
		local iconBG = objectReference:GetRefValue("imgBgImagePro")

		if useFullLevel then
			ClientTextUtils.setText(numLevelTextPlus, string.format("L%s", homeAbilityLevel))
		else
			ClientTextUtils.setText(numLevelTextPlus, homeAbilityLevel)
		end

		iconUImage.url = homeAbilityData.icon

		iconBG:SetColorWithHtmlString(homeAbilityData.iconColor)
	end

	function LuaUIUtils.HomePlantManual_HasPlantRewardCanGet(formulaId, numMax)
		local serverData = pg.me.plantBook[formulaId] or {}
		local curNum = lume.tableLength(serverData)

		if curNum == numMax then
			local isGet = pg.me.singlePlantReward[formulaId] or false

			if isGet == false then
				return true
			end
		end

		return false
	end

	function LuaUIUtils.HomePlantManual_getCurPlantsNumByFormulaId(formulaId)
		local map = pg.me.plantBook[formulaId] or {}

		return lume.tableLength(map)
	end
end
