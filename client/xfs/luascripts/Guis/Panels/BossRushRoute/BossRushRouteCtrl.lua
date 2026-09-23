-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushRoute\\BossRushRouteCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushRouteCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BossRushBuffData = require("Data.bossrush_buff_data")
local BossRushRouteCtrl = Class.LightClass("BossRushRouteCtrl", UICtrl)
local PuppetData = require("Data.puppet_data")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")

BossRushRouteCtrl.messages = {}

function BossRushRouteCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI()
end

function BossRushRouteCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.boss1UButton.luaClick()
		return
	end

	function self.view.boss2UButton.luaClick()
		return
	end

	function self.view.boss3UButton.luaClick()
		return
	end

	function self.view.point1UButton.luaClick()
		return
	end

	function self.view.point2UButton.luaClick()
		return
	end

	function self.view.btnBuff1UButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			tab = 0,
			isShow = true
		})
	end

	function self.view.btnBuff2UButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			tab = 1,
			isShow = true
		})
	end

	self:bindHotKeyPerform("Raw/GamepadButtonWest", function()
		self.view.btnBuff1UButton:OnClickSimulate()
	end)
end

function BossRushRouteCtrl:initUI()
	function self.view.buff1UList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.buff2UList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	LuaUIUtils.setKeyList(self.view.keyListUList, {
		{
			path = "Raw/GamepadButtonWest",
			label = pg.getGameString("CONSOLE_BAR_BUFF")
		},
		{
			path = "Raw/GamepadButtonEast",
			label = pg.getGameString("CONSOLE_BAR_LEAVE")
		}
	})
	self.view.buff1UList:SetList(BossRushUtils.getSelectBatBuffs())

	local isBattleLevel = table.contains(Const.BossRushBattlePlace, BossRushUtils.getCurBossRushPlace())

	self.view.btnBuff1UButton:SetActive(isBattleLevel)
	self.view.buff2UList:SetList(BossRushUtils.getUnlockMingameBuffs())

	local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

	self:renderBossInfo(self.view.boss1UButton, cycleData.bossMid, {
		self.view.line3UButton
	})
	self:renderBossInfo(self.view.boss2UButton, cycleData.bossRight, {
		self.view.line2UButton,
		self.view.line21UButton
	})
	self:renderBossInfo(self.view.boss3UButton, cycleData.bossLeft, {
		self.view.line1UButton,
		self.view.line11UButton
	})
end

function BossRushRouteCtrl:renderBossInfo(button, levelId, lines)
	local bossData = BossRushLevelData[levelId]

	if not bossData or not bossData.bossId then
		return
	end

	local bossInfo = PuppetData[bossData.bossId]

	if not bossInfo then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")

	petIconUImage.url = LuaUIUtils.getPetIcon(bossInfo.iconName, LuaUIUtils.PET_ICON, 0)

	local star = pg.space.bossBestGrade[bossData.bossId] or 0

	ClientTextUtils.setText(numUBaseText, star)

	local state = pg.space.levelState[levelId] or 0

	button:TryChangePage("State", state)

	for _, line in ipairs(lines) do
		line:TryChangePage("State", state)
	end
end

function BossRushRouteCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BossRushRouteCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BossRushRouteCtrl:onShow()
	return
end

function BossRushRouteCtrl:onHide()
	return
end

return BossRushRouteCtrl
