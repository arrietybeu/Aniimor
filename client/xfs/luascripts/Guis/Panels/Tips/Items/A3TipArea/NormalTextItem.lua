-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A3TipArea\\NormalTextItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysNoticeData = require("Data.sys_notice_data")
local SysConfigData = require("Data.sys_config_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("TipsCtrl")
local NormalTextItem = Class.LightClass("NormalTextItem", BaseQueueItem)

NormalTextItem.TIP_MODE = {
	TEXT_TIP = 1,
	ICON_TIP = 0,
	RAINBOW_PET_TIP = 2
}

function NormalTextItem:onInit()
	self:setMaxLimit(2)

	self.scrollList = self.uWidget

	function self.scrollList.luaRenderItem(item, data)
		self:RenderItem(item, data)
	end

	self.idCDPool = {}

	if UNITY_EDITOR then
		self.idCDCallMap = {}
	end
end

if UNITY_EDITOR then
	function NormalTextItem:debugCdCall(noticeId, cancel)
		if cancel then
			self.idCDCallMap[noticeId] = 0

			return
		end

		local count = self.idCDCallMap[noticeId]

		count = count or 0
		count = count + 1

		if count > 10 then
			local cData = SysNoticeData[noticeId]

			logger:warn("tips 在cd时间内调用超过10次, id-count:", noticeId, count)
		end

		self.idCDCallMap[noticeId] = count
	end
end

function NormalTextItem:pushData(data)
	local noticeId = data.noticeId or 0
	local tick = self.idCDPool[noticeId]
	local inCd = tick and tick > Time.realSecondCache

	if UNITY_EDITOR then
		self:debugCdCall(noticeId, not inCd)
	end

	if inCd then
		return
	end

	local cData = SysNoticeData[noticeId]

	data.cd = 1

	if cData and cData.cd then
		data.cd = cData.cd or 1
		self.idCDPool[noticeId] = Time.realSecondCache + data.cd
	end

	data.noticeId = data.noticeId or 0
	data.desc = data.desc or "content is empty!"
	data.duration = data.duration or 2
	data.delay = data.delay or 0
	data.endDelay = Time.realSecondCache + data.delay
	data.isItemObtain = data.isItemObtain == true

	self:enqueue(data)
end

function NormalTextItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function NormalTextItem:tryPopupItem()
	if self:isQueueEmpty() then
		return
	end

	if self:isReachTheLimit() then
		local data = self:firstRunItem()

		data.endTime = Time.realSecondCache

		return
	end

	local idx = -1

	for i, v in ipairs(self.dataQueue) do
		if Time.realSecondCache > v.endDelay then
			idx = i

			break
		end
	end

	if idx < 0 then
		return false
	end

	local data = table.remove(self.dataQueue, idx)

	self:innerParseItem(data)
end

function NormalTextItem:innerParseItem(data)
	if data.tIndex == 2 then
		data.tipStyle = self.TIP_MODE.RAINBOW_PET_TIP
	elseif data.bigIcon or data.normalIcon or data.iconText then
		data.tipStyle = self.TIP_MODE.ICON_TIP

		if data.isItemObtain then
			data.tIndex = 3
		else
			data.tIndex = 0
		end
	else
		data.tIndex = 1
		data.tipStyle = self.TIP_MODE.TEXT_TIP
	end

	data.startTime = Time.realSecondCache

	local duration = data.duration or 3
	local selectedLanguage = pg.languageType or 0

	if data.tipStyle ~= self.TIP_MODE.RAINBOW_PET_TIP then
		if selectedLanguage == ClientConst.LANGUAGE_TYPE_MAP.en then
			duration = duration * (SysConfigData.TOAST_EN_TIME or 1.6)
		elseif selectedLanguage == ClientConst.LANGUAGE_TYPE_MAP.ja_JP or selectedLanguage == ClientConst.LANGUAGE_TYPE_MAP.ko_KR then
			duration = duration * (SysConfigData.TOAST_JK_TIME or 1.4)
		end
	end

	data.endTime = Time.realSecondCache + duration

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)

	if GmToolUtils.openMask then
		data.endTime = data.endTime + 5
	end
