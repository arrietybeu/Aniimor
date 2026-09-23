-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\Component\\GrabEggMyBagComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggMyBagComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local GrabEggMyBagComponent = Class.LightClass("GrabEggMyBagComponent", UIComponent)
local StringEx = require("Core.Framework.String")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local ItemData = require("Data.item_data")
local RobEggChipSlotData = require("Data.robegg_chip_slot_data")
local SysConfigData = require("Data.sys_config_data")
local AnimWeight = "VX_Node_GrabEggs_Searching_Weight"
local AnimCoin = "VX_Node_GrabEggs_Searching_Coin"
local ARMOR_ICON_BY_QUALITY = {
	nil,
	"$UI_Img_GrabEggs_Robot_Armor_Green.png",
	"$UI_Img_GrabEggs_Robot_Armor_Blue.png",
	"$UI_Img_GrabEggs_Robot_Armor_Purple.png",
	"$UI_Img_GrabEggs_Robot_Armor_God.png"
}
local WEAPON_ICON_BY_QUALITY = {
	nil,
	"$UI_Img_GrabEggs_Robot_Weapon_Green.png",
	"$UI_Img_GrabEggs_Robot_Weapon_Blue.png",
	"$UI_Img_GrabEggs_Robot_Weapon_Purple.png",
	"$UI_Img_GrabEggs_Robot_Weapon_God.png"
}

GrabEggMyBagComponent.messages = {
	[MessageName.GRAB_EGG_REPAIR_KIT_START] = {
		"event_onRepairKitStart",
		true
	},
	[MessageName.GRAB_EGG_REPAIR_KIT_END] = {
		"event_onRepairKitEnd",
		true
	},
	[MessageName.GRAB_EGG_EQUIP_PROP] = {
		"event_onEquipPropChanged",
		true
	},
	[MessageName.GRAB_EGG_SAFE_BOX_NUM_CHANGED] = {
		"refreshSafeBox",
		true
	}
}

function GrabEggMyBagComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bagMineUContainer = objectReference:GetRefValue("bagMineUContainer")
	self.weightDetailUComponent = objectReference:GetRefValue("weightDetailUComponent")
	self.btnWeightUButton = objectReference:GetRefValue("btnWeightUButton")
	self.txtEquipValue = objectReference:GetRefValue("txtEquipValue")
	self.barUWidget = objectReference:GetRefValue("barUWidget")
	self.txtCurWeight = objectReference:GetRefValue("txtCurWeight")
	self.txtLimitWeight = objectReference:GetRefValue("txtLimitWeight")
	self.btnTipsUButton = objectReference:GetRefValue("btnTipsUButton")
	self.weightTipsUWidget = objectReference:GetRefValue("weightTipsUWidget")
	self.robotEquipmentUContainer = objectReference:GetRefValue("robotEquipmentUContainer")
	self.txtLoadStateUBaseText = objectReference:GetRefValue("txtLoadStateUBaseText")
	self.bagMineUContainer.forceSyncLoad = true

	self.bagMineUContainer:LoadDefaultUrlManually()

	objectReference = self.bagMineUContainer.content.transform:GetComponent("ObjectReference")
	self.listNormalItem = objectReference:GetRefValue("listNormalItem")
	self.btnEgg = objectReference:GetRefValue("btnEgg")
	self.btnBag = objectReference:GetRefValue("btnBag")
	self.iconBag = objectReference:GetRefValue("iconBag")
	self.iconEgg = objectReference:GetRefValue("iconEgg")
	self.txtBagCapacity = objectReference:GetRefValue("txtBagCapacity")
	self.dragCoverUComponent = objectReference:GetRefValue("dragCoverUComponent")
	self.imgGrayMaskUWidget = objectReference:GetRefValue("imgGrayMaskUWidget")
	self.textSafeBoxUBaseText = objectReference:GetRefValue("textSafeBoxUBaseText")
	self.textSoonUBaseText = objectReference:GetRefValue("textSoonUBaseText")
	self.textSafeBoxWeightUBaseText = objectReference:GetRefValue("textSafeBoxWeightUBaseText")
	self.listSafeBoxUList = objectReference:GetRefValue("listSafeBoxUList")

	function self.listNormalItem.luaRenderItem(button, index, data)
		self:onRenderNormalItem(button, index, data)
	end

	function self.listNormalItem.luaVirtualListRefreshCb()
		self.ctrl:refreshHoverDataFromPointer(self.listNormalItem)
	end

	self.listNormalItem.poolMode = 0

	function self.listSafeBoxUList.luaRenderItem(button, index, data)
		self:onRenderSafeBoxItem(button, index, data)

		if button.isPointerInside then
			self.model:setHoverData(data)
		end
	end

	self.listSafeBoxUList.poolMode = 0
	self.dragCoverUComponent.gameObject.name = self.model.BAG_DRAG_AREA
	self.robotEquipmentUContainer.forceSyncLoad = true

	self.robotEquipmentUContainer:LoadDefaultUrlManually()

	objectReference = self.robotEquipmentUContainer.content.transform:GetComponent("ObjectReference")
	self.weaponUButton = objectReference:GetRefValue("weaponUButton")
	self.weaponChip1UButton = objectReference:GetRefValue("weaponChip1UButton")
	self.weaponChip2UButton = objectReference:GetRefValue("weaponChip2UButton")
	self.weaponChip3UButton = objectReference:GetRefValue("weaponChip3UButton")
	self.armorUButton = objectReference:GetRefValue("armorUButton")
	self.armorChip1UButton = objectReference:GetRefValue("armorChip1UButton")
	self.armorChip2UButton = objectReference:GetRefValue("armorChip2UButton")
	self.armorChip3UButton = objectReference:GetRefValue("armorChip3UButton")
	self.armorIconUImage = objectReference:GetRefValue("armorIconUImage")
	self.leftWeaponUImage = objectReference:GetRefValue("leftWeaponUImage")
	self.rightWeaponUImage = objectReference:GetRefValue("rightWeaponUImage")
	self.listEquipBtn = {
		self.btnBag,
		self.btnEgg,
		self.weaponUButton,
		self.armorUButton
	}
	self.chipBtns = {
		self.weaponChip1UButton,
		self.weaponChip2UButton,
		self.weaponChip3UButton,
		self.armorChip1UButton,
		self.armorChip2UButton,
		self.armorChip3UButton
	}
end

function GrabEggMyBagComponent:onCtor(info)
	self._weightRefreshFrameId = nil
end

