-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\NpcDuelInCombatUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Messagename = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NpcDuelInCombatUIComponent = Class.LightClass("NpcDuelInCombatUIComponent", HudBaseComponent)

NpcDuelInCombatUIComponent.messages = {
	[Messagename.NPC_DUEL_PET_DEATH] = {
		"refeshPetState"
	},
	[Messagename.NPC_DUEL_TASKPROGRESS_UPDATE] = {
		"refreshTask"
	}
}

function NpcDuelInCombatUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.leftCuratorObjectReference = objectReference:GetRefValue("leftCuratorObjectReference")
	self.rightPlayerObjectReference = objectReference:GetRefValue("rightPlayerObjectReference")
	self.titleUWidget = objectReference:GetRefValue("titleUWidget")
	self.listUList = objectReference:GetRefValue("listUList")
	self.hudTargetObjectReference = objectReference:GetRefValue("hudTargetObjectReference")

	self.titleUWidget.gameObject:SetActiveEx(false)
	self.listUList.gameObject:SetActiveEx(false)
end

function NpcDuelInCombatUIComponent:initView()
	do
		local objectReference = self.leftCuratorObjectReference:GetComponent("ObjectReference")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local listUList = objectReference:GetRefValue("listUList")

		ClientTextUtils.setText(textUSDFText, pg.me:getCurNpcDuelBotName())

		local camp = 1

		function listUList.luaRenderItem(button, index, data)
			local isDie = ToBool(data.isDie) or ToBool(data.isEmpty)

			button:TryChangePage("Camp", camp)
			button:TryChangePage("Stage", isDie and 1 or 0)
		end

		self.leftListUList = listUList
	end

	do
		local objectReference = self.rightPlayerObjectReference:GetComponent("ObjectReference")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local listUList = objectReference:GetRefValue("listUList")
		local camp = 0

		ClientTextUtils.setText(textUSDFText, pg.me.playerName)

		function listUList.luaRenderItem(button, index, data)
			local isDie = ToBool(data.isDie) or ToBool(data.isEmpty)

			button:TryChangePage("Camp", camp)
			button:TryChangePage("Stage", isDie and 1 or 0)
		end

		self.rightListUList = listUList
	end

	self:refeshPetState()
	self:refreshCondi()
	self:refreshTask()
end

function NpcDuelInCombatUIComponent:refeshPetState()
	local playPetDieState, botPetDieState = pg.me:npcDuelGetPlayerAndBotPetDieState()

	self.rightListUList:SetList(playPetDieState)
	self.leftListUList:SetList(botPetDieState)
end

function NpcDuelInCombatUIComponent:refreshCondi()
	local objectReference = self.hudTargetObjectReference
	local tabObjectReference = objectReference:GetRefValue("tabObjectReference")
	local detailsObjectReference = objectReference:GetRefValue("detailsObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")

	self.questListUList = detailsObjectReference:GetRefValue("questListUList")

	local questTitleUComponent = detailsObjectReference:GetRefValue("questTitleUComponent")
	local questTitleObjectReference = questTitleUComponent:GetComponent("ObjectReference")

	self.countDownTimerUContainer = detailsObjectReference:GetRefValue("timeCountdownUContainer")
	self.questTitleUSDFText = questTitleObjectReference:GetRefValue("textTitleUSDFText")

	ClientTextUtils.setText(self.questTitleUSDFText, pg.getGameString("NPCDUEL_BATTLE_WIN_CONDITION"))
	questTitleUComponent:TryChangePage("TaskType", "white")

	local listUList = tabObjectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, idx, objcvData)
		local objectReference = button:GetComponent("ObjectReference")
		local ubutton = objectReference:GetRefValue("iconUButton")
		local line = objectReference:GetRefValue("lineUWidget")

		ubutton.isSelected = true

		line.gameObject:SetActiveEx(false)
		ubutton:TryChangePage("TaskType", "battleroom")
		ubutton:TryChangePage("TrackType", "quest")
	end

	function self.questListUList.luaRenderItem(button, idx, objcvData)
		self:setTargetObjectiveInfo(button, idx, objcvData)
	end

	rootUComponent:TryChangePage("challengeState", "show")
	rootUComponent:TryChangePage("TrackType", "target")
	listUList:SetList({
		{}
	})
	self:loadWinTimer()
end

function NpcDuelInCombatUIComponent:refreshTask()
	local data = {}
	local winConditon = pg.me:getNpcDuelWinCondDesc()

	if not string.isNilOrEmpty(winConditon) then
		data[#data + 1] = {
			str = winConditon
		}
	end

	self.questListUList:SetList(data)
end

function NpcDuelInCombatUIComponent:setTargetObjectiveInfo(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local contentTxt = objectReference:GetRefValue("contentTxt")

	button:TryChangePage("TaskType", "white")

	local progress = ""

	if pg.space and pg.space:isNpcDuel() and pg.space.npcDuelTargetBotPetCount > 0 then
		progress = string.format("(%d/%d)", pg.space.npcDuelDefeatedBotPetCount, pg.space.npcDuelTargetBotPetCount)
	end

	ClientTextUtils.setText(contentTxt, string.format("%s%s", data.str, progress))
end

function NpcDuelInCombatUIComponent:loadWinTimer()
	if self.countDownTimerUContainer:CheckURLLoaded() then
		self:startWinTimer(self.countDownTimerUContainer.content)
	else
		self.countDownTimerUContainer:LoadDefaultUrlManually(function(content)
			if not self.transform or IsNil(content) then
				return
			end

			self:startWinTimer(content)
		end)
	end
end

function NpcDuelInCombatUIComponent:startWinTimer(button)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local time = pg.space:npcDuelLeftTime()

	ClientTextUtils.setText(txtNameUSDFText, LuaUIUtils.getCountDownFormateText(time, false))
	self:killTimer(self.winTimer)

	self.winTimer = self:startTimer(function()
		if not pg.space then
			self:stopWinTimer()

			return
		end

		local time = pg.space:npcDuelLeftTime()

		ClientTextUtils.setText(txtNameUSDFText, LuaUIUtils.getCountDownFormateText(time, false))
	end, 1, true)
end

function NpcDuelInCombatUIComponent:stopWinTimer()
	self:killTimer(self.winTimer)

	self.winTimer = nil
end

function NpcDuelInCombatUIComponent:onClose()
	self:stopWinTimer()
	HudBaseComponent.onClose(self)
end

function NpcDuelInCombatUIComponent:onDestroy()
	self:stopWinTimer()
	HudBaseComponent.onDestroy(self)
end

return NpcDuelInCombatUIComponent
