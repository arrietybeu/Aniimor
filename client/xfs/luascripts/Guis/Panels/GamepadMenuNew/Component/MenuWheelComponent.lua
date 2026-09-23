-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenuNew\\Component\\MenuWheelComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local GamepadMenuItemData = require("Data.gamepad_menu_item_fun_data")
local GamepadMenuItemOrderData = require("Data.gamepad_menu_item_order_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local AddressDataConst = require("Const.AddressDataConst")
local FuncIdConfigData = require("Data.func_index_config_data")
local MenuWheelComponent = Class.LightClass("MenuWheelComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local SceneData = require("Data.scene_data")
local FuncMenuData = require("Data.func_menu_data")
local FuncToMenuIdData = require("Data.func_to_menu_id_data")
local NormalFuncToMenuIdData = require("Data.normal_func_to_menu_id_data")
local FuncMenuListData = require("Data.func_menu_list_data")
local FuncMenuCommonData = require("Data.func_menu_common_use_data")
local HomelandReportUtils = require("Utils.HomelandReportUtils")
local MENU_ITEM_NUM = 8
local MenuItemType = {
	PhotoAlbum = "PHOTO_ALBUM",
	HomelandPlantHandbook = "HOMELANDPLANTHANDBOOK",
	PhotoHideUI = "PHOTO_HIDE_UI",
	HomelandDesign = "HOMELANDDESIGN",
	PhotoAppearance = "PHOTO_APPEARANCE",
	Train = "SPECIALTRAIN",
	PhotoSetting = "PHOTO_SETTING",
	PhotoScanCode = "PHOTO_SCAN_CODE",
	HomeCarManagement = "HOMECAR_MANAGEMENT",
	StationManage = "STATIONMANAGE",
	HomeCampReport = "HOMECAMPREPORT",
	HomelandReport = "HOMELANDREPORT",
	HomelandSeason = "HOMELANDSEASON",
	TowerPets = "TOWER_PETS",
	Event = "ACTIVITYCENTER",
	HomelandLog = "HOMELANDLOG",
	PVP = "PVP",
	TowerBuff = "TOWER_BUFF",
	Map = "MAP",
	PetEntry = "PETENTRY",
	PetBall = "PETBALL",
	Help = "HELP",
	Config = "CONFIG",
	Bag = "BAG",
	PetBook = "PETRESEARCH",
	Quest = "QUEST",
	Photo = "TAKEPHOTO",
	Undefined = "",
	RULE = "RULE",
	CASHSHOP = "CASHSHOP",
	SCHOOLGUIDE = "SCHOOLGUIDE",
	SeasonLobby = "SeasonLobby",
	battlepass = "battlepass",
	GrabEggBag = "GRABEGG_BAG",
	Appearance = "APPEARANCE",
	Service = "SERVICE",
	Album = "ALBUM",
	PhotoInvite = "PHOTOINVITE"
}

function MenuWheelComponent:initView()
	self.menuWheels = {}
	self.menuItemRedDotIds = {}
	self.listData = {}
	self.selectedWheelIndex = nil
end

function MenuWheelComponent:clearWheels()
	for _, entry in ipairs(self.menuWheels) do
		for _, menuItem in ipairs(entry.items) do
			menuItem:ClearRedDot()
		end
	end

	self.menuWheels = {}
	self.menuItemRedDotIds = {}
	self.selectedWheelIndex = nil
end

function MenuWheelComponent:initMenuWheel(button)
	local menuWheelTransform = button.transform
	local menuObjRef = menuWheelTransform:GetComponent("ObjectReference")
	local menuWheel = menuObjRef:GetRefValue("menu")
	local nameUSDFText = menuObjRef:GetRefValue("nameUSDFText")
	local titleText = menuObjRef:GetRefValue("txtWheelUSDFText")

	if titleText then
		ClientTextUtils.setText(titleText, pg.getGameString("GAMEPADMENU_MAIN"))
	end

	menuWheel.areaNum = MENU_ITEM_NUM

	local items = {}

	for i = 1, MENU_ITEM_NUM do
		items[i] = menuWheel.transform:GetChild(i - 1):GetComponent("UButton")
	end

	local entry = {
		transform = menuWheelTransform,
		wheel = menuWheel,
		nameText = nameUSDFText,
		items = items
	}

	table.insert(self.menuWheels, entry)
	self:refreshMenuByScene()

	function menuWheel.onLuaWheelIndexChange(index)
		self:refreshMenuByScene()
		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_SELECTED_CHANGED)
	end

	function menuWheel.onLuaWheelSelect(selectIndex)
		selectIndex = self.selectedWheelIndex or selectIndex

		if not selectIndex or selectIndex < 0 then
			self.ctrl:setMenuOpen(false)

			return
		end

		self:selectItemByScene(selectIndex + 1)
	end
end

function MenuWheelComponent:setWheelOffset(offset)
	if #self.menuWheels == 0 then
		return
	end

	self.menuWheels[1].wheel:SetWheelOffset(offset)
end

function MenuWheelComponent:resetWheel()
	for _, entry in ipairs(self.menuWheels) do
		entry.wheel:ResetWheel()
	end
end

function MenuWheelComponent:_broadcastNameText(text)
	for _, entry in ipairs(self.menuWheels) do
		ClientTextUtils.setText(entry.nameText, text)
	end
end

function MenuWheelComponent:selectItem(wheelIndex)
	if #self.menuWheels == 0 then
		return
	end

	local selectItem = self.menuWheels[1].items[wheelIndex]

	if not selectItem then
		return
	end

	local menuItemType = selectItem.customData
	local selectItemInfo = GamepadMenuItemData[selectItem.customData] or {}

	if not selectItemInfo.disable then
		local funcId = Const.FUNCTION_IDS[menuItemType]
		local isUnLock = pg.me:checkFunctionUnlock(menuItemType) and CommonSwitch[menuItemType] ~= false

		if not isUnLock then
			if FuncIdConfigData[menuItemType] and FuncIdConfigData[menuItemType].unlockDesc then
				local tipText = pg.getLocalizationText(FuncIdConfigData[menuItemType].unlockDesc)

				pg.global.ui.tips:showTextTip(tipText)
			end

			return
		end

		if LuaUIUtils.checkFuncForbidden(funcId) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

			return
		end

		self:handleSelect(menuItemType)
	end

	pg.game.input:temporarilyDisableViewControl()
	self.ctrl:setMenuOpen(false)
end

function MenuWheelComponent:refreshMenu()
	if #self.menuWheels == 0 then
		return
	end

	self.listData = SysConfigData.defaultGamepadMenuList or {}

	local rawIndex = self.menuWheels[1].wheel.wheelIndex

	if self.ctrl.isOpen and self.ctrl.curWheelListIndex == 1 and rawIndex ~= -1 then
		self.selectedWheelIndex = rawIndex
	end

	local wheelIndex = self.ctrl.curWheelListIndex == 1 and rawIndex + 1 or -1
	local hoverName = ""

	for _, entry in ipairs(self.menuWheels) do
		for i, menuItem in ipairs(entry.items) do
			local menuItemKey = self.listData[i]
			local isUnLock = pg.me:checkFunctionUnlock(menuItemKey) and CommonSwitch[menuItemKey] ~= false
			local menuItemInfo

			if menuItemKey then
				menuItemInfo = GamepadMenuItemData[menuItemKey]
			end

			if menuItemInfo then
				menuItem.customData = menuItemKey

				local icon = menuItem:Find("Item/Icon"):GetComponent("UImage")

				if isUnLock then
					icon.url = menuItemInfo.icon or ""
				else
					icon.url = AddressDataConst.GAMEPAD_MENU_EMPTY_ICON
				end

				if i == wheelIndex then
					menuItem:TryChangePage("button", 5)

					hoverName = pg.getLocalizationText(menuItemInfo.name)
				else
					menuItem:TryChangePage("button", 0)
				end

				if menuItemInfo.disable or not isUnLock then
					menuItem:TryChangePage("Empty", 0)
				else
					menuItem:TryChangePage("Empty", 1)
				end
			else
				menuItem.customData = ""

				menuItem:TryChangePage("Empty", 0)
				menuItem:TryChangePage("button", 0)
			end
		end
	end

	self:_broadcastNameText(hoverName)
end

function MenuWheelComponent:selectItemByScene(wheelIndex, skipClose)
	if #self.menuWheels == 0 then
		return
	end

	local selectItem = self.menuWheels[1].items[wheelIndex]

	if not selectItem then
		return
	end

	local data = selectItem.customData

	if not data then
		return
	end

	if not self:isMenuItemUnlocked(data.funcKey) then
		local cfg = FuncIdConfigData[data.funcKey]

		if cfg and cfg.unlockDesc then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(cfg.unlockDesc))
		end

		return
	end

	data.btnClickFunc()
	pg.game.input:temporarilyDisableViewControl()

	if not skipClose then
		self.ctrl:setMenuOpen(false)
	end
