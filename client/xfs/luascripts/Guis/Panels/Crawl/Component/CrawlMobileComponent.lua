-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Crawl\\Component\\CrawlMobileComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local CrawlMobileComponent = Class.LightClass("CrawlMobileComponent", UIComponent)

function CrawlMobileComponent:findObjects()
	local oc = self.transform:GetComponent("ObjectReference")

	self.panelCrawl = self.transform:GetComponent("UComponent")
	self.crawlExitBtn = oc:GetRefValue("btnCloseUButton")
	self.crawlBtn = oc:GetRefValue("btnCrawlUButton")
	self.throwCancelBtn = oc:GetRefValue("btnThrowCancelUButton")
	self.throwBtn = oc:GetRefValue("btnThrowUButton")
	self.crawlJoystick = oc:GetRefValue("joyStickUJoyStick")
	self.crawlCancelBtn = oc:GetRefValue("btnCancelUButton")
	self.btnEnlargeUButton = oc:GetRefValue("btnEnlargeUButton")
	self.btnReduceUButton = oc:GetRefValue("btnReduceUButton")
end

function CrawlMobileComponent:initView()
	function self.throwBtn.luaClick()
		self:magnesisGrabOrThrow()
	end

	function self.throwCancelBtn.luaClick()
		self:cancelGrab()
	end

	function self.crawlCancelBtn.luaClick()
		self:cancelGrab()
	end

	function self.crawlExitBtn.luaHover()
		self:setCancelMode(true)
	end

	function self.crawlExitBtn.luaUnhover()
		self:setCancelMode(false)
	end

	function self.crawlExitBtn.luaClick()
		self.panelCrawl:TryChangePage("expand", 0)

		self.crawlJoystick.defaultOpacity = 0

		self:setCancelMode(false)
		pg.game.input:setViewAxisByDelta(0, 0)
	end

	function self.crawlBtn.luaPress()
		self.panelCrawl:TryChangePage("expand", 1)

		self.crawlJoystick.defaultOpacity = 1

		self:setCancelMode(false)
	end

	function self.crawlBtn.luaRelease()
		if not self.crawlJoystick.isDragging then
			self.panelCrawl:TryChangePage("expand", 0)

			self.crawlJoystick.defaultOpacity = 0

			self:magnesisGrabOrThrow()
		end
	end

	function self.crawlJoystick.luaDragUpdate(x, y)
		local ret, page = self.panelCrawl:TryGetCurrentPage("expand")

		if page == 1 and not self.isInCrawlCancelMode then
			pg.game.input:setViewAxisByDeltaPixel(x, y)
		end
	end

	function self.crawlJoystick.luaJoyStickEndDrag()
		local ret, page = self.panelCrawl:TryGetCurrentPage("expand")

		if page == 1 then
			if not self.isInCrawlCancelMode then
				self:magnesisGrabOrThrow()
			end

			self.panelCrawl:TryChangePage("expand", 0)

			self.crawlJoystick.defaultOpacity = 0
		end

		pg.game.input:setViewAxisByDelta(0, 0)
		self:setCancelMode(false)
	end

	function self.btnEnlargeUButton.luaLongPress(pressTime)
		pg.me:magnesisUpdateControlDistance(0.1)
	end

	function self.btnEnlargeUButton.luaClick(pressTime)
		pg.me:magnesisUpdateControlDistance(1)
	end

	function self.btnReduceUButton.luaLongPress(pressTime)
		pg.me:magnesisUpdateControlDistance(-0.1)
	end

	function self.btnReduceUButton.luaClick(pressTime)
		pg.me:magnesisUpdateControlDistance(-1)
	end

	if self.ctrl.isInMagnesis then
		self:onMagnesisMode(true)
	else
		self:onFreeAimModeChange(true)
	end
end

function CrawlMobileComponent:magnesisGrabOrThrow()
	local player = pg.me

	if player then
		player:magnesisGrabOrThrow()
	end
end

function CrawlMobileComponent:setCancelMode(isInCancelMode)
	self.isInCrawlCancelMode = isInCancelMode

	local cancelState = 0

	if isInCancelMode then
		cancelState = 1

		pg.game.input:setViewAxisByDelta(0, 0)
	end

	self.panelCrawl:TryChangePage("CancelMode", cancelState)
end

function CrawlMobileComponent:cancelGrab()
	local player = pg.me

	if player then
		player:magnesisCancel()
	end
end

function CrawlMobileComponent:onMagnesisMode(enable)
	if enable then
		self:onMagnesisBehaviorChange(false)

		function self.crawlCancelBtn.luaClick()
			self:cancelGrab()
		end

		function self.crawlBtn.luaRelease()
			if not self.crawlJoystick.isDragging then
				self.panelCrawl:TryChangePage("expand", 0)

				self.crawlJoystick.defaultOpacity = 0

				self:magnesisGrabOrThrow()
			end
		end

		function self.crawlJoystick.luaJoyStickEndDrag()
			local ret, page = self.panelCrawl:TryGetCurrentPage("expand")

			if page == 1 then
				if not self.isInCrawlCancelMode then
					self:magnesisGrabOrThrow()
				end

				self.panelCrawl:TryChangePage("expand", 0)

				self.crawlJoystick.defaultOpacity = 0
			end

			pg.game.input:setViewAxisByDelta(0, 0)
			self:setCancelMode(false)
		end
	end
end

function CrawlMobileComponent:onMagnesisBehaviorChange(isThrow)
	if isThrow then
		self.panelCrawl:TryChangePage("CrewState", 1)
	else
		self.panelCrawl:TryChangePage("CrewState", 0)
	end
end

function CrawlMobileComponent:onFreeAimModeChange(enable)
	if enable then
		self.panelCrawl:TryChangePage("CrewState", 0)

		function self.crawlBtn.luaRelease()
			if not self.crawlJoystick.isDragging then
				self.panelCrawl:TryChangePage("expand", 0)

				self.crawlJoystick.defaultOpacity = 0

				pg.pawn:serverMsg("RPC_CS_OnFreeAimConfirmBtnClicked")
				pg.pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CONFIRM_BTN_CLICKED)
			end
		end

		function self.crawlCancelBtn.luaClick()
			pg.pawn:serverMsg("RPC_CS_OnFreeAimCancelBtnClicked")
			pg.pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CANCEL_BTN_CLICKED)
		end

		function self.crawlJoystick.luaJoyStickEndDrag()
			local ret, page = self.panelCrawl:TryGetCurrentPage("expand")

			if page == 1 then
				if not self.isInCrawlCancelMode then
					pg.pawn:serverMsg("RPC_CS_OnFreeAimConfirmBtnClicked")
					pg.pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CONFIRM_BTN_CLICKED)
				end

				self.panelCrawl:TryChangePage("expand", 0)

				self.crawlJoystick.defaultOpacity = 0
			end

			pg.game.input:setViewAxisByDelta(0, 0)
			self:setCancelMode(false)
		end
	end
end

function CrawlMobileComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return CrawlMobileComponent
