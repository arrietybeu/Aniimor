-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareViewSimple\\MarkShareViewSimpleCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local json = require("json")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysNoticeData = require("Data.sys_notice_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local MarkShareViewSimpleCtrl = Class.LightClass("MarkShareViewSimpleCtrl", UICtrl)

MarkShareViewSimpleCtrl.messages = {
	[MessageName.ON_REQUEST_SELF_MARK_INFO] = {
		"onRequestSelfMarkInfo",
		true
	},
	[MessageName.ON_DELETE_INFO_STAMP_SUCCESS] = {
		"onDeleteInfoStampSuccess",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function MarkShareViewSimpleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.infoStampId = info.infoStampId
	self.parsedInfo = nil

	self:Init()
end

function MarkShareViewSimpleCtrl:onOpen(info)
	return
end

function MarkShareViewSimpleCtrl:onShow()
	return
end

function MarkShareViewSimpleCtrl:onHide()
	return
end

function MarkShareViewSimpleCtrl:destroy()
	return
end

function MarkShareViewSimpleCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnClose1UButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose2UButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose3UButton.luaClick()
		self:closePanel()
	end
end

function MarkShareViewSimpleCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MarkShareViewSimpleCtrl:Init()
	ClientTextUtils.setText(self.view.concatText, "")
	ClientTextUtils.setText(self.view.selfLikeNum, "")

	local infoStampData = pg.game.markShare.aroundMarkInfoStampGroup[self.infoStampId]

	if infoStampData then
		self.parsedInfo = pg.game.markShare:parseInfoStamp(false, self.infoStampId)

		self:renderMainPlayerPanel(self.parsedInfo)
	else
		pg.me:batchFindMediaMarker({
			self.infoStampId
		})
		self.view.templateUWidget:SetActive(false)
	end

	ClientTextUtils.setText(self.view.txtIDUSDFText, string.format("%s", pg.me.uid))
end

function MarkShareViewSimpleCtrl:renderMainPlayerPanel(parsedInfo)
	self.view.root:TryChangePage("View", 0)
	ClientTextUtils.setText(self.view.txtTitleUSDFText, parsedInfo.playerName)
	ClientTextUtils.setText(self.view.selfLikeNum, parsedInfo.likes)
	self:renderPhotoTemplate(parsedInfo)

	function self.view.btnPositionUButton.luaClick()
		if pg.game.map:checkValidScene(pg.game.map:convertSceneId(pg.me.space.sceneId)) == true then
			pg.game.map:openMapAndLocateMark(pg.game.markShare:getSelfMarkSceneId(self.infoStampId), Const.MAP_MARK_SHARE, self.infoStampId, nil, 1)
			self:closePanel()
		else
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[2126].text))
		end
	end

	function self.view.btnDeleteUButton.luaClick()
		self:removeMark()
	end

	ClientTextUtils.setText(self.view.concatText, parsedInfo.txtClips)
end

function MarkShareViewSimpleCtrl:renderPhotoTemplate(parsedInfo)
	local photoTemplate = parsedInfo.photoTemplate
	local havePhoto = photoTemplate ~= nil

	self.view.templateUWidget:SetActive(havePhoto)

	if havePhoto then
		local objectReference = self.view.templateUWidget:GetComponent("ObjectReference")
		local btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")
		local btnUseUButton = objectReference:GetRefValue("btnUseUButton")
		local photoUImage = objectReference:GetRefValue("photoUImage")

		function btnDetailUButton.luaClick()
			pg.global.ui.albumPhoto:open({
				photoInfo = {
					onlyShow = true,
					sprite = photoUImage.sprite,
					timeStamp = photoTemplate.time
				}
			})
		end

		function btnUseUButton.luaClick()
			local photo = pg.global.ui.photo

			photo:open({
				photoMode = photo.ModeType.NORMAL_MODE,
				preset = photoTemplate.preset
			})
		end

		pg.global.ui.photo.model:queryPresetImg(photoTemplate.imgKey, function(sprite, id)
			photoUImage.sprite = sprite
		end)
	end
end

function MarkShareViewSimpleCtrl:closePanel()
	UIUtils.PlayAnimation(self.view.panelAnimation, "VX_MarkShare_View_Out", function()
		self:destroy()
		pg.global.ui:close(UIConst.UI_ID_MARK_SHARE_VIEW_SIMPLE)
	end)
end

function MarkShareViewSimpleCtrl:onRequestSelfMarkInfo(info)
	if not info.result then
		return
	end

	local marker = info.markers and info.markers[self.infoStampId]

	if not marker then
		return
	end

	local infoStampData = {
		content = type(marker.content) == "string" and json.decode(marker.content) or marker.content,
		likes = marker.likes
	}

	self.parsedInfo = pg.game.markShare:parseInfoStamp(false, self.infoStampId, infoStampData)

	self:renderMainPlayerPanel(self.parsedInfo)
end

function MarkShareViewSimpleCtrl:removeMark()
	if self.parsedInfo and self.parsedInfo.photoTemplate and self.parsedInfo.photoTemplate.imgKey then
		ClientUtils.deletePicture(self.parsedInfo.photoTemplate.imgKey)
	end

	pg.me:removeMediaMarker(self.infoStampId)
end

function MarkShareViewSimpleCtrl:onDeleteInfoStampSuccess(info)
	self:closePanel()
end

return MarkShareViewSimpleCtrl
