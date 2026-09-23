-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Crawl\\Component\\CrawlPCComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local AddressDataConst = require("Const.AddressDataConst")
local MessageName = require("Const.MessageName")
local CrawlPCComponent = Class.LightClass("CrawlPCComponent", UIComponent)
local MagnesisActionPath = {
	"Skill/Grab",
	"Skill/TossItem",
	"Skill/CancelGrab",
	"Skill/PutItem"
}

function CrawlPCComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
end

function CrawlPCComponent:initView()
	function self.listBtnUList.luaRenderItem(button, idx, data)
		self:renderOperateBtn(button, idx, data)
	end

	self:setOperateBtn()

	if self.ctrl.isInMagnesis then
		self:onMagnesisBehaviorChange(false)
	else
		self:onFreeAimModeChange(true)
	end
end

function CrawlPCComponent:setOperateBtn()
	self.listBtnUList:SetList({
		{},
		{}
	})
end

function CrawlPCComponent:renderOperateBtn(button, idx, data)
	local btnRef = button:GetComponent("ObjectReference")
	local txtNameUText = btnRef:GetRefValue("txtNameUText")
	local keyBind = btnRef:GetComponent("KeyBindingPro")
	local icon = btnRef:GetRefValue("iconUImage")

	button:TryChangePage("Behavior", 2)

	if idx == 0 then
		self.magnesisBtn = button
		self.magnesisBtnText = txtNameUText
		self.magnesisBtnKeyBind = keyBind
		self.magnesisBtnIcon = icon
	elseif idx == 1 then
		self.exitMagnesisBtn = button
		self.exitMagnesisBtnText = txtNameUText
		self.exitMagnesisBtnKeyBind = keyBind
		self.exitMagnesisBtnIcon = icon
	end
end

function CrawlPCComponent:onCrawlBtnClick()
	local player = pg.me

	if player then
		player:magnesisGrabOrThrow()
	end
end

function CrawlPCComponent:onGrabCancelBtnClick()
	local player = pg.me

	if player then
		player:magnesisCancel()
	end
end

function CrawlPCComponent:onMagnesisMode(enable)
	if enable then
		self:onMagnesisBehaviorChange(false)
	end
end

function CrawlPCComponent:onMagnesisBehaviorChange(isThrow)
	if isThrow then
		self.magnesisBtn:TryChangePage("GrabState", 3)

		self.magnesisBtnIcon.url = AddressDataConst.MAGNESIS_SKILL_PUT_DOWN

		ClientTextUtils.setText(self.magnesisBtnText, pg.getGameString("MAGNESIS_PUT_ITEM"))

		self.magnesisBtnKeyBind.actionPath = MagnesisActionPath[4]

		self.magnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[4])
		self.exitMagnesisBtn:TryChangePage("GrabState", 1)

		self.exitMagnesisBtnIcon.url = AddressDataConst.MAGNESIS_SKILL_THROW

		ClientTextUtils.setText(self.exitMagnesisBtnText, pg.getGameString("MAGNESIS_THROW"))

		self.exitMagnesisBtnKeyBind.actionPath = MagnesisActionPath[2]

		self.exitMagnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[2])

		function self.magnesisBtn.luaClick()
			self:onGrabCancelBtnClick()
		end

		function self.exitMagnesisBtn.luaClick()
			self:onCrawlBtnClick()
		end
	else
		self.magnesisBtn:TryChangePage("GrabState", 0)

		self.magnesisBtnIcon.url = AddressDataConst.MAGNESIS_SKILL_GRAB

		ClientTextUtils.setText(self.magnesisBtnText, pg.getGameString("MAGNESIS_GRAB"))

		self.magnesisBtnKeyBind.actionPath = MagnesisActionPath[1]

		self.magnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[1])
		self.exitMagnesisBtn:TryChangePage("GrabState", 2)

		self.exitMagnesisBtnIcon.url = AddressDataConst.MAGNESIS_SKILL_EXIT_GRAB

		ClientTextUtils.setText(self.exitMagnesisBtnText, pg.getGameString("MAGNESIS_CANCEL_GRAB"))

		self.exitMagnesisBtnKeyBind.actionPath = MagnesisActionPath[3]

		self.exitMagnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[3])

		local abilityActionPath = LuaUIUtils.getSkillActionPath(pg.me.combatContext.abilityId or 0)

		LuaUIUtils.bindHotKey(self.exitMagnesisBtn.gameObject, abilityActionPath, function()
			if pg.me:MAGNESIS_READY_ST() then
				self:onGrabCancelBtnClick()
			end
		end)

		function self.magnesisBtn.luaClick()
			self:onCrawlBtnClick()
		end

		function self.exitMagnesisBtn.luaClick()
			self:onGrabCancelBtnClick()
		end
	end
end

function CrawlPCComponent:onFreeAimModeChange(enable)
	if enable then
		self.magnesisBtn:TryChangePage("GrabState", 0)
		ClientTextUtils.setText(self.magnesisBtnText, pg.getGameString("MAGNESIS_GRAB"))

		self.magnesisBtnKeyBind.actionPath = MagnesisActionPath[1]

		self.magnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[1])
		self.exitMagnesisBtn:TryChangePage("GrabState", 2)
		ClientTextUtils.setText(self.exitMagnesisBtnText, pg.getGameString("MAGNESIS_CANCEL_GRAB"))

		self.exitMagnesisBtnKeyBind.actionPath = MagnesisActionPath[3]

		self.exitMagnesisBtnKeyBind.keyBoardContent:SetHotKeyPaths(MagnesisActionPath[3])

		function self.magnesisBtn.luaClick()
			pg.pawn:serverMsg("RPC_CS_OnFreeAimConfirmBtnClicked")
			pg.pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CONFIRM_BTN_CLICKED)
		end

		function self.exitMagnesisBtn.luaClick()
			pg.pawn:serverMsg("RPC_CS_OnFreeAimCancelBtnClicked")
			pg.pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CANCEL_BTN_CLICKED)
		end
	end
end

function CrawlPCComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return CrawlPCComponent
