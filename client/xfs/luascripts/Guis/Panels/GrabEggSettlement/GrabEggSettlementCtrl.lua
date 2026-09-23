-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggSettlement\\GrabEggSettlementCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSettlementCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggSettlementCtrl = Class.LightClass("GrabEggSettlementCtrl", UICtrl)
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local SceneData = require("Data.scene_data")
local SysNoticeData = require("Data.sys_notice_data")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local ItemData = require("Data.item_data")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local lume = require("Core.Common.lume")
local PuppetData = require("Data.puppet_data")

GrabEggSettlementCtrl.messages = {
	[MessageName.GRAB_EGG_REWARD_BOX_CHANGED] = {
		"onRewardBoxChanged",
		true
	},
	[MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED] = {
		"refreshNoviceProtectionView",
		true
	}
}

local TASK_ITEM_TEMPLATE_INDEX = 0
local DEATH_INFO_TEMPLATE_INDEX = 1
local DEATH_INFO_TEXT_KEY = "GRAB_EGG_SETTLEMENT_DEATH_INFO"
local ACCIDENTAL_DEATH_TEXT_KEY = "GRAB_EGG_SETTLEMENT_ACCIDENTAL_DEATH"
local LUCKY_CHEST_TIPS_DESC_TEXT_KEY = "GRABEGG_LUCKYCHEST_TIPS_DESC"
local NOVICE_PROTECTION_RESULT_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_RESULT"
local REWARD_STATE_GET = 0
local REWARD_STATE_FULL = 1
local REWARD_STATE_MAX = 2
local BGM_HitAndRun_Fail = "BGM_HitAndRun_Fail"
local BGM_HitAndRun_Victory = "BGM_HitAndRun_Victory"

function GrabEggSettlementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.result = info.result
	self.resInfo = info.resInfo
	self.fallTimer = nil
	self.chestTimer = nil

	self.view.protectInfoUWidget:SetActive(false)
	self:registerComponent()
end

function GrabEggSettlementCtrl:addListener()
	return
end

function GrabEggSettlementCtrl:onRewardBoxChanged()
	if self.resInfo then
		self:refreshChest()
	end
end

function GrabEggSettlementCtrl:refreshNoviceProtectionView()
	if not self.resInfo then
		return
	end

	local hardLv = self.resInfo.levelInfo and tonumber(self.resInfo.levelInfo.hardLv) or pg.space and pg.space.hardLv
	local player = pg.me
	local info = hardLv and player and player.grabEgg_getNoviceProtectionInfo and player:grabEgg_getNoviceProtectionInfo(self.resInfo.sceneId, hardLv)
	local visible = self.resInfo.result == Const.ROB_EGG_RESULT.Failure and info ~= nil and info.isCurrentRoundProtected

	self.view.protectInfoUWidget:SetActive(visible)

	if not visible then
		return
	end

	ClientTextUtils.setText(self.view.protectInfoUSDFText, pg.getFormatText(pg.getGameString(NOVICE_PROTECTION_RESULT_TEXT_KEY), info.remainingTimes, info.totalTimes))
end

function GrabEggSettlementCtrl:onDestroy()
	self:killChestTimer()
	UICtrl.onDestroy(self)

	self.resInfo = nil
end

function GrabEggSettlementCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.openAnim:Play()
	self:refreshUI()
end

function GrabEggSettlementCtrl:onShow()
	return
end

function GrabEggSettlementCtrl:onHide()
	self:killChestTimer()
end

function GrabEggSettlementCtrl:registerComponent()
	function self.view.listTaskUList.luaRenderItem(button, index, data)
		self:onRenderTaskItem(button, index, data)
	end

	function self.view.btnOrganizeUButton.luaClick()
		self:onClickOrganize()
	end

	function self.view.btnShareUButton.luaClick()
		self:onClickShare()
	end

	local btnLuckyInfoUButton = self.view.btnLuckyInfoUButton

	btnLuckyInfoUButton.enabledTooltip = true

	function btnLuckyInfoUButton.luaRenderTooltip(_, tooltip)
		local objectReference = tooltip:GetComponent("ObjectReference")
		local txtTitle = objectReference:GetRefValue("txtTitle")
		local txtDesc = objectReference:GetRefValue("txtDesc")

		tooltip:TryChangePage("headTitle", 1)
		tooltip:TryChangePage("Btn", 0)
		ClientTextUtils.setText(txtTitle, pg.getGameString("GRABEGG_LUCKYCHEST_TITLE"))
		ClientTextUtils.setText(txtDesc, pg.getGameString(LUCKY_CHEST_TIPS_DESC_TEXT_KEY))
	end

	function btnLuckyInfoUButton.luaClick()
		btnLuckyInfoUButton:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)
	end
end

