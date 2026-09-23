-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\Component\\GrabEggSearchComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSearchComponent")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local GrabEggSearchComponent = Class.LightClass("GrabEggSearchComponent", UIComponent)
local StringEx = require("Core.Framework.String")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local AnimSearchLoop = "VX_Node_GrabEggs_Searching_EmojiLoop"
local AnimSearchGood = "VX_Node_GrabEggs_Searching_EmojiGood"
local DISCOVER_END_MARGIN = 0.5
local Quality2SearchResultAnim = {
	[0] = "VX_Node_GrabEggs_Searching_Normal",
	"VX_Node_GrabEggs_Searching_Normal",
	"VX_Node_GrabEggs_Searching_Normal",
	"VX_Node_GrabEggs_Searching_Normal",
	"VX_Node_GrabEggs_Searching_Purple",
	"VX_Node_GrabEggs_Searching_Yellow",
	"VX_Node_GrabEggs_Searching_Yellow"
}
local Quality2SearchResultSound = {
	[0] = "GrabEgg_Loot_White",
	"GrabEgg_Loot_White",
	"GrabEgg_Loot_Green",
	"GrabEgg_Loot_Blue",
	"GrabEgg_Loot_Purple",
	"GrabEgg_Loot_Golden",
	"GrabEgg_Loot_Rainbow"
}
local AnimWeight = "VX_Node_GrabEggs_Searching_Weight"
local AnimCoin = "VX_Node_GrabEggs_Searching_Coin"

function GrabEggSearchComponent:findObjects()
	self.container = self.view.searchPanelContainer
end

function GrabEggSearchComponent:findContainerObjects()
	local objectReference = self.container.content.transform:GetComponent("ObjectReference")

	self.playerBagUWidget = objectReference:GetRefValue("playerBagUWidget")
	self.groundItemUWidget = objectReference:GetRefValue("groundItemUWidget")
	self.listLootUList = objectReference:GetRefValue("listLootUList")
	self.searchBarUComponent = objectReference:GetRefValue("searchBarUComponent")
	self.txtBoxName = objectReference:GetRefValue("txtBoxName")
	self.dragCoverDiscardUComponent = objectReference:GetRefValue("dragCoverDiscardUComponent")
	self.btnBag = objectReference:GetRefValue("btnBag")
	self.btnEgg = objectReference:GetRefValue("btnEgg")
	self.itemListUList = objectReference:GetRefValue("itemListUList")
	self.iconBag = objectReference:GetRefValue("iconBag")
	self.iconEgg = objectReference:GetRefValue("iconEgg")
	self.textLootName = objectReference:GetRefValue("textLootName")

	function self.itemListUList.luaRenderItem(button, index, data)
		self:onRenderNormalItem(button, index, data, self.itemListUList)
	end

	function self.listLootUList.luaRenderItem(button, index, data)
		self:onRenderNormalItem(button, index, data, self.listLootUList)
	end

	function self.itemListUList.luaVirtualListRefreshCb()
		self.ctrl:refreshHoverDataFromPointer(self.itemListUList)
	end

	function self.listLootUList.luaVirtualListRefreshCb()
		self.ctrl:refreshHoverDataFromPointer(self.listLootUList)
	end

	self.dragCoverDiscardUComponent.gameObject.name = self.model.DISCARD_DRAG_AREA
	self.listLootUList.poolMode = 0
	self.itemListUList.poolMode = 0
end

function GrabEggSearchComponent:onCtor(info)
	self.discoveringSlot = nil
	self.lastDiscoveringSlot = nil
	self.discoveringTimer = nil
	self.startReqInFlight = false
	self.resourceBoxName = pg.getLocalizationText(info.name) or info.name

	self.model:setResourceBoxName(self.resourceBoxName)
end

function GrabEggSearchComponent:initView()
	self.isContainerLoading = false

	self.view.inventoryContainer:SetActive(false)
end

function GrabEggSearchComponent:onDestroy()
	if self.discoveringTimer then
		TimerManager.removeTimer(self.discoveringTimer)
	end

	self.discoveringTimer = nil

	self.model:clearNearbySlotMap()
	UIComponent.onDestroy(self)
end

