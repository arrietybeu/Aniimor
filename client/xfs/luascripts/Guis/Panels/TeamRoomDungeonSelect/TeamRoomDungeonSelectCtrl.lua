-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoomDungeonSelect\\TeamRoomDungeonSelectCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local TeamRoomDungeonSelectCtrl = Class.LightClass("TeamRoomDungeonSelectCtrl", UICtrl)

function TeamRoomDungeonSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local teamInfo = pg.me:getCurTeamInfo()

	self.selectedDungeonId = info and info.dungeonId or teamInfo.dungeonSceneId
	self.selectedDungeonLevel = 0
	self.selectedCategoryId = self.model:getCategoryIdByDungeon(self.selectedDungeonId, self.selectedDungeonLevel)

	self:refreshDungeonList()
	ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getGameString("TEAM_SELECT_DUNGEON_TARGET"))
	ClientTextUtils.setText(self.view.txtConfirmUSDFText, pg.getGameString("TEAM_CONFIRM_DUNGEON_TARGET"))
end

function TeamRoomDungeonSelectCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderDungeonItem(button, index, data)
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onClickConfirm()
	end
end

function TeamRoomDungeonSelectCtrl:refreshDungeonList()
	self.dungeonList = self.model:getDungeonList()

	for _, data in ipairs(self.dungeonList) do
		data.selected = data.categoryId == self.selectedCategoryId
	end

	self.view.listUList:SetList(self.dungeonList)
	self:refreshSelectState()
end

function TeamRoomDungeonSelectCtrl:refreshSelectState()
	local selectState, tips = self.model:getSelectState(self.selectedDungeonId, self.selectedDungeonLevel)
	local canConfirm = self.model:isCanConfirmState(selectState)

	self.view.rootUComponent:TryChangePage("SelectState", selectState)
	ClientTextUtils.setText(self.view.txtTipsUSDFText, tips)

	self.view.btnConfirmUButton.interactable = canConfirm
	self.view.btnConfirmUButton.visualInteractable = canConfirm
end

function TeamRoomDungeonSelectCtrl:renderDungeonItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local tabUButton = objectReference:GetRefValue("tabUButton")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local levelList = objectReference:GetRefValue("levelList")
	local picUImage = objectReference:GetRefValue("picUImage")
	local teamPlayName

	for _, levelData in ipairs(data.levelList) do
		teamPlayName = levelData.teamPlayConfig.name

		if teamPlayName then
			break
		end
	end

	ClientTextUtils.setText(textUSDFText, pg.getLocalizationText(teamPlayName))

	local picUrl = data.pic_small

	picUImage:SetActive(not string.isNilOrEmpty(picUrl))

	if picUrl then
		picUImage.url = picUrl
	end

	local selected = data.categoryId == self.selectedCategoryId

	button:SetSelected(selected)
	tabUButton:SetSelected(selected)

	function tabUButton.luaClick()
		local cancelSelected = data.categoryId == self.selectedCategoryId

		self:onDungeonSelected(data)

		if cancelSelected then
			tabUButton:SetSelected(false)
			TimerManager.addNextFrameCb(function()
				if tabUButton and not IsNil(tabUButton) then
					tabUButton:SetSelected(false)
				end
			end)
		end
	end

	function levelList.luaRenderItem(button1, index1, data1)
		self:renderLevelItem(button1, index1, data1)
	end

	for _, levelData in ipairs(data.levelList) do
		levelData.selected = levelData.dungeonId == self.selectedDungeonId and levelData.difficultyID == self.selectedDungeonLevel
	end

	levelList:SetList(data.levelList)

	if not selected then
		levelList:DeselectAll(false)
	end

	function levelList.luaSelectedChanged(uList)
		if uList.selectedItem then
			self:setLevelSelected(uList.selectedItem)
			self:refreshSelectState()
		end
	end
end

function TeamRoomDungeonSelectCtrl:renderLevelItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local textLockUSDFText = objectReference:GetRefValue("textLockUSDFText")
	local textNumLockUSDFText = objectReference:GetRefValue("textNumLockUSDFText")

	button:TryChangePage("State", self:getLevelItemState(data))
	button:SetSelected(data.dungeonId == self.selectedDungeonId and data.difficultyID == self.selectedDungeonLevel)
	ClientTextUtils.setText(textNumUSDFText, self:getPeopleNumText(data.dungeonConfig))
	ClientTextUtils.setText(textNumLockUSDFText, self:getPeopleNumText(data.dungeonConfig))
	ClientTextUtils.setText(textUSDFText, self:getLevelNameText(data))
	ClientTextUtils.setText(textLockUSDFText, self:getLevelNameText(data))
end

function TeamRoomDungeonSelectCtrl:getLevelItemState(data)
	local selectState = self.model:getSelectState(data.dungeonId, data.difficultyID)

	return self.model:isCanConfirmState(selectState) and 0 or 1
end

function TeamRoomDungeonSelectCtrl:getLevelNameText(data)
	local dungeonName = pg.getLocalizationText(data.dungeonConfig.name)

	if data.difficultyID and data.difficultyID > 0 then
		return ClientTextUtils.concatByLanguage(dungeonName, pg.getGameString("DUNGEON_DIFFICUITY_" .. data.difficultyID))
	end

	return dungeonName
end

function TeamRoomDungeonSelectCtrl:getPeopleNumText(dungeonConfig)
	local playerNumMin = dungeonConfig and dungeonConfig.playerNumMin or 1
	local playerNumMax = dungeonConfig and dungeonConfig.playerNumMax or playerNumMin

	return playerNumMax == 1 and 1 or playerNumMin .. "~" .. playerNumMax
end

function TeamRoomDungeonSelectCtrl:onDungeonSelected(data)
	if data.categoryId == self.selectedCategoryId then
		self.selectedCategoryId = 0
		self.selectedDungeonId = 0
		self.selectedDungeonLevel = 0
	else
		self:setDungeonSelected(data)
	end

	self:refreshDungeonList()
end

function TeamRoomDungeonSelectCtrl:onLevelSelected(data)
	self:setLevelSelected(data)
	self:refreshSelectState()
end

function TeamRoomDungeonSelectCtrl:setDungeonSelected(data)
	self.selectedCategoryId = data.categoryId
	self.selectedDungeonId = 0
	self.selectedDungeonLevel = 0
end

function TeamRoomDungeonSelectCtrl:setLevelSelected(data)
	self.selectedCategoryId = data.categoryId
	self.selectedDungeonId = data.dungeonId
	self.selectedDungeonLevel = data.difficultyID
end

function TeamRoomDungeonSelectCtrl:onClickConfirm()
	pg.me:applyTeamDungeon(self.selectedDungeonId, self.selectedDungeonLevel, true)
	self:close()
end

return TeamRoomDungeonSelectCtrl
