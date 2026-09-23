-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\SyncopeUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("SyncopeUIComponent")
local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local SyncopeUIComponent = Class.LightClass("SyncopeUIComponent", HudBaseComponent)

SyncopeUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged"
	}
}

function SyncopeUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCallHelpUButton = objectReference:GetRefValue("btnCallHelpUButton")
	self.btnSkipUButton = objectReference:GetRefValue("btnSkipUButton")
	self.btnStopUButton = objectReference:GetRefValue("btnStopUButton")
	self.btnSelfRescueUButton = objectReference:GetRefValue("btnSelfRescueUButton")

	local stopBtnObjRef = self.btnStopUButton:GetComponent("ObjectReference")
	local stopBtnKeyBind = stopBtnObjRef:GetRefValue("btnNormalKeyBindingPro")

	stopBtnKeyBind.actionPath = "Common/Cancel"

	local stopBtnText = stopBtnObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(stopBtnText, pg.getGameString("STOP_FALLEN_AID"))

	local callHelpBtnObjRef = self.btnCallHelpUButton:GetComponent("ObjectReference")
	local callHelpBtnKeyBind = callHelpBtnObjRef:GetRefValue("btnNormalKeyBindingPro")

	callHelpBtnKeyBind.actionPath = "Hud/EggCallHelp"

	local callHelpBtnText = callHelpBtnObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(callHelpBtnText, pg.getGameString("FALLEN_CALL_HELP"))

	local skipBtnObjRef = self.btnSkipUButton:GetComponent("ObjectReference")
	local skipBtnKeyBind = skipBtnObjRef:GetRefValue("btnNormalKeyBindingPro")

	skipBtnKeyBind.actionPath = "Hud/EggSkip"

	local skipBtnText = skipBtnObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(skipBtnText, pg.getGameString("FALLEN_QUICK_SKIP"))

	local selfRescueBtnObjRef = self.btnSelfRescueUButton:GetComponent("ObjectReference")
	local selfRescueKeyBind = selfRescueBtnObjRef:GetRefValue("btnNormalKeyBindingPro")

	selfRescueKeyBind.actionPath = "Hud/EggSelfRescue"

	local selfRescueBtnText = selfRescueBtnObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(selfRescueBtnText, pg.getGameString("FALLEN_SELF_RESCUE"))

	self.selfRescueCntText = selfRescueBtnObjRef:GetRefValue("textNumUSDFText")
	self.vXClickNoticeUContainer = selfRescueBtnObjRef:GetRefValue("vXClickNoticeUContainer")
end

function SyncopeUIComponent:initView()
	local player = pg.me
	local isFirstAid = player:FIRST_AID_ST()
	local visible = isFirstAid or player:FALLEN_ST()

	self:setVisible(visible, isFirstAid)

	function self.btnCallHelpUButton.luaClick()
		self:callHelp()
	end

	function self.btnStopUButton.luaClick()
		self:onClickStop()
	end

	function self.btnSkipUButton.luaClick()
		self:onSkipBtnClick()
	end

	function self.btnSelfRescueUButton.luaClick()
		self:onSelfRescueBtnClick()
	end
end

function SyncopeUIComponent:callHelp()
	local now = pg.me:getGameTime()

	if not self.lastCallHelpTime or now - self.lastCallHelpTime > (SysConfigData.callHelpDuration or 3) then
		self.lastCallHelpTime = now

		pg.me:serverMsgNoGC("RPC_CS_CallHelp")
	end
end

function SyncopeUIComponent:onClickStop()
	pg.me:serverMsgNoGC("RPC_CS_StopTargetFallenAid")
end

function SyncopeUIComponent:onSkipBtnClick()
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("QUICK_END_FALLEN_CONFIRM"), function()
		pg.me:serverMsgNoGC("RPC_CS_SkipFallenPhase")
	end)
end

function SyncopeUIComponent:onSelfRescueBtnClick()
	local player = pg.me

	if not player:checkSelfRescueCntValid() then
		pg.global.showBubbleMessageById(NoticeDef.CANNOT_HELP_SELF_AGAIN)

		return
	end

	if player:FALLEN_AID_ST() and not Utils.isTargetInSelfRescue(player) then
		pg.global.showBubbleMessageById(NoticeDef.CANNOT_RESCUE_SELF_BE_RESCUED_BY_OTHERS)

		return
	end

	player:serverMsgNoGC("RPC_CS_RequestSelfRescue", function(ret)
		if not ret then
			local selfPlayer = pg.me

			if selfPlayer and selfPlayer:FALLEN_AID_ST() and not Utils.isTargetInSelfRescue(selfPlayer) then
				pg.global.showBubbleMessageById(NoticeDef.CANNOT_RESCUE_SELF_BE_RESCUED_BY_OTHERS)
			end

			return
		end

		facade:SendMessageCommand(MessageName.ENTER_FALLEN_AID)
	end)
end

function SyncopeUIComponent:setVisible(value, isFirstAid)
	self.visible = value
	self.isFirstAid = isFirstAid

	if value then
		self:show()
	else
		self:hide()
	end

	self:refreshSyncopeBtnVisible(isFirstAid)
end

function SyncopeUIComponent:refreshSyncopeBtnVisible(isFirstAid)
	if isFirstAid then
		LuaUIUtils.setUIViewVisible(self.btnStopUButton, true)
		LuaUIUtils.setUIViewVisible(self.btnCallHelpUButton, false)
		LuaUIUtils.setUIViewVisible(self.btnSkipUButton, false)
	else
		LuaUIUtils.setUIViewVisible(self.btnStopUButton, false)
		LuaUIUtils.setUIViewVisible(self.btnCallHelpUButton, true)
		LuaUIUtils.setUIViewVisible(self.btnSkipUButton, true)
	end

	local player = pg.me
	local canUseSelfRescue = ToBool(player.actorCombatAttribute:getRawAttribValue(AttributeConst.can_fallen_self_help))

	LuaUIUtils.setUIViewVisible(self.btnSelfRescueUButton, canUseSelfRescue and not isFirstAid)

	local selfRescueCntValid = player:checkSelfRescueCntValid()

	self.btnSelfRescueUButton.enableTransitionOnStart = false

	self.btnSelfRescueUButton:TryChangePage("button", selfRescueCntValid and 0 or 4)

	self.btnSelfRescueUButton.enableAutoTransition = selfRescueCntValid

	self.vXClickNoticeUContainer.gameObject:SetActiveEx(selfRescueCntValid)

	if selfRescueCntValid then
		ClientTextUtils.setText(self.selfRescueCntText, player:getMaxSelfRescueCnt() - player:getCurSelfRescueCnt())
	else
		ClientTextUtils.setText(self.selfRescueCntText, "<style=Item_Lack>0</style>")
	end
end

function SyncopeUIComponent:onInputDeviceChanged()
	self:refreshSyncopeBtnVisible(self.isFirstAid)
end

return SyncopeUIComponent
