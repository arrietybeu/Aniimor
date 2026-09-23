-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\Component\\BadgeCollectionComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeCollectionComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local ItemData = require("Data.item_data")
local BadgeBaseData = require("Data.badge_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BadgeCollectionConst = require("Common.Const.BadgeCollectionConst")
local UIComponent = require("Guis.Helper.UIComponent")
local SchoolData = require("Data.college_guide_page_data")
local SysConfigData = require("Data.sys_config_data")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local TaskData = require("Data.badge_task_data")
local SourceData = require("Data.item_source_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local LimitData = require("Data.limit_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local BadgeCollectionComponent = Class.LightClass("BadgeCollectionComponent2", UIComponent)
local audioSys = pg.game.audio

function BadgeCollectionComponent:enter(tabType)
	self.medalItemId = 1013

	local badgeCfg = SysConfigData.BADGE_COST

	if badgeCfg then
		self.medalItemId = badgeCfg[1] or 1013
	end

	local _, taskCfg = next(TaskData)

	self.totalLimitId = taskCfg.totalLimitId or 36
	self.mainTabType = tabType

	if self.refUContainer:CheckURLLoaded() then
		self:onUILoaded()
	else
		self.refUContainer:LoadDefaultUrlManually(function()
			self:onUILoaded()
		end)
	end
end

function BadgeCollectionComponent:customRuleTip()
	BadgeCollectionComponent._openHelpTip()
end

function BadgeCollectionComponent:exit()
	return
end

function BadgeCollectionComponent:setFirstTabRed(button, index, data)
	return
end

function BadgeCollectionComponent:getRedStyle()
	return RedDotConst.RedDotStyle.NONE
end

BadgeCollectionComponent.pipeline = {
	inCollection = 1,
	base = 0,
	canOpen = 2
}

function BadgeCollectionComponent:ctor(ctrl, refUContainer, id)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self.cfgId = id
	self.refContainersLoaded = false
end

function BadgeCollectionComponent:onUILoaded()
	self.refContainersLoaded = true

	self:findObjects()
	self:addListener()
	self:refreshPage()
	audioSys:playEvent("SFX_UI_Collect_Badge_Open")
end

function BadgeCollectionComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local root = self.transform:GetChild(0)
	local objectReference = root:GetComponent("ObjectReference")

	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.timeUSDFText = objectReference:GetRefValue("timeUSDFText")
	self.timeUCountDown = objectReference:GetRefValue("timeUCountDown")
	self.time2USDFText = objectReference:GetRefValue("time2USDFText")
	self.infoUButton = objectReference:GetRefValue("infoUButton")
	self.numUSDFText = objectReference:GetRefValue("numUSDFText")
	self.numUProgress = objectReference:GetRefValue("numUProgress")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnConvertUButton = objectReference:GetRefValue("btnConvertUButton")
	self.medalInfoUButton = objectReference:GetRefValue("medalInfoUButton")
	self.btnIconUButton = objectReference:GetRefValue("btnIconUButton")

	local btnOC = self.btnConvertUButton:GetComponent("ObjectReference")

	self.btnNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(self.time2USDFText, string.format("0%s", pg.getGameString("HOUR")))
end

function BadgeCollectionComponent:addListener()
	function self.btnConvertUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_SEASON_SHOP, {
			shopTags = {
				46
			}
		})
	end

	function self.listUList.luaRenderItem(button, index, data)
		self:renderOneCard(button, index, data)
	end

	self.medalInfoUButton.enabledTooltip = false
	self.medalInfoUButton.luaClick = BadgeCollectionComponent._openHelpTip

	function self.infoUButton.luaRenderTooltip(btn, tooltip)
		self:renderTooltip(tooltip)
	end

	self.btnIconUButton.enabledTooltip = false

	function self.btnIconUButton.luaClick()
		pg.global.ui.commonItemTip:open({
			id = self.medalItemId,
			targetRect = self.btnIconUButton
		})
	end
end

function BadgeCollectionComponent._openHelpTip()
	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
		helpId = 117
	})
end

