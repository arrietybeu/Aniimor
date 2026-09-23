-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\PlayerEnhanceCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local PlayerEnhanceCtrl = Class.LightClass("PlayerEnhanceCtrl", UICtrl)
local PlayerSkillTreeComponent = require("Guis.Panels.PlayerEnhance.Component.PlayerSkillTreeComponent")
local PlayerSkillEquipComponent = require("Guis.Panels.PlayerEnhance.Component.PlayerSkillEquipComponent")
local PlayerGamePadComponent = require("Guis.Panels.PlayerEnhance.Component.PlayerGamePadComponent")
local PlayerUISceneComponent = require("Guis.Panels.PlayerEnhance.Component.PlayerUISceneComponent")
local BadgeOverviewComponent = require("Guis.Panels.PlayerEnhance.Component.BadgeOverviewComponent")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local FuncMenuListData = require("Data.func_menu_list_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local ItemSourceData = require("Data.item_source_data")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local NoticeDef = require("Common.NoticeDef")

PlayerEnhanceCtrl.messages = {}

local UI_IN_ANIM = "UI_Pb_Personal_New_Main_In"

function PlayerEnhanceCtrl:_applyOpenInfo(info)
	if not info then
		return
	end

	self.defaultPlayerActive = info.defaultPlayerActive
	self.defaultMode = info.defaultMode
	self.defaultTreeId = info.defaultTreeId
	self.defaultTab = info.defaultTab
	self.badgeTabIndex = info.badgeTabIndex
	self.badgeIdLook = info.badgeIdLook
	self.defaultSelectSkillId = info.defaultSelectSkillId
	self.firstEnter = info.firstEnter
	self.canShowNavigationArrow = info.firstEnter ~= true
end

function PlayerEnhanceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:_applyOpenInfo(info)

	self.skillTreePageCmp = PlayerSkillTreeComponent.new(self, self.view.pbSkillPage)
	self.skillEquipPageCmp = PlayerSkillEquipComponent.new(self, self.view.equipPanel)
	self.badgeOverviewPageCmp = BadgeOverviewComponent.new(self, self.view.badgeRectTransform)
	self.modelScene = PlayerUISceneComponent.new(self)

	self.view.topBackUWidget:SetActive(false)
end

function PlayerEnhanceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:_applyOpenInfo(info)
end

function PlayerEnhanceCtrl:onDestroy()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("PlayerEnhance")
	end

	self.model:redDot_CheckSaveDirty()

	self.tabIndex = nil
	self.defaultPlayerActive = nil
	self.defaultMode = nil
	self.defaultTreeId = nil
	self.defaultTab = nil
	self.badgeTabIndex = nil
	self.badgeIdLook = nil
	self.defaultSelectSkillId = nil
	self.firstEnter = nil
	self.pendingPlayModelEnterTimeline = nil
	self.canShowNavigationArrow = nil
	self.pendingNavigationFocus = nil

	UICtrl.onDestroy(self)
end

function PlayerEnhanceCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onClosePanel()
		end
	end

	local closeBind2 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind2")

	closeBind2.isVirtual = true
	closeBind2.priority = -1
	closeBind2.actionPath = "Hud/OpenInformation"

	function closeBind2.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onClosePanel()
		end
	end

	function self.view.btnClosePanel.luaClick()
		self:onClosePanel()
	end

	function self.view.btnInfoUButton.luaRenderTooltip(button, toolTip)
		LuaUIUtils.renderLevelToolTip(toolTip)
	end

	function self.view.combatList.luaRenderItem(button, index, data)
		self:onRenderEquipSkillItem(button, index, data)
	end

	function self.view.exploreList.luaRenderItem(button, index, data)
		self:onRenderEquipSkillItem(button, index, data)
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local name1 = objectReference:GetRefValue("name1")
		local name2 = objectReference:GetRefValue("name2")

		ClientTextUtils.setText(name1, ClientTextUtils.getGameString(data.tabName))
		ClientTextUtils.setText(name2, ClientTextUtils.getGameString(data.tabName))

		button.gameObject.name = string.format("UI_Node_PersonalTab_%d", index)

		function button.luaClick()
			self.view.listTabUList:DeselectAll()
			self.view.listTabUList:SelectItem(index)
			self:switchTab(data.tabIndex)
		end

		if data.setRedDot then
			data.setRedDot(button)
		end
	end

	function self.view.btnEquipC.luaClick()
		self:switchToCombatEquip()
	end

	function self.view.btnEquipE.luaClick()
		self:switchToExploreEquip()
	end

	function self.view.btnEquipP.luaClick()
		self:switchToPetEquip()
	end

	function self.view.btnGiftUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PLAYER_LV_REWARD, {
			closeCallBack = function()
				return
			end
		}, function()
			return
		end)
	end

	function self.view.btnAmendUButton.luaClick()
		local param = {
			playerId = pg.me.uid,
			callBack = function()
				return
			end
		}

		pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_MAIN, param)
	end

	function self.view.badgeUList.luaRenderItem(button, index, data)
		self:onRenderBadgeTab(button, index, data)
	end

	function self.view.badgeUList.luaClick(button, data)
		if data.isUnlock then
			self:openBadgePage(data.tabIndex)
			self:initTabShow()
		else
			pg.global.showBubbleMessage(NoticeDef.BADGE_MAIN_IS_LOCK)
		end
	end

	function self.view.btnGoUButton.luaClick()
		self:onClickGoButton()
	end

	ClientTextUtils.setText(self.view.btnGONameUSDFText, pg.getGameString("PROMOTE_TITLE"))
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PLAYER_REWARD_BTN, self.view.btnGiftUButton, function()
		if pg.global.ui.playerLvReward.model:redDot_CheckHasLvReward() then
			return RedDotConst.RedDotStyle.POINT
		end

		return RedDotConst.RedDotStyle.NONE
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PLAYER_UP_STAR, self.view.btnStar, function()
		if self.model:redDot_CheckCanStarUP() then
			return RedDotConst.RedDotStyle.UP_SIGN
		end

		return RedDotConst.RedDotStyle.NONE
	end)

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("PlayerEnhance", function()
			if self.view then
				if not self.canShowNavigationArrow then
					local navMgr = pg.global.navMgr
					local focusedUContent = navMgr.CurrentFocusedUContent

					if focusedUContent then
						self.pendingNavigationFocus = focusedUContent

						navMgr:ClearFocus()
					end

					return
				end

				self:refreshConsoleBarState()
			end
		end)
	end