function GrabEggSearchComponent:initContainer(callback)
	if self.isContainerLoading then
		return
	end

	if self.container:CheckURLLoaded() then
		if callback then
			callback()
		end

		return
	end

	self.isContainerLoading = true

	self.container:LoadDefaultUrlManually(function()
		self.isContainerLoading = false

		self:findContainerObjects()
		self.container:SetActive(true)

		if callback then
			callback()
		end
	end)
end

function GrabEggSearchComponent:showResourceBox(slots)
	self:initContainer(function()
		self.playerBagUWidget:SetActive(false)
		self.groundItemUWidget:SetActive(true)
		self:refreshLootList(slots)
		self:trySearchNext()
	end)
end

function GrabEggSearchComponent:showDeathMonsterBox(slots)
	self:initContainer(function()
		self.playerBagUWidget:SetActive(false)
		self.groundItemUWidget:SetActive(true)
		self:refreshLootList(slots)
		self:trySearchNext()
	end)
end

function GrabEggSearchComponent:showPlayerBag(slots)
	self:initContainer(function()
		self.playerBagUWidget:SetActive(true)
		self.groundItemUWidget:SetActive(false)
		self:refreshBagState()
		self:refreshEgg()
		self:refreshNormalList(slots)
		self:trySearchNext()
	end)
end

function GrabEggSearchComponent:showNearbyItems()
	self:initContainer(function()
		self.playerBagUWidget:SetActive(false)
		self.groundItemUWidget:SetActive(true)
		self.searchBarUComponent:TryChangePage("State", 1)
		ClientTextUtils.setText(self.textLootName, self.resourceBoxName)
		self:refreshLootList()
	end)
end

function GrabEggSearchComponent:onRenderNormalItem(button, index, data, list)
	button.gameObject.name = data.slotIndex

	LuaUIUtils.updateGrabEggBtnDragMode(list, button)
	LuaUIUtils.refreshGrabEggAntiqueTags(button, data)

	local haveData = ToBool(data.itemId)

	button.draggable = false

	LuaUIUtils.refreshGrabEggSkillChipIcon(button, haveData and data.itemId or nil)

	if self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.model:setNearbySlot(index + 1, data.entityId)
	end

	if not haveData then
		if self.discoveringSlot == data.slotIndex then
			TimerManager.removeTimer(self.discoveringTimer)

			self.discoveringTimer = nil
			self.lastDiscoveringSlot = self.discoveringSlot
			self.discoveringSlot = nil

			self:trySearchNext()
		end

		function button.luaHover()
			self:onHover(button)
		end

		function button.luaUnhover()
			self:onUnHover(button)
		end

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local itemId = data.itemId
	local itemData = ItemData[itemId]
	local weight = itemData.weight or 0

	progressUProgress.value = (math.floor(weight / 3) + (weight % 3 ~= 0 and 1 or 0)) / 5
	button.interactable = false
	button.draggable = false

	if data.needDiscovery then
		if self.discoveringSlot == data.slotIndex then
			local objectReference = button:GetComponent("ObjectReference")
			local emojiUContainer = objectReference:GetRefValue("emojiUContainer")
			local iconPlayerUImage = objectReference:GetRefValue("iconPlayerUImage")

			emojiUContainer.forceSyncLoad = true

			emojiUContainer:LoadDefaultUrlManually(function(obj)
				local objectReference = obj.transform:GetComponent("ObjectReference")
				local anim = objectReference:GetRefValue("anim")

				UIUtils.PlayAnimation(anim, AnimSearchLoop)
			end)
			iconPlayerUImage:SetActive(false)
			button:TryChangePage("State", 1)
		else
			button:TryChangePage("State", 0)
		end
	elseif data.searchingUid then
		local objectReference = button:GetComponent("ObjectReference")
		local emojiUContainer = objectReference:GetRefValue("emojiUContainer")
		local iconPlayerUImage = objectReference:GetRefValue("iconPlayerUImage")

		if emojiUContainer then
			emojiUContainer.forceSyncLoad = true

			emojiUContainer:LoadDefaultUrlManually(function(obj)
				local objectReference = obj.transform:GetComponent("ObjectReference")
				local anim = objectReference:GetRefValue("anim")

				UIUtils.PlayAnimation(anim, AnimSearchLoop)
			end)
		end

		if iconPlayerUImage then
			iconPlayerUImage:SetActive(true)
			button:TryChangePage("Teammate", pg.me:getTeamOrder(data.searchingUid) - 1)
			button:TryChangePage("State", 1)
		end
	else
		button.draggable = true
		button.interactable = true

		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
		local btnAnimation = objectReference:GetRefValue("btnAnimation")
		local searchEffectWidget = objectReference:GetRefValue("searchEffectWidget")
		local weightPanelUWidget = objectReference:GetRefValue("weightPanelUWidget")
		local txtValueUBaseText = objectReference:GetRefValue("txtValueUBaseText")
		local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")
		local durableUContainer = objectReference and objectReference:GetRefValue("durableUContainer")

		if not btnAnimation.isPlaying then
			searchEffectWidget:SetActive(false)
		end

		itemIconUImage.forceSyncLoad = true
		itemIconUImage.url = data.icon

		ClientTextUtils.setText(txtNumUBaseText, self.model:getItemCountText(data, false, true))
		LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
		weightPanelUWidget:TryChangePage("Type", self.model:isShowWeight() and 0 or 1)

		local price = LuaUIUtils.getPropDecomposeNum(data, itemData.sellPrice)

		ClientTextUtils.setText(txtValueUBaseText, ClientTextUtils.formatSeparatedNumber(price * data.count))

		if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.Search, data.slotIndex) then
			self.ctrl:unRegisterDragEffect(self.ctrl.CompName.Search, data.slotIndex)
			dragDropAnimation:Play()
		end

		button:TryChangePage("Quality", data.quality)
		self.ctrl:refreshOwnerTag(button, data.ownerUid)

		button.draggable = true

		function button.luaClick()
			self:onClickItem(button, data, self:getHoverBtnDataList(data))
		end

		function button.luaDoubleClick()
			self:onDoubleClick(data)
		end

		function button.luaEndDrag(dropWidget)
			self:onDragEnd(button, dropWidget, data)
		end

		function button.luaBeginDrag()
			self:onDragBegin(button)
		end

		function button.luaHover()
			self:onHover(button)
		end

		function button.luaUnhover()
			self:onUnHover(button)
		end

		function button.luaNavFocused()
			self.model:setHoverData(data)
			self.ctrl:refreshBottomBarGamepad(self:getHoverBtnDataList(data))
		end

		function button.luaNavUnfocused()
			self.ctrl:clearBottomBarGamepad()
		end
	end
