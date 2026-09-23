-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ItemPropUIUtils.lua

local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local ItemPropUIUtils = {}
local CORE_CARRY_CERTIFY_TIPS_UNLOCK = "CORE_CARRY_CERTIFY_TIPS_UNLOCK"

function ItemPropUIUtils.renderConsumeItem(button, data, showOwnNum, lockTips, disableShowLack, includeHomelandWarehouse, excludeLockedCount, useShortNumber)
	if IsNil(button) then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local imgIcon = LuaUIUtils.safeGetRefValue(objectReference, "imgIcon")
	local txtNum = LuaUIUtils.safeGetRefValue(objectReference, "txtNum")
	local itemId = data and data[1] or 0
	local needNum = data and data[2] or 0
	local ownNum = ClientUtils.getItemCountById(itemId, not excludeLockedCount) or 0

	if includeHomelandWarehouse then
		local itemCfg = ItemData[itemId]

		if itemCfg and itemCfg.isHomeItem == 1 and pg.me:isInSelfHomeland() then
			ownNum = ownNum + (ClientUtils.getHomelandItemCountById(itemId) or 0)
		end
	end

	local showLack = not disableShowLack and ownNum < needNum
	local numText
	local isSpecial = ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL
	local shouldShowOwn = showOwnNum and not isSpecial
	local button = objectReference.gameObject:GetComponent("UButton")

	if imgIcon then
		imgIcon.url = LuaUIUtils.getIconByItemId(itemId)
	end

	if button then
		button.enabledTooltip = false
		button.luaRenderTooltip = nil

		if not lockTips then
			function button.luaClick()
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = itemId,
					targetRect = button
				})
			end
		else
			button.luaClick = nil
		end
	end

	if shouldShowOwn and not disableShowLack then
		numText = LuaUIUtils.formatStyledItemNum(ownNum, needNum)
	elseif showLack then
		numText = LuaUIUtils.formatStyledItemNum(nil, needNum, nil, true)
	elseif shouldShowOwn then
		if useShortNumber then
			numText = string.format("%s/%s", LuaUIUtils.formatShortItemNum(ownNum), LuaUIUtils.formatShortItemNum(needNum))
		else
			numText = string.format("%s/%s", ownNum, needNum)
		end
	elseif useShortNumber then
		numText = LuaUIUtils.formatShortItemNum(needNum)
	else
		numText = needNum
	end

	if txtNum then
		ClientTextUtils.setText(txtNum, numText)
	end
end

function ItemPropUIUtils.renderConsumeItemList(uList, itemIdNumList, showOwnNum, lockTips, disableShowLack, includeHomelandWarehouse, excludeLockedCount, useShortNumber)
	if not uList then
		return
	end

	function uList.luaRenderItem(button, _, data)
		ItemPropUIUtils.renderConsumeItem(button, data, showOwnNum, lockTips, disableShowLack, includeHomelandWarehouse, excludeLockedCount, useShortNumber)
	end

	uList:SetList(itemIdNumList or {})
end

function ItemPropUIUtils.refreshCarryMainAttrList(mainAttrList, mainProperties)
	if IsNil(mainAttrList) then
		return
	end

	local attrList = Utils.isTable(mainProperties) and mainProperties or {}

	function mainAttrList.luaRenderItem(sBtn, _, sData)
		local objectReference = sBtn:GetComponent("ObjectReference")
		local attributeName = objectReference:GetRefValue("attributeName")
		local attributeValue = objectReference:GetRefValue("attributeValue")
		local iconTypeUImage = objectReference:GetRefValue("iconTypeUImage")

		ClientTextUtils.setText(attributeName, sData.name)
		ClientTextUtils.setText(attributeValue, sData.tDesc)

		if iconTypeUImage then
			iconTypeUImage.url = sData.icon
		end
	end

	mainAttrList:SetList(attrList)
end

function ItemPropUIUtils.getCarryDebugDesc(data)
	local dataDescStr = data.itemDes or ""

	if not pg.game.setting:getShowDebugId() then
		return dataDescStr
	end

	local assistPosList = data.assistCarryPosList or {}
	local assistTypeList = data.assistCarryTypeList or {}
	local assistUnlockLvs = data.slotUnlockLv or {}
	local inventoryName = "invId(" .. tostring(data.invId) .. ")genID(" .. tostring(data.genID) .. ")"
	local assistPosDebugStr = string.format("当前携带物[%s]槽位数据: \n", inventoryName)

	for i = 1, #assistPosList do
		local curPosStr = ""
		local pos = assistPosList[i]

		if Utils.isTable(pos) and next(pos) then
			local equipedInvId = pos[1] or 0
			local equipedGenId = pos[2] or 0
			local unlockStr = data.assistUnlock[i] == 1 and "已解锁" or "未解锁"
			local unlockLv = assistUnlockLvs[i] or 0

			if equipedInvId > 0 then
				curPosStr = string.format("当前[%d]槽位-[%d]类型-解锁等级[%d]-状态[%s]:已装配符文[invId(%d), genID(%d)]", i, assistTypeList[i], unlockLv, unlockStr, equipedInvId, equipedGenId)
			else
				curPosStr = string.format("当前[%d]槽位-[%d]类型-解锁等级[%d]-状态[%s]:未装配符文", i, assistTypeList[i], unlockLv, unlockStr)
			end
		end

		assistPosDebugStr = assistPosDebugStr .. curPosStr .. "\n"
	end

	return dataDescStr .. "\n" .. assistPosDebugStr