function GrabEggMyBagComponent:initView()
	function self.btnTipsUButton.luaRenderTooltip(button, panel)
		local objectReference = panel:GetComponent("ObjectReference")
		local listWeightUList = objectReference:GetRefValue("listWeightUList")
		local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
		local txtStageUBaseText = objectReference:GetRefValue("txtStageUBaseText")

		ClientTextUtils.setText(txtStageUBaseText, pg.getGameString("GRAB_EGG_BAG_LOAD_STATE"))

		local result, loadState = self.weightDetailUComponent:TryGetCurrentPage("WeightState")

		function listWeightUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local numBuffUBaseText = objectReference:GetRefValue("numBuffUBaseText")
			local stateUBaseText = objectReference:GetRefValue("stateUBaseText")
			local textCurrentUBaseText = objectReference:GetRefValue("textCurrentUBaseText")
			local isCurState = data.loadState == loadState

			if isCurState then
				ClientTextUtils.setText(textCurrentUBaseText, data.name)
			else
				ClientTextUtils.setText(stateUBaseText, data.name)
			end

			button:TryChangePage("State", data.loadState)
			button:TryChangePage("Burden", isCurState and 1 or 0)

			if numBuffUBaseText then
				numBuffUBaseText:SetActive(true)
				ClientTextUtils.setText(numBuffUBaseText, data.buffNum)
			end
		end

		local loadTipsData = {
			{
				loadState = 0,
				buffNum = 0,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_1")
			},
			{
				loadState = 1,
				buffNum = 1,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_2")
			},
			{
				loadState = 2,
				buffNum = 2,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_3")
			},
			{
				loadState = 3,
				buffNum = 3,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_4")
			},
			{
				loadState = 4,
				buffNum = 4,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_5")
			},
			{
				loadState = 5,
				buffNum = 5,
				name = pg.getGameString("GRAB_EGG_BAG_LOAD_6")
			}
		}

		listWeightUList:SetList(loadTipsData)

		function btnInfoUButton.luaClick()
			pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_WEIGHT_INFO)
			self.btnTipsUButton:CloseTooltip()
		end
	end

	function self.btnTipsUButton.luaTooltipPopup(_, flag)
		LuaUIUtils.setUIVisible(self.weightTipsUWidget, not flag)
	end

	self.btnWeightUButton.isSelected = self.model:isShowWeight()

	function self.btnWeightUButton.luaClick()
		local show = not self.btnWeightUButton.isSelected

		self.model:setShowWeight(show)
		self.ctrl:showWeight(show)
	end

	for k, btn in pairs(self.listEquipBtn) do
		function btn.luaHover()
			self:onHover(btn, true)
		end

		function btn.luaUnhover()
			self:onUnHover(btn, true)
		end

		function btn.luaNavFocused()
			self:onEquipSlotNavFocused(btn)
		end

		function btn.luaNavUnfocused()
			if self.ctrl then
				self.ctrl:clearBottomBarGamepad()
			end
		end
	end

	for k, btn in pairs(self.chipBtns) do
		function btn.luaHover()
			self:onHover(btn, true)
		end

		function btn.luaUnhover()
			self:onUnHover(btn, true)
		end

		function btn.luaNavFocused()
			self:onEquipSlotNavFocused(btn)
		end

		function btn.luaNavUnfocused()
			self.ctrl:clearBottomBarGamepad()
		end
	end

	ClientTextUtils.setText(self.textSafeBoxUBaseText, pg.getGameString("GRAB_EGG_SAFE_BOX_TITLE"))
	ClientTextUtils.setText(self.textSoonUBaseText, pg.getGameString("GRAB_EGG_PENDANT_SOON"))
end

function GrabEggMyBagComponent:onDestroy()
	if self._weightRefreshFrameId then
		TimerManager.delFrameCb(self._weightRefreshFrameId)

		self._weightRefreshFrameId = nil
	end

	self.curTipsData = nil

	UIComponent.onDestroy(self)
end

function GrabEggMyBagComponent:showUI()
	self:refreshNormalList()
	self:refreshBagState()
	self:refreshEgg()
	self:refreshWeapon()
	self:refreshArmor()
	self:refreshWeaponChips()
	self:refreshArmorChips()
	self:refreshSafeBox()
	self:refreshValue()
	self:refreshWeight()

	if self.model:isRepairingKit() then
		self:event_onRepairKitStart()
	end
end

function GrabEggMyBagComponent:onRenderNormalItem(button, index, data)
	button.gameObject.name = data.slotIndex

	LuaUIUtils.updateGrabEggBtnDragMode(self.listNormalItem, button)
	LuaUIUtils.refreshGrabEggAntiqueTags(button, data)

	local haveData = data.itemId ~= nil

	button.draggable = haveData

	if not haveData then
		self:refreshRepairProgressOnButton(button)
		LuaUIUtils.refreshGrabEggSkillChipIcon(button, nil)

		if data.slotIndex then
			function button.luaHover()
				self:onHover(button, false)
			end

			function button.luaUnhover()
				self:onUnHover(button, false)
			end
		else
			button.luaHover = nil
			button.luaUnhover = nil
		end

		button.luaNavFocused = nil
		button.luaNavUnfocused = nil

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local weightPanelUWidget = objectReference:GetRefValue("weightPanelUWidget")
	local txtValueUBaseText = objectReference:GetRefValue("txtValueUBaseText")
	local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")
	local durableUContainer = objectReference:GetRefValue("durableUContainer")
	local itemId = data.itemId
	local itemData = ItemData[itemId]

	if not itemData then
		return
	end

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUBaseText, self.model:getItemCountText(data, false, true))
	LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
	button:TryChangePage("Quality", data.quality)
	LuaUIUtils.refreshGrabEggSkillChipIcon(button, itemId)

	local weight = itemData.weight or 0

	progressUProgress.value = (math.floor(weight / 3) + (weight % 3 ~= 0 and 1 or 0)) / 5

	ClientTextUtils.setText(txtValueUBaseText, ClientTextUtils.formatSeparatedNumber(LuaUIUtils.getPropDecomposeNum(data, itemData.sellPrice)))
	weightPanelUWidget:TryChangePage("Type", self.model:isShowWeight() and 0 or 1)
	self.ctrl:refreshOwnerTag(button, data.ownerUid, not self.model:isInGrabEggSpace())
	self:refreshRepairProgressOnButton(button, nil, nil, true)

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, data.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, data.slotIndex)
		dragDropAnimation:Play()
	end

	self:refreshCommonTips(data)

	function button.luaEndDrag(dropWidget)
		self:onDragEnd(button, dropWidget, data)
	end

	function button.luaBeginDrag()
		self:onDragBegin(button)
	end

	function button.luaClick()
		self:onClickItem(button, data, self:getHoverBtnDataList(data, true))
	end

	function button.luaDoubleClick()
		self:onDoubleClick(data)
	end

	function button.luaHover()
		self:onHover(button, false)
	end

	function button.luaUnhover()
		self:onUnHover(button, false)
	end

	function button.luaNavFocused()
		self.model:setHoverData(data)
		self.ctrl:refreshBottomBarGamepad(self:getHoverBtnDataList(data, true))
	end

	function button.luaNavUnfocused()
		self.ctrl:clearBottomBarGamepad()
	end
end

function GrabEggMyBagComponent:onRenderSafeBoxItem(button, index, data)
	button.gameObject.name = data.slotIndex

	local objectReference = button:GetComponent("ObjectReference")
	local itemUButton = objectReference and objectReference:GetRefValue("itemUButton")

	LuaUIUtils.refreshGrabEggAntiqueTags(itemUButton, data)

	local unlock = data.unlock

	if not unlock then
		button.draggable = false

		button:TryChangePage("Safebox", 2)

		function button.luaClick()
			self:onClickLockedSafeBox()
		end

		return
	end

	local haveData = data.itemId ~= nil

	button.draggable = haveData
	button.luaClick = nil

	if not haveData then
		button:TryChangePage("Safebox", 0)

		function button.luaHover()
			self:onHover(button, false)
		end

		function button.luaUnhover()
			self:onUnHover(button, false)
		end

		button.luaNavFocused = nil
		button.luaNavUnfocused = nil

		return
	end

	button:TryChangePage("Safebox", 1)

	local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")

	objectReference = objectReference:GetRefValue("itemObjectReference")

	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local durableUContainer = objectReference:GetRefValue("durableUContainer")
	local itemId = data.itemId
	local itemData = ItemData[itemId]

	if not itemData then
		return
	end

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUText, self.model:getItemCountText(data, false, true))
	LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
	button:TryChangePage("Quality", data.quality)
	LuaUIUtils.refreshGrabEggSkillChipIcon(itemUButton, itemId)
	self.ctrl:refreshOwnerTag(itemUButton, data.ownerUid, not self.model:isInGrabEggSpace())
	self:refreshRepairProgressOnButton(itemUButton, data, button, true)

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, data.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, data.slotIndex)
		dragDropAnimation:Play()
	end

	self:refreshCommonTips(data)

	function button.luaEndDrag(dropWidget)
		self:onDragEnd(button, dropWidget, data)
	end

	function button.luaBeginDrag()
		self:onDragBegin(button)
	end

	function button.luaClick()
		self:onClickItem(button, data, self:getHoverBtnDataList(data))
	end

	function button.luaDoubleClick()
		self:onDoubleClick(data)
	end

	function button.luaHover()
		self:onHover(button, false)
	end

	function button.luaUnhover()
		self:onUnHover(button, false)
	end

	function button.luaNavFocused()
		self.model:setHoverData(data)
		self.ctrl:refreshBottomBarGamepad(self:getHoverBtnDataList(data))
	end

	function button.luaNavUnfocused()
		self.ctrl:clearBottomBarGamepad()
	end