end

function GrabEggSearchComponent:getHoverBtnDataList(data)
	local canEquip = self.model:isEquipBagType(data.type, false)
	local isInGrabEggSpace = self.model:isInGrabEggSpace()
	local isCollect = self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM
	local canSplit = isInGrabEggSpace and data.count > 1 and (data.isMyBag or not isCollect)

	return self.model:getItemBtnDataListByType(data, {
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY] = true,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] = canEquip,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX] = true,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = isInGrabEggSpace and not isCollect and data.type ~= ItemConst.ITEM_TYPE.BAG,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.SPLIT] = canSplit
	})
end

function GrabEggSearchComponent:onClickItem(button, data, btnDataList)
	local haveBtnList = false

	if btnDataList then
		for k, v in pairs(btnDataList) do
			if v then
				haveBtnList = true

				break
			end
		end
	end

	local isNearbyItem = self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM and not data.isMyBag

	LuaUIUtils.popupPropTip({
		showGrabEgg = true,
		showLock = false,
		fromParamCount = true,
		id = data.itemId,
		num = data.num,
		targetRect = button,
		itemId = data.itemId,
		itemCount = data.count,
		invId = data.invId,
		showNumSelector = haveBtnList and data.count > 1 and not isNearbyItem,
		btnDataList = btnDataList,
		oriData = data,
		extra = {
			closeFun = function()
				self.ctrl:refreshBottomBarByFocus()
			end
		}
	})
	self.ctrl:clearBottomBarGamepad()
end

function GrabEggSearchComponent:refreshNormalList(slots)
	if not slots then
		local itemList = self.model:getOtherBagNormalDataList()

		self.itemListUList:SetList(itemList)
	else
		for k, slot in pairs(slots) do
			local data = self.model:getResourceDataBySlot(slot)

			self.itemListUList:SetElement(slot - ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN, data)
		end
	end
end

