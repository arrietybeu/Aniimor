-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\SocialMediaShareListComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local SocialPlatformData = require("Data.social_platform_data")
local UIComponent = require("Guis.Helper.UIComponent")
local SocialMediaShareService = require("SDK.SocialMediaShareService")
local ImageShareManager = CS.FunPlus.WorldX.SDK.ImageShareManager
local IMAGE_SHARE_STYLE = "image"
local IMAGE_TO_URL_SHARE_STYLE = "imageToUrl"
local IMAGE_OPERATION_CHECK = "check"
local IMAGE_OPERATION_SHARE = "share"
local IMAGE_OPERATION_STEP_CHECK_IMAGE = "checkImage"
local IMAGE_OPERATION_STEP_FINISH = "finish"
local IMAGE_OPERATION_STEP_REQUEST_IMAGE = "requestImage"
local IMAGE_OPERATION_STEP_START = "start"
local IMAGE_OPERATION_STEP_UPLOAD_IMAGE = "uploadImage"
local FACEBOOK_SOCIAL_TYPE = "facebook"
local INSTAGRAM_SOCIAL_TYPE = "ins"
local SYSTEM_SHARE_PLATFORM = "system"
local TWITTER_SOCIAL_TYPE = "twitter"
local SOCIAL_MEDIA_WEB_URL = {
	[FACEBOOK_SOCIAL_TYPE] = "https://www.facebook.com/",
	[INSTAGRAM_SOCIAL_TYPE] = "https://www.instagram.com/",
	[TWITTER_SOCIAL_TYPE] = "https://x.com/compose/post"
}
local SocialMediaShareListComponent = Class.LightClass("SocialMediaShareListComponent", UIComponent)

function SocialMediaShareListComponent:ctor(ctrl, listBtnUList, requestImagePath)
	self.listBtnUList = listBtnUList
	self.requestImagePath = requestImagePath

	local platform = pg.global.platform
	local isCn = ClientConfigAppCountry == "cn"
	local isOverseas = isCn == false

	self.isOverseasPC = isOverseas and platform:isPC()
	self.isShareSupportedPlatform = platform:isMobile() or isOverseas and platform:isPC()
	self.imageCheckResultMap = {}
	self.imageOperation = nil

	UIComponent.ctor(self, ctrl, listBtnUList.transform)
end

function SocialMediaShareListComponent:initView()
	if not self.isShareSupportedPlatform then
		self:hide()

		return
	end

	function self.listBtnUList.luaClick(_, socialMediaInfo)
		self:tryShare(socialMediaInfo)
	end

	function self.listBtnUList.luaRenderItem(button, _, socialMediaInfo)
		self:renderListItem(button, socialMediaInfo)
	end
end

function SocialMediaShareListComponent:tryShare(socialMediaInfo)
	local operation = {
		mode = IMAGE_OPERATION_SHARE,
		socialMediaInfo = socialMediaInfo
	}

	self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_START)
end

function SocialMediaShareListComponent:checkImage(sprite, callback)
	local operation = {
		mode = IMAGE_OPERATION_CHECK,
		sprite = sprite,
		callback = callback
	}

	self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_START)
end

function SocialMediaShareListComponent:advanceImageOperation(operation, step)
	if step == IMAGE_OPERATION_STEP_START then
		self:startImageOperation(operation)

		return
	end

	local isCurrentStep = step == IMAGE_OPERATION_STEP_FINISH or operation.state == step

	if self.imageOperation ~= operation or not isCurrentStep then
		return
	end

	if step == IMAGE_OPERATION_STEP_REQUEST_IMAGE then
		self:processImageRequestResult(operation)

		return
	end

	if step == IMAGE_OPERATION_STEP_UPLOAD_IMAGE then
		self:processImageUploadResult(operation)

		return
	end

	if step == IMAGE_OPERATION_STEP_CHECK_IMAGE then
		self:processImageCheckResult(operation)

		return
	end

	if step == IMAGE_OPERATION_STEP_FINISH then
		self:finishImageOperation(operation)
	end
end

function SocialMediaShareListComponent:startImageOperation(operation)
	if self.imageOperation then
		return
	end

	self.imageOperation = operation
	operation.state = IMAGE_OPERATION_STEP_REQUEST_IMAGE

	local function onImageReady(imagePath, sprite)
		operation.imagePath = imagePath
		operation.requestSprite = sprite

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_REQUEST_IMAGE)
	end

	self.requestImagePath(onImageReady)
end

