-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FunMenuExit\\FunMenuExitCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local FunMenuExitCtrl = Class.LightClass("FunMenuExitCtrl", UICtrl)
local Const = require("Common.Const.Const")

function FunMenuExitCtrl:addListener()
	function self.view.listItemUList.luaRenderItem(button, index, data)
		self:onRenderItem(button, index, data)
	end
end

function FunMenuExitCtrl:onDestroy()
	self:killTimer(self.npcDuelInfoTimer)

	self.npcDuelInfoTimer = nil

	self:resumeGameTime()
	UICtrl.onDestroy(self)
end

function FunMenuExitCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshFuncItem()
	self:refreshBtnState(info)
	self:pauseGameTime()

	if pg.space and pg.space:isNpcDuel() then
		self.view.rootUComponent:TryChangePage("State", "BattleRoom")
		self:loadNpcDuelInfo()
	else
		self.view.rootUComponent:TryChangePage("State", "Normal")
	end

	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, {
		right = {
			{
				path = "Raw/GamepadLeftStickMove",
				label = pg.getGameString("CONSOLE_BAR_SELECT")
			},
			{
				path = "Common/Comfirm",
				label = pg.getGameString("CONSOLE_BAR_CONFIRM")
			}
		}
	})
end

FunMenuExitCtrl.ButtonTypeToPath = {
	[Const.ExitButtonType.END_AND_EXIT] = "Raw/GamepadButtonNorth",
	[Const.ExitButtonType.CONTINUE] = "Raw/GamepadButtonEast",
	[Const.ExitButtonType.TEMPORARY_EXIT] = "Raw/GamepadButtonWest",
	[Const.ExitButtonType.READJUST] = "Raw/GamepadSelect"
}

function FunMenuExitCtrl:pauseGameTime()
	if self.model:checkStopGameTime() and pg.space then
		pg.space:pauseGameByType(Const.GameTimeScaleType.FUNC_MENU_EXIT, -1)

		self.isGameTimeStopped = true
	end
end

function FunMenuExitCtrl:resumeGameTime()
	if self.isGameTimeStopped and pg.space then
		pg.space:resumeGameByType(Const.GameTimeScaleType.FUNC_MENU_EXIT)

		self.isGameTimeStopped = nil
	end
end

function FunMenuExitCtrl:closePanel()
	self:resumeGameTime()
	self:dismiss()
end

function FunMenuExitCtrl:refreshBtnState(info)
	local BtnCount = 0

	for i = 1, 3 do
		if info["backFunc" .. i + 1] then
			BtnCount = BtnCount + 1
		end
	end

	self.view.rootUComponent:TryChangePage("Type", BtnCount)
	self.view.btnReturn2.gameObject:SetActiveEx(info.backFunc4)
	self.view.btnExit1.gameObject:SetActiveEx(info.backFunc2)
	self.view.btnExit2.gameObject:SetActiveEx(info.backFunc3)
	self.view.btnReturn1:TryChangePage("Type", info.iconType1 or 0)
	self.view.btnReturn2:TryChangePage("Type", info.iconType2 or 0)
	self.view.btnExit1:TryChangePage("Type", info.iconType3 or 1)
	self.view.btnExit2:TryChangePage("Type", info.iconType4 or 1)

	function self.view.btnReturn1.luaClick()
		self:closePanel()

		if info.backFunc1 then
			info:backFunc1()
		end
	end

	if info.backFunc2 then
		function self.view.btnExit1.luaClick()
			self:closePanel()
			info:backFunc2()
		end
	end

	if info.backFunc3 then
		function self.view.btnExit2.luaClick()
			self:closePanel()
			info:backFunc3()
		end
	end

	if info.backFunc4 then
		function self.view.btnReturn2.luaClick()
			self:closePanel()
			info:backFunc4()
		end
	end

	if info.btn1Text then
		ClientTextUtils.setText(self.view.txtReturn1, info.btn1Text)
	end

	if info.btn2Text then
		ClientTextUtils.setText(self.view.txtExit1, info.btn2Text)
	end

	if info.btn3Text then
		ClientTextUtils.setText(self.view.txtExit2, info.btn3Text)
	end

	if info.btn4Text then
		ClientTextUtils.setText(self.view.txtReturn2, info.btn4Text)
	end

	if info.btn1Type then
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[info.btn1Type], function()
			self.view.btnReturn1:OnClickSimulate()
		end, self.view.btnReturn1.gameObject)

		local objectReference = self.view.btnReturn1.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[info.btn1Type])
	else
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE], function()
			self.view.btnReturn1:OnClickSimulate()
		end, self.view.btnReturn1.gameObject)

		local objectReference = self.view.btnReturn1.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE])
	end

	if info.btn2Type then
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[info.btn2Type], function()
			self.view.btnExit1:OnClickSimulate()
		end, self.view.btnExit1.gameObject)

		local objectReference = self.view.btnExit1.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[info.btn2Type])
	else
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.TEMPORARY_EXIT], function()
			self.view.btnExit1:OnClickSimulate()
		end, self.view.btnExit1.gameObject)

		local objectReference = self.view.btnExit1.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.TEMPORARY_EXIT])
	end

	if info.btn3Type then
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[info.btn3Type], function()
			self.view.btnExit2:OnClickSimulate()
		end, self.view.btnExit2.gameObject)

		local objectReference = self.view.btnExit2.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[info.btn3Type])
	else
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.END_AND_EXIT], function()
			self.view.btnExit2:OnClickSimulate()
		end, self.view.btnExit2.gameObject)

		local objectReference = self.view.btnExit2.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.END_AND_EXIT])
	end

	if info.btn4Type then
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[info.btn4Type], function()
			self.view.btnReturn2:OnClickSimulate()
		end, self.view.btnReturn2.gameObject)

		local objectReference = self.view.btnReturn2.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[info.btn4Type])
	else
		self:bindHotKeyPerform(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.READJUST], function()
			self.view.btnReturn2:OnClickSimulate()
		end, self.view.btnReturn2.gameObject)

		local objectReference = self.view.btnReturn2.transform:GetComponent("ObjectReference")

		objectReference:GetRefValue("keyHotKeyContent"):SetHotKeyPaths(FunMenuExitCtrl.ButtonTypeToPath[Const.ExitButtonType.READJUST])
	end
