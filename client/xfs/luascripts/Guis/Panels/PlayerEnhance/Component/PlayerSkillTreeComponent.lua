-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\Component\\PlayerSkillTreeComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PlayerSkillTreeComponent = Class.LightClass("PlayerSkillTreeComponent", UIComponent)
local HandBookVbData = require("Data.handbook_vb_config_data")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AudioConst = require("Const.AudioConst")

function PlayerSkillTreeComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.tree = self.objectReference:GetRefValue("tree")
	self.btnTips = self.objectReference:GetRefValue("btnTips")
	self.btnReset = self.objectReference:GetRefValue("btnReset")
	self.activeHeadName = self.objectReference:GetRefValue("activeHeadName")
	self.acHeadList = self.objectReference:GetRefValue("acHeadList")
	self.passiveHeadName = self.objectReference:GetRefValue("passiveHeadName")
	self.paHeadList = self.objectReference:GetRefValue("paHeadList")
	self.ruleList = self.objectReference:GetRefValue("ruleList")
	self.tipsHotKeyContent = self.objectReference:GetRefValue("tipsHotKeyContent")
	self.lockingHotKeyContent = self.objectReference:GetRefValue("lockingHotKeyContent")
	self.titleHeadUSDFText = self.objectReference:GetRefValue("titleHeadUSDFText")
	self.keyTitleHotKeyContent = self.view.objectReference:GetRefValue("keyTitleHotKeyContent")
	self.currencykeyHotKeyContent = self.view.objectReference:GetRefValue("currencykeyHotKeyContent")

	local container = self.tree.content:GetComponent("ObjectReference")

	self.progressList = container:GetRefValue("progress")
	self.activeList = container:GetRefValue("active")
	self.passiveList = container:GetRefValue("passive")

	function self.btnTips.luaClick()
		pg.global.ui.tips:openStarImprove()
	end

	function self.progressList.luaRenderItem(item, _, data)
		self:onRenderHeadStarItem(item, data)
	end

	function self.activeList.luaRenderItem(item, index, data)
		self:onRenderSkillGroup(item, index, data)
	end

	function self.passiveList.luaRenderItem(item, index, data)
		self:onRenderSkillGroup(item, index, data)
	end

	function self.acHeadList.luaRenderItem(item, _, data)
		self:onRenderLearnItem(item, data)
	end

	function self.paHeadList.luaRenderItem(item, _, data)
		self:onRenderLearnItem(item, data)
	end

	function self.ruleList.luaRenderItem(item, _, data)
		self:onRenderOwnPropItem(item, data)
	end

	function self.btnReset.luaClick()
		self:onReset()
	end

	self.cacheInfo = nil

	if self.keyTitleHotKeyContent then
		self.keyTitleHotKeyContent:SetHotKeyPaths("Raw/GamepadSelect")
	end

	if self.currencykeyHotKeyContent then
		self.currencykeyHotKeyContent:SetHotKeyPaths("Raw/GamepadRightStickPress")
	end
end

function PlayerSkillTreeComponent:open(data)
	self.closeMode = (data.treeId == nil or data.noJump) and 0 or 1
	self.defaultId = data.treeId

	ClientTextUtils.setText(self.activeHeadName, pg.getGameString(self.model.SKILL_TYPE_NAME[AbilityConst.SKILL_TYPE.COMBATS]))
	ClientTextUtils.setText(self.passiveHeadName, pg.getGameString(self.model.SKILL_TYPE_NAME[AbilityConst.SKILL_TYPE.PASSIVE]))
	ClientTextUtils.setText(self.titleHeadUSDFText, pg.getGameString("PLAYER_TITLE"))
	self:refreshSkillTreePage()
	self.model:redDot_SetPlayerTabTreeState()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.PLAYER_TAB_TREE)
	self.ctrl:bindGamepadScrollUList(self.tree, 150, true)
	self.ctrl:bindHotKeyPerform("Raw/GamepadSelect", function()
		self:jumpToCurrentTitle()
	end, self.tree.gameObject)

	if self.keyTitleHotKeyContent then
		self.progressList:SetNavGroupHotkeyContent(self.keyTitleHotKeyContent.gameObject)
	end

	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr:SetConsoleBarState("onSkillTreePage", true)
	end

	self.btnReset:SetActiveFastest(true)
end

function PlayerSkillTreeComponent:jumpToCurrentTitle()
	if not self.activeList or not self.progressList or not self.tree then
		return
	end

	local curStar = LuaUIUtils.getPlayerStar()
	local hideLevel = self.model.HIDE_LEVEL or 0

	if curStar <= hideLevel then
		return
	end

	local activeIdx = curStar - 1 - hideLevel
	local progressIdx = 2 * activeIdx
	local activeData = self.activeList.itemData

	if activeData and activeIdx >= 0 and activeIdx < activeData.Count then
		local ok, rowItem = self.activeList:TryGetChildAt(activeIdx)

		if ok and rowItem then
			self.tree:GoToPos(rowItem.rectTransform, true)
		end
	end

	local progressData = self.progressList.itemData

	if progressData and progressIdx >= 0 and progressIdx < progressData.Count then
		local ok2, progressItem = self.progressList:TryGetChildAt(progressIdx)

		if ok2 and progressItem then
			pg.global.navMgr:PushFocusItem(progressItem)
		end
	end
