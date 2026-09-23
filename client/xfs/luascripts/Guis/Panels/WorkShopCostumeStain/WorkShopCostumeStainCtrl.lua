-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\WorkShopCostumeStainCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local WorkShopCostumeStainCtrl = Class.LightClass("WorkShopCostumeStainCtrl", UICtrl)
local ColorPickComponent = require("Guis.Panels.WorkShopCostumeStain.Component.ColorPickerComponent")
local ClothFabricComponent = require("Guis.Panels.WorkShopCostumeStain.Component.ClothFabricComponent")
local ClothDecalComponent = require("Guis.Panels.WorkShopCostumeStain.Component.ClothDecalComponent")
local TimerManager = require("Core.Timer.TimerManager")
local ClientConst = require("Const.ClientConst")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local AvatarShareService = require("Guis.Utils.AvatarShareService")
local GameConst = CS.FunPlus.WorldX.Const.GameConst

WorkShopCostumeStainCtrl.messages = {}
WorkShopCostumeStainCtrl.TAB_MENU = {
	{
		name = "AVATAR_DYE",
		idx = 1,
		isOpen = true
	}
}

function WorkShopCostumeStainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.selectSecondUV = nil
	self.selectSimpleDye = nil
	self.selectMergeGroup = nil
	self.colorPick = ColorPickComponent.new(self, self.view.colorPicker)
	self.fabric = ClothFabricComponent.new(self)
	self.decal = ClothDecalComponent.new(self)
end

function WorkShopCostumeStainCtrl:closePanel()
	self.model:killHighLightTween()
	self.model.avatarScene:setAvatarCameraModeFar()
	UICtrl.closePanel(self)
end

function WorkShopCostumeStainCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:closePanel()
	end

	function self.view.btnApply.luaClick()
		local consume = self.model:getOperationConsume()

		for _, v in ipairs(consume) do
			if v.ownNum < v.num then
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PAY_FAIL"), 3)

				return
			end
		end

		self:onBtnConfirmSubmit()
	end

	function self.view.listItemsUList.luaRenderItem(button, _, data)
		self:onRenderConsume(button, data)
	end

	function self.view.tabList.luaRenderItem(button, index, data)
		self:onRenderTabItem(button, data)
	end

	function self.view.subItemList.luaRenderItem(button, index, data)
		self:onRenderSubItem(button, data)
	end

	function self.view.patternList.luaRenderItem(button, _, data)
		self:onRenderPatternItem(button, data)
	end

	function self.view.btnHideUButton.luaClick()
		AvatarUtils.onHideUIClicked(self.view.btnHideUButton)
	end

	if self.view.uploadUButton then
		function self.view.uploadUButton.luaClick()
			AvatarShareService.exportClothes()
		end

		local uploadText = self.view.uploadUButton.transform:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(uploadText, pg.getGameString("AVATAR_SAVE_CODE"))
	end

	if self.view.downloadUButton then
		self.view.downloadUButton:SetActiveFastest(not pg.global.platform:isConsole())

		function self.view.downloadUButton.luaClick()
			AvatarShareService.openImportPanel(AvatarShareService.SHARE_TYPE.CLOTHES)
		end

		local downloadText = self.view.downloadUButton.transform:Find("Btn/Text"):GetComponent("USDFText")

		ClientTextUtils.setText(downloadText, pg.getGameString("AVATAR_SHARE_CODE"))
	end
end

function WorkShopCostumeStainCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.avatarScene = nil
end

function WorkShopCostumeStainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.initMode = info.mode

	self.model:setCurShowClothId(info)
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("APPEARANCE_CONSUME_TEXT"))
end

function WorkShopCostumeStainCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_WorkShopCostume_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_WorkShopCostume_CameraMove", true)
end

function WorkShopCostumeStainCtrl:onShow()
	self.model:initAvatarSceneData()
	self.model.avatarScene:registerGesture(self.uid, {
		maskRayBoxTrans = self.view.maskRayBoxTrans
	})
	self.model.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)

	if self.view.uploadUButton and pg.me then
		self.view.uploadUButton:SetActiveFastest(true)
	end

	self:refreshTabView()
	AvatarShareService.tryImportFromClipboard(AvatarShareService.SHARE_TYPE.CLOTHES)