function SocialMediaShareListComponent:processImageRequestResult(operation)
	if operation.imagePath == "" then
		operation.canUse = false

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_FINISH)

		return
	end

	if operation.mode == IMAGE_OPERATION_SHARE then
		operation.sprite = operation.requestSprite

		if not operation.sprite then
			operation.canUse = true

			self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_FINISH)

			return
		end
	end

	local checkResult = self.imageCheckResultMap[operation.imagePath]

	if checkResult ~= nil then
		if checkResult == false then
			pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_FAIL"))
		end

		operation.canUse = checkResult

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_FINISH)

		return
	end

	if not pg.me then
		operation.state = IMAGE_OPERATION_STEP_CHECK_IMAGE
		operation.canUse = true

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_CHECK_IMAGE)

		return
	end

	operation.state = IMAGE_OPERATION_STEP_UPLOAD_IMAGE

	local function onImageUploaded(_, success, imgUrl)
		operation.uploadSucceeded = success
		operation.imgUrl = imgUrl

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_UPLOAD_IMAGE)
	end

	pg.me:addPhotoImgSprite(operation.sprite, onImageUploaded)
end

function SocialMediaShareListComponent:processImageUploadResult(operation)
	if not operation.uploadSucceeded or not operation.imgUrl or operation.imgUrl == "" then
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

		operation.canUse = false

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_FINISH)

		return
	end

	operation.state = IMAGE_OPERATION_STEP_CHECK_IMAGE

	local function onImageChecked(pass)
		operation.canUse = pass

		self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_CHECK_IMAGE)
	end

	Utils.checkPhoto(Const.PhotoCheckScene.Share, operation.imgUrl, onImageChecked)
end

function SocialMediaShareListComponent:processImageCheckResult(operation)
	self.imageCheckResultMap[operation.imagePath] = operation.canUse

	self:advanceImageOperation(operation, IMAGE_OPERATION_STEP_FINISH)
end

function SocialMediaShareListComponent:finishImageOperation(operation)
	self.imageOperation = nil
	operation.state = IMAGE_OPERATION_STEP_FINISH

	if operation.mode == IMAGE_OPERATION_SHARE then
		if operation.canUse == true then
			self:shareImage(operation.socialMediaInfo, operation.imagePath)
		end

		return
	end

	operation.callback(operation.canUse)
end

function SocialMediaShareListComponent:shareImage(socialMediaInfo, imagePath)
	if self.isOverseasPC then
		local socialType = socialMediaInfo.socialType

		local function onImageCopied(success)
			if success ~= true then
				return
			end

			Application.OpenURL(SOCIAL_MEDIA_WEB_URL[socialType])
		end

		ImageShareManager.CopyImageToClipboard(imagePath, onImageCopied)

		return
	end

	local sharePlatform = socialMediaInfo.socialType == INSTAGRAM_SOCIAL_TYPE and SYSTEM_SHARE_PLATFORM or socialMediaInfo.socialType
	local shareText = socialMediaInfo.style == IMAGE_TO_URL_SHARE_STYLE and pg.getGameString("PHOTO_ANIIMO") or ""

	ImageShareManager.ShareImage(sharePlatform, imagePath, shareText, shareText, socialMediaInfo.style)
end

function SocialMediaShareListComponent:renderListItem(button, socialMediaInfo)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = socialMediaInfo.buttonIcon
end

function SocialMediaShareListComponent:refresh()
	if not self.isShareSupportedPlatform then
		return
	end

	self.listBtnUList:SetList(self:getListData())
end

function SocialMediaShareListComponent:getListData()
	local shareConfig = SocialMediaShareService.getCurrentConfig(SocialMediaShareService.ConfigType.Image)

	if shareConfig == nil then
		return {}
	end

	local list = {}

	for _, socialMediaId in ipairs(shareConfig.socialMedia) do
		local socialPlatform = SocialPlatformData[socialMediaId]
		local socialType = socialPlatform.socialType

		list[#list + 1] = {
			tIndex = 0,
			socialMediaId = socialMediaId,
			socialType = socialType,
			buttonIcon = socialPlatform.buttonIcon,
			style = socialType == TWITTER_SOCIAL_TYPE and IMAGE_TO_URL_SHARE_STYLE or IMAGE_SHARE_STYLE
		}
	end

	return list
end

function SocialMediaShareListComponent:onDestroy()
	self.isOverseasPC = nil
	self.isShareSupportedPlatform = nil
	self.imageCheckResultMap = nil
	self.imageOperation = nil
	self.listBtnUList.luaClick = nil
	self.listBtnUList.luaRenderItem = nil
	self.listBtnUList = nil
	self.requestImagePath = nil
end

return SocialMediaShareListComponent
