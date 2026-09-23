-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReward\\PvpRewardCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpRewardCtrl = Class.LightClass("PvpRewardCtrl", UICtrl)
local DungeonConst = require("Common.Const.DungeonConst")
local Time = require("Core.Common.Time")
local PVPRewardScene = require("GameApp.Scenes.UIScenes.PVPRewardScene")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpRewardCtrl.messages = {
	[MessageName.PVP_DETAIL_COVENANT_AGAIN] = {
		"onDetailCovenantAgain",
		true
	}
}

function PvpRewardCtrl:onCreate()
	UICtrl.onCreate(self)
end

function PvpRewardCtrl:addListener()
	function self.view.btnRePlay.luaClick()
		self:onBtnRePlay()
	end

	function self.view.btnLeave.luaClick()
		self:onBtnLeave()
	end

	function self.view.playerList.luaRenderItem(button, _, data)
		self:onRenderPlayerItem(button, data)
	end
end

function PvpRewardCtrl:onOpen()
	UICtrl.onOpen(self)

	local data = self.model:getBattleResult()
	local victory = data.result == DungeonConst.PLAYER_RESULT.SUCCESS

	self:hide()
	self:startTimer(function()
		self:show()
		self:refreshBattleInfo(data)
	end, 0.8, false)

	self.tickTimer = self:startTimer(function()
		self:viewTick()
	end, 0.1, true)

	self.model:clearPVPData()
end

function PvpRewardCtrl:onUISceneLoaded()
	local data = self.model:getBattleResult()
	local victory = data.result == DungeonConst.PLAYER_RESULT.SUCCESS

	self.uiScene:showResult(victory)
end

function PvpRewardCtrl:refreshBattleInfo(data)
	local victory = data.result == DungeonConst.PLAYER_RESULT.SUCCESS

	self.view.rootCmp:TryChangePage("Result", victory and 0 or 1)
	self.view.panelAnimation:Play(victory and "VX_Pb_PVP_Result_Win" or "VX_Pb_PVP_Result_Lose")
	pg.game.audio:triggerEvent(victory and "SFX_UI_PVP_Win" or "SFX_UI_PVP_Lose")
	ClientTextUtils.setText(self.view.name, data.name)
	ClientTextUtils.setText(self.view.scoreNum, data.oldScore)
	ClientTextUtils.setText(self.view.scoreNumFailure, data.oldScore)

	if data.addScore == 0 then
		ClientTextUtils.setText(self.view.scoreAddNum, "")
		ClientTextUtils.setText(self.view.scoreAddNumFailure, "")
	else
		ClientTextUtils.setText(self.view.scoreAddNum, string.format("+%d", data.addScore))
		ClientTextUtils.setText(self.view.scoreAddNumFailure, string.format("-%d", data.addScore))
	end

	if pg.me:isMatchStatusInCovenantResult() then
		self.view.rootCmp:TryChangePage("Type", 1)
		self:refreshCovenantInfo()
	else
		self.view.rootCmp:TryChangePage("Type", 0)
	end
end

function PvpRewardCtrl:refreshCovenantInfo(uid, state)
	local pList = self.model:getPlayerStateList(uid, state)

	self.view.playerList:SetList(pList)
end

function PvpRewardCtrl:onShow()
	return
end

function PvpRewardCtrl:viewTick()
	local remandSecond = self.model:getEndTime() - Time.secondCache

	if remandSecond < 0 then
		return
	end

	if self.view.timeLeave == nil then
		return
	end

	ClientTextUtils.setText(self.view.timeLeave, string.format("(%ss)", math.round(remandSecond)))
end

function PvpRewardCtrl:onRenderPlayerItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local icon = oc:GetRefValue("icon")
	local txtName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(txtName, data.name)
	button:TryChangePage("PlayerState", data.state)
end

function PvpRewardCtrl:onBtnRePlay()
	if pg.me:isMatchStatusInCovenantAgain() then
		return
	end

	if pg.me:isMatchStatusInCovenantResult() then
		pg.me:requestPvpBattleAgain(function(res)
			if not res then
				return
			end

			self:refreshCovenantInfo(pg.me.uid, true)
		end)
	else
		pg.me:serverMsg("RPC_CS_QuitSpace")
		pg.game.pvp:bindReMatchFunc()
		self:dismiss()
	end
end

function PvpRewardCtrl:onDetailCovenantAgain(params)
	self:refreshCovenantInfo(params.uid, params.isAgain)
end

function PvpRewardCtrl:onBtnLeave()
	pg.me:serverMsg("RPC_CS_QuitSpace")
	self:dismiss()
end

function PvpRewardCtrl:onHide()
	return
end

function PvpRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.tickTimer then
		self:killTimer(self.tickTimer)
	end

	self.tickTimer = nil
end

return PvpRewardCtrl
