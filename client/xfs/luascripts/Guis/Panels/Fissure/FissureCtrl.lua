-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Fissure\\FissureCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RiftLevelData = require("Data.rift_level_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("FissureCtrl")
local MessageName = require("Const.MessageName")
local RIFT_TEXT = {
	RecommendElement = "Rift_RecommendElement",
	VictoryCondition = "Rift_VictoryCondition",
	RecommendLevel = "Rift_RecommendLevel",
	FirstClearReward = "Rift_FirstClearReward",
	Team = "Rift_Team",
	StartChallenge = "Rift_StartChallenge",
	Title = "Rift_Title",
	NeedClearPreDifficulty = "Rift_NeedClearPreDifficulty",
	TabRadical = "Rift_TabRadical",
	TabDepth = "Rift_TabDepth",
	TabSteady = "Rift_TabSteady",
	Mutation = "Rift_Mutation"
}
local FissureCtrl = Class.LightClass("FissureCtrl", UICtrl)

FissureCtrl.messages = {
	[MessageName.PREPARE_PETS_UPDATE] = {
		"refreshPets",
		true
	}
}

local TAB_NAME = {
	RIFT_TEXT.TabSteady,
	RIFT_TEXT.TabDepth,
	RIFT_TEXT.TabRadical
}

function FissureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.curLevelId = info.levelId

	if not self.curLevelId and info.npcId then
		self.curLevelId = self:_firstLevelOfNpc(info.npcId)
	end

	self:initView()
	self:_initLists()
	self:refreshPets()
	self:refreshAll()
end

function FissureCtrl:onDestroy()
	if pg.me and pg.me.clearRiftFocusCamera then
		pg.me:clearRiftFocusCamera()
	end

	UICtrl.onDestroy(self)
end

function FissureCtrl:_firstLevelOfNpc(npcId)
	local picked, pickedLv

	for id, data in pairs(RiftLevelData) do
		if data.npcid == npcId then
			local lv = data.entity_lv or 0

			if not picked or id < picked then
				picked, pickedLv = id, lv
			end
		end
	end

	return picked
end

function FissureCtrl:addListener()
	UICtrl.addListener(self)

	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:close()
		end
	end

	function self.view.btnSwitchUButton.luaClick()
		pg.global.ui.petManagement:open({
			isRift = true,
			levelId = self.curLevelId
		}, nil, nil, nil, nil, true)
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onClickStart()
	end
end

function FissureCtrl:initView()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString(RIFT_TEXT.Title))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString(RIFT_TEXT.Team))
	ClientTextUtils.setText(self.view.txtLevelUBaseText, pg.getGameString(RIFT_TEXT.RecommendLevel))
	ClientTextUtils.setText(self.view.txtElementUBaseText, pg.getGameString(RIFT_TEXT.RecommendElement))
	ClientTextUtils.setText(self.view.txtBuffUBaseText, pg.getGameString(RIFT_TEXT.Mutation))
	ClientTextUtils.setText(self.view.txtVictoryUSDFText, pg.getGameString(RIFT_TEXT.VictoryCondition))
	ClientTextUtils.setText(self.view.txtReWardNameUSDFText, pg.getGameString(RIFT_TEXT.FirstClearReward))
end

function FissureCtrl:_initLists()
	if self.view.listTabUList then
		function self.view.listTabUList.luaRenderItem(button, index, data)
			self:_renderDifficultyTab(button, index, data)
		end

		function self.view.listTabUList.luaSelectedChanged(ulist, selected)
			if selected and ulist.selectedItem then
				self.view.rightPanelAnimation:Play("VX_Pb_GameMode_Fissure_Main_In")
				self:onSelectDifficulty(ulist.selectedItem.levelId)
			end
		end
	end

	function self.view.listNewUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderPetHeadRound(button, data)
	end

	function self.view.elementListUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	function self.view.listBuffUList.luaRenderItem(button, index, data)
		self:_renderMutationItem(button, index, data)
	end
end