end

function NormalTextItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function NormalTextItem:RenderItem(item, data)
	if data.tipStyle == self.TIP_MODE.RAINBOW_PET_TIP then
		self:refreshRainbowPetView(item, data)
	elseif data.tipStyle == self.TIP_MODE.ICON_TIP then
		self:refreshIconView(item, data)
	else
		self:refreshTextView(item, data)
	end

	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function NormalTextItem:refreshRainbowPetView(item, data)
	local objRef = item:GetComponent("ObjectReference")

	LuaUIUtils.setRainbowPetAppearText(objRef:GetRefValue("textUSDFText"), data.templateId)
	LuaUIUtils.renderRainbowPetIcon(objRef:GetRefValue("playerHeadRectTransform"), data.templateId)
end

function NormalTextItem:refreshTextView(item, data)
	local objRef = item:GetComponent("ObjectReference")
	local iDesc = objRef:GetRefValue("text")
	local descTxt

	if data.outLineDesc then
		descTxt = string.format("%s %s", data.desc, data.outLineDesc)
	else
		descTxt = data.desc
	end

	ClientTextUtils.setText(iDesc, descTxt)
end

function NormalTextItem:refreshIconView(item, data)
	local objRef = item:GetComponent("ObjectReference")
	local normalTxt = objRef:GetRefValue("textUText")
	local outLineTxt = objRef:GetRefValue("outLineTxtUText")
	local itemIcon = objRef:GetRefValue("itemIcon")
	local entIcon = objRef:GetRefValue("iconPet")
	local skillIcon = objRef:GetRefValue("iconSkill")
	local extractionUWidget = objRef:GetRefValue("extractionUWidget")

	ClientTextUtils.setText(normalTxt, pg.getLocalizationText(data.desc))

	if data.outLineDesc then
		LuaUIUtils.setUIViewVisible(outLineTxt, true)
		ClientTextUtils.setText(outLineTxt, pg.getLocalizationText(data.outLineDesc))
	else
		LuaUIUtils.setUIViewVisible(outLineTxt, false)
		ClientTextUtils.setText(outLineTxt, "")
	end

	if data.bigIcon then
		item:TryChangePage("stage", data.iconStyle == 99 and 3 or 2)

		entIcon.url = data.bigIcon
		skillIcon.url = data.bigIcon
	elseif data.normalIcon then
		item:TryChangePage("stage", 1)

		itemIcon.url = data.normalIcon
	elseif data.iconStyle == 4 then
		item:TryChangePage("stage", 4)
	else
		item:TryChangePage("stage", data.state or 0)
	end

	if data.extractionTimePage ~= nil and extractionUWidget then
		extractionUWidget:TryChangePage("ExtractionTime", data.extractionTimePage)
	end

	if data.label then
		item:TryChangePage("isRare", 1)
	else
		item:TryChangePage("isRare", 0)
	end

	pg.game.audio:playEvent("SFX_UI_CommonRewardToast")
end

function NormalTextItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function NormalTextItem:hideById(noticeId)
	local curTime = Time.realSecondCache

	for _, v in ipairs(self.runList) do
		if v.noticeId == noticeId then
			v.endTime = curTime
		end
	end

	local dataNum = #self.dataQueue

	for i = dataNum, 1, -1 do
		local item = self.dataQueue[i]

		if item.noticeId == noticeId then
			table.remove(self.dataQueue, i)
		end
	end
end

function NormalTextItem:onSceneUnload()
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		if data.deleteOnSceneUnload == 1 then
			self:recycleToast(data)
		end
	end
end

function NormalTextItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		self:recycleToast(self.runList[i], force)
	end

	self:clearDataQueue()
end

function NormalTextItem:GMPushData(data)
	data.state = data.param

	if data.state then
		data.iconText = true
	end
end

function NormalTextItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function NormalTextItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

return NormalTextItem