end

function MenuWheelComponent:refreshMenuByScene()
	if #self.menuWheels == 0 then
		return
	end

	local BossRushExtraFunc = {
		{
			icon = "$ui_icon_boss2.png",
			name = pg.getGameString("BOSS_RUSH_INFO"),
			btnClickFunc = function()
				pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_ROUTE)
			end
		}
	}

	self.listData = self:getFunctionButtonByScene()

	local rawIndex = self.menuWheels[1].wheel.wheelIndex

	if self.ctrl.isOpen and self.ctrl.curWheelListIndex == 1 and rawIndex ~= -1 then
		self.selectedWheelIndex = rawIndex
	end

	local wheelIndex = self.ctrl.curWheelListIndex == 1 and rawIndex + 1 or -1
	local isBossRush = pg.me.space and pg.me.space:isBossRushEnv()
	local extraIdx = #self.listData + 1
	local hoverName = ""

	for _, entry in ipairs(self.menuWheels) do
		for i, menuItem in ipairs(entry.items) do
			local data = self.listData[i]

			if not data and isBossRush and i == extraIdx then
				data = BossRushExtraFunc[1]
			end

			if data then
				menuItem.customData = data

				self:_renderMenuItem(menuItem, i, wheelIndex, data)

				if i == wheelIndex then
					hoverName = data.name
				end
			else
				menuItem.customData = nil

				self:_bindMenuItemRedDot(menuItem, nil)
				menuItem:TryChangePage("Empty", 0)

				if i == wheelIndex then
					menuItem:TryChangePage("button", 5)
				else
					menuItem:TryChangePage("button", 0)
				end
			end
		end
	end

	self:_broadcastNameText(hoverName)