end

function PlayerEnhanceCtrl:requestPlayModelEnterTimeline()
	if self.view and self.modelScene then
		self.pendingPlayModelEnterTimeline = nil

		self:playModelEnterTimeline()

		return
	end

	self.pendingPlayModelEnterTimeline = true
end

function PlayerEnhanceCtrl:playModelEnterTimeline()
	if self.firstEnter then
		self:startTimer(function()
			pg.game.audio:playEvent("SFX_UI_Personal_SystemStart")
			self:playUIInAnim()
		end, 2.3499999999999996)
	else
		self:playUIInAnim()
	end

	self.modelScene:playEnterAnimation()
end

function PlayerEnhanceCtrl:playUIInAnim()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLAYER_ENHANCE_LOADING) then
		pg.global.ui.playerEnhanceLoading:close()
	end

	local afterUIInAnimation

	if self.firstEnter then
		function afterUIInAnimation()
			self.canShowNavigationArrow = true

			local navMgr = pg.global.navMgr
			local pendingNavigationFocus = self.pendingNavigationFocus

			self.pendingNavigationFocus = nil

			if self.view and navMgr and pendingNavigationFocus and pg.game.input:isUsingGamepad() then
				navMgr:FocusItem(pendingNavigationFocus)
			end
		end
	else
		self.canShowNavigationArrow = true
		self.pendingNavigationFocus = nil
	end

	UIUtils.PlayAnimation(self.view.mainPanelAnimation, UI_IN_ANIM, afterUIInAnimation)
	self.view.topBackUWidget:SetActive(true)
	self:initTabShow()

	if self.firstEnter then
		local badgeTabData = self.model:getBadgeTabData()

		self.view.badgeUList:SetList(badgeTabData)
	end

	self.firstEnter = nil
	self.badgeTabIndex = nil
	self.badgeIdLook = nil