end

function GrabEggMyBagComponent:getHoverBtnDataList(data, withUnload)
	local canEquip = self.model:isEquipBagType(data.type, false)
	local isInGrabEggSpace = self.model:isInGrabEggSpace()
	local canSplit = data.packSlot.count > 1
	local isEquipItem = data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR
	local canRepair = data.type == ItemConst.ITEM_TYPE.REPAIR_KIT and isInGrabEggSpace or isEquipItem and not isInGrabEggSpace
	local canSafeBox = not self.model:isSafeBoxSlot(data.slotIndex)

	return self.model:getItemBtnDataListByType(data, {
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] = canEquip,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] = withUnload and self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY or self.model:isSafeBoxSlot(data.slotIndex) or withUnload and data.isMyBag and not self.model:isSafeBoxSlot(data.slotIndex) and self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX] = canSafeBox,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = isInGrabEggSpace,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.SPLIT] = canSplit,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR] = canRepair
	})
end

function GrabEggMyBagComponent:getEquipSlotBtnDataList(data)
	if not data or not data.itemId then
		return nil
	end

	local isInGrabEggSpace = self.model:isInGrabEggSpace()
	local isInventory = self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY

	if data.type == ItemConst.ITEM_TYPE.CHIP then
		return self.model:getItemBtnDataListByType(data, {
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] = true
		})
	elseif data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR then
		return self.model:getItemBtnDataListByType(data, {
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] = isInventory,
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = isInGrabEggSpace,
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR] = true
		})
	else
		return self.model:getItemBtnDataListByType(data, {
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] = isInventory,
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = isInGrabEggSpace
		})
	end
end

function GrabEggMyBagComponent:onEquipSlotNavFocused(btn)
	local data = btn.dataFromUList
	local btnDataList = data and data.itemId and self:getEquipSlotBtnDataList(data) or nil

	self.model:setHoverData(data)
	self.ctrl:refreshBottomBarGamepad(btnDataList)
end

function GrabEggMyBagComponent:onClickLockedSafeBox()
	if self.model:isInGrabEggSpace() then
		pg.global.ui.tips:showTextTip(pg.getGameString("GRAB_EGG_SAFE_BOX_UNLOCK_IN_LOBBY"))

		return
	end

	local talentId = self.model:getNextSafeBoxLinkTalentId()
	local talentName = self.model:getNextSafeBoxLinkTalentName() or ""

	pg.global.ui:open(UIConst.UI_ID_COMMON_CONFIRM, {
		title = pg.getGameString("GRAB_EGG_SAFE_BOX_UNLOCK_TITLE"),
		desc = string.format(pg.getGameString("GRAB_EGG_SAFE_BOX_UNLOCK_DESC"), talentName),
		okCb = function()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_TALENT, {
				talentId
			})
		end
	})
end

function GrabEggMyBagComponent:onClickItem(button, data, btnDataList)
	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_DECOMPOSE"))

		return
	end

	if pg.game.input:isUsingGamepad() and data and data.invId and data.genID and self.model:isRepairingItem(data.invId, data.genID) then
		self.model:cancelRepairTimer()

		return
	end

	self.curTipsData = data

	local haveBtnList = false

	if btnDataList then
		for k, v in pairs(btnDataList) do
			if v then
				haveBtnList = true

				break
			end
		end
	end

	LuaUIUtils.popupPropTip({
		fromParamCount = true,
		showLock = false,
		showGrabEgg = true,
		id = data.itemId,
		num = data.num,
		targetRect = button,
		itemId = data.itemId,
		itemCount = data.count,
		invId = data.invId,
		genID = data.genID,
		showNumSelector = haveBtnList and data.count > 1,
		btnDataList = btnDataList,
		oriData = data,
		isShowItemInHand = self.model:isInGrabEggSpace(),
		onShowItemInHand = function()
			pg.global.ui:close(UIConst.UI_ID_GRAB_EGGS_BAG)
		end,
		extra = {
			closeFun = function()
				self.ctrl:refreshBottomBarByFocus()
			end
		}
	})
	self.ctrl:clearBottomBarGamepad()
end

function GrabEggMyBagComponent:refreshNormalList()
	local bagCapacity = self.model:getMyBagCapacity()
	local itemList = self.model:getNormalItemDataList(bagCapacity, self.listNormalItem)

	self.listNormalItem:SetList(itemList)
end

function GrabEggMyBagComponent:refreshSafeBox()
	local dataList = self.model:getSafeBoxData()

	self.listSafeBoxUList:SetList(dataList)
end

function GrabEggMyBagComponent:event_onEquipPropChanged(payload)
	if not payload then
		return
	end

	local invId, genId = payload[1], payload[2]

	self:onRefreshSlotByGenId(genId, invId)
end

function GrabEggMyBagComponent:event_onRepairKitStart()
	if self.repairProgressTimerId then
		self:killTimer(self.repairProgressTimerId)
	end

	self.repairProgressTimerId = self:startTimer(function()
		self:refreshRepairProgress()
	end, 0.1, true)
end

function GrabEggMyBagComponent:event_onRepairKitEnd()
	if self.repairProgressTimerId then
		self:killTimer(self.repairProgressTimerId)

		self.repairProgressTimerId = nil
	end

	self:refreshRepairProgress()
end

function GrabEggMyBagComponent:refreshRepairProgress()
	local normalList = self.listNormalItem

	if normalList then
		local count = normalList.itemCount or 0

		for i = 0, count - 1 do
			local res, btn = normalList:TryGetChildAt(i)

			if res and btn then
				self:refreshRepairProgressOnButton(btn)
			end
		end
	end

	local safeBoxList = self.listSafeBoxUList

	if safeBoxList then
		local count = safeBoxList.itemCount or 0

		for i = 0, count - 1 do
			local res, btn = safeBoxList:TryGetChildAt(i)

			if res and btn then
				local data = btn.dataFromUList

				if data and data.itemId then
					local objectReference = btn:GetComponent("ObjectReference")
					local itemUButton = objectReference and objectReference:GetRefValue("itemUButton")

					if itemUButton then
						self:refreshRepairProgressOnButton(itemUButton, data, btn)
					end
				end
			end
		end
	end

	if self.weaponUButton and self.weaponUButton.dataFromUList then
		self:refreshRepairProgressOnButton(self.weaponUButton)
	end

	if self.armorUButton and self.armorUButton.dataFromUList then
		self:refreshRepairProgressOnButton(self.armorUButton)
	end
end

function GrabEggMyBagComponent:refreshRepairProgressOnButton(button, data, dragButton, forceSetup)
	data = data or button.dataFromUList
	dragButton = dragButton or button

	local isRepairing = data and data.invId and data.genID and self.model:isRepairingItem(data.invId, data.genID)
	local objectReference = button:GetComponent("ObjectReference")
	local repairCountdownUContainer = objectReference and objectReference:GetRefValue("repairCountdownUContainer")

	if not repairCountdownUContainer then
		return
	end

	if not isRepairing then
		repairCountdownUContainer:SetActive(false)

		dragButton.draggable = true
		dragButton.dropable = true

		if data then
			data.repairSetupKey = nil
		end

		return
	end

	repairCountdownUContainer:SetActive(true)

	if not repairCountdownUContainer:CheckURLLoaded() then
		repairCountdownUContainer.forceSyncLoad = true

		repairCountdownUContainer:LoadDefaultUrlManually(function()
			self:refreshRepairProgressOnButton(button, data, dragButton, forceSetup)
		end)

		return
	end

	local innerRef = repairCountdownUContainer.content.transform:GetComponent("ObjectReference")

	if not innerRef then
		return
	end

	local setupKey = string.format("%s:%s", data.invId, data.genID)

	if forceSetup or data.repairSetupKey ~= setupKey then
		self:setupRepairCountdown(innerRef, data)

		dragButton.draggable = false
		dragButton.dropable = false
		data.repairSetupKey = setupKey
	end

	local remainSec = self.model:getRepairRemainingSec()
	local durationSec = self.model:getRepairDurationSec()
	local txtTimeUBaseText = innerRef:GetRefValue("txtTimeUBaseText")

	if txtTimeUBaseText then
		ClientTextUtils.setText(txtTimeUBaseText, string.format("%.1fs", remainSec))
	end

	local countDownUCountDown = innerRef:GetRefValue("countDownUCountDown")

	if countDownUCountDown and durationSec > 0 then
		countDownUCountDown:Reset(remainSec, durationSec)
	end