end

function PlayerSkillTreeComponent:close()
	pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)

	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr:SetConsoleBarState("onSkillTreePage", false)
	end
end

function PlayerSkillTreeComponent:onDestroy()
	pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
	UIComponent.onDestroy(self)
end

function PlayerSkillTreeComponent:refreshSkillTreePage()
	local headData = self.model:getTreeHeadList()

	self.progressList:SetList(headData)
	self:refreshDataList()
	self:refreshConsumeList()
end

function PlayerSkillTreeComponent:refreshConsumeList()
	local consumeData = self.model:getLearnDataList()

	self.ruleList:SetList(consumeData)
end

function PlayerSkillTreeComponent:refreshDataList()
	if self.oldSelect then
		self.oldSelect.isSelected = false
	end

	self.oldSelect = nil

	self:refreshListWithType(AbilityConst.SKILL_TYPE.COMBATS)
	self:refreshListWithType(AbilityConst.SKILL_TYPE.PASSIVE)
end

function PlayerSkillTreeComponent:refreshListWithType(type)
	self:refreshHeadListWithType(type)
	self:refreshTreeListWithType(type)
end

function PlayerSkillTreeComponent:refreshHeadListWithType(type)
	local xHeadList

	if type == AbilityConst.SKILL_TYPE.COMBATS then
		xHeadList = self.acHeadList
	elseif type == AbilityConst.SKILL_TYPE.PASSIVE then
		xHeadList = self.paHeadList
	end

	local headData = self.model:getTreeLearnPointDataList(type)

	xHeadList:SetList(headData)
end

function PlayerSkillTreeComponent:refreshTreeListWithType(type, refresh)
	local xTreeList

	if type == AbilityConst.SKILL_TYPE.COMBATS then
		xTreeList = self.activeList
	elseif type == AbilityConst.SKILL_TYPE.PASSIVE then
		xTreeList = self.passiveList
	end

	if refresh then
		self.model:refreshSkillTreeDataList(xTreeList.itemData)
		xTreeList:RefreshList()
	else
		local dataList = self.model:getSkillTreeDataList(type)

		xTreeList:SetList(dataList)
	end

	if self.defaultId ~= nil and not refresh then
		local index = -1
		local dataList = xTreeList.itemData
		local max = dataList.Count - 1

		for i = 0, max do
			local item = dataList[i]

			if item.realId == self.defaultId or item.id == self.defaultId then
				index = i

				break
			end
		end

		if index >= 0 then
			local res, skBtn = xTreeList:TryGetChildAt(index)

			if res then
				self.tree:GoToPos(skBtn.rectTransform, true)
				skBtn:OnClickSimulate()
			end
		end
	end
end

function PlayerSkillTreeComponent:onRenderHeadStarItem(item, data)
	if data.tIndex == 1 then
		return
	end

	local oc = item:GetComponent("ObjectReference")
	local tLevel = oc:GetRefValue("txtLevel")
	local starIcon = oc:GetRefValue("starIcon")
	local btnStar = oc:GetRefValue("btnStar")

	ClientTextUtils.setText(tLevel, data.starName)

	starIcon.url = data.icon

	local curStar = LuaUIUtils.getPlayerStar()

	if data.star and curStar >= data.star then
		item:TryChangePage("LvUp", 1)
	else
		item:TryChangePage("LvUp", 0)
	end

	function btnStar.luaRenderTooltip(_, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local tipsStr = pg.getGameString("TITLE_TIPS")
		local title = LuaUIUtils.getStarTitleName(data.star or pg.me.starTitle, true)
		local needLevel = LuaUIUtils.getMaxCurrentLv(data.star)

		ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(tipsStr, title, needLevel))
	end

	function btnStar.luaClick()
		btnStar:OpenTooltip()
	end

	function item.luaClick(isFromNavigation)
		if isFromNavigation then
			return
		end

		btnStar:OpenTooltip()
	end
end

function PlayerSkillTreeComponent:onRenderLearnItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local tNumb = oc:GetRefValue("numUText")
	local iIcon = oc:GetRefValue("iconUImage")

	iIcon.url = data.icon

	ClientTextUtils.setText(tNumb, data.use or 0)

	function button.luaClick()
		LuaUIUtils.popupPropTip({
			id = data.id,
			num = data.num,
			targetRect = button
		})
	end
end

function PlayerSkillTreeComponent:onRenderOwnPropItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local tNumb = oc:GetRefValue("numUText")
	local iIcon = oc:GetRefValue("iconUImage")

	button:TryChangePage("ColorText", 1)

	iIcon.url = data.icon

	ClientTextUtils.setText(tNumb, data.num)

	function button.luaClick()
		LuaUIUtils.popupPropTip({
			singleDisplay = true,
			id = data.id,
			num = data.num,
			targetRect = button
		})
	end