function GrabEggSearchComponent:refreshBagState()
	local bagCapacity = self.model:getOtherBagCapacity()
	local bagData = self.model:getOtherBagData()

	self.btnBag.dataFromUList = bagData
	self.btnBag.draggable = bagCapacity > 0

	if bagCapacity == 0 then
		self.btnBag:TryChangePage("BagState", 1)

		self.btnBag.luaClick = nil

		return
	end

	local objectReference = self.btnBag:GetComponent("ObjectReference")
	local dragDropAnimation = objectReference:GetRefValue("dragDropAnimation")

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.Search, bagData.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.Search, bagData.slotIndex)
		dragDropAnimation:Play()
	end

	self.btnBag:TryChangePage("BagState", 0)
	self.btnBag:TryChangePage("Quality", bagData.quality)

	self.iconBag.url = bagData.icon

	self.ctrl:refreshOwnerTag(self.btnBag, bagData.ownerUid)

	function self.btnBag.luaClick()
		local isInGrabEggSpace = self.model:isInGrabEggSpace()

		self:onClickItem(self.btnBag, bagData, self.model:getItemBtnDataListByType(bagData, {
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] = true
		}))
	end

	function self.btnBag.luaDoubleClick()
		self:onDoubleClick(bagData)
	end

	function self.btnBag.luaEndDrag(dropWidget)
		self:onDragEnd(self.btnBag, dropWidget, bagData)
	end

	function self.btnBag.luaBeginDrag()
		self:onDragBegin(self.btnBag)
	end
end

function GrabEggSearchComponent:refreshEgg()
	self.btnEgg.gameObject.name = ItemConst.ROB_EGG_EQUIP_SLOT.EGG_POS_BEGIN

	local eggCapacity = self.model:getOtherBagEggCapacity()
	local eggData = self.model:getOtherEggData()
	local haveEgg = eggData.itemId ~= nil

	self.btnEgg.dataFromUList = eggData
	self.btnEgg.draggable = haveEgg

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

	if self.ctrl:checkNeedPlayDragEffect(self.ctrl.CompName.Search, eggData.slotIndex) then
		self.ctrl:unRegisterDragEffect(self.ctrl.CompName.Search, eggData.slotIndex)
		dragDropAnimation:Play()
	end

	self.btnEgg:TryChangePage("EggState", 0)
	self.btnEgg:TryChangePage("Quality", eggData.quality)

	self.iconEgg.url = eggData.icon

	self.ctrl:refreshOwnerTag(self.btnEgg, eggData.ownerUid)

	function self.btnEgg.luaClick()
		local isInGrabEggSpace = self.model:isInGrabEggSpace()

		self:onClickItem(self.btnEgg, eggData, self.model:getItemBtnDataListByType(eggData, {
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY] = true,
			[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = isInGrabEggSpace
		}))
	end

	function self.btnEgg.luaDoubleClick()
		self:onDoubleClick(eggData)
	end

	function self.btnEgg.luaEndDrag(dropWidget)
		self:onDragEnd(self.btnEgg, dropWidget, eggData)
	end

	function self.btnEgg.luaBeginDrag()
		self:onDragBegin(self.btnEgg)
	end
end

function GrabEggSearchComponent:refreshLootList(slots)
	local isCollect = self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM
	local dataList = {}

	if isCollect then
		dataList = self.model:getCollectItemList()

		self.listLootUList:SetList(dataList)

		local isEmpty = self.model:getResourceBoxItemCount() == 0

		self.view.rootUComponent:TryChangePage("Empty", isEmpty and 1 or 0)
		self.container:SetActive(not isEmpty)
	elseif not slots then
		dataList = self.model:getNormalResourceDataList()

		self.listLootUList:SetList(dataList)
	else
		for k, slot in pairs(slots) do
			local data = self.model:getResourceDataBySlot(slot)

			self.listLootUList:SetElement(slot - 1, data)
		end
	end
end

function GrabEggSearchComponent:armDiscoverEndTimer(slotIndex, endTime)
	if self.discoveringTimer then
		TimerManager.removeTimer(self.discoveringTimer)

		self.discoveringTimer = nil
	end

	local delay = math.max((endTime or 0) - Time.secondCache, 0) + DISCOVER_END_MARGIN

	self.discoveringTimer = TimerManager.addTimer(delay, function()
		self.discoveringTimer = nil

		if endTime and Time.secondCache < endTime then
			self:armDiscoverEndTimer(slotIndex, endTime)

			return
		end

		self.model:endDiscoverItem(slotIndex, function(errorCode)
			if errorCode ~= Const.LootErrCode.Success then
				logger:error("End Loot error, code: %s, slot: %s", errorCode, slotIndex)
			end
		end)
	end)