end

function PlayerEnhanceCtrl:onShow()
	self.model:redDot_SetPlayerFuncMenuTreeState()
	self.model:redDot_SetPlayerHUDTreeState()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_PLAYER)
	ClientTextUtils.setText(self.view.closeBtnUSDFText, pg.getLocalizationText(FuncMenuListData[21].name))

	local tabData = self.model:getListTabData()

	self.curListTabData = tabData

	self.view.listTabUList:SetList(tabData)
	self:initDefaultPage()

	if not self.firstEnter then
		self.pendingPlayModelEnterTimeline = nil

		local badgeTabData = self.model:getBadgeTabData()

		self.view.badgeUList:SetList(badgeTabData)
		self:playModelEnterTimeline()
	else
		UIUtils.SampleAnimation(self.view.mainPanelAnimation, 0, UI_IN_ANIM)

		if self.pendingPlayModelEnterTimeline then
			self.pendingPlayModelEnterTimeline = nil

			self:playModelEnterTimeline()
		end
	end
end

function PlayerEnhanceCtrl:initTabShow()
	local tabIndex = self:getTabIndexByMode(self.page)

	if tabIndex == nil then
		return
	end

	local listIndex = self:getListIndexByTabIndex(tabIndex)

	if listIndex == nil then
		return
	end

	self.view.listTabUList:DeselectAll()
	self.view.listTabUList:SelectItem(listIndex, false)
end

function PlayerEnhanceCtrl:refreshView()
	self:refreshPlayerInfoView()
	self:refreshCombatSkillView()
	self:refreshExploreSkillView()
end

function PlayerEnhanceCtrl:refreshConsoleBarState()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local onMainPage = self.page == self.model.MODEL_STATE.MAIN_PAGE
	local onSkillTreePage = self.page == self.model.MODEL_STATE.SKILL_TREE
	local onBadgePage = self.page == self.model.MODEL_STATE.BADGE_PAGE

	navMgr:SetConsoleBarState("onMainPage", onMainPage)
	navMgr:SetConsoleBarState("onSkillTreePage", onSkillTreePage)
	navMgr:SetConsoleBarState("onBadgePage", onBadgePage)
end

function PlayerEnhanceCtrl:refreshPlayerInfoView()
	local res = self.model:getPlayerBaseInfo()
	local playerMaxLv = LuaUIUtils.getMaxCurrentLv(res.star)

	self.view.starUImage.url = res.icon

	ClientTextUtils.setText(self.view.playerNameUSDFText, LuaUIUtils.getMeDisplayName())
	ClientTextUtils.setText(self.view.starUSDFText, res.starName)
	ClientTextUtils.setText(self.view.playerStarUSDFText, res.fullStarName)
	ClientTextUtils.setText(self.view.playerLevelUSDFText, pg.getGameString("PLAYER_LEVEL_TXT") .. string.format("%s/%s", res.lv, playerMaxLv))
	ClientTextUtils.setText(self.view.playerLvNumUSDFText, res.lv)
	ClientTextUtils.setText(self.view.txtPetLvUSDFText, pg.getFormatText(pg.getGameString("CURRENT_MAX_LEVEL"), res.maxPetLv))
	self.view.cardRootCmp:TryChangePage("Nation", self.model.getStarTitleColor(res.star))
	self.view.btnInfoUButton:SetActive(res.star > 0)
	ClientTextUtils.setText(self.view.playerTitleUSDFText, self.model.getMeTitle())
	self.view.imgLikabilityUImage:SetActive(false)

	local pData = LuaUIUtils.getPlayerInfo()

	self.view.lvExpUProgress.maxValue = 1
	self.view.lvExpUProgress.value = pData.curExp / pData.maxExp

	local canUpStar = LuaUIUtils.checkNeedUpTitle()

	self.view.btnGoUButton:TryChangePage("Up", canUpStar and 1 or 0)
end

function PlayerEnhanceCtrl:refreshCombatSkillView()
	local dataList = self.model:getEquippedSkillList(true)

	self.view.combatList:SetList(dataList)
	ClientTextUtils.setText(self.view.textCG, self.model:getGroupName(true))