end

function GrabEggMyBagComponent:setupRepairCountdown(innerRef, data)
	local stopUButton = innerRef:GetRefValue("stopUButton")

	if stopUButton then
		function stopUButton.luaClick()
			self.model:cancelRepairTimer()
		end
	end

	local countDownUCountDown = innerRef:GetRefValue("countDownUCountDown")

	if countDownUCountDown then
		countDownUCountDown:TryChangePage("Stage", 1)
	end
end

function GrabEggMyBagComponent:refreshBagState()
	self.btnBag.gameObject.name = ItemConst.ROB_EGG_EQUIP_SLOT.BAG

	local bagCapacity = self.model:getMyBagCapacity()
	local bagData = self.model:getBagData()

	self.btnBag.dataFromUList = bagData
	self.btnBag.draggable = bagCapacity > 0

	if bagCapacity == 0 then
		self.btnBag:TryChangePage("BagState", 1)

		self.btnBag.luaClick = nil

		ClientTextUtils.setText(self.txtBagCapacity, "")

		return
	end

	local objectReference = self.btnBag:GetComponent("ObjectReference")
	local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, bagData.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, bagData.slotIndex)
		dragDropAnimation:Play()
	end

	self.btnBag:TryChangePage("BagState", 0)
	self.btnBag:TryChangePage("Quality", bagData.quality)

	local normalItemCount = self.model:getMyBagNormalItemCount()

	self.iconBag.url = bagData.icon

	local bagName = pg.getLocalizationText(bagData.name)
	local formatStr

	formatStr = normalItemCount == bagCapacity and "%s: <style=Item_Lack>%s</style>/%s" or "%s: %s/%s"

	ClientTextUtils.setText(self.txtBagCapacity, string.format(formatStr, bagName, normalItemCount, bagCapacity))
	self.ctrl:refreshOwnerTag(self.btnBag, bagData.ownerUid, not self.model:isInGrabEggSpace())
	self:refreshCommonTips(bagData)

	function self.btnBag.luaClick()
		self:onClickItem(self.btnBag, bagData, self:getEquipSlotBtnDataList(bagData))
	end

	function self.btnBag.luaEndDrag(dropWidget)
		self:onDragEnd(self.btnBag, dropWidget, bagData)
	end

	function self.btnBag.luaBeginDrag()
		self:onDragBegin(self.btnBag)
	end

	function self.btnBag.luaDoubleClick()
		self:onDoubleClick(bagData)
	end
end

function GrabEggMyBagComponent:refreshEgg()
	self.btnEgg.gameObject.name = ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN

	local eggCapacity = self.model:getMyBagEggCapacity()
	local eggData = self.model:getEggData()
	local haveEgg = eggData.itemId ~= nil

	self.btnEgg.dataFromUList = eggData
	self.btnEgg.draggable = haveEgg

	self.btnEgg:SetActive(eggCapacity > 0)

	if eggCapacity == 0 then
		self.btnEgg:TryChangePage("EggState", 2)

		return
	end

	if not haveEgg then
		self.btnEgg:TryChangePage("EggState", 1)

		return
	end

	local objectReference = self.btnEgg:GetComponent("ObjectReference")
	local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, eggData.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, eggData.slotIndex)
		dragDropAnimation:Play()
	end

	self.btnEgg:TryChangePage("EggState", 0)
	self.btnEgg:TryChangePage("Quality", eggData.quality)

	self.iconEgg.url = eggData.icon

	self.ctrl:refreshOwnerTag(self.btnEgg, eggData.ownerUid, not self.model:isInGrabEggSpace())
	self:refreshCommonTips(eggData)

	function self.btnEgg.luaClick()
		self:onClickItem(self.btnEgg, eggData, self:getEquipSlotBtnDataList(eggData))
	end

	function self.btnEgg.luaEndDrag(dropWidget)
		self:onDragEnd(self.btnEgg, dropWidget, eggData)
	end

	function self.btnEgg.luaBeginDrag()
		self:onDragBegin(self.btnEgg)
	end

	function self.btnEgg.luaDoubleClick()
		self:onDoubleClick(eggData)
	end
end

function GrabEggMyBagComponent:refreshWeapon()
	local weaponData = self.model:getWeaponData()

	self:refreshEquipButton(self.weaponUButton, weaponData, ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON)
	self:refreshRobotWeaponImage(weaponData)
end

function GrabEggMyBagComponent:refreshArmor()
	local armorData = self.model:getArmorData()

	self:refreshEquipButton(self.armorUButton, armorData, ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR)
	self:refreshRobotArmorImage(armorData)
end

function GrabEggMyBagComponent:refreshRobotWeaponImage(weaponData)
	local haveWeapon = weaponData and weaponData.itemId ~= nil

	if self.leftWeaponUImage then
		self.leftWeaponUImage:SetActive(haveWeapon)
	end

	if self.rightWeaponUImage then
		self.rightWeaponUImage:SetActive(haveWeapon)
	end

	if not haveWeapon then
		return
	end

	local url = WEAPON_ICON_BY_QUALITY[weaponData.quality]

	if not url then
		return
	end

	if self.leftWeaponUImage then
		self.leftWeaponUImage.url = url
	end

	if self.rightWeaponUImage then
		self.rightWeaponUImage.url = url
	end
end

function GrabEggMyBagComponent:refreshRobotArmorImage(armorData)
	local haveArmor = armorData and armorData.itemId ~= nil

	if self.robotEquipmentUContainer and self.robotEquipmentUContainer.content then
		self.robotEquipmentUContainer.content:TryChangePage("Equipment", haveArmor and 0 or 1)
	end

	if not haveArmor or not self.armorIconUImage then
		return
	end

	local url = ARMOR_ICON_BY_QUALITY[armorData.quality]

	if url then
		self.armorIconUImage.url = url
	end
end

