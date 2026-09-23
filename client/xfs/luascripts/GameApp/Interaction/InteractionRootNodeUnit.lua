-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractionRootNodeUnit.lua

local ItemData = require("Data.item_data")
local SceneData = require("Data.scene_data")
local InteractionConst = require("Common.Const.InteractionConst")
local DropUtils = require("Common.Utils.DropUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local Class = require("Core.Framework.Class")
local InteractionRootNodeUnit = Class.LightClass("InteractionRootNodeUnit")

function InteractionRootNodeUnit:ctor(globalId)
	self.globalId = globalId
	self.onlyFunc = false
	self.interactUnits = {}
	self.interactBtnStyles = {}
	self.btnStylesCount = 0
end

function InteractionRootNodeUnit:addInteractUnit(interactUnit)
	self.interactUnits[#self.interactUnits + 1] = interactUnit

	local btnStyleCount = #interactUnit:getInteractBtnStyle()

	self.btnStylesCount = self.btnStylesCount + btnStyleCount
end

function InteractionRootNodeUnit:doInteract()
	if self.btnStylesCount == 1 then
		for _, unit in ipairs(self.interactUnits) do
			local btnStyles = unit:getInteractBtnStyle()

			if #btnStyles == 1 then
				unit:tryInteractive(btnStyles[1].index or 1)

				break
			end
		end
	else
		pg.global.ui.interactSecond:open({
			unitRoot = self
		})
	end
end

function InteractionRootNodeUnit:getSubBtnStyles()
	local count = 0

	for _, unit in ipairs(self.interactUnits) do
		local styleCount = unit:getInteractBtnStyle()

		count = count + #styleCount
	end

	return count
end

function InteractionRootNodeUnit:checkIsEmpty()
	return #self.interactUnits == 0
end

function InteractionRootNodeUnit:getSortId()
	return self.interactUnits[1]:getSortId()
end

function InteractionRootNodeUnit:getInteractName()
	if self.onlyFunc then
		return self.interactUnits[1]:getActionName()
	end

	local entity = pg.getEntityByGlobalId(self.globalId)

	if entity then
		if Utils.isVehicle(entity) then
			return self.interactUnits[1]:getActionName()
		end

		if entity.isMainPlayer or entity.isMainPet then
			return self.interactUnits[1]:getText()
		end

		if Utils.isPlayer(entity) or Utils.isPlayerGhost(entity) or Utils.isPetGhost(entity) then
			return self.interactUnits[1]:getActionName()
		end

		if Utils.isResourceBox(entity) or Utils.isGrabEggTransfer(entity) then
			return self.interactUnits[1]:getCustomName()
		end

		if Utils.isRobEggSpaceEgg(entity) then
			return self.interactUnits[1]:getCombineName()
		end

		if Utils.isEggShip(entity) and #self.interactUnits <= 1 then
			return self.interactUnits[1]:getCustomName()
		end

		if entity.needDoGroupReward then
			return self.interactUnits[1]:getActionName()
		end

		if #self.interactUnits == 1 and entity.isFishingCaptureBoss and entity:isFishingCaptureBoss() then
			return self.interactUnits[1]:getActionName()
		end

		local cfgData = entity:getConfigData()

		if cfgData.actionName and #self.interactUnits == 1 then
			return self.interactUnits[1]:getText()
		end

		if Utils.isPuppet(entity) then
			local name = entity:getName()

			if not string.isNilOrEmpty(name) then
				return pg.getLocalizationText(name)
			end
		else
			if entity.getInteractName then
				return entity:getInteractName(self.interactUnits)
			end

			return pg.getLocalizationText(cfgData.name)
		end
	end

	return self.interactUnits[1]:getText()
end

function InteractionRootNodeUnit:getEnt()
	if self.globalId then
		local entity = pg.getEntityByGlobalId(self.globalId)

		return entity
	end
end

function InteractionRootNodeUnit:isMarkShare()
	return self.interactUnits[1] and self.interactUnits[1].interactionType == InteractionConst.INTERACTION_TYPE_MARK_SHARE
end

function InteractionRootNodeUnit:getInteractIcon()
	if self.btnStylesCount == 1 then
		return self.interactUnits[1]:getIcon()
	end

	local entity = pg.getEntityByGlobalId(self.globalId)

	if entity then
		local cfgData = entity:getConfigData()

		if cfgData.actionName and #self.interactUnits == 1 then
			return self.interactUnits[1]:getIcon()
		end

		local firstUnit = self.interactUnits[1]

		if firstUnit and firstUnit.isHudShowQuest then
			return firstUnit:getIcon()
		end

		if Utils.isNpc(entity) or entity.useNpcFirstLevelInteractIcon and entity:useNpcFirstLevelInteractIcon() then
			return cfgData.firstLevelInteractIcon or AddressDataConst.BRANCH_OPTION_ICON
		end

		if Utils.isPlayer(entity) then
			return firstUnit:getIcon()
		end
	end

	return AddressDataConst.UI_INTERACT_COMMON_ICON
end

function InteractionRootNodeUnit:getActionPath()
	return "Hud/Interact"
end

function InteractionRootNodeUnit:getTextColor()
	if self.btnStylesCount ~= 1 then
		return
	end

	for _, unit in ipairs(self.interactUnits) do
		local btnStyles = unit:getInteractBtnStyle()

		if #btnStyles == 1 then
			return btnStyles[1].textColor
		end
	end
end

function InteractionRootNodeUnit:compareOtherRootNode(other)
	if #self.interactUnits ~= #other.interactUnits then
		return false
	end

	local len = #self.interactUnits

	for idx = 1, len do
		local unit1 = self.interactUnits[idx]
		local unit2 = other.interactUnits[idx]

		if unit1 ~= unit2 then
			return false
		end
	end

	return true
end

function InteractionRootNodeUnit:refreshInteractUnit()
	local hasChanged = false

	for idx = #self.interactUnits, 1, -1 do
		if not self.interactUnits[idx]:canInteractive() then
			hasChanged = true

			table.remove(self.interactUnits, idx)
		end
	end

	if hasChanged then
		facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
	end
end

function InteractionRootNodeUnit:getInteractItemBaiscInfo()
	local entity = pg.getEntityByGlobalId(self.globalId)
	local ret = {}

	if entity then
		ret.props = entity.props

		if Utils.isCollectItem(entity) then
			if entity.isMultiple then
				ret.itemId = entity.reward or 0
				ret.count = entity.count or 1
			else
				local dropItemsInfo = {}
				local dropId = entity.reward or 0
				local itemDict = DropUtils.genDropDisplayInfo(dropId)

				if itemDict then
					for itemId, numInfo in pairs(itemDict) do
						local num = ItemUtils.getItemCountFromNumInfo(numInfo)

						table.insert(dropItemsInfo, {
							itemId = itemId,
							count = num
						})
					end
				end

				ret.itemId = dropItemsInfo[1] and dropItemsInfo[1].itemId or 0
				ret.count = dropItemsInfo[1] and dropItemsInfo[1].count or 1
			end
		end
	end

	return ret
end

function InteractionRootNodeUnit:isDisplayCollectItemPriceDesc()
	local basicInfo = self:getInteractItemBaiscInfo()
	local sceneCfg = pg.me and pg.me.space and pg.me.space.sceneId and SceneData[pg.me.space.sceneId]
	local isDisplayPrice = sceneCfg and sceneCfg.InteractionType and sceneCfg.InteractionType == 1

	isDisplayPrice = isDisplayPrice or pg.space:isGrabEgg()

	return isDisplayPrice and ToBool(basicInfo.itemId)
end

function InteractionRootNodeUnit:getInteractItemSellPriceInfos()
	local ret = {
		richText = "",
		quality = 0
	}

	if not self:isDisplayCollectItemPriceDesc() then
		return ret
	end

	local basicInfo = self:getInteractItemBaiscInfo()
	local itemId = basicInfo.itemId
	local itemCnt = basicInfo.count or 1
	local nameDesc = ""
	local price = 0
	local itemIcon
	local quality = 0

	if ToBool(itemId) then
		local itemInfo = LuaUIUtils.getItemClientInfoById(itemId)

		nameDesc = itemInfo and itemInfo.name and pg.getLocalizationText(itemInfo.name) or ""

		local itemCfg = ItemData[itemId]
		local priceData = {
			itemId = itemId,
			props = basicInfo.props
		}

		price = LuaUIUtils.getPropDecomposeNum(priceData, (itemCfg and itemCfg.sellPrice or 0) * itemCnt)
		itemIcon = itemInfo and itemInfo.icon or ""
		quality = itemInfo and itemInfo.quality or 0
	end

	ret = {
		richText = pg.getFormatText(pg.getGameString("COLLECT_ITEM_PRICE_RICH_TEXT"), nameDesc, tostring(itemCnt), tostring(price)),
		itemIcon = itemIcon,
		quality = quality
	}

	return ret
end

return InteractionRootNodeUnit