end

function MenuWheelComponent:_getFuncMenuId(funcKey)
	if not funcKey then
		return nil
	end

	return FuncToMenuIdData[funcKey] or NormalFuncToMenuIdData[funcKey] or Const.FUNCTION_IDS[funcKey]
end

function MenuWheelComponent:_checkExtraCondition(funcKey)
	if funcKey == MenuItemType.HomelandReport then
		return HomelandReportUtils.isAvailable()
	elseif funcKey == MenuItemType.HomeCampReport then
		return HomelandReportUtils.isHomeCampReportAvailable()
	elseif funcKey == MenuItemType.SeasonLobby then
		local hudModel = pg.global.ui.hudV2 and pg.global.ui.hudV2.model

		return hudModel and hudModel:isSeasonLobbyAvailable() or false
	end

	local funcMenuId = self:_getFuncMenuId(funcKey)

	if not funcMenuId then
		return true
	end

	local hudModel = pg.global.ui.hudV2 and pg.global.ui.hudV2.model

	if not hudModel then
		return true
	end

	local config = FuncMenuListData[funcMenuId] or FuncMenuCommonData[funcMenuId]
	local functionType = config and (config["function"] or config.functionType)

	return hudModel:checkFuncExtraCondition(funcMenuId, functionType)
end

function MenuWheelComponent:_getMenuItemRedDotData(funcKey)
	if not funcKey then
		return nil
	end

	local funcMenuId = self:_getFuncMenuId(funcKey)

	if not funcMenuId then
		return nil
	end

	local config = FuncMenuListData[funcMenuId] or FuncMenuCommonData[funcMenuId]
	local redDotData = {}

	if config then
		for key, value in pairs(config) do
			redDotData[key] = value
		end
	end

	redDotData.id = funcMenuId
	redDotData.functionName = redDotData.functionName or funcKey

	return redDotData