function GrabEggMyBagComponent:refreshEquipButton(btn, equipData, equipSlotIndex)
	btn.gameObject.name = equipSlotIndex

	local haveData = equipData and equipData.itemId ~= nil

	btn.dataFromUList = equipData

	local isRepairing = haveData and equipData.invId and equipData.genID and self.model:isRepairingItem(equipData.invId, equipData.genID)

	btn.draggable = haveData and not isRepairing

	local objectReference = btn:GetComponent("ObjectReference")

	LuaUIUtils.refreshGrabEggAntiqueTags(btn, equipData)

	local textEmptyUBaseText = objectReference and objectReference:GetRefValue("textEmptyUBaseText")
	local durableUContainer = objectReference and objectReference:GetRefValue("durableUContainer")

	if not haveData then
		btn:TryChangePage("EggState", 1)

		if textEmptyUBaseText then
			ClientTextUtils.setText(textEmptyUBaseText, equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON and pg.getGameString("GRAB_EGG_EMPTY_WEAPON") or pg.getGameString("GRAB_EGG_EMPTY_ARMOR"))
		end

		if durableUContainer then
			durableUContainer:SetActive(false)
		end

		self:refreshRepairProgressOnButton(btn, equipData, nil, true)

		btn.luaClick = nil
		btn.luaEndDrag = nil
		btn.luaBeginDrag = nil
		btn.luaDoubleClick = nil

		return
	end

	btn:TryChangePage("EggState", 0)
	btn:TryChangePage("Quality", equipData.quality)
	LuaUIUtils.refreshGrabEggDurable(durableUContainer, equipData)

	local iconUImage = objectReference and objectReference:GetRefValue("iconUImage")

	if iconUImage then
		iconUImage.url = equipData.icon
	end

	local txtNumUBaseText = objectReference and objectReference:GetRefValue("txtNumUBaseText")

	if txtNumUBaseText then
		txtNumUBaseText:SetActive(true)
		ClientTextUtils.setText(txtNumUBaseText, self.model:getItemCountText(equipData, false, true))
	end

	local dragDropAnimation = objectReference and objectReference:GetRefValue("dragDropAnimation")

	if dragDropAnimation and self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, equipSlotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, equipSlotIndex)
		dragDropAnimation:Play()
	end

	self.ctrl:refreshOwnerTag(btn, equipData.ownerUid, not self.model:isInGrabEggSpace())
	self:refreshCommonTips(equipData)
	self:refreshRepairProgressOnButton(btn, equipData, nil, true)

	function btn.luaClick()
		self:onClickItem(btn, equipData, self:getEquipSlotBtnDataList(equipData))
	end

	function btn.luaEndDrag(dropWidget)
		self:onDragEnd(btn, dropWidget, equipData)
	end

	function btn.luaBeginDrag()
		self:onDragBegin(btn)
	end

	function btn.luaDoubleClick()
		self:onDoubleClick(equipData)
	end
end

function GrabEggMyBagComponent:refreshWeaponChips()
	local weaponData = self.model:getWeaponData()

	self:refreshChipSlot(self.weaponChip1UButton, weaponData, 1)
	self:refreshChipSlot(self.weaponChip2UButton, weaponData, 2)
	self:refreshChipSlot(self.weaponChip3UButton, weaponData, 3)
end

function GrabEggMyBagComponent:refreshArmorChips()
	local armorData = self.model:getArmorData()

	self:refreshChipSlot(self.armorChip1UButton, armorData, 1)
	self:refreshChipSlot(self.armorChip2UButton, armorData, 2)
	self:refreshChipSlot(self.armorChip3UButton, armorData, 3)
end

function GrabEggMyBagComponent:refreshChipSlot(btn, equipData, slotIdx)
	local packSlot = equipData and equipData.packSlot
	local validSlot = packSlot and packSlot:checkChipSlotValid(slotIdx)
	local objectReference = btn:GetComponent("ObjectReference")
	local textEmptyUBaseText = objectReference and objectReference:GetRefValue("textEmptyUBaseText")
	local iconEmptyUImage = objectReference and objectReference:GetRefValue("iconEmptyUImage")

	if not validSlot then
		btn:TryChangePage("EggState", 2)
		btn:SetActive(false)

		btn.dataFromUList = nil
		btn.draggable = false
		btn.luaClick = nil
		btn.luaEndDrag = nil
		btn.luaBeginDrag = nil
		btn.luaDoubleClick = nil

		LuaUIUtils.refreshGrabEggSkillChipIcon(btn, nil)

		return
	end

	btn:SetActive(true)

	local slotData = self.model:getChipSlotData(equipData, slotIdx)
	local haveChip = slotData.itemId ~= nil

	btn.dataFromUList = slotData
	btn.draggable = haveChip

	if not haveChip then
		btn:TryChangePage("EggState", 1)

		local slotCfg = slotData.chipSlotType and RobEggChipSlotData[slotData.chipSlotType]

		if textEmptyUBaseText then
			local name = slotCfg and slotCfg.slotName and pg.getLocalizationText(slotCfg.slotName) or ""

			ClientTextUtils.setText(textEmptyUBaseText, name)
		end

		if iconEmptyUImage then
			iconEmptyUImage.url = slotCfg and slotCfg.slotIcon or ""
		end

		btn.luaClick = nil
		btn.luaEndDrag = nil
		btn.luaBeginDrag = nil
		btn.luaDoubleClick = nil

		LuaUIUtils.refreshGrabEggSkillChipIcon(btn, nil)

		return
	end

	btn:TryChangePage("EggState", 0)
	btn:TryChangePage("Quality", slotData.quality)
	LuaUIUtils.refreshGrabEggSkillChipIcon(btn, slotData.itemId)
	self.ctrl:refreshOwnerTag(btn, slotData.ownerUid, not self.model:isInGrabEggSpace())

	local iconUImage = objectReference and objectReference:GetRefValue("iconUImage")

	if iconUImage then
		iconUImage.url = slotData.icon
	end

	local txtNumUBaseText = objectReference and objectReference:GetRefValue("txtNumUBaseText")

	if txtNumUBaseText then
		txtNumUBaseText:SetActive(false)
	end

	local dragKey = self:getChipDragKey(slotData.equipSlotIndex, slotData.chipSlotIdx)
	local dragDropAnimation = objectReference and objectReference:GetRefValue("dragDropAnimation")

	if dragDropAnimation and self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.MyBag, dragKey) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.MyBag, dragKey)
		dragDropAnimation:Play()
	end

	function btn.luaClick()
		self:onClickItem(btn, slotData, self:getEquipSlotBtnDataList(slotData))
	end

	function btn.luaEndDrag(dropWidget)
		self:onDragEnd(btn, dropWidget, slotData)
	end

	function btn.luaBeginDrag()
		self:onDragBegin(btn)
	end

	function btn.luaDoubleClick()
		self:onDoubleClick(slotData)
	end
end

function GrabEggMyBagComponent:refreshValue()
	local equipValue = self.model:getMyEquipmentValue()

	ClientTextUtils.setText(self.txtEquipValue, ClientTextUtils.formatSeparatedNumber(equipValue))
end

function GrabEggMyBagComponent:refreshWeight()
	if self._weightRefreshFrameId then
		return
	end

	self._weightRefreshFrameId = TimerManager.addNextFrameCb(function()
		self._weightRefreshFrameId = nil

		self:doRefreshWeight()
	end)
end

function GrabEggMyBagComponent:doRefreshWeight()
	local curWeight = self.model:getMyCurLoad()
	local limitWeight = self.model:getMyLoadLimit()
	local proportion = (limitWeight == 0 and 0 or curWeight / limitWeight) * 100
	local weightRange = SysConfigData.WEIGHT_RANGE
	local normalLoad = weightRange[2]
	local maxBoundary = weightRange[#weightRange]
	local state = self.model:getLoadState(curWeight, limitWeight)

	self.barUWidget.maxHp = maxBoundary
	self.barUWidget.hp = math.min(proportion, normalLoad)

	if state == 0 then
		self.barUWidget.sp = 0
	else
		self.barUWidget.sp = math.min(proportion, maxBoundary) - normalLoad
	end

	self.weightDetailUComponent:TryChangePage("WeightState", state)
	ClientTextUtils.setText(self.txtCurWeight, curWeight)

	limitWeight = string.format("%.1f", limitWeight)
	limitWeight = limitWeight:gsub("%.0$", "")

	if state ~= 0 then
		ClientTextUtils.setText(self.txtLoadStateUBaseText, pg.getGameString("GRAB_EGG_BAG_LOAD_" .. state + 1))
	end

	ClientTextUtils.setText(self.txtLimitWeight, ClientTextUtils.concatByLanguage(limitWeight, "kg"))

	local safeCur = self.model:getSafeBoxCurLoad()
	local safeMax = self.model:getSafeBoxLoadLimit()

	self.textSafeBoxWeightUBaseText.supportRichText = true

	local safeCurText

	if safeCur == safeMax then
		safeCurText = string.format("<style=Item_Lack>%s</style>", safeCur)
	else
		safeCurText = tostring(safeCur)
	end

	local safeWeightText = string.format("%s/%s", safeCurText, safeMax)

	ClientTextUtils.setText(self.textSafeBoxWeightUBaseText, ClientTextUtils.concatByLanguage(safeWeightText, "kg"))
end

function GrabEggMyBagComponent:DragToBagWithIndex(propData, index, targetData, showTips, showEffect)
	if not self.model:checkDragRule(propData, targetData, index, showTips) then
		return false
	end

	if showEffect then
		self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, index)
	end

	pg.me:serverMsg("RPC_CS_MoveRobEggItem", propData.invId, propData.genID, targetData and targetData.invId or ItemConst.INV_TYPE_EQUIP_SLOTS, index, propData.packSlot.count)

	return true
