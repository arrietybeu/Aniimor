-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarBuffPanel\\HomeCarBuffPanelCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarBuffPanelCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCarBuffPanelCtrl = Class.LightClass("HomeCarBuffPanelCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local NoticeDef = require("Common.NoticeDef")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeAddonData = require("Data.home_addon_data")
local SysNoticeData = require("Data.sys_notice_data")

HomeCarBuffPanelCtrl.messages = {}

function HomeCarBuffPanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.ownerUid = info and info.ownerUid

	self:refreshBuffList()
end

function HomeCarBuffPanelCtrl:addListener()
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOMECAMP_CAMP_BUFF"))
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("HOMECAMP_GAIN_ACTIVATED"))

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnInfoUButton.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtContent = objectReference:GetRefValue("txtNameUSDFText")
		local toolTipText = self:getTooltipText()

		ClientTextUtils.setText(txtContent, toolTipText)
		self:removeTooltipTimer()

		self.timerId = TimerManager.addRepeatTimer(1, function()
			if UIUtils.IsNull(cmp) then
				self:removeTooltipTimer()

				return
			end

			local toolTipText = self:getTooltipText()

			ClientTextUtils.setText(txtContent, toolTipText)
		end)
	end

	function self.view.btnInfoUButton.luaTooltipPopup(btn, isOpen)
		if isOpen == false then
			self:removeTooltipTimer()
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtValueUSDFText = objectReference:GetRefValue("txtValueUSDFText")
		local elementUButton = objectReference:GetRefValue("elementUButton")

		if data.element then
			LuaUIUtils.setElementButtonNew(elementUButton, data.element)
		end

		button:TryChangePage("Unlock", data.canGet and 0 or 1)
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(txtValueUSDFText, "+" .. data.num .. "%")
	end
end

function HomeCarBuffPanelCtrl:removeTooltipTimer()
	if self.timerId then
		TimerManager.removeTimer(self.timerId)

		self.timerId = nil
	end
end

function HomeCarBuffPanelCtrl:getMergedBuffList(addOnIdList)
	local activeIdSet = {}

	for _, id in ipairs(addOnIdList) do
		activeIdSet[id] = true
	end

	local buffInfoByElement = {}

	for index, info in ipairs(HomeAddonData) do
		local buffInfo = buffInfoByElement[info.element]

		if not buffInfo then
			buffInfo = {
				canGet = false,
				num = 0,
				index = index,
				name = info.name,
				element = info.element
			}
			buffInfoByElement[info.element] = buffInfo
		end

		if activeIdSet[index] then
			buffInfo.num = buffInfo.num + info.num
			buffInfo.canGet = true
		end
	end

	local buffList = {}

	for _, buffInfo in pairs(buffInfoByElement) do
		table.insert(buffList, buffInfo)
	end

	table.sort(buffList, function(a, b)
		return a.index < b.index
	end)

	return buffList
end

function HomeCarBuffPanelCtrl:getTooltipText()
	local buffGetTime = HomelandConfigData.addOnValidSeconds or 10800
	local text = pg.getFormatText(pg.getGameString("HOMECAMP_CAMP_BUFF_INFO"), buffGetTime / 3600) .. "\n"
	local curTime = Time.getSecond()
	local endTime = pg.me.campAddOnEndTs
	local buffIdList = pg.me.campAddOnIds or {}
	local buffList = self:getMergedBuffList(buffIdList)

	if endTime == 0 or endTime < curTime or #buffIdList == 0 then
		-- block empty
	else
		local time = ClientTextUtils.getLocalizationCountDown(math.floor(endTime - curTime))

		text = text .. "\n" .. ClientTextUtils.concatByLanguage(pg.getGameString("HOMECAMP_GAIN_REMAINING_TIME"), time) .. "\n\n"
		text = text .. pg.getFormatText(pg.getGameString("HOMECAMP_CURRENT_GAIN_EFFECT"), #buffIdList, #HomeAddonData) .. "\n"

		for _, buffInfo in ipairs(buffList) do
			if buffInfo.canGet then
				text = text .. pg.getLocalizationText(buffInfo.name) .. " +" .. buffInfo.num .. "%\n"
			end
		end
	end

	return text
end

function HomeCarBuffPanelCtrl:getBuffList()
	local buffGetList

	if self.ownerUid then
		buffGetList = HomeLandUtils.getCampAddOnIdsByOwnerFromCreatedMap(pg.space, self.ownerUid) or {}
	else
		buffGetList = HomeLandUtils.getCampAddOnIds(pg.space) or {}
	end

	local buffList = self:getMergedBuffList(buffGetList)

	return buffList, #buffGetList
end

function HomeCarBuffPanelCtrl:refreshBuffList()
	local getNum = 0
	local buffList, getNum = self:getBuffList()
	local maxNum = #HomeAddonData

	self.view.listUList:SetList(buffList)
	ClientTextUtils.setText(self.view.txtNumUSDFText, getNum .. "/" .. maxNum)
	self:refreshStatusText()
end

function HomeCarBuffPanelCtrl:refreshStatusText()
	local txt
	local endTime = pg.me.campAddOnEndTs or 0
	local buffIdList = pg.me.campAddOnIds or {}

	if #buffIdList <= 0 or endTime <= Time.getSecond() then
		local noticeData = SysNoticeData[NoticeDef.HOMECAMP_BUFF_COND_DESC]

		txt = noticeData and pg.getLocalizationText(noticeData.text) or ""
	else
		local ownerUid = pg.me.campAddOnOwnerUid

		if not ownerUid or tostring(ownerUid) == tostring(pg.me.uid) then
			local noticeData = SysNoticeData[NoticeDef.HOMECAMP_BUFF_GAINED_SELF]

			txt = noticeData and pg.getLocalizationText(noticeData.text) or ""
		else
			local ownerName = pg.me:getCampAddOnOwnerDisplayName(ownerUid, pg.me.campAddOnOwnerName)
			local noticeData = SysNoticeData[NoticeDef.HOMECAMP_BUFF_GAINED_OTHER]

			txt = noticeData and pg.getLocalizationText(noticeData.text, ownerName) or ""
		end
	end

	ClientTextUtils.setText(self.view.txtStateUSDFText, txt)
end

function HomeCarBuffPanelCtrl:onBuffGained(params)
	self:refreshBuffList()
end

function HomeCarBuffPanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:removeTooltipTimer()
end

function HomeCarBuffPanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.ownerUid = info and info.ownerUid

	self:refreshBuffList()
end

function HomeCarBuffPanelCtrl:onShow()
	return
end

function HomeCarBuffPanelCtrl:onHide()
	return
end

return HomeCarBuffPanelCtrl