end

function WorkShopCostumeStainCtrl:onHide()
	self.model.avatarScene:unRegisterGesture(self.uid)
end

function WorkShopCostumeStainCtrl:refreshTabView()
	self.view.tabList:SetList(self.TAB_MENU)

	local index = self.initMode - 1 or 0
	local res, button = self.view.tabList:TryGetChildAt(index)

	if not res then
		return
	end

	button:OnClickSimulate()
end

function WorkShopCostumeStainCtrl:onRenderTabItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local icon = oc:GetRefValue("icon")
	local txtName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(txtName, pg.getGameString(data.name))

	if data.isOpen then
		button.interactable = true

		button:TryChangePage("button", 0)
	else
		button.interactable = false

		button:TryChangePage("button", 4)
	end

	function button.luaClick()
		self:onSelectTab(button)
	end
end

function WorkShopCostumeStainCtrl:onSelectTab(button)
	local data = button.dataFromUList

	if not data.isOpen then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)

		return
	end

	ClientTextUtils.setText(self.view.titleShadowUBaseText, pg.getGameString(data.name))

	local btnList = self.view.tabList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", v == button and 1 or 0)
	end

	self.selectTabIdx = data.idx

	if self.selectTabIdx ~= 1 then
		self.selectSecondUV = nil
		self.selectSimpleDye = nil
		self.selectMergeGroup = nil
	end

	if self.selectTabIdx == 1 then
		self.view.rootComponent:TryChangePage("State", 0)
	elseif self.selectTabIdx == 2 then
		self.view.rootComponent:TryChangePage("State", 1)
		self.view.rightPanelUComponent:TryChangePage("Info", 3)
		self.decal:selectDefaultDecalTab()
	elseif self.selectTabIdx == 3 then
		self.view.rootComponent:TryChangePage("State", 2)
		self.view.rightPanelUComponent:TryChangePage("Info", 4)
		self.fabric:selectDefaultFabricTab()
	end

	self:onRefreshAreaView()
end

function WorkShopCostumeStainCtrl:onRefreshAreaView()
	local areas = self.model:getMatAreas(self.selectTabIdx)

	self.view.subItemList:SetList(areas)

	if #areas == 0 then
		return
	end

	local res, subBtn = self.view.subItemList:TryGetChildAt(0)

	if not res then
		return
	end

	subBtn:OnClickSimulate()
end

function WorkShopCostumeStainCtrl:onRenderSubItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local nameUText = oc:GetRefValue("nameUText")

	ClientTextUtils.setText(nameUText, data.name)

	function button.luaClick()
		self:onSelectItem(button)
	end
end

function WorkShopCostumeStainCtrl:onSelectItem(button)
	if button then
		local data = button.dataFromUList

		if data.mergeGroupId then
			local hasNormal = self.model:mergeGroupHasNormal(data.members)

			self.selectMergeGroup = {
				groupId = data.mergeGroupId,
				groupIndex = data.groupIndex,
				members = data.members,
				hasNormal = hasNormal,
				enableGradient = hasNormal and data.enableGradient == true
			}
			self.selectSimpleDye = nil
			self.selectSecondUV = nil
			self.selectAreaIdx = nil
		elseif data.simpleMatName then
			self.selectMergeGroup = nil
			self.selectSimpleDye = {
				matName = data.simpleMatName
			}
			self.selectSecondUV = nil
			self.selectAreaIdx = nil
		elseif data.u2MatName then
			self.selectMergeGroup = nil
			self.selectSecondUV = {
				matName = data.u2MatName,
				partIndex = data.u2PartIndex
			}
			self.selectSimpleDye = nil
		else
			self.selectMergeGroup = nil
			self.selectSecondUV = nil
			self.selectSimpleDye = nil
			self.selectAreaIdx = data.idx
		end
	end

	local btnList = self.view.subItemList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", v == button and 1 or 0)
	end

	if self.selectMergeGroup then
		local normalOnly = self.selectMergeGroup.hasNormal == true

		self.model:enableMergeGroupSwitches(self.selectMergeGroup.groupIndex, normalOnly)
		self.model:selectMergeGroupHighLight(self.selectMergeGroup.groupIndex, normalOnly)
	elseif self.selectSimpleDye then
		self.model:selectSimpleDyeHighLight(self.selectSimpleDye.matName)
	elseif self.selectSecondUV then
		self.model:selectSecondUVHighLight(self.selectSecondUV.matName)
	else
		self.model:selectAreaHighLight(self.selectAreaIdx)
	end

	if self.selectTabIdx == 1 then
		self.colorPick:selectDefaultColorTab()
	elseif self.selectTabIdx == 2 then
		-- block empty
	elseif self.selectTabIdx == 3 then
		-- block empty
	end