end

function GrabEggMyBagComponent:DragToResourceBox(propData, index, showEffect)
	if not index then
		return
	end

	if showEffect then
		self.ctrl:registerDragEffect(self.ctrl.CompName.Search, index)
	end

	local entityId = self.model:getBoxEntityId()

	pg.me:serverMsg("RPC_CS_MoveItemToResourceBox", entityId, propData.invId, propData.genID, index, propData.packSlot.count)
end

function GrabEggMyBagComponent:onDragBegin(button)
	LuaUIUtils.popupPropTip()

	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.ctrl:showInventoryDragArea(true)
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.ctrl:showDiscardDragArea(true)
	end

	if bagType ~= UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.view.dragDeleteUButton:SetActive(true)
	end

	button:TryChangePage("DragState", 2)

	local dragWidget = CS.XGUI.UComponent.draggingWidget

	dragWidget:TryChangePage("DragState", 1)

	dragWidget.dataFromUList = button.dataFromUList

	self:refreshDragWidgetChips(dragWidget, button.dataFromUList)
	self:setEquipChipsOwnStateOnDrag(button.dataFromUList, true)
	self:refreshCanDragInState(button.dataFromUList, true)
end

function GrabEggMyBagComponent:getEquipChipBtns(data)
	if not data then
		return nil
	end

	if data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
		return {
			self.weaponChip1UButton,
			self.weaponChip2UButton,
			self.weaponChip3UButton
		}
	elseif data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR then
		return {
			self.armorChip1UButton,
			self.armorChip2UButton,
			self.armorChip3UButton
		}
	end

	return nil
end

function GrabEggMyBagComponent:isChipBtnOfDraggedEquip(btn, dragData)
	local chips = self:getEquipChipBtns(dragData)

	if not chips then
		return false
	end

	for _, chipBtn in ipairs(chips) do
		if chipBtn == btn then
			return true
		end
	end

	return false
end

function GrabEggMyBagComponent:setEquipChipsOwnStateOnDrag(data, dragging)
	local chips = self:getEquipChipBtns(data)

	if not chips then
		return
	end

	if dragging then
		for _, btn in ipairs(chips) do
			if btn then
				btn:TryChangePage("OwnState", 0)
				btn:TryChangePage("DragState", 2)
			end
		end
	else
		for _, btn in ipairs(chips) do
			if btn then
				btn:TryChangePage("DragState", 0)
			end
		end

		if data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
			self:refreshWeaponChips()
		else
			self:refreshArmorChips()
		end
	end
end

function GrabEggMyBagComponent:refreshDragWidgetChips(dragWidget, data)
	if not dragWidget or not data then
		return
	end

	local equipData

	if data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
		equipData = self.model:getWeaponData()
	elseif data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR then
		equipData = self.model:getArmorData()
	else
		return
	end

	local objectReference = dragWidget:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local equipBtn = objectReference:GetRefValue("equipUComponent")

	if equipBtn then
		self:refreshEquipButton(equipBtn, equipData, data.slotIndex)
	end

	for i = 1, 3 do
		local chipBtn = objectReference:GetRefValue("chip" .. i .. "UComponent")

		if chipBtn then
			local slotData = self.model:getChipSlotData(equipData, i)

			if slotData and slotData.itemId then
				self:refreshChipSlot(chipBtn, equipData, i)
				chipBtn:SetActive(true)
			else
				chipBtn:SetActive(false)
			end
		end
	end
end

function GrabEggMyBagComponent:showEquipPlaceFailTip(failReason)
	if failReason == self.model.EQUIP_PLACE_FAIL_OVERWEIGHT then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_SAFE_BOX_OVERWEIGHT"))
	elseif failReason == self.model.EQUIP_PLACE_FAIL_CANT_SWAP then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_EQUIP_PLACE_NOT_ENOUGH"))
	end
end

function GrabEggMyBagComponent:onDragEnd(button, dropWidget, data)
	LuaUIUtils.popupPropTip()

	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.ctrl:showInventoryDragArea(false, data)
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.ctrl:showDiscardDragArea(false)
	end

	if bagType ~= UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.view.dragDeleteUButton:SetActive(false)
	end

	button:TryChangePage("DragState", 0)
	self:refreshCanDragInState(button.dataFromUList, false)
	self:setEquipChipsOwnStateOnDrag(data, false)

	if UIUtils.IsNull(dropWidget) then
		return
	end

	dropWidget:TryChangePage("DragState", 0)

	local dropName = dropWidget.gameObject.name

	if data.type == ItemConst.ITEM_TYPE.CHIP then
		local targetData = dropWidget.dataFromUList

		if data.equipGenID then
			if targetData and self:isChipSlotTarget(targetData) and targetData.equipGenID == data.equipGenID and targetData.chipSlotIdx ~= data.chipSlotIdx and targetData.chipSlotType == data.chipSlotType then
				self.model:swapEquipChip(data.equipSlotIndex, data.chipSlotIdx, targetData.chipSlotIdx)

				return
			end

			if targetData and targetData.isMyBag and not self.model:isEquipBagSlot(targetData.slotIndex) then
				self.model:removeChipFromEquip(data.invId, data.equipGenID, data.chipSlotIdx, targetData.invId, targetData.slotIndex)
			elseif bagType ~= UIConst.GRAB_EGG_BAG_TYPE.INVENTORY and bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM and targetData and not targetData.isMyBag then
				local entityId = self.model:getBoxEntityId()

				self.model:moveChipToLootBox(entityId, targetData.slotIndex, data.chipSlotIdx, data.invId, data.equipGenID)
			elseif dropName == self.model.DISCARD_DRAG_AREA then
				self.model:moveChipToLootBox("", 0, data.chipSlotIdx, data.invId, data.equipGenID)
			elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY and dropName == self.model.INVENTORY_DRAG_AREA then
				self.model:removeChipFromEquip(data.invId, data.equipGenID, data.chipSlotIdx, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE, 0)
			end

			return
		end

		if targetData and self:isChipSlotTarget(targetData) then
			self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, self:getChipDragKey(targetData.equipSlotIndex, targetData.chipSlotIdx))
		end

		if self.model:dragChipToEquipSlot(data, targetData, false) then
			return
		end
	end

	if data.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
		local targetData = dropWidget.dataFromUList

		if targetData and self.model:isEquipBagSlot(targetData.slotIndex) and (targetData.type == ItemConst.ITEM_TYPE.WEAPON or targetData.type == ItemConst.ITEM_TYPE.ARMOR) then
			self.model:tryRepairEquipWithKit(data, targetData)

			return
		end
	end

	if self.ctrl:isDragEquipSlotItem(data) and bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM and dropName ~= self.model.DISCARD_DRAG_AREA then
		local targetData = dropWidget.dataFromUList
		local isUnloadTarget = dropName == self.model.INVENTORY_DRAG_AREA or targetData and (not targetData.isMyBag or not self.model:isEquipBagSlot(targetData.slotIndex))

		if isUnloadTarget then
			local enough, failReason = self.model:checkEquipSwapPlaceEnough(data, targetData)

			if not enough then
				self:showEquipPlaceFailTip(failReason)

				return
			end
		end
	end

	do
		local targetData = dropWidget.dataFromUList
		local isSrcEquip = (data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR) and not self.ctrl:isDragEquipSlotItem(data)
		local isWornEquipSlot = targetData and targetData.isMyBag and targetData.itemId ~= nil and (targetData.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or targetData.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR)
		local typeMatch = isWornEquipSlot and self.model:checkTypeCanPutInSlot(data.type, data.itemId, targetData.slotIndex)

		if isSrcEquip and typeMatch then
			local enough, failReason = self.model:checkEquipSwapPlaceEnough(targetData, data)

			if not enough then
				self:showEquipPlaceFailTip(failReason)

				return
			end
		end
	end

	local index

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		if dropName == self.model.INVENTORY_DRAG_AREA then
			pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
		else
			local targetData = dropWidget.dataFromUList

			self:DragToBagWithIndex(data, targetData and targetData.slotIndex, targetData, true, true)
		end
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		if dropName == self.model.DISCARD_DRAG_AREA then
			pg.me:releaseCarryIfGenID(data.genID)
			pg.me:serverMsg("RPC_CS_ThrowItemFromRobBag", data.invId, data.genID, data.packSlot.count)
		elseif dropWidget.dataFromUList.isMyBag then
			local targetData = dropWidget.dataFromUList

			self:DragToBagWithIndex(data, targetData and targetData.slotIndex, targetData, true, true)
		end
	elseif dropName == self.model.DISCARD_DRAG_AREA then
		pg.me:releaseCarryIfGenID(data.genID)
		pg.me:serverMsg("RPC_CS_ThrowItemFromRobBag", data.invId, data.genID, data.packSlot.count)
	elseif dropWidget.dataFromUList.isMyBag then
		local targetData = dropWidget.dataFromUList

		self:DragToBagWithIndex(data, targetData and targetData.slotIndex, targetData, true, true)
	else
		index = dropWidget.dataFromUList.slotIndex

		self:DragToResourceBox(data, index, true)
	end
