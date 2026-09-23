-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPhotoRecognize\\EventPhotoRecognizeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventPhotoRecognizeCtrl")
local MessageName = require("Const.MessageName")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapBlockConfigData = require("Data.map_block_config_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local ActivityConst = require("Common.Const.ActivityConst")
local EventPhotoRecognizeCtrl = Class.LightClass("EventPhotoRecognizeCtrl", UICtrl)

EventPhotoRecognizeCtrl.messages = {}

function EventPhotoRecognizeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function EventPhotoRecognizeCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	function self.view.clueUList.luaRenderItem(button, index, data)
		self:renderClueItem(button, index, data)
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end

		self.view.btnCloseUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadConfirm)
	end

	function self.view.clueUList.luaFinishRender(list)
		self.isRecognizeFinished = true

		self.view.widget:TryChangePage("state", "idenified")

		if self.targetTemplateId == self.photoTemplateId then
			self:startTimer(function()
				self:dismiss()
			end, 1)
		else
			self.view.btnCloseUButton:SetActive(true)
		end
	end
end

function EventPhotoRecognizeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.targetTemplateId = info.targetTemplateId
	self.photoPath = info.photoPath
	self.sprite = info.sprite
	self.photoTemplateId = info.curTemplateId
	self.eventId = info.eventId
	self.photoTimeStamp = info.timeStamp
	self.photoPos = info.position
	self.photoSceneId = info.sceneId
	self.correctGender = info.correctGender

	self:initUI()
end

function EventPhotoRecognizeCtrl:onShow()
	return
end

function EventPhotoRecognizeCtrl:onHide()
	return
end

function EventPhotoRecognizeCtrl:onDestroy()
	self:reportPhotoData()
	self.model:destroyPhoto(self.photoPath)
	UICtrl.onDestroy(self)
end

function EventPhotoRecognizeCtrl:initUI()
	self.view.widget:TryChangePage("state", "recognizing")
	self.view.btnCloseUButton:SetActive(false)

	if string.startsWith(self.photoPath, "$") then
		self.view.photoUImage.url = self.photoPath
	elseif self.photoPath then
		self.view.photoUImage.sprite = self.model:getPhoto(self.photoPath)
	elseif self.sprite then
		self.view.photoUImage.sprite = self.sprite
	end

	local blockIds = Utils.getBelongedMapBlockIds(self.photoSceneId, self.photoPos)
	local blockId = blockIds and blockIds[1]

	if blockId then
		local name = MapBlockConfigData[blockId].areaName

		ClientTextUtils.setText(self.view.locationText, pg.getLocalizationText(name))
	end

	ClientTextUtils.setText(self.view.timeUBaseText, LuaUIUtils.timeStampToUtcString(self.photoTimeStamp))

	local petName = PetData[self.photoTemplateId] and PetData[self.photoTemplateId].name

	ClientTextUtils.setText(self.view.recognizeText, string.format("%s-%s", pg.getLocalizationText(petName), pg.getGameString("PETSHAPE_IDENTIFY")))

	self.clueList = self.model:getClueList(self.photoTemplateId, self.targetTemplateId)
	self.isRecognizeFinished = false

	self.view.clueUList:SetList(self.clueList)
end

function EventPhotoRecognizeCtrl:renderClueItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootButton = objectReference:GetRefValue("rootButton")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	rootButton:TryChangePage("State", data.state)
	ClientTextUtils.setText(textUBaseText, data.str)
	pg.game.audio:playEvent("SFX_UI_ImoSurvey_GetClue")

	if pg.game.input:isUsingGamepad() then
		local recognizeSuccess = data.state == 1 or data.state == 2
		local rumbleName = recognizeSuccess and "CommonHigh" or "CommonLight"

		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, rumbleName)
	end
end

function EventPhotoRecognizeCtrl:tryDismiss()
	if not self.isRecognizeFinished then
		return false
	end

	self:dismiss()

	return true
end

function EventPhotoRecognizeCtrl:reportPhotoData()
	if self.photoTemplateId then
		local clueData = {}

		if not Utils.tableIsEmptyOrNil(self.clueList) then
			for i = ActivityConst.PuppetPhotoClueType.Attr, ActivityConst.PuppetPhotoClueType.Explore do
				if self.clueList[i].state == 1 or self.clueList[i].state == 2 then
					clueData[i] = true
				end
			end
		end

		pg.me:reqActivityPhotoReport(self.eventId, self.photoTemplateId, clueData)

		if self.targetTemplateId ~= self.photoTemplateId then
			if not Utils.tableIsEmptyOrNil(clueData) then
				pg.global.showBubbleMessageRaw(pg.getGameString("PETSHAPE_CLUETIP"), 3)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("PET_RESEARCH_SHAPE_WRONG"), 3)
			end
		else
			local key = ClientConst.PrefKey.EventFormResearch .. self.eventId

			pg.global.prefsCacheUtils:setString(key, self.photoPath)

			local genderKey = ClientConst.PrefKey.EventFormResearchGender .. self.eventId

			pg.global.prefsCacheUtils:setInt(genderKey, self.correctGender)
		end
	end
end

function EventPhotoRecognizeCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return EventPhotoRecognizeCtrl