end

function WorkShopCostumeStainCtrl:refreshConsume()
	if not self.view or not self.view.listItemsUList then
		return
	end

	local consume = self.model:getOperationConsume()

	if #consume <= 0 then
		self.view.consumeUWidget:SetActiveFastest(false)
	else
		self.view.consumeUWidget:SetActiveFastest(true)
	end

	self.view.listItemsUList:SetList(consume)
end

function WorkShopCostumeStainCtrl:onRenderConsume(button, data)
	LuaUIUtils.renderItemWithCountCheck(button, data, function(numText)
		local ownCount = ItemUtils.getItemCountById(pg.me, data.id)

		LuaUIUtils.renderConsumeText(numText, ownCount, data.num, 1, nil, nil, true)
	end, true)
end

function WorkShopCostumeStainCtrl:onBtnConfirmSubmit()
	local clothesId = self.model.clothId
	local usedNum, unlockNum, allNum = AvatarUtils.getClothesPresetNumInfo(clothesId)
	local targetIndex = usedNum < unlockNum and usedNum + 1 or nil

	self.model.avatarScene:setCurEntityRot(0, self.model.avatarScene.cameraDuration)
	self.model:initAvatarSceneData(true)
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PRESET_SNAPSHOT)
	TimerManager.addTimer(self.model.avatarScene.cameraDuration, function()
		local sizeDelta = Vector2.New(Screen.height, Screen.height)
		local position = Vector2.New(Screen.width / 2 - sizeDelta.x / 2, Screen.height / 2 - sizeDelta.y / 2)

		Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(_, _, success, imageKey)
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
			pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

			if not success then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_WORKSHOP_SAVE_PRESET, {
				title = pg.getGameString("SAVE_PRESET"),
				partName = ItemData[clothesId].itemName,
				usedNum = usedNum,
				unlockNum = unlockNum,
				allNum = allNum,
				confirmCallback = function(presetName)
					if targetIndex then
						self:savePresetCallback(targetIndex, presetName, imageKey)
					else
						pg.global.ui:open(UIConst.UI_ID_WORKSHOP_COVER_PRESET, {
							title = pg.getGameString("APPEARANCE_PRESET"),
							configId = clothesId,
							designType = AvatarUtils.DESIGN_TYPE.COSTUME,
							coverCallback = function(index)
								self:savePresetCallback(index, presetName, imageKey)
							end
						})
					end
				end
			})
		end, position, sizeDelta, 3, false, true)
	end)
end

function WorkShopCostumeStainCtrl:savePresetCallback(index, newName, imageKey)
	self.model:onSubmitChanged(index, newName, imageKey, function(res)
		if not res then
			return
		end

		pg.me:applyPlayerClothStain()

		local ent = self.model.avatarScene:getCurEntity()
		local slotId = self.model.slotId

		if ent and ent.curShow and ent.curShow.clothesDesigns and ent.curShow.clothesDesigns[slotId] then
			ClientModelUtils.applyClothStainInfo(ent, slotId, ent.curShow.clothesDesigns[slotId])
		elseif ent and ent.applyPlayerClothStain then
			ent:applyPlayerClothStain()
		end

		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_COVER_PRESET)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_SAVE_PRESET)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_DESIGN)
		facade:sendMsgToUI(MessageName.ON_PRESET_SAVE, {
			tabName = "APPEARANCE_CLOTHES"
		})
	end)
end

return WorkShopCostumeStainCtrl