end

function GrabEggSearchComponent:onStartSearch(slotIndex, endTime)
	self.startReqInFlight = false

	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local allData = list.itemData

	self.discoveringSlot = slotIndex

	self:armDiscoverEndTimer(slotIndex, endTime)

	for index, data in pairs(allData) do
		if data.slotIndex == slotIndex then
			data.endTime = endTime

			list:SetElement(index, data)

			break
		end
	end
end

function GrabEggSearchComponent:onFinishSearch(slotIndex)
	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local allData = list.itemData

	if self.discoveringSlot == slotIndex then
		if self.discoveringTimer then
			TimerManager.removeTimer(self.discoveringTimer)

			self.discoveringTimer = nil
		end

		self.lastDiscoveringSlot = self.discoveringSlot
		self.discoveringSlot = nil
	end

	local haveFind

	for index, data in pairs(allData) do
		if data.slotIndex == slotIndex then
			haveFind = true
			data.needDiscovery = false
			data.tIndex = 0
			data.searchingUid = nil

			local goodQuality = data.quality >= 6

			local function endSearch()
				list:SetElement(index, data)
				self:playBtnResultEffect(slotIndex)
				self:trySearchNext()
			end

			if goodQuality then
				local btnList = list:GetAllButtons()

				for i = 0, btnList.Length - 1 do
					local button = btnList[i]
					local data = button.dataFromUList

					if data.slotIndex == slotIndex then
						local objectReference = button:GetComponent("ObjectReference")
						local emojiUContainer = objectReference:GetRefValue("emojiUContainer")

						emojiUContainer.forceSyncLoad = true

						emojiUContainer:LoadDefaultUrlManually(function(obj)
							local objectReference = obj.transform:GetComponent("ObjectReference")
							local anim = objectReference:GetRefValue("anim")

							UIUtils.PlayAnimation(anim, AnimSearchGood, endSearch)
						end)

						break
					end
				end
			else
				endSearch()
			end

			break
		end
	end

	if not haveFind then
		self:trySearchNext()
	end
end

function GrabEggSearchComponent:playBtnResultEffect(slotIndex)
	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local btnList = list:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local button = btnList[i]
		local data = button.dataFromUList

		if data.slotIndex == slotIndex then
			local objectReference = button:GetComponent("ObjectReference")
			local btnAnimation = objectReference:GetRefValue("btnAnimation")
			local searchEffectWidget = objectReference:GetRefValue("searchEffectWidget")
			local resultAnim = Quality2SearchResultAnim[data.quality]

			if resultAnim then
				searchEffectWidget:SetActive(true)
				UIUtils.PlayAnimation(btnAnimation, resultAnim)
			end

			local resultSound = Quality2SearchResultSound[data.quality]

			if resultSound then
				pg.game.audio:playEvent(resultSound)
			end

			break
		end
	end
end

function GrabEggSearchComponent:onInterruptedSearch(slotIndex)
	if self.discoveringSlot == slotIndex then
		if self.startReqInFlight then
			return
		end

		self.startReqInFlight = true

		self.model:startDiscoverItem(slotIndex, function(errorCode)
			self.startReqInFlight = false

			if errorCode ~= Const.LootErrCode.Success then
				logger:error("Restart Loot error, code: %s, slot: %s", errorCode, slotIndex)
			end
		end)
	end
end

function GrabEggSearchComponent:onRefreshResourceData(slots)
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX then
		self:showResourceBox(slots)
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER then
		-- block empty
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		self:showDeathMonsterBox(slots)
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG then
		self:showPlayerBag(slots)
	elseif bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self:showNearbyItems(slots)
	end
end

