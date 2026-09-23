-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\Component\\MockGuideComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local RogueUtils = require("Utils.RogueUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local RedDotConst = require("Const.RedDotConst")
local MockGuideComponent = Class.LightClass("MockGuideComponent", UIComponent)
local logger = require("Core.Log.LoggerManager").getLogger("MockGuideComponent")

function MockGuideComponent:ctor(ctrl, refUContainer)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self._uiLoaded = false
end

function MockGuideComponent:_loadUI()
	if not self._isEntered or self._isParentHidden or self._isLoading then
		return
	end

	if self.refUContainer:CheckURLLoaded() then
		self:onUILoaded()

		return
	end

	self._isLoading = true

	self.refUContainer:LoadDefaultUrlManually(function()
		self._isLoading = false

		if self._isEntered and not self._isParentHidden then
			self:onUILoaded()
		end
	end)
end

function MockGuideComponent:enter(tabType)
	self.mainTabType = tabType
	self._isEntered = true

	self:_loadUI()
end

function MockGuideComponent:onUILoaded()
	local root = self.transform:GetChild(0)
	local objectReference = root:GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.taskListUList = objectReference:GetRefValue("taskListUList")
	self.tipUSDFText = objectReference:GetRefValue("tipUSDFText")
	self.timeDescUSDFText = objectReference:GetRefValue("timeDescUSDFText")
	self.timerUSDFText = objectReference:GetRefValue("timerUSDFText")

	self:addListener()

	self._uiLoaded = true

	self:refreshUI()
end

function MockGuideComponent:exit()
	self._isEntered = false

	self:_stopCountDownTimer()
end

function MockGuideComponent:onShow()
	self._isParentHidden = false

	if not self._isEntered then
		return
	end

	if self.timerUSDFText then
		self:_startCountDownTimer()
	else
		self:_loadUI()
	end
end

function MockGuideComponent:onHide()
	self._isParentHidden = true

	self:_stopCountDownTimer()
end

function MockGuideComponent:onDestroy()
	self._isEntered = false
	self._uiLoaded = false
	self.mainTabType = nil

	UIComponent.onDestroy(self)
end

function MockGuideComponent:addListener()
	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local rootComponent = objectReference:GetRefValue("rootComponent")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		rootComponent:TryChangePage("Selected", data.selected and 1 or 0)

		local levelInfo = data.levels and data.levels[1] and data.levels[1].info

		ClientTextUtils.setText(txtNameUSDFText, levelInfo and pg.getLocalizationText(levelInfo.levelName) or "")
		rootComponent:TryChangePage("State", levelInfo.elementName)
	end

	function self.listTabUList.luaClick(button, data)
		self:setSelectedTab(data)
	end

	local function rendersamllTip(_, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("TOWER_UNLOCK_TIP_PRELEVEL"))
	end

	function self.taskListUList.luaRenderItem(button, index, levelData)
		local objectReference = button:GetComponent("ObjectReference")
		local rootComponent = objectReference:GetRefValue("rootComponent")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtName1USDFText = objectReference:GetRefValue("txtName1USDFText")
		local listUList = objectReference:GetRefValue("listUList")
		local btnGoObjectReference = objectReference:GetRefValue("btnGoObjectReference")
		local lockUSDFText = objectReference:GetRefValue("lockUSDFText")
		local infoUButton = objectReference:GetRefValue("infoUButton")

		infoUButton.luaRenderTooltip = rendersamllTip

		ClientTextUtils.setText(lockUSDFText, pg.getGameString("SCHOOL_GUIDE_CRAFT_LOCK"))

		local levelInfo = levelData.info
		local hasGot = RogueUtils.isSeasonWeeklyRewardReceived(levelData.levelId)
		local canGet = RogueUtils.canGetSeasonWeeklyReward(levelData.levelId)
		local isUnlock = RogueUtils.isSeasonWeeklyRewardUnlocked(levelData.levelId) or hasGot

		rootComponent:TryChangePage("LevelNum", index)
		rootComponent:TryChangePage("TaskState", RogueUtils.checkLevelUnlock(levelData.levelId) and 0 or 1)
		ClientTextUtils.setText(txtNameUSDFText, levelInfo and string.format(pg.getGameString("Rogue_Week_Difficult"), levelInfo.difficultyLabel + 1) or "")
		ClientTextUtils.setText(txtName1USDFText, levelInfo and pg.getLocalizationText(levelInfo.difficulty) or "")
		LuaUIUtils.setRewardListByDropIds(listUList, levelData.dropData, 6, function(rewardBtn, index, rewardData)
			local widget = rewardBtn:GetComponent("UWidget")

			if canGet then
				widget:TryChangePage("State", "Recive")
			elseif hasGot then
				widget:TryChangePage("State", "Get")
			else
				widget:TryChangePage("State", "Normal")
			end

			rewardBtn:ClearRedDot()

			if rewardData.tIndex == 0 then
				pg.global.setRedDot(string.format(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD_ITEM, levelData.info.elementType, levelData.levelId), rewardBtn, canGet, RedDotConst.RedDotStyle.REWARD)
			end
		end)

		function listUList.luaClick(button, data, navItem)
			LuaUIUtils.onRewardItemClick(button, data, nil, navItem)
		end

		self:addListener_gotoBtn(btnGoObjectReference, levelData.levelId)
	end
end

function MockGuideComponent:setRewardItemRedDot(button, rewardData, levelData)
	return
end

function MockGuideComponent:addListener_gotoBtn(objectReference, levelId)
	local uIBtn1stConfirmUButton = objectReference:GetRefValue("uIBtn1stConfirmUButton")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("BUTTON_NAME_1"))

	function uIBtn1stConfirmUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_LEVEL_DETAIL, {
			levelId = levelId
		})
	end
end

function MockGuideComponent:refreshUI()
	if not self._uiLoaded then
		return
	end

	ClientTextUtils.setText(self.timeDescUSDFText, pg.getGameString("SCHOOL_GUIDE_TIME_TIP"))
	ClientTextUtils.setText(self.tipUSDFText, pg.getGameString("Rogue_Week_Reward_Un_Pass_Tips"))
	self:_startCountDownTimer()

	self.levelData = self.model:GetMockGuideData()

	self:setSelectedTab(self.levelData[1])
	self.listTabUList:SetList(self.levelData)
end

function MockGuideComponent:setSelectedTab(data)
	if not data then
		logger:error("没有关卡数据")

		return
	end

	self.taskListUList:SetList(data.levels)

	for _, tabData in ipairs(self.levelData) do
		if tabData == data then
			tabData.selected = true
		else
			tabData.selected = false
		end
	end

	self.listTabUList:RefreshList()
end

function MockGuideComponent:_startCountDownTimer()
	self:_stopCountDownTimer()

	local endTime = RogueUtils.getWeeklyTime() + 1

	local function refresh()
		local remainTime = math.max(0, endTime - Time.secondCache)

		ClientTextUtils.setText(self.timerUSDFText, LuaUIUtils.getCountDownString(remainTime, UIConst.TimeType.Short, true))

		if remainTime <= 0 then
			self:_stopCountDownTimer()
		end
	end

	refresh()

	if endTime > Time.secondCache then
		self._countDownTimer = self:startTimer(refresh, 1, true)
	end
end

function MockGuideComponent:_stopCountDownTimer()
	if not self._countDownTimer then
		return
	end

	self:killTimer(self._countDownTimer)

	self._countDownTimer = nil
end

return MockGuideComponent
