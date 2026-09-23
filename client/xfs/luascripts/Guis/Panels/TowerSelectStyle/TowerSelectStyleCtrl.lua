-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSelectStyle\\TowerSelectStyleCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSelectStyleCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TowerSelectStyleCtrl = Class.LightClass("TowerSelectStyleCtrl", UICtrl)
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local RogueUtils = require("Utils.RogueUtils")
local UIConst = require("Const.UIConst")
local RogueTransformData = require("Data.rogue_transform_data")

TowerSelectStyleCtrl.messages = {}

function TowerSelectStyleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.openSeasonId = pg.me.rogueSeasonId
	self.levelId = info.levelId
	self.curSelectedItem = nil
	self.selectRandomTimer = nil
	self.selectCloseTimer = nil

	if not pg.me.rogueInitSeriesInfo.hadInit then
		pg.me:initRogueSeriesInfo(function(result)
			if self.openSeasonId ~= pg.me.rogueSeasonId then
				return
			end

			self:initUI()
		end)

		return
	end

	self:initUI()
end

function TowerSelectStyleCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnSelectUButton.luaClick()
		if self.curSelectedStyle then
			if self.curSelectedStyle == Const.ROGUE_SERIES_SELECT_DELAY_VALUE and not RogueUtils.randomStyleRevealed then
				RogueUtils.randomStyleRevealed = true
				self.view.btnSelectUButton.interactable = false
				self.curSelectedData.type = 0
				self.curSelectedData.styleId = RogueUtils.getRandomStyleRealId()

				self.curSelectedItem:TryChangePage("Random", 0)
				self.curSelectedItem:TryChangePage("Avatar", 0)

				local objectReference = self.curSelectedItem:GetComponent("ObjectReference")
				local iconAvatarUImage = objectReference:GetRefValue("iconAvatarUImage")
				local transformCfg = RogueTransformData[self.curSelectedData.styleId]

				if transformCfg then
					local bossIcon = LuaUIUtils.getSkillIconByAbilityId(transformCfg.transformSkill)

					iconAvatarUImage.url = bossIcon
				end

				self.selectRandomTimer = self:startTimer(function()
					RogueUtils.refreshSelectedStyleInfo(self, self.curSelectedStyle, true)
					self.view.styleUList:RefreshElement(self.view.styleUList:GetChildIndex(self.curSelectedItem))
					self.curSelectedItem:TryChangePage("Random", 1)

					self.view.btnSelectUButton.interactable = true
					self.selectRandomTimer = nil
				end, 1.9)

				return
			end

			pg.me:selectRogueSeries(self.curSelectedStyle)
			RogueUtils.setSelectedRogueLevel(self.levelId)
			facade:sendMsgToUI(MessageName.ROGUE_LEVEL_CHANGE)

			if self.curSelectedItem == nil then
				local _, item = self.view.styleUList:TryGetChildAt(0)

				self.curSelectedItem = item
			end

			if self.selectCloseTimer then
				return
			end

			if self.curSelectedItem then
				if self.curSelectedStyle == Const.ROGUE_SERIES_SELECT_DELAY_VALUE then
					self.curSelectedItem:InvokeCallback(CS.XGUI.EInvokeTime.User2)
				else
					self.curSelectedItem:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				end
			end

			local delayTime = 0.8

			self.selectCloseTimer = self:startTimer(function()
				self.selectCloseTimer = nil

				self:close()
			end, delayTime)
		end
	end

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function TowerSelectStyleCtrl:initUI()
	local difficultyCfg = RogueDifficultyData[self.levelId]

	if not difficultyCfg then
		return
	end

	self.view.backgroundUImage.url = difficultyCfg.battleResultBackground

	function self.view.styleUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local stylePetUImage = objectReference:GetRefValue("stylePetUImage")
		local styleIconUImage = objectReference:GetRefValue("styleIconUImage")
		local styleNameUBaseText = objectReference:GetRefValue("styleNameUBaseText")
		local selectedPet1UImage = objectReference:GetRefValue("selectedPet1UImage")
		local selectedPet2UImage = objectReference:GetRefValue("selectedPet2UImage")
		local selectedIconUImage = objectReference:GetRefValue("selectedIconUImage")
		local selectedNameUBaseText = objectReference:GetRefValue("selectedNameUBaseText")
		local iconAvatarUImage = objectReference:GetRefValue("iconAvatarUImage")
		local randomUBaseText = objectReference:GetRefValue("randomUBaseText")
		local btnBossUButton = objectReference:GetRefValue("btnBossUButton")
		local petSkilUltimateUButton = objectReference:GetRefValue("petSkilUltimateUButton")
		local petSkil1UButton = objectReference:GetRefValue("petSkil1UButton")
		local petSkil2UButton = objectReference:GetRefValue("petSkil2UButton")
		local styleIcon2UImage = objectReference:GetRefValue("styleIcon2UImage")

		button:TryChangePage("state", data.type)

		if data.type == 1 then
			ClientTextUtils.setText(selectedNameUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_NAME"))
			ClientTextUtils.setText(styleNameUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_NAME"))
			ClientTextUtils.setText(randomUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_NAME"))
			button:TryChangePage("Avatar", 1)

			return
		end

		button:TryChangePage("Avatar", 0)
		button:TryChangePage("Random", 1)

		local styleCfg = RandomBuffSeriesName[data.styleId]

		if not styleCfg then
			return
		end

		styleIconUImage.url = styleCfg.buffSeriesIcon
		styleIcon2UImage.url = styleCfg.buffSeriesIcon
		selectedIconUImage.url = styleCfg.buffSeriesIcon

		ClientTextUtils.setText(selectedNameUBaseText, pg.getLocalizationText(styleCfg.buffSeriesName))
		ClientTextUtils.setText(styleNameUBaseText, pg.getLocalizationText(styleCfg.buffSeriesName))

		stylePetUImage.url = styleCfg.bossPoster1
		selectedPet1UImage.url = styleCfg.bossPoster2
		selectedPet2UImage.url = styleCfg.bossPoster3

		local transformCfg = RogueTransformData[data.styleId]

		if not transformCfg then
			return
		end

		local bossIcon = LuaUIUtils.getSkillIconByAbilityId(transformCfg.transformSkill)

		iconAvatarUImage.url = bossIcon

		function btnBossUButton.luaClick()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
			else
				local skillInfo = {
					hideSkillButton = true,
					enabledTooltip = false,
					name = pg.getLocalizationText(transformCfg.transformName),
					icon = bossIcon,
					desc = pg.getLocalizationText(transformCfg.transformDesc),
					attrs = {
						{
							name = pg.getLocalizationText(transformCfg.transformType)
						}
					},
					video = transformCfg.transformVideo
				}

				btnBossUButton.isSelected = true

				pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
					autoVer = true,
					targetRect = btnBossUButton,
					data = skillInfo,
					onCloseCallback = function()
						btnBossUButton.isSelected = false
					end
				})
			end
		end

		RogueUtils.renderSkillBtn(petSkilUltimateUButton, transformCfg.bossUltimateSkillId, transformCfg.bossUltimateSkillVideo)
		RogueUtils.renderSkillBtn(petSkil1UButton, transformCfg.bossSkill1Id, transformCfg.bossSkill1Video)
		RogueUtils.renderSkillBtn(petSkil2UButton, transformCfg.bossSkill2Id, transformCfg.bossSkill2Video)
	end

	function self.view.styleUList.luaClick(button, data)
		if self.selectRandomTimer then
			self:killTimer(self.selectRandomTimer)

			self.selectRandomTimer = nil

			self.view.styleUList:RefreshElement(self.view.styleUList:GetChildIndex(self.curSelectedItem))
			self.curSelectedItem:TryChangePage("Random", 1)

			self.view.btnSelectUButton.interactable = true
		end

		self.curSelectedStyle = data.originStyleId
		self.curSelectedItem = button
		self.curSelectedData = data

		RogueUtils.refreshSelectedStyleInfo(self, data.originStyleId, RogueUtils.randomStyleRevealed)
	end

	local styleList = {}

	for key, value in pairs(pg.me.rogueInitSeriesInfo) do
		if RandomBuffSeriesName[key] then
			table.insert(styleList, {
				type = 0,
				styleId = key,
				originStyleId = key
			})
		end

		if key == Const.ROGUE_SERIES_SELECT_DELAY_VALUE then
			if RogueUtils.randomStyleRevealed then
				table.insert(styleList, {
					type = 0,
					styleId = RogueUtils.getRandomStyleRealId(),
					originStyleId = key
				})
			else
				table.insert(styleList, {
					type = 1,
					styleId = key,
					originStyleId = key
				})
			end
		end
	end

	table.sort(styleList, function(a, b)
		return a.originStyleId < b.originStyleId
	end)

	if styleList[1] then
		self.curSelectedStyle = styleList[1].originStyleId
		styleList[1].selected = true
	end

	self.view.styleUList:SetList(styleList)

	function self.view.styleItemUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewards(button, index, data)
	end

	RogueUtils.refreshSelectedStyleInfo(self, self.curSelectedStyle)
end

function TowerSelectStyleCtrl:onNavFocusChange()
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local inGroup = currentFocusedGroupName == "Selected"

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsolrBar_TowerSelectStyle_IsInSelected", inGroup)
end

function TowerSelectStyleCtrl:onDestroy()
	if self.selectRandomTimer then
		self:killTimer(self.selectRandomTimer)

		self.selectRandomTimer = nil
	end

	if self.selectCloseTimer then
		self:killTimer(self.selectCloseTimer)

		self.selectCloseTimer = nil
	end

	pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
	UICtrl.onDestroy(self)
end

function TowerSelectStyleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openSeasonId = pg.me.rogueSeasonId
end

function TowerSelectStyleCtrl:onShow()
	return
end

function TowerSelectStyleCtrl:onHide()
	return
end

function TowerSelectStyleCtrl:closePanel()
	if self:checkUIClosing() then
		return
	end

	self:close()
end

return TowerSelectStyleCtrl
