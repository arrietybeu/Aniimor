-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PetSaveRootComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local PetSaveRootComponent = Class.LightClass("PetSaveRootComponent", EventContainerComponent)
local PetSaveComponent = require("Guis.Panels.Event.Component.PetSaveComponent")
local PetSaveManualComponent = require("Guis.Panels.Event.Component.PetSaveManualComponent")

function PetSaveRootComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function PetSaveRootComponent:refreshPage()
	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	local curWeek = ClientActivityUtils.checkPetSaveCurWeek()
	local savePetOpen = ClientActivityUtils.checkIsPetSaveType(curWeek)

	self.showPage = nil

	local showContainerName = savePetOpen and "petSaveUContainer" or "recordManualUContainer"
	local showContainer = self.objectReference:GetRefValue(showContainerName)

	showContainer:SetActive(true)
	showContainer:LoadDefaultUrlManually(function(widget)
		if savePetOpen then
			self.showPage = PetSaveComponent.new(self, widget:GetComponent("ObjectReference"), {
				week = curWeek,
				eventId = self.eventId
			})
		else
			self.showPage = PetSaveManualComponent.new(self, widget:GetComponent("ObjectReference"), {
				week = curWeek,
				eventId = self.eventId
			})
		end
	end)
	self.rootUComponent:TryChangePage("PanelType", savePetOpen and 1 or 0)
	self:refreshRootNodeRedDot()
end

function PetSaveRootComponent:refreshRootNodeRedDot()
	self:refreshCommonNodeRedDot()

	if self.showPage and self.showPage.refreshNodeRedDot then
		self.showPage:refreshNodeRedDot()
	end
end

function PetSaveRootComponent:onEnterPlayEvent()
	local curWeek = ClientActivityUtils.checkPetSaveCurWeek()
	local savePetOpen = ClientActivityUtils.checkIsPetSaveType(curWeek)

	if savePetOpen then
		pg.game.audio:playEvent("SFX_UI_Event_PetSave_MoveIn")
	else
		pg.game.audio:playEvent("SFX_UI_CollegeRecords_MoveIn")
	end
end

function PetSaveRootComponent:onBeforeExitPage()
	if self.showPage and self.showPage.stopVideo then
		self.showPage:stopVideo()
	end
end

function PetSaveRootComponent:onDestroy()
	if self.showPage then
		self.showPage:destroy()

		self.showPage = nil
	end

	UIComponent.onDestroy(self)
end

return PetSaveRootComponent