function BadgeCollectionComponent:refreshPage()
	self:refreshTime()
	self:refreshMedalNum()

	local baseTitle = SchoolData[self.cfgId].name

	ClientTextUtils.setText(self.titleUSDFText, ClientTextUtils.getLocalizationText(baseTitle))
	ClientTextUtils.setText(self.timeUSDFText, pg.getGameString("COLLECT_BADGE_TIME") .. ": ")
	ClientTextUtils.setText(self.btnNameUText, pg.getGameString("COLLECT_BADGE_BUTTON_GOTO"))

	self.cardData, self.tipData = self:getCardData()

	self.listUList:SetList(self.cardData)
end

function BadgeCollectionComponent:refreshMedalNum()
	local hasCnt, totalCnt, remainCnt = self:getLimitInfo(self.totalLimitId)
	local totalCntStr

	if remainCnt > 0 then
		totalCntStr = string.format("%d(+%d)", totalCnt, remainCnt)
	else
		totalCntStr = totalCnt
	end

	ClientTextUtils.setText(self.numUSDFText, pg.getFormatText(pg.getGameString("COLLECT_BADGE_HAS_NUM"), hasCnt, totalCntStr))

	self.numUProgress.minValue = 0
	self.numUProgress.maxValue = totalCnt
	self.numUProgress.value = hasCnt
end

function BadgeCollectionComponent:onItemCountChanged()
	self:refreshMedalNum()
end

function BadgeCollectionComponent:refreshTime()
	LuaUIUtils.setCountDownTime(self.timeUCountDown, self:getLimitNextTime(self.totalLimitId), UIConst.TimeType.Short)
end

function BadgeCollectionComponent:refreshOpenRed()
	self.redPath = string.format(RedDotConst.RedDotPath.SCHOOL_GUIDE_BADGE_ENTER_BTN, self.cfgId)

	pg.global.setPreViewRedDot(self.redPath, self.btnGoUButton, function()
		local style = LuaUIUtils.SchoolGuide_getBadgeCollectionRedDotStyle()

		return style
	end)
end

function BadgeCollectionComponent:getCardData()
	local res = {}
	local tipRes = {}

	for _, v in pairs(TaskData) do
		if v.sort and self.checkCondition(v.showCondition) then
			table.insert(res, {
				name = v.name,
				icon = v.icon,
				picture = v.picture,
				desc = v.desc,
				source = SourceData[v.source],
				limitId = v.limitId,
				rewardData = LuaUIUtils.getRewardItemByDropId(v.reward),
				_sort = v.sort
			})

			if v.limitId then
				table.insert(tipRes, {
					name = v.name,
					icon = v.icon,
					limitId = v.limitId,
					_sort = v.sort
				})
			end
		end
	end

	table.sort(res, function(a, b)
		return a._sort < b._sort
	end)
	table.sort(tipRes, function(a, b)
		return a._sort < b._sort
	end)

	return res, tipRes
end

function BadgeCollectionComponent.checkCondition(conditionId)
	if conditionId == nil then
		return true
	end

	return ClientUtils.checkCondition(conditionId)
end