end

function PlayerEnhanceCtrl:refreshExploreSkillView()
	local dataList = self.model:getEquippedSkillList(false)

	self.view.exploreList:SetList(dataList)
	ClientTextUtils.setText(self.view.textEG, self.model:getGroupName(false))
end

function PlayerEnhanceCtrl:onRenderEquipSkillItem(button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local iIcon = oc:GetRefValue("icon")
	local iPbKey = oc:GetRefValue("hotKeyContent")

	function button.luaClick()
		if data.locked then
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
		elseif data.isCombat then
			self:switchToCombatEquip(data)
		else
			self:switchToExploreEquip(data)
		end
	end

	if data.locked then
		button:TryChangePage("Lock", 0)

		return
	else
		button:TryChangePage("Lock", 1)
	end

	iPbKey:SetHotKeyPaths(data.fixedKeyBoard)
	button:TryChangePage("BgType", data.isCombat and 0 or 1)

	local treePath = string.format(RedDotConst.RedDotPath.PLAYER_EQUIP_SKILL_LIST_ITEM, tostring(data.isCombat), data.index)
	local showRedDot = self.model:redDot_GetPlayerMainEquipState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.POINT)

	button.name = index

	if data.isEmpty then
		button:TryChangePage("isEmpty", 1)

		return
	end

	iIcon.url = data.icon

	button:TryChangePage("isEmpty", 0)
end

function PlayerEnhanceCtrl:onRenderExplorePetItem(button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local iIcon = oc:GetRefValue("iconUImage")
	local listCharUList = oc:GetRefValue("listCharUList")
	local addonUComponent = oc:GetRefValue("addonUComponent")

	button:TryChangePage("state", data.isEmpty and 2 or 0)

	function button.luaClick()
		self:switchToPetEquip()
	end

	local treePath = string.format(RedDotConst.RedDotPath.PLAYER_EQUIP_PET_LIST_ITEM, data.index)
	local showRedDot = self.model:redDot_GetPlayerMainPetState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.POINT)

	button.name = index

	if data.isEmpty then
		return
	end

	button:TryChangePage("Type", data.shine and 1 or 0)

	iIcon.url = data.icon

	if #data.exploreData > 0 then
		addonUComponent:TryChangePage("ShowElementIcon", 1)

		function listCharUList.luaRenderItem(uButton, _, charData)
			self:renderPetChar(uButton, charData)
		end

		listCharUList:SetList(data.exploreData)
	else
		addonUComponent:TryChangePage("ShowElementIcon", 0)
	end
end

function PlayerEnhanceCtrl:renderPetChar(uButton, data)
	uButton:TryChangePage("quality", data.propertyLv - 1)
	uButton:TryChangePage("PetChar", data.index)
end

function PlayerEnhanceCtrl:switchModelTrans(state, data, closeTransition)
	if self.page == self.model.MODEL_STATE.SKILL_EQUIP and state ~= self.model.MODEL_STATE.SKILL_EQUIP then
		self.skillEquipPageCmp:close()
	end

	if self.page == self.model.MODEL_STATE.SKILL_TREE and state ~= self.model.MODEL_STATE.SKILL_TREE then
		self.skillTreePageCmp:close()
	end

	self.modelScene:setPlayerActive(true)

	if state == self.model.MODEL_STATE.MAIN_PAGE then
		self.view.listTabUList:SetActive(true)

		local res, tabSkillTree = self.view.listTabUList:TryGetChildAt(0)

		if res then
			tabSkillTree:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end

		self.view.component:TryChangePage("Sence", 0)

		if not closeTransition then
			self.modelScene:switchToMain()
		end

		self:startTimer(function()
			self:refreshView()
		end, 0.1)
		ClientTextUtils.setText(self.view.topUSDFText, pg.getGameString("PERSONAL_TAB_0"))
	elseif state == self.model.MODEL_STATE.SKILL_TREE then
		self.view.listTabUList:SetActive(true)
		self.view.component:TryChangePage("Sence", 1)
		self.modelScene:setPlayerActive(false)
		self.skillTreePageCmp:open(data)
		ClientTextUtils.setText(self.view.topUSDFText, pg.getGameString("PERSONAL_TAB_1"))
	elseif state == self.model.MODEL_STATE.SKILL_EQUIP then
		self.view.component:TryChangePage("Sence", 2)
		self.view.listTabUList:SetActive(false)

		local mode = data and data.mode or 1

		if mode == 1 then
			self.modelScene:switchToCombats()
		else
			self.modelScene:switchToExplore()
		end

		self.skillEquipPageCmp:open(mode or 1, data and data.id, data and data.defaultSelectSkillId)
		ClientTextUtils.setText(self.view.topUSDFText, pg.getGameString("CHARACTER_SKILL_EQUIP"))
	elseif state == self.model.MODEL_STATE.BADGE_PAGE then
		self.view.listTabUList:SetActive(true)
		self.view.component:TryChangePage("Sence", 3)
		self.modelScene:setPlayerActive(false)
		ClientTextUtils.setText(self.view.topUSDFText, pg.getGameString("PERSONAL_TAB_BADGE"))
	end

	self.page = state

	self:refreshConsoleBarState()