end

function GrabEggMyBagComponent:onDoubleClick(data)
	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	if self.model:isSafeBoxSlot(data.slotIndex) then
		local emptyIndex = self.model:getMyBagEmptyIndex(data.type)

		if emptyIndex then
			pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, data.packSlot.count)
		elseif not self.model:isInGrabEggSpace() then
			pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
		end

		LuaUIUtils.popupPropTip()

		return
	end

	if data.type == ItemConst.ITEM_TYPE.CHIP then
		if data.equipGenID then
			local emptyIndex = self.model:getMyBagEmptyIndex()

			if emptyIndex then
				self.model:removeChipFromEquip(data.invId, data.equipGenID, data.chipSlotIdx, ItemConst.INV_TYPE_ROB_EGG, emptyIndex)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
			end
		elseif not self.model:doubleClickChipToEquipSlot(data, false) then
			if self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
				pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
			else
				self:DragToResourceBox(data, self.model:getResourceBoxEmptyIndex())
			end
		end

		LuaUIUtils.popupPropTip()

		return
	end

	local isEquipSlot = self.model:isEquipBagSlot(data.slotIndex)
	local isEquipItem = data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR

	if isEquipSlot and isEquipItem then
		if data.packSlot and not self.model:checkUnloadEquipSpace(data.packSlot) then
			if not self.model:isInGrabEggSpace() then
				pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
			end
		else
			local emptyIndex = self.model:getMyBagEmptyIndex()

			if emptyIndex then
				pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, data.packSlot.count)
			elseif not self.model:isInGrabEggSpace() then
				pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
			end
		end

		LuaUIUtils.popupPropTip()

		return
	end

	local equipIndex = self.model:getDoubleClickIndex(data.type, data.itemId)
	local sameSlot = equipIndex == data.slotIndex and data.invId == ItemConst.INV_TYPE_EQUIP_SLOTS

	if sameSlot or not equipIndex or not self:DragToBagWithIndex(data, equipIndex, nil, false, false) then
		local emptyIndex = self.model:getMyBagEmptyIndex()

		if isEquipSlot and emptyIndex and data.type ~= ItemConst.ITEM_TYPE.BAG then
			pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, data.packSlot.count)
		elseif self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
			pg.me:serverMsg("RPC_CS_MoveRobEggItem", data.invId, data.genID, 0, 0, data.packSlot.count)
		elseif data.type ~= ItemConst.ITEM_TYPE.EGG then
			self:DragToResourceBox(data, self.model:getResourceBoxEmptyIndex())
		end
	end

	LuaUIUtils.popupPropTip()
end

function GrabEggMyBagComponent:onHover(btn, needCheck)
	self.model:setHoverData(btn.dataFromUList)

	if not btn.isAnyInstanceInDragging then
		btn:TryChangePage("DragState", 0)

		return
	end

	local dragWidget = CS.XGUI.UComponent.draggingWidget
	local dragData = dragWidget.dataFromUList
	local targetData = btn.dataFromUList

	if self:isChipBtnOfDraggedEquip(btn, dragData) then
		return
	end

	btn:TryChangePage("DragState", 4)
	dragWidget:TryChangePage("DragState", 3)

	local _, page = btn:TryGetCurrentPage("EggState")
	local isEmpty = page == 2

	if needCheck and not isEmpty then
		btn:TryChangePage("DargSel", self:calcHoverDragSel(dragData, targetData))
	else
		btn:TryChangePage("DargSel", 0)
		self.ctrl:refreshDragEquipPlaceState(targetData)
	end
end

function GrabEggMyBagComponent:onUnHover(btn, needCheck)
	if self.model then
		self.model:setHoverData(nil)
	end

	if not btn.isAnyInstanceInDragging then
		btn:TryChangePage("DragState", 0)

		return
	end

	local dragWidget = CS.XGUI.UComponent.draggingWidget
	local dragData = dragWidget.dataFromUList
	local targetData = btn.dataFromUList

	if self:isChipBtnOfDraggedEquip(btn, dragData) then
		return
	end

	btn:TryChangePage("DragState", dragData ~= targetData and 0 or 2)
	dragWidget:TryChangePage("DragState", 1)

	local _, page = btn:TryGetCurrentPage("EggState")
	local isEmpty = page == 2

	if needCheck and not isEmpty then
		btn:TryChangePage("DargSel", self:calcUnhoverDragSel(dragData, targetData))
	else
		btn:TryChangePage("DargSel", 0)
		self.ctrl:clearDragEquipPlaceState()
	end
end

function GrabEggMyBagComponent:calcHoverDragSel(dragData, targetData)
	if self:isChipSlotTarget(targetData) then
		local isEmptyChipSlot = targetData.itemId == nil

		if not isEmptyChipSlot then
			return 0
		end

		if self:canDragChipIntoSlot(dragData, targetData) then
			return 1
		end

		return 2
	end

	if self:isRepairKitOnEquipSlot(dragData, targetData) then
		return self:canRepairKitHighlight(dragData, targetData) and 1 or 2
	end

	if targetData == dragData or self.model:checkDragRule(dragData, targetData, targetData and targetData.slotIndex, false) then
		return 1
	end

	return 2
end

function GrabEggMyBagComponent:calcUnhoverDragSel(dragData, targetData)
	if self:isChipSlotTarget(targetData) then
		local isEmptyChipSlot = targetData.itemId == nil

		if isEmptyChipSlot and self:canDragChipIntoSlot(dragData, targetData) then
			return 1
		end

		return 0
	end

	if self:isRepairKitOnEquipSlot(dragData, targetData) then
		return self:canRepairKitHighlight(dragData, targetData) and 1 or 0
	end

	local haveData = targetData and targetData.itemId ~= nil

	if not haveData and self.model and self.model:checkDragRule(dragData, targetData, targetData and targetData.slotIndex, false) then
		return 1
	end

	return 0
end

function GrabEggMyBagComponent:isChipSlotTarget(targetData)
	return targetData and targetData.chipSlotIdx ~= nil and targetData.equipGenID ~= nil
end

function GrabEggMyBagComponent:getChipDragKey(equipSlotIndex, chipSlotIdx)
	return equipSlotIndex * 10 + chipSlotIdx
end