function GrabEggSettlementCtrl:refreshUI()
	local difficultData = DungeonDifficultLevelData[self.resInfo.sceneId]

	difficultData = difficultData and difficultData[pg.space.hardLv]

	local resultUIAsset = difficultData and difficultData.resultUIAsset

	if self.view.bg and resultUIAsset and resultUIAsset[1] then
		self.view.bg.url = resultUIAsset[1]
	end

	if self.resInfo.result == Const.ROB_EGG_RESULT.Success then
		self.view.rootUComponent:TryChangePage("State", 0)
		pg.game.audio:playEvent(BGM_HitAndRun_Victory)
		ClientTextUtils.setText(self.view.txtSuccessRoleUBaseText, pg.getGameString("GRAB_EGG_SETTLE_STATE1"))
	else
		self.view.rootUComponent:TryChangePage("State", 2)
		pg.game.audio:playEvent(BGM_HitAndRun_Fail)
		ClientTextUtils.setText(self.view.txtSuccessRoleUBaseText, pg.getGameString("GRAB_EGG_SETTLE_STATE3"))
	end

	ClientTextUtils.setText(self.view.txtTitleProfitUBaseText, pg.getGameString("GRAB_EGG_PROFIT"))

	local hardLv = pg.space.hardLv

	self.view.rootUComponent:TryChangePage("Difficulty", hardLv - 1)

	if hardLv == Const.DungeonDifficultLevel.CHAOS then
		ClientTextUtils.setText(self.view.txtDifficultyUBaseText, pg.getGameString("GRAB_EGG_ChaosDifficulty_3"))
	else
		ClientTextUtils.setText(self.view.txtDifficultyUBaseText, pg.getGameString("DUNGEON_DIFFICUITY_" .. hardLv))
	end

	LuaUIUtils.setUIVisible(self.view.btnHarvestDetailsUButton, false)
	LuaUIUtils.setUIVisible(self.view.btnDefeatDetailsUButton, false)
	LuaUIUtils.setUIVisible(self.view.btnShareUButton, false)

	local sceneData = SceneData[self.resInfo.sceneId]

	ClientTextUtils.setText(self.view.txtMapNameUBaseText, pg.getLocalizationText(sceneData.sceneName))

	local startTime = pg.me.space.start_ts or 0
	local totalTime = self.resInfo.finish_time - startTime
	local killUserCount = self.resInfo.killUser and lume.count(self.resInfo.killUser) or 0
	local killNpcCount = self.resInfo.killNpc and lume.count(self.resInfo.killNpc) or 0

	ClientTextUtils.setText(self.view.txtTimeUBaseText, TimeUtils.timeToFormatString(totalTime))
	self.view.txtHarvestUBaseText:SetNumber(self.resInfo.profit)

	local needShowDouble = self.resInfo.coinFactor and self.resInfo.coinFactor > 0

	self.view.doublePointUWidget:SetActive(needShowDouble)

	if needShowDouble then
		local startNum = self.resInfo.profit
		local endNum = self.resInfo.profit + math.floor(self.resInfo.profit * self.resInfo.coinFactor)

		ClientTextUtils.setText(self.view.txtDoubleUBaseText, string.format(pg.getGameString("GRAB_EGG_SETTLE_DOUBLE"), "x" .. self.resInfo.coinFactor))
		ClientTextUtils.setText(self.view.txtPointAddUBaseText, string.format("+%s", endNum - startNum))

		local function getDigitCount(num)
			if num == 0 then
				return 1
			end

			return math.floor(math.log10(math.abs(num))) + 1
		end

		local diffCount = getDigitCount(endNum) - getDigitCount(startNum)
		local startString = diffCount > 0 and string.rep("0", diffCount) .. startNum or startNum

		self.view.txtHarvestUBaseText:SetText(startString)
		self.view.valueUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
			startString = diffCount > 0 and string.rep("1", diffCount) .. startNum or startNum
			self.view.txtHarvestUBaseText.StartNumber = tonumber(startString)
			self.view.txtHarvestUBaseText.EndNumber = endNum

			if endNum ~= 0 then
				self.view.txtHarvestUBaseText:StartDancing()
			end

			pg.game.audio:playEvent("SFX_UI_QiangDan_DoubleSettlementCoinLoop")
			self:startTimer(function()
				self.view.valueUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
			end, 2)
			self:startTimer(function()
				pg.game.audio:stopEvent("SFX_UI_QiangDan_DoubleSettlementCoinLoop")
			end, 1.7)
		end)
		self:startTimer(function()
			pg.game.audio:playEvent("SFX_UI_QiangDan_DoubleSettlementTag")
		end, 0.5)
	else
		ClientTextUtils.setText(self.view.txtPointAddUBaseText, "")
	end

	ClientTextUtils.setText(self.view.txtDefeatUBaseText, killUserCount + killNpcCount)

	local taskList = {}
	local transferNum = #self.resInfo.transEggs
	local carryBigEgg = false

	for k, v in ipairs(self.resInfo.transEggs) do
		local templateId = v.templateId
		local itemData = ItemData[templateId]

		if itemData and itemData.eggtype == Const.ROB_EGG_TYPE.SUPER_BIG then
			carryBigEgg = true
			transferNum = transferNum - 1

			break
		end
	end

	if transferNum > 0 then
		taskList[#taskList + 1] = {
			name = "GRAB_EGG_TRANSFER_EGG",
			tIndex = TASK_ITEM_TEMPLATE_INDEX,
			num = transferNum
		}
	end

	if carryBigEgg then
		taskList[#taskList + 1] = {
			name = "GRAB_EGG_GET_BIG_EGG",
			tIndex = TASK_ITEM_TEMPLATE_INDEX
		}
	end

	local killedReason = self.resInfo.killed_reason
	local killedName = self.resInfo.killed_name

	if killedReason == Const.ROBEGG_DEATH_REASON.KILLED_BY_PUPPET then
		local puppetInfo = PuppetData[tonumber(killedName)]

		killedName = puppetInfo and pg.getLocalizationText(puppetInfo.name) or ""
	end

	local killedByEntity = killedReason == Const.ROBEGG_DEATH_REASON.KILLED_BY_PLAYER or killedReason == Const.ROBEGG_DEATH_REASON.KILLED_BY_PUPPET

	if self.resInfo.result == Const.ROB_EGG_RESULT.Failure then
		if killedByEntity and not string.isNilOrEmpty(killedName) then
			taskList[#taskList + 1] = {
				tIndex = DEATH_INFO_TEMPLATE_INDEX,
				textKey = DEATH_INFO_TEXT_KEY,
				killedName = killedName
			}
		elseif killedReason == Const.ROBEGG_DEATH_REASON.ACCIDENGTAL_DEATH then
			taskList[#taskList + 1] = {
				tIndex = DEATH_INFO_TEMPLATE_INDEX,
				textKey = ACCIDENTAL_DEATH_TEXT_KEY
			}
		end
	end

	self.view.listTaskUList:SetList(taskList)
	self:refreshChest()
	self:refreshNoviceProtectionView()
