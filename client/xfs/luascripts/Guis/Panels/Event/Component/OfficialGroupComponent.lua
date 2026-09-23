-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\OfficialGroupComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("OfficialGroupComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local GameEventData = require("Data.game_event_data")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local OfficialGroupComponent = Class.LightClass("OfficialGroupComponent", EventContainerComponent)

function OfficialGroupComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.appUList = self.objectReference:GetRefValue("appUList")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
end

function OfficialGroupComponent:addListener()
	return
end

function OfficialGroupComponent:refreshPage()
	self:setEventTitle(self.eventTitleUContainer)

	self.appUList.ScrollType = CS.XGUI.EScrollType.Horizontal

	local officialGroupInfo = self.model:getOfficialGroupInfo()
	local areaType = LuaUIUtils.isOverseas() and 1 or 0

	self.rootUComponent:TryChangePage("APP", areaType)

	function self.appUList.luaRenderItem(button, index, data)
		self:renderAppButton(button, index, data)
	end

	self.appUList:SetList(officialGroupInfo)

	if officialGroupInfo and #officialGroupInfo > 8 then
		self.appUList:SetScrollDisabled(false)
	else
		self.appUList:SetScrollDisabled(true)
	end
end

function OfficialGroupComponent:renderAppButton(btn, index, data)
	if not btn then
		return
	end

	if not data then
		return
	end

	function btn.luaNavFocused()
		if not data.hasGet then
			btn:TryChangePage("Hover", 1)
		end
	end

	function btn.luaNavUnfocused()
		btn:TryChangePage("Hover", 0)
	end

	local objectReference = btn:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local btnRewardUButton = objectReference:GetRefValue("btnRewardUButton")

	if btnRewardUButton then
		local btnRewardReference = btnRewardUButton:GetComponent("ObjectReference")
		local rewardIconUImage = btnRewardReference:GetRefValue("iconUImage")
		local textNumUBaseText = btnRewardReference:GetRefValue("textNumUBaseText")
		local rewards = LuaUIUtils.getRewardItemByDropId(data.dropId)
		local data = rewards and rewards[1]

		ClientTextUtils.setText(textNumUBaseText, data.num)

		rewardIconUImage.url = LuaUIUtils.getIconByItemId(data.id)

		function btnRewardUButton.luaClick()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.num,
				targetRect = btnRewardUButton
			})
		end
	end

	iconUImage:SetUrlWithCallback(data.iconName, function()
		local spriteSize = iconUImage:GetSpriteSize()

		iconUImage:SetSize(spriteSize)
	end, nil, true)
	ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))
	btn:TryChangePage("State", data.hasGet and 1 or 0)

	function btn.luaClick()
		if not data.hasGet then
			pg.me:reqOfficialGroupReward(self.eventId, pg.me.serverArea, data.id, function()
				self:refreshPage()
			end)
		end

		if data.showType == self.model.OFFICIAL_GROUP_SHOW_TYPE.QR_CODE then
			pg.global.ui:open(UIConst.UI_ID_QR_CODE, {
				id = data.id,
				codeUrl = data.qrCodePath
			})
		elseif data.showType == self.model.OFFICIAL_GROUP_SHOW_TYPE.URL then
			local targetUrl = data.url

			if targetUrl then
				pg.global.sdkManager:openUrl("OfficialGroup", "OFFICIAL_GROUP_SHOW_TYPE.URL", targetUrl)
			end
		end
	end
end

function OfficialGroupComponent:onEnterPlayEvent()
	pg.game.audio:playEvent("SFX_UI_OfficialCommunity_MoveIn")
end

function OfficialGroupComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return OfficialGroupComponent