end

function FunMenuExitCtrl:refreshFuncItem()
	local funcData = self.model:getFuncListData()

	self.view.listItemUList:SetList(funcData)
end

function FunMenuExitCtrl:onRenderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("imgIcon")
	local textName = objectReference:GetRefValue("textName")

	icon.url = data.cfg.icon

	ClientTextUtils.setText(textName, pg.getLocalizationText(data.cfg.name))

	function button.luaClick()
		if data.cfg["function"] then
			self:closePanel()
			self[data.cfg["function"]](self, data)
		end
	end
end

function FunMenuExitCtrl:config()
	pg.global.ui:open(UIConst.UI_ID_SETTING)
end

function FunMenuExitCtrl:mail()
	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		initTab = pg.game.chat.tabType.Mail
	}, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function FunMenuExitCtrl:help()
	pg.global.ui:open(UIConst.UI_ID_HELP)
end

function FunMenuExitCtrl:escape()
	ClientUtils.escape()
end

function FunMenuExitCtrl:announcement()
	pg.global.ui.announcement.model:getAnnouncementData(true)
end

function FunMenuExitCtrl:service()
	pg.global.ui.hudV2:openServicePanel()
end

function FunMenuExitCtrl:markShare()
	if not CommonSwitch.MARK_SHARE then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_EDIT)
end

function FunMenuExitCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function FunMenuExitCtrl:loadNpcDuelInfo()
	if self.view.battleRoomInfoUContainer:CheckURLLoaded() then
		self.view.battleRoomInfoUContainer:SetActive(true)

		local content = self.view.battleRoomInfoUContainer.content

		if not IsNil(content) then
			self:refreshNpcDuelInfo(content)
		end
	else
		self.view.battleRoomInfoUContainer:LoadDefaultUrlManually(function(content)
			if IsNil(content) then
				return
			end

			self:refreshNpcDuelInfo(content)
		end)
	end
end

function FunMenuExitCtrl:refreshNpcDuelInfo(content)
	local objectReference = content:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local skillBuffUComponent = objectReference:GetRefValue("skillBuffUComponent")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")

		if data.buffInfo then
			skillBuffUComponent.gameObject:SetActiveEx(true)

			local objectReference = skillBuffUComponent.gameObject:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local buffInfo = data.buffInfo

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("NPCDUEL_BATTLE_FIELD_EFFECT"))
			ClientTextUtils.setText(textUSDFText, buffInfo.buffName)

			iconUImage.url = buffInfo.buffIcon

			function skillBuffUComponent.luaRenderTooltip(button, toolTip)
				self:RenderNpcDuelBuffPopup(toolTip)
			end
		elseif data.winConditon then
			skillBuffUComponent.gameObject:SetActiveEx(false)
			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("NPCDUEL_BATTLE_WIN_CONDITION"))
			ClientTextUtils.setText(textUSDFText, data.winConditon)
		end
	end

	local time = pg.space:npcDuelLeftTime()

	ClientTextUtils.setText(textUSDFText, LuaUIUtils.getCountDownFormateText(time, false))
	self:killTimer(self.npcDuelInfoTimer)

	self.npcDuelInfoTimer = self:startTimer(function()
		if pg.space and pg.space.npcDuelLeftTime then
			local time = pg.space:npcDuelLeftTime()

			ClientTextUtils.setText(textUSDFText, LuaUIUtils.getCountDownFormateText(time, false))
		else
			self:killTimer(self.npcDuelInfoTimer)

			self.npcDuelInfoTimer = nil
		end
	end, 1, true)

	local buffInfo = pg.me:getCurBuffInfo()
	local data = {}

	if next(buffInfo) then
		data[#data + 1] = {
			buffInfo = buffInfo
		}
	end

	local winConditon = pg.me:getNpcDuelWinCondDesc()

	if not string.isNilOrEmpty(winConditon) then
		data[#data + 1] = {
			winConditon = winConditon
		}
	end

	listUList:SetList(data)
end

function FunMenuExitCtrl:RenderNpcDuelBuffPopup(toolTip)
	local objectReference = toolTip:GetComponent("ObjectReference")
	local rootCmp = objectReference:GetRefValue("rootCmp")
	local buffNameUText = objectReference:GetRefValue("buffNameUText")
	local buffDetailUText = objectReference:GetRefValue("buffDetailUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local buffInfo = pg.me:getCurBuffInfo()

	if next(buffInfo) then
		rootCmp:TryChangePage("InfoState", "Icon")
		ClientTextUtils.setText(buffNameUText, buffInfo.buffName)
		ClientTextUtils.setText(buffDetailUText, buffInfo.buffDesc)

		iconUImage.url = buffInfo.buffIcon
	end
end

return FunMenuExitCtrl
