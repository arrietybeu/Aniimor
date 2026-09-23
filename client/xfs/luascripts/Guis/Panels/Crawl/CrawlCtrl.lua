-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Crawl\\CrawlCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CrawlCtrl")
local CrawlPCComponent = require("Guis.Panels.Crawl.Component.CrawlPCComponent")
local CrawlMobileComponent = require("Guis.Panels.Crawl.Component.CrawlMobileComponent")
local CrawlAimComponent = require("Guis.Panels.Crawl.Component.CrawlAimComponent")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CrawlCtrl = Class.LightClass("CrawlCtrl", UICtrl)

CrawlCtrl.messages = {
	[MessageName.MAGNESIS_MODE_CHANGE] = {
		"onCrawlModeChange",
		true
	},
	[MessageName.MAGNESIS_AIM] = {
		"onMagnesisAimChange",
		true
	},
	[MessageName.MAGNESIS_SWITCH_BEHAVIOR] = {
		"onMagnesisBehaviorChange",
		true
	},
	[MessageName.SKILL_FREE_AIM] = {
		"onFreeAimModeChange",
		true
	}
}

function CrawlCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CrawlCtrl:onOpen()
	self:loadPlatformComponent()

	self.crawlAimComponent = CrawlAimComponent.new(self, self.view.crawlAimObjectReference.transform)

	local controlAxisBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "controlAxis")

	controlAxisBind.isVirtual = true
	controlAxisBind.priority = 0
	controlAxisBind.actionPath = "Skill/Zoom"

	function controlAxisBind.luaTrigger(inputInfo)
		local deltaZoom = inputInfo.valueVec2.y

		pg.me:magnesisUpdateControlDistance(deltaZoom)
	end

	local gamepadZoomDelta = 10
	local controlAxisGamePadZoomIn = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "controlAxisGamePadZoomIn")

	controlAxisGamePadZoomIn.isVirtual = true
	controlAxisGamePadZoomIn.priority = 0
	controlAxisGamePadZoomIn.actionPath = "Skill/ZoomIn"

	function controlAxisGamePadZoomIn.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if self.zoomInTimer == nil then
				local function zoomInFunc()
					pg.me:magnesisUpdateControlDistance(-gamepadZoomDelta)
				end

				zoomInFunc()

				self.zoomInTimer = self:startTimer(zoomInFunc, 0.05, true)
			end
		elseif inputInfo.phase == "Canceled" and self.zoomInTimer then
			self:killTimer(self.zoomInTimer)

			self.zoomInTimer = nil
		end
	end

	local controlAxisGamePadZoomOut = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "controlAxisGamePadZoomOut")

	controlAxisGamePadZoomOut.isVirtual = true
	controlAxisGamePadZoomOut.priority = 0
	controlAxisGamePadZoomOut.actionPath = "Skill/ZoomOut"

	function controlAxisGamePadZoomOut.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if self.zoomOutTimer == nil then
				local function zoomOutFunc()
					pg.me:magnesisUpdateControlDistance(gamepadZoomDelta)
				end

				zoomOutFunc()

				self.zoomOutTimer = self:startTimer(zoomOutFunc, 0.05, true)
			end
		elseif inputInfo.phase == "Canceled" and self.zoomOutTimer then
			self:killTimer(self.zoomOutTimer)

			self.zoomOutTimer = nil
		end
	end
end

function CrawlCtrl:loadPlatformComponent()
	if pg.global.ui:runPlatformByMobile() then
		local container = self.view.mobileUContainer

		if not IsNil(container.content) then
			self.crawlComponent = CrawlMobileComponent.new(self, container.content.transform)
		else
			container:LoadDefaultUrlManually(function()
				self.crawlComponent = CrawlMobileComponent.new(self, container.content.transform)
			end)
		end
	else
		local container = self.view.pcUContainer

		if not IsNil(container.content) then
			self.crawlComponent = CrawlPCComponent.new(self, container.content.transform)
		else
			container:LoadDefaultUrlManually(function()
				self.crawlComponent = CrawlPCComponent.new(self, container.content.transform)
			end)
		end
	end
end

function CrawlCtrl:onCrawlModeChange(enable)
	if self.crawlComponent and self.crawlComponent.onMagnesisMode then
		self.crawlComponent:onMagnesisMode(enable)
	end

	if self.crawlAimComponent and self.crawlAimComponent.onMagnesisModeChange then
		self.crawlAimComponent:onMagnesisModeChange(enable)
	end

	if not enable then
		self:hide()
	end
end

function CrawlCtrl:onMagnesisAimChange(isAim)
	if self.crawlAimComponent and self.crawlAimComponent.onMagnesisAimChange then
		self.crawlAimComponent:onMagnesisAimChange(isAim)
	end
end

function CrawlCtrl:onMagnesisBehaviorChange(isThrow)
	if self.crawlComponent and self.crawlComponent.onMagnesisBehaviorChange then
		self.crawlComponent:onMagnesisBehaviorChange(isThrow)
	end

	if self.crawlAimComponent and self.crawlAimComponent.onMagnesisBehaviorChange then
		self.crawlAimComponent:onMagnesisBehaviorChange(isThrow)
	end
end

function CrawlCtrl:onFreeAimModeChange(enable)
	if self.crawlComponent and self.crawlComponent.onFreeAimModeChange then
		self.crawlComponent:onFreeAimModeChange(enable)
	end

	if self.crawlAimComponent and self.crawlAimComponent.onFreeAimModeChange then
		self.crawlAimComponent:onFreeAimModeChange(enable)
	end

	if not enable then
		self:hide()
	end
end

function CrawlCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.crawlComponent = nil
	self.crawlAimComponent = nil
end

return CrawlCtrl