function BadgeCollectionComponent:renderOneCard(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textDescribeUSDFText = objectReference:GetRefValue("textDescribeUSDFText")
	local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	local rewardUList = objectReference:GetRefValue("rewardUList")
	local imageUImage = objectReference:GetRefValue("imageUImage")
	local btnOC = btnGoUButton:GetComponent("ObjectReference")
	local btnNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(textTitleUSDFText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(textDescribeUSDFText, pg.getLocalizationText(data.desc))
	ClientTextUtils.setText(btnNameUText, pg.getGameString("COLLECT_BADGE_TASK_GOTO"))

	iconUImage.url = data.icon
	imageUImage.url = data.picture

	function btnGoUButton.luaClick()
		if data.source then
			LuaUIUtils.clueSeek(data.source, nil, btnGoUButton)
		end
	end

	function rewardUList.luaRenderItem(btn, idx, d)
		LuaUIUtils.renderRewardItem(btn, d)
	end

	rewardUList:SetList(data.rewardData)
end

function BadgeCollectionComponent:renderTooltip(tooltip)
	local objectReference = tooltip:GetComponent("ObjectReference")
	local textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local textDescUSDFText = objectReference:GetRefValue("textDescUSDFText")

	ClientTextUtils.setText(textTtileUSDFText, pg.getGameString("COLLECT_BADGE_TIP_TITLE"))

	local _, totalCnt, remainCnt = self:getLimitInfo(self.totalLimitId)

	ClientTextUtils.setText(textDescUSDFText, string.format(pg.getGameString("COLLECT_BADGE_TIP_DESC"), totalCnt + (remainCnt or 0)))

	function listUList.luaRenderItem(btn, idx, data)
		self:renderOneTipLine(btn, idx, data)
	end

	listUList:SetList(self.tipData)
end

function BadgeCollectionComponent:renderOneTipLine(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textValueUSDFText = objectReference:GetRefValue("textValueUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local hasCnt, totalCnt = self:getLimitInfo(data.limitId)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(textValueUSDFText, string.format("%s/%s", hasCnt, totalCnt))

	iconUImage.url = data.icon
end

function BadgeCollectionComponent:setImage(img, url)
	if not img then
		return
	end

	if string.startsWith(url, "http") then
		img:SetTextureByUrl(url)
	else
		img.url = url
	end
end

function BadgeCollectionComponent:getLimitInfo(limitId)
	local limitMap = pg.me.useLimitMap

	return limitMap:getUsedCount(limitId), limitMap:getTotalCount(limitId), limitMap:getLastRemainCount(limitId)
end

function BadgeCollectionComponent:getLimitNextTime(limitId)
	local limitCfg = LimitData[limitId]

	if not limitCfg then
		return 0
	end

	local refreshOffset = Utils.getSecondsAreaDayStart()
	local nowWithOffset = Time.secondCache - refreshOffset
	local nextRefreshTs

	if limitCfg.type == Const.LIMIT_DAY then
		nextRefreshTs = TimeUtils.getAreaNextDayBegin(nowWithOffset)
	elseif limitCfg.type == Const.LIMIT_WEEK then
		nextRefreshTs = TimeUtils.getAreaNextWeekBegin(nowWithOffset)
	elseif limitCfg.type == Const.LIMIT_MONTH then
		nextRefreshTs = TimeUtils.getAreaNextMonthBegin(nowWithOffset)
	else
		return 0
	end

	nextRefreshTs = nextRefreshTs + refreshOffset

	return math.max(0, nextRefreshTs)
end

function BadgeCollectionComponent:checkContentLoaded()
	return self.refContainersLoaded
end

function BadgeCollectionComponent:_getRewardData(displayRewardInfo, displayRewardType, hasGet, canGet, firstReward, extraFunc)
	local ret = {}

	if not displayRewardInfo then
		return ret
	end

	local itemRate = {}
	local itemCountTable = {}
	local sortTable = {}

	for index, itemInfo in ipairs(displayRewardInfo) do
		if itemCountTable[itemInfo[1]] then
			itemCountTable[itemInfo[1]] = itemCountTable[itemInfo[1]] + itemInfo[2]
		else
			itemCountTable[itemInfo[1]] = itemInfo[2]
			sortTable[itemInfo[1]] = index
		end

		itemRate[itemInfo[1]] = itemInfo[3]
	end

	if pg.me then
		local t, replaceIdMap = ItemUtils.getReplacedItemCountTable(pg.me, itemCountTable)

		if replaceIdMap then
			for oriId, newId in pairs(replaceIdMap) do
				if sortTable[oriId] then
					sortTable[newId] = sortTable[oriId]
				end
			end
		end

		for itemId, itemNum in pairs(t) do
			local item = {}

			item.num = itemNum
			item.id = itemId
			item.type = 0
			item.tIndex = 0
			item.displayRewardType = displayRewardType
			item.rate = itemRate[itemId] or 1
			item.hasGet = hasGet
			item.canGet = canGet
			item.firstReward = firstReward
			item.extraFunc = extraFunc
			ret[#ret + 1] = item
		end

		table.sort(ret, function(a, b)
			if not a.id then
				return false
			end

			if not b.id then
				return true
			end

			return sortTable[a.id] < sortTable[b.id]
		end)
	else
		for _, itemInfo in ipairs(displayRewardInfo) do
			local item = {}

			item.num = itemInfo[2]
			item.id = itemInfo[1]
			item.type = 0
			item.tIndex = 0
			item.displayRewardType = displayRewardType
			item.rate = itemRate[itemInfo[1]] or 1
			item.hasGet = hasGet
			item.canGet = canGet
			item.firstReward = firstReward
			item.extraFunc = extraFunc
			ret[#ret + 1] = item
		end
	end

	return ret
end

function BadgeCollectionComponent:onBadgeOpenChanged()
	return
end

return BadgeCollectionComponent