function FissureCtrl:_renderDifficultyTab(button, index, data)
	local cfg = data.config or {}
	local objectReference = button:GetComponent("ObjectReference")
	local leftTabObjectReference = objectReference:GetRefValue("leftTabObjectReference")
	local icon = leftTabObjectReference:GetRefValue("iconUImage")

	icon.url = string.format("$UI_Img_Fissure_TabIcon_0%d.png", index + 1)

	local textUSDFText = objectReference:GetRefValue("textUSDFText")

	ClientTextUtils.setText(textUSDFText, pg.getGameString(TAB_NAME[index + 1]))
	button:SetSelected(data.levelId == self.curLevelId)

	local isFinish = self.model:isFinished(data.levelId)

	button:TryChangePage("Stage", isFinish and 1 or 0)
end

function FissureCtrl:_renderMutationItem(button, index, data)
	local objRef = button:GetComponent("ObjectReference")

	if IsNil(objRef) then
		return
	end

	local buffCfg = data.config or {}
	local icon = objRef:GetRefValue("iconImagePro")
	local title = objRef:GetRefValue("textTitleUBaseText")
	local detail = objRef:GetRefValue("textDetailUSDFText")

	icon.url = buffCfg.buffIcon

	ClientTextUtils.setTextWithId(title, buffCfg.buffName)
	ClientTextUtils.setTextWithId(detail, buffCfg.descShort or buffCfg.desc)
end

function FissureCtrl:onSelectDifficulty(levelId)
	if not levelId or self.curLevelId == levelId then
		return
	end

	self.curLevelId = levelId

	self:refreshByLevel()
end

function FissureCtrl:refreshAll()
	local difficulties, selectIndex = self.model:getDifficultyGroup(self.curLevelId)

	if #difficulties == 0 then
		logger:warn("[Fissure] no level config for", tostring(self.curLevelId))

		return
	end

	self.curLevelId = difficulties[selectIndex].levelId

	if self.view.listTabUList then
		self.view.listTabUList:SetList(difficulties)
		self.view.listTabUList:SelectItem(selectIndex - 1, false)
	end

	self:refreshByLevel()
end

function FissureCtrl:refreshPets()
	self.petInfos = self.model:getFollowPets()

	self.view.listNewUList:SetList(self.petInfos)
end

function FissureCtrl:refreshByLevel()
	local cfg = self.model:getLevelConfig(self.curLevelId)

	if not cfg then
		return
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, cfg.Name or "")
	ClientTextUtils.setText(self.view.txtDetailUSDFText, cfg.desc or "")
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d-%d", 1, 4))
	ClientTextUtils.setText(self.view.txtLevelNumUSDFText, "Lv." .. tostring(cfg.entity_lv or 0))

	if self.view.elementListUList then
		self.view.elementListUList:SetList(self.model:getRecommendElements(cfg))
	end

	ClientTextUtils.setText(self.view.txtVictoryInfoUBaseText, self.model:getVictoryConditionText(cfg))

	if self.view.listBuffUList then
		self.view.listBuffUList:SetList(self.model:getMutationBuffs(cfg))
	end

	if self.view.rewardUList and cfg.firstRewardId and cfg.firstRewardId > 0 then
		local hasGot = pg.me:getLevelState(self.curLevelId) == Const.RiftState.Got

		LuaUIUtils.setRewardListByDropId(self.view.rewardUList, cfg.firstRewardId, 6, hasGot)
	end

	self:_refreshChallengeButton()
end

function FissureCtrl:onClickStart()
	if not self.curLevelId then
		return
	end

	if not self.model:isChallengeAvailable(self.curLevelId) then
		return
	end

	if pg.me and pg.me.startFissureChallenge then
		pg.me:startFissureChallenge(self.curLevelId)
		self:close()
	else
		logger:warn("[Fissure] pg.me:startFissureChallenge not available")
	end
end

function FissureCtrl:_refreshChallengeButton()
	if not self.view.btnConfirmUButton then
		return
	end

	local canChallenge = self.model:isChallengeAvailable(self.curLevelId)

	self.view.btnConfirmUButton.interactable = canChallenge

	local txt = canChallenge and pg.getGameString(RIFT_TEXT.StartChallenge) or pg.getGameString(RIFT_TEXT.NeedClearPreDifficulty)

	ClientTextUtils.setText(self.view.btnConfirmText, txt)

	if self.view.btnConfirmUButton.visualInteractable ~= nil then
		self.view.btnConfirmUButton.visualInteractable = canChallenge
	end
end

return FissureCtrl