end

function PlayerEnhanceCtrl:initDefaultPage()
	local defaultMode = self:getDefaultMode()

	if defaultMode == self.model.MODEL_STATE.BADGE_PAGE then
		if self:getListIndexByTabIndex(1) ~= nil then
			self:openBadgePage(self.badgeTabIndex)
		else
			self.badgeTabIndex = nil
			self.badgeIdLook = nil

			self:switchModelTrans(self.model.MODEL_STATE.MAIN_PAGE, {
				mode = 0
			}, true)
		end
	elseif defaultMode == self.model.MODEL_STATE.SKILL_TREE then
		self:switchModelTrans(defaultMode, {
			noJump = true,
			mode = 0,
			treeId = self.defaultTreeId,
			defaultSelectSkillId = self.defaultSelectSkillId
		}, true)
	elseif defaultMode == self.model.MODEL_STATE.SKILL_EQUIP then
		self:switchModelTrans(defaultMode, {
			mode = 1,
			defaultSelectSkillId = self.defaultSelectSkillId
		}, true)
	else
		self:switchModelTrans(self.model.MODEL_STATE.MAIN_PAGE, {
			mode = 0
		}, true)
	end

	self.defaultMode = nil
	self.defaultTreeId = nil
	self.defaultSelectSkillId = nil
end

function PlayerEnhanceCtrl:getDefaultMode()
	if self.defaultMode then
		return self.defaultMode
	end

	if self.defaultTab == 1 then
		return self.model.MODEL_STATE.BADGE_PAGE
	elseif self.defaultTab == 2 then
		return self.model.MODEL_STATE.SKILL_TREE
	end

	return self.model.MODEL_STATE.MAIN_PAGE
end

function PlayerEnhanceCtrl:getTabIndexByMode(mode)
	if mode == self.model.MODEL_STATE.MAIN_PAGE then
		return 0
	elseif mode == self.model.MODEL_STATE.BADGE_PAGE then
		return 1
	elseif mode == self.model.MODEL_STATE.SKILL_TREE then
		return 2
	end
end

function PlayerEnhanceCtrl:getListIndexByTabIndex(tabIndex)
	local tabData = self.curListTabData or self.model:getListTabData()

	for index, data in ipairs(tabData) do
		if data.tabIndex == tabIndex then
			return index - 1
		end
	end
end

function PlayerEnhanceCtrl:initMainPage()
	self:switchModelTrans(self.model.MODEL_STATE.MAIN_PAGE, {
		mode = 0
	}, true)
end

function PlayerEnhanceCtrl:switchTab(tab)
	local curTab = math.clamp(tab, 0, 2)

	if self.tabIndex ~= curTab then
		if self.tabIndex == 1 then
			self:closeBadgePage()
		elseif self.tabIndex == 2 then
			self:closeSkillTreePage()
		end

		self.tabIndex = curTab

		if curTab == 2 then
			self:openSkillTreePage()
		elseif curTab == 1 then
			self:openBadgePage()
		else
			self:switchModelTrans(self.model.MODEL_STATE.MAIN_PAGE)
		end
	end
end

function PlayerEnhanceCtrl:openBadgeUI()
	return