function GrabEggSearchComponent:trySearchNext(errorIndex)
	if self.discoveringSlot or self.startReqInFlight or self.discoveringTimer then
		return
	end

	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local allData = list.itemData
	local searchIndex

	for i = 0, allData.Count - 1 do
		local data = allData[i]

		if data.needDiscovery and data.slotIndex ~= errorIndex then
			if not self.lastDiscoveringSlot or data.slotIndex > self.lastDiscoveringSlot then
				searchIndex = data.slotIndex

				break
			else
				searchIndex = searchIndex or data.slotIndex
			end
		end
	end

	if searchIndex then
		self.startReqInFlight = true

		self.model:startDiscoverItem(searchIndex, function(errorCode)
			self.startReqInFlight = false

			if errorCode == Const.LootErrCode.Success then
				return
			elseif errorCode == Const.LootErrCode.AlreadyDisCovery or errorCode == Const.LootErrCode.Finished then
				self:trySearchNext(searchIndex)
			elseif errorCode == Const.LootErrCode.Failure then
				if not self:resumeInFlightDiscoverIfAny() then
					logger:error("Start Loot error, code: %s, slot: %s", errorCode, searchIndex)
				end
			else
				logger:error("Start Loot error, code: %s, slot: %s", errorCode, searchIndex)
				self:trySearchNext(searchIndex)
			end
		end)
	end

	self.searchBarUComponent:TryChangePage("State", searchIndex and 0 or 1)

	if not searchIndex then
		ClientTextUtils.setText(self.txtBoxName, self.resourceBoxName)
		ClientTextUtils.setText(self.textLootName, self.resourceBoxName)
	end
end

function GrabEggSearchComponent:resumeInFlightDiscoverIfAny()
	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local allData = list.itemData

	for index = 0, allData.Count - 1 do
		local data = allData[index]

		if data.myDiscoverTime and data.needDiscovery and not data.searchingUid then
			self.discoveringSlot = data.slotIndex

			local remain = data.myDiscoverTime - Time.secondCache

			if remain <= 0 then
				self.model:endDiscoverItem(data.slotIndex, function(errorCode)
					if errorCode ~= Const.LootErrCode.Success then
						logger:error("End Loot error, code: %s, slot: %s", errorCode, data.slotIndex)
					end
				end)
			else
				self:armDiscoverEndTimer(data.slotIndex, data.myDiscoverTime)
				list:SetElement(index, data)
			end

			return true
		end
	end

	return false
end

function GrabEggSearchComponent:onDragBegin(button)
	LuaUIUtils.popupPropTip()
	button:TryChangePage("DragState", 2)

	local dragWidget = CS.XGUI.UComponent.draggingWidget

	dragWidget.dataFromUList = button.dataFromUList

	dragWidget:TryChangePage("DragState", 1)

	local objectReference = dragWidget:GetComponent("ObjectReference")
	local searchEffectWidget = objectReference:GetRefValue("searchEffectWidget")

	if searchEffectWidget then
		searchEffectWidget:SetActive(false)
	end

	local bagType = self.model:getBagType()

	if bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.view.dragDeleteUButton:SetActive(true)
	end

	self.ctrl:refreshCanDragInState(button.dataFromUList, true)
end

function GrabEggSearchComponent:onDragEnd(button, dropWidget, data)
	LuaUIUtils.popupPropTip()
	button:TryChangePage("DragState", 0)

	local bagType = self.model:getBagType()

	if bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.view.dragDeleteUButton:SetActive(false)
	end

	self.ctrl:refreshCanDragInState(button.dataFromUList, false)

	if UIUtils.IsNull(dropWidget) then
		return
	end

	dropWidget:TryChangePage("DragState", 0)

	local dropName = dropWidget.gameObject.name

	if bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM and dropName == self.model.DISCARD_DRAG_AREA then
		self.model:takeItemFromBox(data.slotIndex, ItemConst.INV_TYPE_INVAILD, 0)

		return
	end

	local targetData = dropWidget.dataFromUList

	if not targetData then
		return
	end

	if data.type == ItemConst.ITEM_TYPE.CHIP and targetData.chipSlotIdx and targetData.equipGenID then
		self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, targetData.equipSlotIndex * 10 + targetData.chipSlotIdx)

		local fromNearby = bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM

		self.model:dragChipToEquipSlot(data, targetData, true, fromNearby)

		return
	end

	if data.type == ItemConst.ITEM_TYPE.REPAIR_KIT and targetData.isMyBag and self.model:isEquipBagSlot(targetData.slotIndex) and (targetData.type == ItemConst.ITEM_TYPE.WEAPON or targetData.type == ItemConst.ITEM_TYPE.ARMOR) then
		self.model:tryRepairEquipWithKit(data, targetData)

		return
	end

	if targetData.isMyBag then
		self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, targetData.slotIndex)
		self:DragToMyBagWithIndex(data, targetData.invId, targetData.slotIndex, targetData)
	else
		self.ctrl:registerDragEffect(self.ctrl.CompName.Search, targetData.slotIndex)
		self:swapItemInResourceBox(data, targetData)
	end
