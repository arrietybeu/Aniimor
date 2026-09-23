-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestSceneChoice\\QuestSceneChoiceCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestSceneChoiceCtrl = Class.LightClass("QuestSceneChoiceCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Queue = require("Core.Framework.Queue")
local isFinish = false
local State = 0

QuestSceneChoiceCtrl.Timeout = 10
QuestSceneChoiceCtrl.ShowFinishTime = 5
QuestSceneChoiceCtrl.ShowLikeTime = 3
QuestSceneChoiceCtrl.LikeListType = {
	L = 1,
	R = 2
}

local SceneChoiceText = {
	{
		title = "QUEST_SCENE_CHOICE_TXT_1",
		choice = {
			"QUEST_SCENE_CHOICE_TXT_1a",
			"QUEST_SCENE_CHOICE_TXT_1b"
		}
	},
	{
		title = "QUEST_SCENE_CHOICE_TXT_2",
		choice = {
			"QUEST_SCENE_CHOICE_TXT_2a",
			"QUEST_SCENE_CHOICE_TXT_2b"
		}
	},
	{
		title = "QUEST_SCENE_CHOICE_TXT_3",
		choice = {
			"QUEST_SCENE_CHOICE_TXT_3a",
			"QUEST_SCENE_CHOICE_TXT_3b"
		}
	},
	{
		title = "QUEST_SCENE_CHOICE_TXT_4",
		choice = {
			"QUEST_SCENE_CHOICE_TXT_4a",
			"QUEST_SCENE_CHOICE_TXT_4b"
		}
	}
}

function QuestSceneChoiceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QuestSceneChoiceCtrl:addListener()
	function self.view.btnOptionLUButton.luaClick()
		if State == 1 or self.view.lProgressUProgress.value > 0.5 then
			return
		end

		self.selectIndex = self.LikeListType.L
		self.view.lProgressUProgress.value = self.view.lProgressUProgress.value + 0.05
		State = 1
		self.view.lSliderSelUSlider.value = self.view.lProgressUProgress.value

		self.view.btnOptionLUComponent:TryChangePage("State", State)
	end

	function self.view.btnOptionRUButton.luaClick()
		if State == 1 or self.view.rProgressUProgress.value > 0.5 then
			return
		end

		self.selectIndex = self.LikeListType.R
		self.view.rProgressUProgress.value = self.view.rProgressUProgress.value + 0.05
		State = 1
		self.view.rSliderSelUSlider.value = self.view.rProgressUProgress.value

		self.view.btnOptionRUComponent:TryChangePage("State", State)
	end

	function self.view.lPlayerNameUScrollList.luaRenderItem(button, data)
		self:onRenderEnterItem(button, data, 1)
	end

	function self.view.rPlayerNameUScrollList.luaRenderItem(button, data)
		self:onRenderEnterItem(button, data, 2)
	end
end

function QuestSceneChoiceCtrl:onRenderEnterItem(button, data, likeType)
	local objectReference = button:GetComponent("ObjectReference")
	local contentTxt = objectReference:GetRefValue("txtName")

	ClientTextUtils.setText(contentTxt, data[1].name)

	if self.LikeListType.L == likeType and self.view.lProgressUProgress.value <= 0.45 then
		self.view.lProgressUProgress.value = self.view.lProgressUProgress.value + 0.05
	elseif self.LikeListType.R == likeType and self.view.rProgressUProgress.value <= 0.45 then
		self.view.rProgressUProgress.value = self.view.rProgressUProgress.value + 0.05
	end
end

function QuestSceneChoiceCtrl:onShow()
	return
end

function QuestSceneChoiceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info ~= nil then
		self.index = info.index or 1
	end

	self.itemQueue = Queue.new(10)

	self:showPanel(info)
end

function QuestSceneChoiceCtrl:showPanel(info)
	self.view.rootUComponent:TryChangePage("IsFinish", isFinish and 1 or 0)

	self.view.progressUProgress.value = 1
	self.view.lProgressUProgress.value = 0
	self.view.rProgressUProgress.value = 0
	self.Countdown = self.Timeout
	self.ProgressShowTimer = self:startTimer(function()
		if not self.view then
			return
		end

		self.Countdown = self.Countdown - 1

		local progress = math.min((self.Countdown - self.ShowFinishTime) / (self.Timeout - self.ShowFinishTime), 1)

		self.view.progressUProgress:ProgressToValue(progress, nil, 0.2)

		if self.Countdown == 0 then
			self:killTimer(self.ProgressShowTimer)

			self.ProgressShowTimer = nil

			self:dismiss()
		elseif self.Countdown == self.ShowFinishTime then
			State = 2

			LuaUIUtils.setUIViewVisible(self.view.progressUProgress, false)
			self.view.btnOptionLUComponent:TryChangePage("State", State)
			self.view.btnOptionRUComponent:TryChangePage("State", State)
			ClientTextUtils.setText(self.view.lTxtNumUBaseText, math.ceil(self.view.lProgressUProgress.value * 100) .. "%")
			ClientTextUtils.setText(self.view.rTxtNumUBaseText, math.ceil(self.view.rProgressUProgress.value * 100) .. "%")
			ClientTextUtils.setText(self.view.txtTitleUBaseText, ClientTextUtils.getGameString("QUEST_SCENE_CHOICE_TXT_1z"))

			self.view.lSliderSelUSlider.value = self.view.lProgressUProgress.value
			self.view.rSliderSelUSlider.value = self.view.rProgressUProgress.value

			if self.selectIndex == self.LikeListType.L then
				self.view.lSliderSelUSlider:SetActive(true)
				self.view.rProgressUProgress:SetActive(true)
				self.view.lFrameSelUImage:SetActive(true)
			elseif self.selectIndex == self.LikeListType.R then
				self.view.rSliderSelUSlider:SetActive(true)
				self.view.lProgressUProgress:SetActive(true)
				self.view.rFrameSelUImage:SetActive(true)
			else
				self.view.lProgressUProgress:SetActive(true)
				self.view.rProgressUProgress:SetActive(true)
			end
		elseif self.Countdown == self.ShowLikeTime then
			isFinish = true

			self.view.rootUComponent:TryChangePage("IsFinish", isFinish and 1 or 0)
		end

		local randIndex = math.random(1, 10)

		if self.Countdown > self.ShowFinishTime then
			if randIndex % 2 == 0 then
				self:setLikeList(self.view.lPlayerNameUScrollList, self.LikeListType.L)
			elseif randIndex % 3 == 0 then
				self:setLikeList(self.view.rPlayerNameUScrollList, self.LikeListType.R)
			end
		end
	end, 1, true)

	ClientTextUtils.setText(self.view.txtTitleUBaseText, ClientTextUtils.getGameString(SceneChoiceText[self.index].title))
	ClientTextUtils.setText(self.view.lTxtOptionUBaseText, ClientTextUtils.getGameString(SceneChoiceText[self.index].choice[1]))
	ClientTextUtils.setText(self.view.rTxtOptionUBaseText, ClientTextUtils.getGameString(SceneChoiceText[self.index].choice[2]))
	self.view.btnOptionLUComponent:TryChangePage("State", State)
	self.view.btnOptionRUComponent:TryChangePage("State", State)
end

function QuestSceneChoiceCtrl:onHide()
	return
end

function QuestSceneChoiceCtrl:checkFadeOutHud()
	return false
end

function QuestSceneChoiceCtrl:onDestroy()
	isFinish = false
	State = 0

	self.itemQueue:clear()
	UICtrl.onDestroy(self)
end

function QuestSceneChoiceCtrl:setLikeList(ulist, likeType)
	if State == 0 then
		local nameStr = pg.getGameString("QUEST_SCENE_CHOICE_NAMES")
		local nameArr = nameStr.split(nameStr, "，")
		local indexMax = likeType == self.LikeListType.L and #nameArr / 2 or #nameArr
		local randIndex = math.random(1, indexMax)
		local itemData = {
			{
				name = pg.getLocalizationText(nameArr[randIndex])
			}
		}

		ulist:PushRenderItem(itemData)
		self.itemQueue:enQueue({
			ulist = ulist,
			itemData = itemData
		})
		self:startTimer(function()
			if not self.itemQueue:isEmpty() then
				local queueItem = self.itemQueue:deQueue()

				if queueItem then
					queueItem.ulist:DestroyItem(queueItem.itemData)
				end
			end
		end, 3)
	end
end

return QuestSceneChoiceCtrl
