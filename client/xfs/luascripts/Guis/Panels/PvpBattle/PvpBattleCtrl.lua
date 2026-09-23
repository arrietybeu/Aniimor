-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpBattle\\PvpBattleCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PvpBattleCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpBattleCtrl = Class.LightClass("PvpBattleCtrl", UICtrl)
local PrepareComponent = require("Guis.Panels.PvpBattle.Component.PvpPrepareComponent")
local DungeonConst = require("Common.Const.DungeonConst")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local HotkeyConst = require("Const.HotkeyConst")
local PlayableConst = require("Common.Const.PlayableConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local STATUS = DungeonConst.STATUS

PvpBattleCtrl.messages = {
	[MessageName.DUNGEON_STATE_CHANGE] = {
		"onStateChange",
		true
	},
	[MessageName.PVP_RESULT] = {
		"onPVPResult",
		true
	},
	[MessageName.PVP_PET_STATE_CHANGE] = {
		"onPetStateChange",
		true
	},
	[MessageName.PVP_SWITCH_PET_REMAIN_COUNT] = {
		"onSwitchPetChange",
		true
	},
	[MessageName.PVP_SWITCH_MASTER_PET] = {
		"onSwitchMasterPet",
		true
	}
}

function PvpBattleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.prepareCmp = PrepareComponent.new(self, self.view.countDownOf)
end

function PvpBattleCtrl:addListener()
	function self.view.petList1.luaRenderItem(button, _, data)
		self:onPetItemRefresh(button, data)
	end

	function self.view.petList2.luaRenderItem(button, _, data)
		self:onPetItemRefresh(button, data)
	end

	function self.view.switchCountList.luaRenderItem(button, _, data)
		self:onSwitchDotRefresh(button, data)
	end
end

function PvpBattleCtrl:onOpen(info)
	self:playStartVideo()
end

function PvpBattleCtrl:onShow()
	return
end

function PvpBattleCtrl:refreshView()
	local infos = self.model:getTeamInfos()

	self.petItemMap = {}

	if infos.selfInfo.petList then
		ClientTextUtils.setText(self.view.name1, infos.selfInfo.name)
		self.view.petList1:SetList(infos.selfInfo.petList)
	end

	if infos.enemyInfo.petList then
		ClientTextUtils.setText(self.view.name2, infos.enemyInfo.name)
		self.view.petList2:SetList(infos.enemyInfo.petList)
	end

	self:onSwitchPetChange()

	if self.model:isInGaming() then
		self:startBattle()
	end

	if self.model:isGameRewarded() then
		self:onPVPResult()
	end
end

function PvpBattleCtrl:playStartVideo()
	self.view.component:TryChangePage("Page", 1)

	self.hasEnterUI = false
	self.view.videoBG.resID = pg.game.pvp:isFairMode() and "$VX_PVP_RedLOGOExchange.mp4" or "$VX_PVP_BlueLOGOExchange.mp4"

	function self.view.videoBG.luaLoopEnd()
		self:enterBattleUI()
	end

	self:startTimer(function()
		self:enterBattleUI()
	end, 5)
end

function PvpBattleCtrl:enterBattleUI()
	if self.hasEnterUI then
		return
	end

	self.hasEnterUI = true

	pg.global.ui:open(UIConst.UI_ID_HUD_V2)
	self:enterCountDown()
	self:refreshView()
end

function PvpBattleCtrl:enterCountDown()
	self.view.component:TryChangePage("Page", 0)
	self.prepareCmp:startCountDown()
end

function PvpBattleCtrl:onPetItemRefresh(item, data)
	local orc = item:GetComponent("ObjectReference")
	local cmp = item:GetComponent("UButton")
	local icon = orc:GetRefValue("icon")

	cmp:TryChangePage("state", 0)

	self.petItemMap[data.id] = cmp
end

function PvpBattleCtrl:onSwitchDotRefresh(item, data)
	item:TryChangePage("button", data.hasDot and 5 or 0)
	item:SetSelected(data.hasDot)
end

function PvpBattleCtrl:onHide()
	return
end

function PvpBattleCtrl:onStateChange(state)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("pvpDungeon status change, state=%d", state)
	end

	if state == STATUS.PLAYER_READY then
		pg.game.input:enableSkillInput(false, HotkeyConst.INPUT_BLOCK_FLAG.GameMode)
	elseif state == STATUS.COUNT_DONW then
		self:refreshView()
	elseif state == STATUS.PLAYING then
		self:startBattle()
	elseif self.status == STATUS.REWARD then
		self:killTimer(self.vTick)
	elseif self.status == STATUS.CLOSE then
		-- block empty
	end
end

function PvpBattleCtrl:startBattle()
	pg.game.audio:triggerEvent("SFX_UI_PVP_StartFight")

	self.vTick = self:startTimer(function()
		self:viewTick()
	end, 0.02, true)

	pg.game.input:enableSkillInput(true, HotkeyConst.INPUT_BLOCK_FLAG.GameMode)
end

function PvpBattleCtrl:viewTick()
	if not self.model:isInGaming() then
		return
	end

	local remandSecond = self.model:getEndTime() - Time.secondCache

	if remandSecond <= 0 then
		return
	end

	ClientTextUtils.setText(self.view.btRemandTime, TimeUtils.timeToFormatString(remandSecond))
end

function PvpBattleCtrl:onPVPResult()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("pvpDungeon status change, result")
	end

	local curPet = self.model:getCurPet()

	if curPet then
		curPet.eModel:SetActive(false)
	end

	curPet = self.model:getCurPet(true)

	if curPet then
		curPet.eModel:SetActive(false)
	end

	pg.global.ui:open(UIConst.UI_ID_PVP_REWARD, nil, nil, nil, {
		ignoreDisableMainCamera = true
	})
	pg.global.ui:close(UIConst.UI_ID_PVP_BATTLE)
	pg.global.ui:close(UIConst.UI_ID_HUD_V2)
end

function PvpBattleCtrl:onPetStateChange(info)
	if self.petItemMap == nil or self.petItemMap[info.petId] == nil then
		return
	end

	self.petItemMap[info.petId]:TryChangePage("state", info.pInfo.isDead and 1 or 0)
end

function PvpBattleCtrl:onSwitchPetChange()
	local cRes = self.model:getSwitchPetInfo()

	self.view.switchCountList:SetList(cRes)
end

function PvpBattleCtrl:onSwitchMasterPet()
	self:enterCountDown()
end

function PvpBattleCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.vTick then
		self:killTimer(self.vTick)
	end

	self.vTick = nil
end

return PvpBattleCtrl