end

function GrabEggSearchComponent:DragToMyBagWithIndex(dragData, invId, index, targetData)
	if not self.model:checkDragRule(dragData, targetData, index) then
		return
	end

	if self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.model:collectItemToMyBag(dragData.entityId, dragData.interactId, index)
	else
		self.model:takeItemFromBox(dragData.slotIndex, invId, index)
	end
end

function GrabEggSearchComponent:swapItemInResourceBox(dragData, targetData)
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		local targetSlot = targetData.slotIndex
		local dragSlot = dragData.slotIndex

		dragData.slotIndex = targetSlot
		targetData.slotIndex = dragSlot

		self.listLootUList:SetElement(targetSlot - 1, dragData)
		self.listLootUList:SetElement(dragSlot - 1, targetData)

		return
	end

	if (bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER or bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG) and not self.model:checkDragRule(dragData, targetData, targetData.slotIndex) then
		return
	end

	self.model:swapItemInResourceBox(dragData.slotIndex, targetData.slotIndex)
end

function GrabEggSearchComponent:tryTransferToBagOrSafeBox(propData)
	local emptyIndex, haveBag = self.model:getMyBagEmptyIndex(propData.type)

	if emptyIndex then
		self:DragToMyBagWithIndex(propData, ItemConst.INV_TYPE_ROB_EGG, emptyIndex)

		return
	end

	local safeIndex = self.model:getSafeBoxEmptyIndex()

	if safeIndex then
		if not self.model:checkSafeBoxOverweight(propData, nil) then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_SAFE_BOX_OVERWEIGHT"))

			return
		end

		self:DragToMyBagWithIndex(propData, ItemConst.INV_TYPE_EQUIP_SLOTS, safeIndex)

		return
	end

	if haveBag then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_2"))
	end
end

function GrabEggSearchComponent:onDoubleClick(propData)
	local type = propData.type

	if type == ItemConst.ITEM_TYPE.CHIP then
		local isCollect = self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM

		if not self.model:doubleClickChipToEquipSlot(propData, true, isCollect) then
			self:tryTransferToBagOrSafeBox(propData)
		end

		LuaUIUtils.popupPropTip()

		return
	end

	local equipIndex = self.model:getDoubleClickIndex(type, propData.itemId)

	if equipIndex then
		self:DragToMyBagWithIndex(propData, ItemConst.INV_TYPE_EQUIP_SLOTS, equipIndex)
	else
		self:tryTransferToBagOrSafeBox(propData)
	end

	LuaUIUtils.popupPropTip()
end

function GrabEggSearchComponent:onHover(btn)
	self.model:setHoverData(btn.dataFromUList)

	if not btn.isAnyInstanceInDragging then
		btn:TryChangePage("DragState", 0)

		return
	end

	local dragWidget = CS.XGUI.UComponent.draggingWidget

	btn:TryChangePage("DragState", 4)
	dragWidget:TryChangePage("DragState", 3)
	self.ctrl:refreshDragEquipPlaceState(btn.dataFromUList)
end

function GrabEggSearchComponent:onUnHover(btn)
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

	btn:TryChangePage("DragState", dragData ~= targetData and 0 or 2)
	dragWidget:TryChangePage("DragState", 1)
	self.ctrl:clearDragEquipPlaceState()
end

function GrabEggSearchComponent:showDragArea(active)
	if not self.container:CheckURLLoaded() then
		return
	end

	self.dragCoverDiscardUComponent:SetActive(active)
end

function GrabEggSearchComponent:showWeight(show)
	local list
	local bagType = self.model:getBagType()

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER or bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		list = self.listLootUList
	else
		list = self.itemListUList
	end

	local btnList = list:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local btn = btnList[i]
		local data = btn.dataFromUList

		if not data.needDiscovery and not data.searchingUid and data.itemId then
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

return GrabEggSearchComponent