end

function ItemPropUIUtils.refreshCarryAdvancedModule(advancedUWidget, jewelUWidget, advancedLockedUWidget, txtLockedUSDFText, data, isCompareState)
	if IsNil(advancedUWidget) or IsNil(jewelUWidget) or IsNil(advancedLockedUWidget) then
		return
	end

	local compareState = isCompareState == true
	local isOwnCarryItem = data and data.invId ~= nil and data.genID ~= nil

	jewelUWidget.gameObject:SetActiveEx(compareState)

	local hasEff = Utils.isTable(data.energyEffects) and next(data.energyEffects)

	advancedUWidget.gameObject:SetActiveEx(hasEff or compareState)

	if not isOwnCarryItem then
		advancedLockedUWidget.gameObject:SetActiveEx(false)

		return
	end

	local isAdvancedLocked, requiredLevel = PetManagementDataHelper.getCoreCarryCertifyAdvancedLockInfo(data)

	advancedLockedUWidget.gameObject:SetActiveEx(isAdvancedLocked)
	advancedUWidget.gameObject:SetActiveEx(hasEff or compareState)

	if isAdvancedLocked and txtLockedUSDFText then
		local formatText = pg.getGameString(CORE_CARRY_CERTIFY_TIPS_UNLOCK)

		formatText = formatText == CORE_CARRY_CERTIFY_TIPS_UNLOCK and "large than %d can unlock" or formatText

		if formatText then
			ClientTextUtils.setText(txtLockedUSDFText, string.format(formatText, requiredLevel))
		end
	end
end

function ItemPropUIUtils.refreshCarryModule(objectReference, param, isCompareState)
	if IsNil(objectReference) or not Utils.isTable(param) then
		return false
	end

	LuaUIUtils.checkParseCarryInfo(param)

	if not param.carryCoreAttr or param.carryCoreAttr.type ~= ItemConst.ITEM_TYPE_CARRY_CORE then
		return false
	end

	local txtCoreAttrDesc = objectReference:GetRefValue("txtCoreAttrDesc")
	local mainAttrList = objectReference:GetRefValue("mainAttrList")
	local coreBonusUWidget = objectReference:GetRefValue("coreBonusUWidget")
	local advancedUWidget = objectReference:GetRefValue("advancedUWidget")
	local advancedList = objectReference:GetRefValue("advancedList")
	local jewelUWidget = objectReference:GetRefValue("jewelUWidget")
	local assistList = objectReference:GetRefValue("assistList")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local txtEnergy = objectReference:GetRefValue("txtEnergy")
	local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	local txtAdvanceUBaseText = objectReference:GetRefValue("txtAdvanceUBaseText")
	local advancedLockedUWidget = objectReference:GetRefValue("advancedLockedUWidget")
	local txtLockedUSDFText = objectReference:GetRefValue("txtLockedUSDFText")

	if txtTitleUBaseText then
		ClientTextUtils.setText(txtTitleUBaseText, pg.getGameString("PET_EQUIPMENT_CORE_BUFF"))
	end

	if txtAdvanceUBaseText then
		ClientTextUtils.setText(txtAdvanceUBaseText, pg.getGameString("PET_EQUIPMENT_EXTRA_BUFF"))
	end

	ItemPropUIUtils.refreshCarryMainAttrList(mainAttrList, param.mainProperties)

	if txtDesc then
		ClientTextUtils.setText(txtDesc, ItemPropUIUtils.getCarryDebugDesc(param))
	end

	if txtEnergy then
		ClientTextUtils.setText(txtEnergy, param.energySum or 0)
	end

	if coreBonusUWidget then
		coreBonusUWidget:SetActive(true)
	end

	if txtCoreAttrDesc then
		ClientTextUtils.setText(txtCoreAttrDesc, param.carryCoreAttr and param.carryCoreAttr.buffDesc)
	end

	LuaUIUtils.refreshCarryAssistInfo(assistList, advancedList, param, true)
	ItemPropUIUtils.refreshCarryAdvancedModule(advancedUWidget, jewelUWidget, advancedLockedUWidget, txtLockedUSDFText, param, isCompareState)

	return true
end

return ItemPropUIUtils