end

function MenuWheelComponent:_bindMenuItemRedDot(menuItem, funcKey)
	local redDotData = self:_getMenuItemRedDotData(funcKey)
	local bindingId = redDotData and redDotData.id or false

	if self.menuItemRedDotIds[menuItem] == bindingId then
		return
	end

	menuItem:ClearRedDot()

	self.menuItemRedDotIds[menuItem] = bindingId

	if not redDotData then
		return
	end

	pg.global.ui.funcMenu:bind_RedDotForMenuItem(menuItem, redDotData)
end

function MenuWheelComponent:_renderMenuItem(menuItem, menuIndex, wheelIndex, data)
	self:_bindMenuItemRedDot(menuItem, data.funcKey)

	local isUnlocked = self:isMenuItemUnlocked(data.funcKey)
	local icon = menuItem:Find("Item/Icon"):GetComponent("UImage")

	if isUnlocked then
		icon.url = data.icon

		menuItem:TryChangePage("Empty", 1)
	else
		icon.url = AddressDataConst.GAMEPAD_MENU_EMPTY_ICON

		menuItem:TryChangePage("Empty", 0)
	end

	if menuIndex == wheelIndex then
		menuItem:TryChangePage("button", 5)
	else
		menuItem:TryChangePage("button", 0)
	end
end

function MenuWheelComponent:getCurConfigId()
	local configId = 1

	if pg.me.space and SceneData[pg.me.space.sceneId].funcListId then
		configId = SceneData[pg.me.space.sceneId].funcListId
	end

	return configId
end

function MenuWheelComponent:getFunctionButtonByScene()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		return self:_getPhotoFunctionButtons()
	end

	local sceneId = pg.me.space.sceneId
	local funListData = {}
	local orderData = GamepadMenuItemOrderData[sceneId]

	if not orderData then
		local config = FuncMenuData[self:getCurConfigId()]

		if config.mode == 1 or config.mode == 3 then
			orderData = GamepadMenuItemOrderData[0]
		end
	end

	if orderData then
		for funIndex = 1, 10 do
			funListData[funIndex] = orderData["function" .. funIndex]
		end
	end

	local funcList = {}

	for funIndex = 1, 10 do
		local key = funListData[funIndex]

		if key and self:_checkExtraCondition(key) then
			funcList[#funcList + 1] = {
				funcKey = key,
				name = pg.getLocalizationText(GamepadMenuItemData[key].name),
				icon = GamepadMenuItemData[key].icon,
				btnClickFunc = function()
					self:handleSelect(key)
				end
			}
		end
	end

	return funcList
end

function MenuWheelComponent:_getPhotoFunctionButtons()
	local photoCtrl = pg.global.ui.photo

	if not photoCtrl or not photoCtrl.view then
		return {}
	end

	local v = photoCtrl.view

	local function readIconUrl(btn)
		if not btn then
			return ""
		end

		local iconTrans = btn.transform:Find("Icon")

		if not iconTrans then
			return ""
		end

		local img = iconTrans:GetComponent("UImage")

		return img and img.url or ""
	end

	local function makeItem(displayName, btn)
		return {
			name = displayName,
			icon = readIconUrl(btn),
			btnClickFunc = function()
				if btn then
					btn:OnClickSimulate()
				end
			end
		}
	end

	return {
		makeItem(pg.getGameString("GAMEPAD_PHOTO_SCAN_CODE"), v.btnScanCodeUButton),
		makeItem(pg.getGameString("GAMEPAD_PHOTO_SETTING"), v.btnSettingUButton),
		makeItem(pg.getGameString("GAMEPAD_PHOTO_APPEARANCE"), v.btnAppearanceUButton),
		makeItem(pg.getGameString("PHOTO_HIDE"), v.btnHideUIUButton),
		makeItem(pg.getGameString("GAMEPAD_PHOTO_ALBUM"), v.btnAlbumUButton)
	}