end

function PlayerEnhanceCtrl:onRenderBadgeTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local titleIconUImage = objectReference:GetRefValue("titleIconUImage")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local titleIconLightUImage = objectReference:GetRefValue("titleIconLightUImage")
	local txtNotUnlockedUSDFText = objectReference:GetRefValue("txtNotUnlockedUSDFText")
	local name, iconPath, arkName = BadgeUtils.getMainTypeNameAndIconInPlayerUI(data.tabIndex)

	if data.isUnlock then
		button:TryChangePage("State", 1)

		if not string.isNilOrEmpty(iconPath) then
			titleIconUImage.url = iconPath
			titleIconLightUImage.url = iconPath
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))

		local num = self.model.getBadgeNumByTab(data.tabIndex)

		ClientTextUtils.setText(txtNumUSDFText, string.format("x%s", num))
	else
		button:TryChangePage("State", 0)
		ClientTextUtils.setText(txtNotUnlockedUSDFText, arkName)
	end
end

function PlayerEnhanceCtrl:onClickGoButton()
	pg.global.ui.SpecialTrainNew:open()
end

function PlayerEnhanceCtrl:openBadgePage(badgeTab)
	self.tabIndex = 1

	self:switchModelTrans(self.model.MODEL_STATE.BADGE_PAGE)

	local curBadgeTab = badgeTab or self.badgeTabIndex

	self.badgeOverviewPageCmp:open(curBadgeTab, self.badgeIdLook)
end

function PlayerEnhanceCtrl:closeBadgePage()
	self.badgeOverviewPageCmp:close()
end

function PlayerEnhanceCtrl:openSkillTreePage(treeId)
	self.tabIndex = 2

	self:switchModelTrans(self.model.MODEL_STATE.SKILL_TREE, {
		treeId = treeId
	})
	self:initTabShow()
end

function PlayerEnhanceCtrl:closeSkillTreePage()
	self.skillTreePageCmp:close()
end

function PlayerEnhanceCtrl:openSkillEquipPage()
	self:switchModelTrans(self.model.MODEL_STATE.SKILL_EQUIP)
end

function PlayerEnhanceCtrl:closeSkillEquipPage()
	self.tabIndex = 0

	self:switchModelTrans(self.model.MODEL_STATE.MAIN_PAGE)
	self:initTabShow()
end

function PlayerEnhanceCtrl:switchToCombatEquip(data)
	self:switchModelTrans(self.model.MODEL_STATE.SKILL_EQUIP, {
		mode = 1,
		id = data and data.id
	})
end

function PlayerEnhanceCtrl:switchToExploreEquip(data)
	self:switchModelTrans(self.model.MODEL_STATE.SKILL_EQUIP, {
		mode = 2,
		id = data and data.id
	})
end

function PlayerEnhanceCtrl:switchToCombatEquipWithSelect(defaultSelectSkillId)
	self:switchModelTrans(self.model.MODEL_STATE.SKILL_EQUIP, {
		mode = 1,
		defaultSelectSkillId = defaultSelectSkillId
	})
end

function PlayerEnhanceCtrl:switchToPetEquip()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
		hideOtherTab = true,
		tab = 2,
		closeAction = function()
			self.modelScene:setPlayerActive(true)
		end
	}, function()
		self.modelScene:setPlayerActive(false)
	end)
end

function PlayerEnhanceCtrl:onClosePanel()
	if self.page == self.model.MODEL_STATE.MAIN_PAGE then
		self:dismiss()
	elseif self.page == self.model.MODEL_STATE.SKILL_TREE then
		if self.skillTreePageCmp.closeMode == 0 then
			self:dismiss()
		else
			self:openSkillEquipPage()
		end
	elseif self.page == self.model.MODEL_STATE.SKILL_EQUIP then
		if self.skillEquipPageCmp:tryGamepadBackToSkillList() then
			return
		end

		self:closeSkillEquipPage()
	elseif self.page == self.model.MODEL_STATE.BADGE_PAGE and self.badgeOverviewPageCmp:checkCanDismiss() then
		self:dismiss()
	end
end

function PlayerEnhanceCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return PlayerEnhanceCtrl