end

function GrabEggSettlementCtrl:refreshChest()
	self:killChestTimer()

	local isSuccess = self.resInfo.result == Const.ROB_EGG_RESULT.Success

	self.view.treasureChestUWidget:SetActive(isSuccess)

	if not isSuccess then
		return
	end

	local chestInfo = self.model:getSettlementChestInfo(self.resInfo.levelRewardBoxId, self.resInfo.levelInfo)
	local rewardState

	if chestInfo.isGranted then
		rewardState = REWARD_STATE_GET
	elseif chestInfo.isDailyFull then
		rewardState = REWARD_STATE_MAX
	else
		rewardState = REWARD_STATE_FULL
	end

	self.view.rootUComponent:TryChangePage("Reward", rewardState)

	local countText = pg.getFormatText("<b><style=Hint_BgL>{0}</style>/{1}</b>", chestInfo.acquired, chestInfo.limit)

	ClientTextUtils.setText(self.view.textGetBoxNumUSDFText, string.format(pg.getGameString("GRABEGG_LUCKYCHEST_OBTAI"), countText))

	if not chestInfo.isGranted then
		local fullText

		if chestInfo.isDailyFull then
			fullText = pg.getLocalizationText(SysNoticeData[NoticeDef.ROB_EGG_CHEST_MAX_DAILY_TIP].text)
		else
			fullText = pg.getGameString("BOX_STORAGE_FULL_TEXT")
		end

		ClientTextUtils.setText(self.view.textFullGetUSDFText, fullText)

		return
	end

	self.view.rewardBoxIconUImage.url = chestInfo.icon

	self.view.rootUComponent:TryChangePage("Color", chestInfo.quality - 1)
	self:startChestCountdown(chestInfo.openTimestamp)
end

function GrabEggSettlementCtrl:startChestCountdown(openTimestamp)
	local function refreshCountdown()
		local remainSec = math.max(0, (openTimestamp or 0) - Time.secondCache)

		ClientTextUtils.setText(self.view.textTimeSubUSDFText, LuaUIUtils.getCountDownString(remainSec, UIConst.TimeType.Short, true))

		if remainSec <= 0 then
			self:killChestTimer()
		end

		return remainSec
	end

	if refreshCountdown() > 0 then
		self.chestTimer = self:startTimer(refreshCountdown, 1, true)
	end
end

function GrabEggSettlementCtrl:killChestTimer()
	if self.chestTimer then
		self:killTimer(self.chestTimer)

		self.chestTimer = nil
	end
end

function GrabEggSettlementCtrl:onRenderTaskItem(button, index, data)
	if data.tIndex == DEATH_INFO_TEMPLATE_INDEX then
		local objectReference = button:GetComponent("ObjectReference")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local formatText = pg.getGameString(data.textKey)
		local desc = data.killedName and pg.getFormatText(formatText, data.killedName) or formatText

		ClientTextUtils.setText(textUSDFText, desc)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtDescUBaseText = objectReference:GetRefValue("txtDescUBaseText")
	local formatText = pg.getGameString(data.name)
	local desc = data.num and string.format(formatText, data.num) or formatText

	ClientTextUtils.setText(txtDescUBaseText, desc)
end

function GrabEggSettlementCtrl:onClickShare()
	return
end

function GrabEggSettlementCtrl:onClickOrganize()
	pg.me:finishedSettlement()
end

return GrabEggSettlementCtrl