end

function PlayerSkillTreeComponent:onRenderSkillGroup(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(b, i, d)
		self:onRenderSkillItem(b, d)
	end

	listUList:SetList(data)

	local num = index % 2

	button:TryChangePage("Bg", num)
end

function PlayerSkillTreeComponent:onRenderSkillItem(button, data)
	if data.isEmpty then
		button:TryChangePage("isEmpty", 1)

		button.navForceNonInteractable = true

		return
	else
		button:TryChangePage("isEmpty", 0)

		button.navForceNonInteractable = false
	end

	button.name = data.id

	local treePath = string.format(RedDotConst.RedDotPath.PLAYER_TREE_LIST_ITEM, data.id or 0)
	local showRedDot = self.model:redDot_GetPlayerTreeTrListItemState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.NEW)

	function button.luaClick()
		if self.oldSelect then
			self.oldSelect.isSelected = false
		end

		self.oldSelect = button
		button.isSelected = true

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				singleDisplay = true,
				autoHor = true,
				targetRect = button,
				data = data,
				onCallback = function(isLearn)
					self:onLearnOrUpCallback(button, isLearn)
					self.model:redDot_SetPlayerTabTreeState()
					pg.global.refreshRedDotState(RedDotConst.RedDotPath.PLAYER_TAB_TREE)
					pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
				end,
				onSwitchToLearn = function()
					self.ctrl:switchToCombatEquip(data)
				end
			})
		end

		self.model:redDot_SetPlayerTreeTrListItemState(data)
		self.model:redDot_SetPlayerTabTreeState()
		pg.global.setRedDot(treePath, button, false)
	end

	local oc = button:GetComponent("ObjectReference")
	local tLevel = oc:GetRefValue("txtLevel")
	local tName = oc:GetRefValue("txtName")
	local iIcon = oc:GetRefValue("icon")

	ClientTextUtils.setText(tName, data.name)

	local skillState = data.state

	if skillState == self.model.SKILL_STATE.CAN_UPGRADE then
		button:TryChangePage("Update", 1)
	else
		button:TryChangePage("Update", 0)
	end

	if data.keyBoard then
		local isMobile = pg.global.ui:runPlatformByMobile()
		local iPbKey = oc:GetRefValue("keyHotKey")

		iPbKey.gameObject:SetActiveEx(not isMobile)

		if not isMobile then
			iPbKey:SetHotKeyPaths(data.keyBoard)
		end

		button:TryChangePage("Equip", 1)
	else
		button:TryChangePage("Equip", 0)
	end

	if skillState == self.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		button:TryChangePage("SkillStage", 0)
		ClientTextUtils.setText(tLevel, "")
	elseif skillState == self.model.SKILL_STATE.CAN_UNLOCK or skillState == self.model.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET then
		button:TryChangePage("SkillStage", 1)
		ClientTextUtils.setText(tLevel, string.format("0/%d", data.maxLv))
	else
		button:TryChangePage("SkillStage", 2)
		ClientTextUtils.setText(tLevel, string.format("%d/%d", data.level, data.maxLv))
	end

	iIcon.url = data.icon

	button:TryChangePage("SkillType", data.isRare and 1 or 0)
end

function PlayerSkillTreeComponent:onRefreshSkillTree()
	self:refreshDataList()
end

function PlayerSkillTreeComponent:onReset()
	local costText = ""

	if HandBookVbData.playerSkillResetCost then
		costText = LuaUIUtils.getItemCountConsumeShowText(HandBookVbData.playerSkillResetCost[1], HandBookVbData.playerSkillResetCost[2], true)
	end

	local args = {
		title = pg.getGameString("RESET_SKILL_TREE"),
		tipTop = string.format(pg.getGameString("RESET_SKILL_TREE_TIP"), costText)
	}

	args.data = {
		HandBookVbData.playerSkillResetCost or {}
	}

	function args.confirmCb()
		pg.me:serverMsg("RPC_CS_ResetSkillTree", false, function(result)
			if not result then
				return
			end

			facade:sendMsgToUI(MessageName.RED_DOT_PLAYER_SKILL_TREE)
			self:refreshSkillTreePage()
		end)
	end

	args.type = 4

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, args)
end

function PlayerSkillTreeComponent:onLearnOrUpCallback(button, isLearn)
	local data = button.dataFromUList
	local oc = button:GetComponent("ObjectReference")
	local Anima = oc:GetRefValue("btnAnimation")

	Anima:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	self.model:parseSkillInfo(data)
	self:refreshHeadListWithType(data.abilityType)
	self:refreshTreeListWithType(data.abilityType, true)

	if data.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
		self:refreshTreeListWithType(AbilityConst.SKILL_TYPE.PASSIVE, true)
	end

	self:refreshConsumeList()
	pg.game.audio:playEvent(AudioConst.SFX_UI_PLAYER_LEARN_SKILL)
end

return PlayerSkillTreeComponent
