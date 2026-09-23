-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\HomeBookUnlockItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeBookUnlockItem = Class.LightClass("HomeBookUnlockItem", BaseQueueItem)
local DEFAULT_DURATION = 5
local TITLE_GAME_STRING = "HOME_BOOK_UNLOCK"
local DEFAULT_TITLE = "家园图鉴解锁"

function HomeBookUnlockItem:onInit()
	self.scrollList = self.uWidget

	self:setMaxLimit(2, true)

	function self.scrollList.luaRenderItem(item, data)
		self:renderItem(item, data)
	end
end

function HomeBookUnlockItem:pushData(data)
	if type(data.itemId) ~= "number" then
		return
	end

	if not HomeBookDataUtils.getEntity(data.itemId) then
		return
	end

	self:enqueue(data)
end

function HomeBookUnlockItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function HomeBookUnlockItem:tryPopupItem()
	while not self:isQueueEmpty() and not self:isReachTheLimit() do
		local data = self:dequeue()

		data.endTime = Time.realSecondCache + (data.duration or DEFAULT_DURATION)

		self:addRunItem(data)
		self.scrollList:PushRenderItem(data)
	end
end

function HomeBookUnlockItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local currentTime = Time.realSecondCache

	for i = #self.runList, 1, -1 do
		local data = self.runList[i]

		if currentTime >= data.endTime then
			self:recycleToast(data)
		end
	end
end

function HomeBookUnlockItem:onClearRunningList()
	for i = #self.runList, 1, -1 do
		self:recycleToast(self.runList[i])
	end
end

function HomeBookUnlockItem:recycleToast(data)
	if data.removing then
		return
	end

	data.removing = true

	self.scrollList:DestroyItem(data)
	self:removeItem(data)
end

function HomeBookUnlockItem:renderItem(item, data)
	local displayData = HomeBookDataUtils.getEntryDisplayData(data.itemId)

	if not displayData then
		self:recycleToast(data)

		return
	end

	local objectReference = item:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

	iconUImage.url = displayData.icon or ""

	local title = ClientTextUtils.getGameString(TITLE_GAME_STRING)

	if title == TITLE_GAME_STRING then
		title = DEFAULT_TITLE
	end

	ClientTextUtils.setText(txtTitleUSDFText, title)
	ClientTextUtils.setText(txtNameUSDFText, displayData.name or "")
	ClientTextUtils.setText(txtAddUSDFText, string.format("+%d", displayData.addGrade or 0))
	item:TryChangePage("Quality", displayData.quality or 1)

	item.luaClick = nil
end

function HomeBookUnlockItem:onDestroy()
	BaseQueueItem.onDestroy(self)

	self.scrollList.luaRenderItem = nil
end

return HomeBookUnlockItem