function GrabEggMyBagComponent:canRepairKitHighlight(dragData, targetData)
	if not dragData or dragData.type ~= ItemConst.ITEM_TYPE.REPAIR_KIT or not dragData.isMyBag then
		return false
	end

	if not targetData or not targetData.isMyBag or not self.model:isEquipBagSlot(targetData.slotIndex) or targetData.type ~= ItemConst.ITEM_TYPE.WEAPON and targetData.type ~= ItemConst.ITEM_TYPE.ARMOR then
		return false
	end

	return self.model:canRepairEquipWithKit(dragData, targetData)
end

function GrabEggMyBagComponent:isRepairKitOnEquipSlot(dragData, targetData)
	return dragData and dragData.type == ItemConst.ITEM_TYPE.REPAIR_KIT and targetData and targetData.isMyBag and self.model:isEquipBagSlot(targetData.slotIndex) and (targetData.type == ItemConst.ITEM_TYPE.WEAPON or targetData.type == ItemConst.ITEM_TYPE.ARMOR)
end

function GrabEggMyBagComponent:canDragChipIntoSlot(dragData, targetData)
	if not dragData or dragData.type ~= ItemConst.ITEM_TYPE.CHIP then
		return false
	end

	local equipData

	if targetData.equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
		equipData = self.model:getWeaponData()
	elseif targetData.equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR then
		equipData = self.model:getArmorData()
	end

	return equipData ~= nil and equipData.packSlot ~= nil and self.model:canInsertChip(dragData.itemId, equipData.packSlot, targetData.chipSlotIdx)
end

function GrabEggMyBagComponent:refreshCommonTips(data)
	if not self.curTipsData or not data then
		return
	end

	if self.curTipsData.invId ~= data.invId or self.curTipsData.genID ~= data.genID then
		return
	end

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
		return
	end

	self.curTipsData = data

	pg.global.ui.commonItemTip:refreshView()
end

function GrabEggMyBagComponent:showDragArea(active)
	self.dragCoverUComponent:SetActive(active)
end

function GrabEggMyBagComponent:setElementAndRestoreFocus(list, idx, newData)
	local navMgr = pg.global.navMgr
	local prevFocused = navMgr and navMgr.CurrentFocusedUContent or nil
	local found, oldButton = list:TryGetChildAt(idx)
	local needRestoreFocus = found and oldButton == prevFocused

	list:SetElement(idx, newData)

	if needRestoreFocus then
		TimerManager.addNextFrameCb(function()
			if not self.view then
				return
			end

			local success, newButton = list:TryGetChildAt(idx)

			if success and newButton then
				navMgr:FocusItem(newButton)
			end

			self.ctrl:refreshBottomBarByFocus()
		end)
	else
		self.ctrl:refreshBottomBarByFocus()
	end
end

function GrabEggMyBagComponent:onRefreshSlot(slotIndex, invId)
	if invId == ItemConst.INV_TYPE_ROB_EGG then
		if slotIndex >= ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN and slotIndex <= ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_END then
			self:refreshEgg()
		else
			local allData = self.listNormalItem.itemData

			for idx, data in pairs(allData) do
				if data.slotIndex == slotIndex then
					local newData = self.model:getBagItemDataBySlot(slotIndex, invId)

					self:setElementAndRestoreFocus(self.listNormalItem, idx, newData)

					break
				end
			end
		end
	elseif invId == ItemConst.INV_TYPE_EQUIP_SLOTS then
		if slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.BAG then
			self:refreshNormalList()
			self:refreshEgg()
		elseif slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
			self:refreshWeapon()
			self:refreshWeaponChips()
		elseif slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR then
			self:refreshArmor()
			self:refreshArmorChips()
		elseif self.model:isSafeBoxSlot(slotIndex) then
			local allData = self.listSafeBoxUList.itemData

			for idx, data in pairs(allData) do
				if data.slotIndex == slotIndex then
					local newData = self.model:getSafeBoxItem(slotIndex)

					self:setElementAndRestoreFocus(self.listSafeBoxUList, idx, newData)

					break
				end
			end
		end
	end

	self:refreshBagState()
	self:refreshValue()
	self:refreshWeight()
end

function GrabEggMyBagComponent:onRefreshSlotByGenId(genId, invId)
	local slotsInfo

	if invId == ItemConst.INV_TYPE_ROB_EGG then
		slotsInfo = pg.me.slotsInfo
	elseif invId == ItemConst.INV_TYPE_EQUIP_SLOTS then
		slotsInfo = pg.me.equipSlotsInfo
	else
		return
	end

	for index, data in pairs(slotsInfo) do
		if data.genId == genId then
			self:onRefreshSlot(index, invId)
		end
	end
end

function GrabEggMyBagComponent:showWeight(show)
	local btnList = self.listNormalItem:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local btn = btnList[i]
		local data = btn.dataFromUList

		if data.itemId then
			local objectReference = btn:GetComponent("ObjectReference")
			local weightPanelUWidget = objectReference:GetRefValue("weightPanelUWidget")
			local addonAnimation = objectReference:GetRefValue("addonAnimation")

			if weightPanelUWidget then
				weightPanelUWidget:TryChangePage("Type", show and 0 or 1)

				if show then
					addonAnimation:Play(AnimWeight)
				else
					addonAnimation:Play(AnimCoin)
				end
			end
		end
	end
end

function GrabEggMyBagComponent:refreshCanDragInState(dragData, show)
	local targetData

	for k, btn in ipairs(self.listEquipBtn) do
		targetData = btn.dataFromUList

		local haveData = targetData and targetData.itemId ~= nil
		local _, page = btn:TryGetCurrentPage("EggState")
		local isEmpty = page == 2

		if not isEmpty then
			local highlight

			if show and self:isRepairKitOnEquipSlot(dragData, targetData) then
				highlight = self:canRepairKitHighlight(dragData, targetData)
			else
				highlight = show and not haveData and self.model:checkDragRule(dragData, targetData, targetData and targetData.slotIndex, false)
			end

			btn:TryChangePage("DargSel", highlight and 1 or 0)
		end
	end

	for _, btn in ipairs(self.chipBtns) do
		local _, page = btn:TryGetCurrentPage("EggState")

		if page ~= 2 then
			local slotData = btn.dataFromUList
			local isEmptyChipSlot = slotData and self:isChipSlotTarget(slotData) and slotData.itemId == nil
			local highlight = show and isEmptyChipSlot and self:canDragChipIntoSlot(dragData, slotData)

			btn:TryChangePage("DargSel", highlight and 1 or 0)
		end
	end
end

function GrabEggMyBagComponent:showDecomposeMask(show)
	for k, btn in ipairs(self.listEquipBtn) do
		local objectReference = btn:GetComponent("ObjectReference")
		local imgGrayMaskUWidget = objectReference:GetRefValue("imgGrayMaskUWidget")

		if imgGrayMaskUWidget then
			imgGrayMaskUWidget:SetActive(show)
		end

		if not show then
			local data = btn.dataFromUList

			btn.draggable = data and data.itemId ~= nil and true or false
		else
			btn.draggable = false
		end
	end

	for k, btn in ipairs(self.chipBtns) do
		local objectReference = btn:GetComponent("ObjectReference")
		local imgGrayMaskUWidget = objectReference:GetRefValue("imgGrayMaskUWidget")

		if imgGrayMaskUWidget then
			imgGrayMaskUWidget:SetActive(show)
		end

		if not show then
			local data = btn.dataFromUList

			btn.draggable = data and data.itemId ~= nil and true or false
		else
			btn.draggable = false
		end
	end

	local btnList = self.listNormalItem:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local btn = btnList[i]

		if not show then
			local data = btn.dataFromUList

			btn.draggable = data and data.itemId ~= nil and true or false
		else
			btn.draggable = false
		end
	end

	if self.imgGrayMaskUWidget then
		self.imgGrayMaskUWidget:SetActive(show)
	end
end

return GrabEggMyBagComponent
