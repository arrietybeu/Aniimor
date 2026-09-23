-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncTemplateUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncTemplateUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncTemplateUIComponent = Class.LightClass("PhotoFuncTemplateUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Utils = require("Common.Utils.Utils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local TrackId = 8469778076
local TemplateType = {
	Liked = 3,
	Hot = 2,
	Official = 1,
	Saved = 4
}
local TabConfig = {
	{
		label = "PHOTO_TEMPLATE_TYPE_OFFICIAL",
		type = TemplateType.Official
	},
	{
		label = "PHOTO_TEMPLATE_TYPE_HOT",
		type = TemplateType.Hot
	},
	{
		label = "PHOTO_TEMPLATE_TYPE_LIKED",
		type = TemplateType.Liked
	},
	{
		label = "PHOTO_TEMPLATE_TYPE_SAVED",
		type = TemplateType.Saved
	}
}
local OptionType = {
	Download = 4,
	CopyCode = 3,
	Details = 2,
	Track = 1,
	Delete = 5
}
local OptionConfig = {
	[OptionType.Track] = {
		func = "onClickTrack",
		icon = "$UI_Icon_MarkShare_Position.png",
		label = "PHOTO_TEMPLATE_TRACK",
		type = OptionType.Track
	},
	[OptionType.Details] = {
		func = "onClickDetail",
		icon = "$UI_Icon_FunMenuMini_Research.png",
		label = "PHOTO_TEMPLATE_DETAIL",
		type = OptionType.Details
	},
	[OptionType.CopyCode] = {
		func = "onClickCopyCode",
		icon = "$UI_Icon_FunMenuMini_Research.png",
		label = "PHOTO_COPY_CODE",
		type = OptionType.CopyCode
	},
	[OptionType.Download] = {
		func = "onClickDownload",
		icon = "$UI_Btn_Avatar_PinchFace_Download.png",
		label = "PHOTO_TEMPLATE_DOWNLOAD",
		type = OptionType.Download
	},
	[OptionType.Delete] = {
		func = "onClickDelete",
		icon = "$UI_Icon_MarkShare_Delete.png",
		label = "PHOTO_TEMPLATE_DELETE",
		type = OptionType.Delete
	}
}
local Type2Options = {
	[TemplateType.Official] = {
		[OptionType.Track] = true,
		[OptionType.Details] = true
	},
	[TemplateType.Hot] = {
		[OptionType.Track] = true,
		[OptionType.Details] = true,
		[OptionType.CopyCode] = true
	},
	[TemplateType.Liked] = {
		[OptionType.Track] = true,
		[OptionType.Details] = true,
		[OptionType.CopyCode] = true
	},
	[TemplateType.Saved] = {
		[OptionType.Track] = true,
		[OptionType.Details] = true,
		[OptionType.CopyCode] = true,
		[OptionType.Delete] = true
	}
}

function PhotoFuncTemplateUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listFirstUList = objectReference:GetRefValue("listFirstUList")
	self.listSecondUList = objectReference:GetRefValue("listSecondUList")
end

function PhotoFuncTemplateUIComponent:initView()
	self:initTemplate()
end

function PhotoFuncTemplateUIComponent:onDestroy()
	for k, v in ipairs(TabConfig) do
		v.selected = nil
	end

	UIComponent.onDestroy(self)
end

function PhotoFuncTemplateUIComponent:initTemplate()
	self.curType = nil

	function self.listFirstUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))

		function button.luaSelectChanged(isSelect)
			if not isSelect then
				return
			end

			self.curType = data.type

			local dataList

			if self.curType == TemplateType.Official then
				dataList = self.model:getOfficialTemplate(false)

				self:setTemplateList(dataList)
			elseif self.curType == TemplateType.Hot then
				dataList = self.model:getHotTemplate(false)

				self:setTemplateList(dataList)
			elseif self.curType == TemplateType.Liked then
				self.model:getLikedTemplate(function(list)
					if self.curType == TemplateType.Liked then
						self:setTemplateList(list)
					end
				end, false)
			elseif self.curType == TemplateType.Saved then
				self.model:getSavedTemplate(function(list)
					if self.curType == TemplateType.Saved then
						self:setTemplateList(list)
					end
				end, false)
			end
		end

		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listSecondUList)
	end

	function self.listSecondUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")

		button:TryChangePage("Lock", 0)

		button.interactable = true
		button.visualInteractable = true
		button.skipInListSwitch = false
		button.enabledTooltip = true

		local id = data.id

		button.isSelected = self.useTemplateId == id

		if data.icon then
			iconUImage.sprite = data.icon
		elseif data.imgKey then
			iconUImage.url = ""

			self.model:queryPresetImg(data.imgKey, function(sprite, id)
				if id == data.id then
					iconUImage.sprite = sprite
				end
			end, data.id)
		else
			iconUImage.url = ""
			iconUImage.url = data.preset.icon
		end

		if data.title == nil or data.title == "" then
			button:TryChangePage("Text", 1)
		else
			button:TryChangePage("Text", 0)
			ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(data.title))
		end

		btnFavoriteUButton:SetActive(self.curType ~= TemplateType.Saved)
		btnFavoriteUButton:TryChangePage("enable", self.model:isLikedTemplate(id) and 1 or 0)

		function btnFavoriteUButton.luaClick()
			local isLiked = self.model:isLikedTemplate(id)

			self.model:likeTemplate(id, not isLiked, function(a, b)
				local isLiked = self.model:isLikedTemplate(id)
				local tipStr = isLiked and "PHOTO_TEMPLATE_LIKED" or "PHOTO_TEMPLATE_UNLIKED"

				pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString(tipStr), pg.getLocalizationText(data.title)))
				btnFavoriteUButton:TryChangePage("enable", self.model:isLikedTemplate(id) and 1 or 0)
			end)
		end

		function button.luaClick()
			self.useTemplateId = data.id

			self:useTemplate(data)
		end

		function button.luaRenderTooltip(btn, prop)
			self:refreshToolTip(prop, data, iconUImage.sprite, button)
		end
	end
