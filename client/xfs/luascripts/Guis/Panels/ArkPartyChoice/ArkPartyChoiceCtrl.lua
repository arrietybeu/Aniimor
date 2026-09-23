-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ArkPartyChoice\\ArkPartyChoiceCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local ArkPartyChoiceCtrl = Class.LightClass("ArkPartyChoiceCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local PetConfigData = require("Data.pet_config_data")
local PetLevelData = require("Data.pet_level_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ElementPropData = require("Data.element_prop_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local EventArkCarnData = require("Data.event_ark_carn_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

ArkPartyChoiceCtrl.messages = {
	[MessageName.EVENT_VOTE_PET_VOTED] = {
		"onVotePetRefresh",
		true
	},
	[MessageName.EVENT_VOTE_INFO_PULL] = {
		"onVoteInfoPull",
		true
	}
}

function ArkPartyChoiceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.activityId = info.activityId
	self.phaseId = info.phaseId
	self.stageId = info.stageId
	self.isFinish = info.isFinish

	self:refresh()
	pg.game.audio:triggerEvent("SFX_UI_ArkParty_VoteMoveIn")
end

function ArkPartyChoiceCtrl:refresh()
	self.hasVoted = pg.me.arkCarnVotePet and #pg.me.arkCarnVotePet > 0

	if self.hasVoted then
		self.view.rootUWidget:TryChangePage("Buttonstate", 1)
	elseif self.isFinish then
		self.view.rootUWidget:TryChangePage("Buttonstate", 1)
		ClientTextUtils.setText(self.view.text1UBaseText, pg.getGameString("ARK_CARNIVAL_16"))
	else
		self.view.btnDarkUButton.interactable = false
	end

	self:refreshAllList()
	ClientTextUtils.setText(self.view.title1UBaseText, pg.getGameString("ARK_CARNIVAL_1"))
	ClientTextUtils.setText(self.view.title2UBaseText, pg.getGameString("ARK_CARNIVAL_2"))
	ClientTextUtils.setText(self.view.title3UBaseText, pg.getGameString("ARK_CARNIVAL_3"))
	ClientTextUtils.setText(self.view.title4UBaseText, pg.getGameString("ARK_CARNIVAL_4"))

	if self.selectList1Index then
		self.view.list1UList:SelectItem(self.selectList1Index - 1)
	end

	if self.selectList2Index then
		self.view.list2UList:SelectItem(self.selectList2Index - 1)
	end

	if self.selectList3Index then
		self.view.list3UList:SelectItem(self.selectList3Index - 1)
	end

	if self.selectList4Index then
		self.view.list4UList:SelectItem(self.selectList4Index - 1)
	end
end

function ArkPartyChoiceCtrl:onVotePetRefresh()
	pg.global.ui.tips:showTextTip(pg.getGameString("ARK_CARNIVAL_17"))

	self.curVotedNum = 0

	pg.game.event:pullVoteData()
end

function ArkPartyChoiceCtrl:onVoteInfoPull(voteInfo)
	self.curVotedNum = self.curVotedNum + 1

	if self.curVotedNum == 4 then
		self:refresh()
	end
end

function ArkPartyChoiceCtrl:refreshAllList()
	local drummers = self.model:getDrummerData(self.phaseId, 1)

	self.view.list1UList:SetList(drummers)

	local dancers = self.model:getDancerData(self.phaseId, 1)

	self.view.list2UList:SetList(dancers)

	local accompanies = self.model:getAccompanyData(self.phaseId, 1)

	self.view.list3UList:SetList(accompanies)

	local atmos = self.model:getAtmosData(self.phaseId, 1)

	self.view.list4UList:SetList(atmos)
end

function ArkPartyChoiceCtrl:refreshVoteState()
	if not self.view.list1UList.selectedItem then
		return
	end

	if not self.view.list2UList.selectedItem then
		return
	end

	if not self.view.list3UList.selectedItem then
		return
	end

	if not self.view.list4UList.selectedItem then
		return
	end

	self.view.btnDarkUButton.interactable = not self.hasVoted and self.stageId == 1
end

function ArkPartyChoiceCtrl:addListener()
	function self.view.list1UList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)

		if data.isVoted then
			self.selectList1Index = data.index
		end
	end

	function self.view.list2UList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)

		if data.isVoted then
			self.selectList2Index = data.index
		end
	end

	function self.view.list3UList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)

		if data.isVoted then
			self.selectList3Index = data.index
		end
	end

	function self.view.list4UList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)

		if data.isVoted then
			self.selectList4Index = data.index
		end
	end

	function self.view.list1UList.luaSelectedChanged(ulist, selected)
		self:refreshVoteState()
	end

	function self.view.list2UList.luaSelectedChanged(ulist, selected)
		self:refreshVoteState()
	end

	function self.view.list3UList.luaSelectedChanged(ulist, selected)
		self:refreshVoteState()
	end

	function self.view.list4UList.luaSelectedChanged(ulist, selected)
		self:refreshVoteState()
	end

	function self.view.btnDarkUButton.luaClick()
		local selectPets = {}
		local carnData = EventArkCarnData[self.phaseId][self.stageId]

		selectPets[ActivityConst.PET_BAND_POS_TYPE.Drummer] = self.view.list1UList.selectedItem.id
		selectPets[ActivityConst.PET_BAND_POS_TYPE.Dancer] = self.view.list2UList.selectedItem.id
		selectPets[ActivityConst.PET_BAND_POS_TYPE.Accompany] = self.view.list3UList.selectedItem.id
		selectPets[ActivityConst.PET_BAND_POS_TYPE.Atmos] = self.view.list4UList.selectedItem.id

		pg.me:serverMsg("RPC_CS_ReqActArkCarnVoteMusicPet", self.phaseId, selectPets)
	end

	function self.view.btnBackUButton.luaClick()
		pg.global.ui:close(UIConst.UI_ID_ARK_PARTY_CHOICE)
	end
end

function ArkPartyChoiceCtrl:renderPetList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local emoUImage = objectReference:GetRefValue("emoUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local pec1UBaseText = objectReference:GetRefValue("pec1UBaseText")
	local pec2UBaseText = objectReference:GetRefValue("pec2UBaseText")
	local highestUProgress = objectReference:GetRefValue("highestUProgress")
	local afterVotingUProgress = objectReference:GetRefValue("afterVotingUProgress")

	emoUImage.url = "$UI_Event_Arkparty_" .. data.id .. ".png"

	ClientTextUtils.setText(nameUBaseText, data.name)

	if self.hasVoted or self.stageId > 1 then
		button.interactable = false

		if data.isMax then
			button:TryChangePage("Percentagestate", 1)
			ClientTextUtils.setText(pec1UBaseText, string.format("%.1f", data.votePec * 100) .. "%")

			highestUProgress.normalizedValue = data.votePec
		else
			button:TryChangePage("Percentagestate", 2)
			ClientTextUtils.setText(pec2UBaseText, string.format("%.1f", data.votePec * 100) .. "%")

			afterVotingUProgress.normalizedValue = data.votePec
		end
	end
end

function ArkPartyChoiceCtrl:onDestroy()
	self.selectList1Index = nil
	self.selectList2Index = nil
	self.selectList3Index = nil
	self.selectList4Index = nil

	UICtrl.onDestroy(self)
end

function ArkPartyChoiceCtrl:onShow()
	UICtrl.onShow(self)
end

return ArkPartyChoiceCtrl