end

function MenuWheelComponent:isMenuItemUnlocked(funcKey)
	if not funcKey then
		return true
	end

	return pg.me:checkFunctionUnlock(funcKey) and CommonSwitch[funcKey] ~= false
end

function MenuWheelComponent:handleSelect(menuItemType)
	if menuItemType == MenuItemType.Photo then
		pg.global.ui.hudV2:openPhotoPanel()
	elseif menuItemType == MenuItemType.Quest then
		pg.global.ui.hudV2:openQuest()
	elseif menuItemType == MenuItemType.PetBook then
		pg.global.ui.hudV2:openPetResearch()
	elseif menuItemType == MenuItemType.Bag then
		pg.global.ui.inventory:open()
	elseif menuItemType == MenuItemType.Config then
		pg.global.ui:open(UIConst.UI_ID_SETTING)
	elseif menuItemType == MenuItemType.Help then
		pg.global.ui:open(UIConst.UI_ID_HELP)
	elseif menuItemType == MenuItemType.PetBall then
		pg.global.ui.hudV2:openPetBall()
	elseif menuItemType == MenuItemType.PetEntry then
		pg.global.ui.hudV2:openPetPanel()
	elseif menuItemType == MenuItemType.Map then
		pg.global.ui.hudV2:openMap()
	elseif menuItemType == MenuItemType.PVP then
		pg.global.ui.hudV2:openPvpMenu()
	elseif menuItemType == MenuItemType.Train then
		pg.global.ui.hudV2:openSpecialTrain()
	elseif menuItemType == MenuItemType.Event then
		pg.global.ui:open(UIConst.UI_ID_EVENT)
	elseif menuItemType == MenuItemType.TowerPets then
		pg.global.ui:open(UIConst.UI_ID_TOWER_STAGE_INFO)
	elseif menuItemType == MenuItemType.TowerBuff then
		pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL)
	elseif menuItemType == MenuItemType.HomelandLog then
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_PET_ACTION, {
			type = 1
		})
	elseif menuItemType == MenuItemType.HomelandPlantHandbook then
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK)
	elseif menuItemType == MenuItemType.HomelandDesign then
		pg.global.ui.funcMenu:furnitureDesign()
	elseif menuItemType == MenuItemType.HomelandSeason then
		pg.global.ui.funcMenu:homelandSeason()
	elseif menuItemType == MenuItemType.HomelandReport then
		pg.global.ui.funcMenu:homelandReport()
	elseif menuItemType == MenuItemType.HomeCampReport then
		pg.global.ui.funcMenu:homeCampReport()
	elseif menuItemType == MenuItemType.StationManage then
		pg.global.ui.homeStationManage:open()
	elseif menuItemType == MenuItemType.HomeCarManagement then
		if CommonSwitch.CAMP_MANAGER then
			pg.global.ui:open(UIConst.UI_ID_CAMP_MANAGER)
		end
	elseif menuItemType == MenuItemType.PhotoInvite then
		pg.global.ui.funcMenu:photoInvite()
	elseif menuItemType == MenuItemType.Album then
		pg.global.ui.funcMenu:album()
	elseif menuItemType == MenuItemType.Service then
		pg.global.ui.funcMenu:service()
	elseif menuItemType == MenuItemType.Appearance then
		pg.global.ui.funcMenu:appearance()
	elseif menuItemType == MenuItemType.GrabEggBag then
		pg.global.ui.hudV2:openBag()
	elseif menuItemType == MenuItemType.battlepass then
		pg.global.ui.funcMenu:battlepass()
	elseif menuItemType == MenuItemType.SeasonLobby then
		pg.global.ui:open(UIConst.UI_ID_SEASON_LOBBY)
	elseif menuItemType == MenuItemType.SCHOOLGUIDE then
		pg.global.ui.funcMenu:schoolGuide()
	elseif menuItemType == MenuItemType.CASHSHOP then
		pg.global.ui.funcMenu:cashShop()
	elseif menuItemType == MenuItemType.RULE then
		pg.global.ui.funcMenu:gameplayRule()
	end
end

return MenuWheelComponent
