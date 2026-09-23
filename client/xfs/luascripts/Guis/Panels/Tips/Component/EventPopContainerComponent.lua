-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\EventPopContainerComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventPopContainerComponent = Class.LightClass("EventPopContainerComponent", UIComponent)

function EventPopContainerComponent:onCtor(info)
	self.container = self.transform:GetComponent("UContainer")
	self.refContainersLoaded = false
	self.loadSerial = 0
end

function EventPopContainerComponent:checkContainerLoaded()
	return self.refContainersLoaded
end

function EventPopContainerComponent:unloadContainer()
	self.loadSerial = (self.loadSerial or 0) + 1

	self.container:DestroyContent()

	self.refContainersLoaded = false
end

function EventPopContainerComponent:findObjects()
	if not self:checkContainerLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.petPicUImage = self.objectReference:GetRefValue("petPicUImage")
	self.confirmUButton = self.objectReference:GetRefValue("confirmUButton")
	self.confirmUBaseText = self.objectReference:GetRefValue("confirmUBaseText")
	self.closeUButton = self.objectReference:GetRefValue("closeUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.nextTimeUWidget = self.objectReference:GetRefValue("nextTimeUWidget")
	self.nextTimeUButton = self.objectReference:GetRefValue("nextTimeUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function EventPopContainerComponent:showEvent(title, desc, okCb, closeCb, extraInfo)
	self.loadSerial = (self.loadSerial or 0) + 1

	local loadSerial = self.loadSerial

	if not self:checkContainerLoaded() then
		self.container:LoadDefaultUrlManually(function()
			if loadSerial ~= self.loadSerial then
				return
			end

			self.refContainersLoaded = true

			self:findObjects()
			self:showEventInternal(title, desc, okCb, closeCb, extraInfo)
		end)
	else
		self:showEventInternal(title, desc, okCb, closeCb, extraInfo)
	end
end

function EventPopContainerComponent:showEventInternal(title, desc, okCb, closeCb, extraInfo)
	ClientTextUtils.setText(self.titleUBaseText, pg.getLocalizationText(title or ""))
	ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(desc or ""))

	if extraInfo and extraInfo.image then
		self.petPicUImage.url = extraInfo.image
	else
		self.petPicUImage.url = ""
	end

	if extraInfo and extraInfo.hint then
		self.nextTimeUWidget:SetActiveFastest(true)
	else
		self.nextTimeUWidget:SetActiveFastest(false)
	end

	function self.confirmUButton.luaClick()
		local hintSelected = extraInfo and extraInfo.hintCb and self.nextTimeUButton.isSelected

		self.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Hide, function()
			self:hide()
			self:unloadContainer()

			if okCb then
				okCb()
			end

			if extraInfo and extraInfo.hintCb then
				extraInfo.hintCb(hintSelected)
			end
		end)
	end

	function self.closeUButton.luaClick()
		local hintSelected = extraInfo and extraInfo.hintCb and self.nextTimeUButton.isSelected

		self.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Hide, function()
			self:hide()
			self:unloadContainer()

			if closeCb then
				closeCb()
			end

			if extraInfo and extraInfo.hintCb then
				extraInfo.hintCb(hintSelected)
			end
		end)
	end

	self:show()
end

function EventPopContainerComponent:onHide()
	self.ctrl:componentSetIsModel("Event", false)
end

function EventPopContainerComponent:onShow()
	self.ctrl:componentSetIsModel("Event", true)
	self:onShowPlayEvent()
end

function EventPopContainerComponent:onShowPlayEvent()
	pg.game.audio:playEvent("SFX_UI_Event_PetSave_FacePic")
end

return EventPopContainerComponent
