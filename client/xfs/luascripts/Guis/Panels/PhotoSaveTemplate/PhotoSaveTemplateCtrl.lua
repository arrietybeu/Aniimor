-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoSaveTemplate\\PhotoSaveTemplateCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotoSaveTemplateCtrl = Class.LightClass("PhotoSaveTemplateCtrl", UICtrl)
local TitleLimit = 20
local ContentLimit = 100

PhotoSaveTemplateCtrl.messages = {}

function PhotoSaveTemplateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.title = nil
	self.content = nil
	self.templateInfo = info.templateInfo
	self.sprite = info.sprite
	self.successCallback = info.successCallback

	self:initView()
end

function PhotoSaveTemplateCtrl:addListener()
	function self.view.titleInputUTMPInputField.luaValueChanged(newName)
		local count = 0

		self.title, count = ClientTextUtils.getValidName(newName, TitleLimit / 2)

		self.view.titleInputUTMPInputField:SetTextWithoutNotify(self.title)
	end

	function self.view.contentInputUTMPInputField.luaValueChanged(newName)
		local count = 0

		self.content, count = ClientTextUtils.getValidName(newName, ContentLimit / 2)

		self.view.contentInputUTMPInputField:SetTextWithoutNotify(self.content)
	end

	function self.view.btnConfirmUButton.luaClick()
		if string.isNilOrEmpty(self.title) then
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_PRESET_TITLE"))

			return
		end

		if string.isNilOrEmpty(self.content) then
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_PRESET_DESC"))

			return
		end

		pg.me:sensitiveWordsCheck(self.title, function(text)
			pg.me:sensitiveWordsCheck(self.content, function(text)
				self.templateInfo.title = self.title
				self.templateInfo.desc = self.content

				pg.me:uploadPresetWithImgSprite(self.templateInfo, self.sprite, function(id)
					pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_SAVED"))

					if self.successCallback then
						self.successCallback()
					end

					self:close()
				end)
			end, nil, {
				DetailType = "Photo_Description",
				Level = pg.me.level
			})
		end, nil, {
			DetailType = "Photo_Title",
			Level = pg.me.level
		})
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end
end

function PhotoSaveTemplateCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PhotoSaveTemplateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PhotoSaveTemplateCtrl:onShow()
	return
end

function PhotoSaveTemplateCtrl:onHide()
	return
end

function PhotoSaveTemplateCtrl:initView()
	self.view.photoUImage.sprite = self.sprite

	ClientTextUtils.setText(self.view.titleLimitUBaseText, "")
	ClientTextUtils.setText(self.view.contentLimitUBaseText, "")
end

return PhotoSaveTemplateCtrl