end

function PhotoFuncTemplateUIComponent:refreshUI()
	if not self.haveRefreshed then
		self.listFirstUList:SetList(TabConfig)
		self.listFirstUList:DeselectAll()
		self.listFirstUList:SelectItem(0)

		self.haveRefreshed = true
	end
end

function PhotoFuncTemplateUIComponent:setTemplateList(list)
	if not list then
		self.listSecondUList:RefreshList()
	else
		self.listSecondUList:SetList(list)
	end

	self.uWidget:TryChangePage("status", self.listSecondUList.itemData.Count > 0 and 0 or 1)
end

function PhotoFuncTemplateUIComponent:refreshToolTip(prop, templateData, sprite, oriBtn)
	local objectReference = prop:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtUText = objectReference:GetRefValue("txtUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		ClientTextUtils.setText(txtUText, pg.getGameString(data.label))

		iconUImage.url = data.icon

		function button.luaClick()
			self[data.func](self, templateData, sprite)

			if oriBtn and NotNil(oriBtn) then
				oriBtn:ClosePopup()
			end
		end
	end

	local isOfficial = string.startsWith(tostring(templateData.id), "official_")

	listUList:SetList(self:getOptionList(isOfficial))
end

function PhotoFuncTemplateUIComponent:getOptionList(isOfficial)
	local ret = {}
	local optionSet = Type2Options[self.curType]

	for k, type in pairs(OptionType) do
		if optionSet[type] and (type ~= OptionType.CopyCode or not isOfficial) then
			ret[#ret + 1] = OptionConfig[type]
		end
	end

	table.sort(ret, function(a, b)
		return a.type < b.type
	end)

	return ret
end

function PhotoFuncTemplateUIComponent:onClickTrack(data)
	if Utils.isSelfInSpaceDungeon() then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	local sceneId = data.preset.sceneId

	if not pg.game.map:checkValidScene(pg.game.map:convertSceneId(sceneId)) then
		pg.global.showBubbleMessageById(2126)

		return
	end

	local pos = data.preset.playerPos
	local seekInfo = {
		sourceScene = sceneId,
		type = LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS,
		sourcePosition = {
			pos.x,
			pos.y,
			pos.z,
			"$UI_Icon_MarkPoint_photo.png"
		},
		buttonTxt = TrackId,
		extraParam = {
			replaceIcon = "$UI_Icon_MarkPoint_photo.png",
			infoTitle = pg.getLocalizationText(data.title),
			infoText = pg.getLocalizationText(data.desc),
			infoImage = data.preset.icon,
			photoData = {
				imgKey = data.imgKey,
				userName = pg.getLocalizationText(data.userName),
				id = data.id
			}
		}
	}

	LuaUIUtils.clueSeek(seekInfo)
end

function PhotoFuncTemplateUIComponent:onClickDetail(data, sprite)
	pg.global.ui:open(UIConst.UI_ID_PHOTO_DOWNLOAD_TEMPLATE, {
		templateInfo = data
	})
end

function PhotoFuncTemplateUIComponent:onClickDownload(data)
	pg.global.ui:open(UIConst.UI_ID_PHOTO_DOWNLOAD_TEMPLATE, {
		templateInfo = data
	})
end

function PhotoFuncTemplateUIComponent:onClickCopyCode(data)
	local presetId = data.id
	local _, idStr = Utils.parsePhotoPresetUniqueId(data.id)

	UIUtils.ClipboardWriter(idStr)
	pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_COPY_SUCCESS"))
end

function PhotoFuncTemplateUIComponent:onClickDelete(data)
	self.model:deleteSavedTemplate(data.id, data.imgKey, function()
		self.model:getSavedTemplate(function(list)
			if self.curType == TemplateType.Saved then
				self:setTemplateList(list)
			end
		end, false)
	end)
end

function PhotoFuncTemplateUIComponent:useTemplate(data)
	local pos = data.preset.playerPos

	if self.model:isArriveTrackPos(data.preset.sceneId, pos.x, pos.y, pos.z) then
		pg.me:pawnAutoPathFinding(Vector3(pos.x, pos.y, pos.z), function()
			if pg.global.ui:checkUIVisible(UIConst.UI_ID_PHOTO) then
				pg.global.ui.photo:applyPreset(data.preset)
				pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_USED"))
			end
		end, AutoPathFindUtils.PathFindType.Voxel)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_POS"))
		pg.global.ui.photo:applyPreset(data.preset)
	end
end

return PhotoFuncTemplateUIComponent
