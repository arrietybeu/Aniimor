-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PhotoStudioEditComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PhotographyStudioSlotData = require("Data.photography_studio_slot_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local Utils = require("Common.Utils.Utils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local STUDIO_NAME_MAX_LEN = 7
local STUDIO_DEFAULT_COVER_URL = AppearanceVariableData.STUDIO_DEFAULT_IMAGE
local PhotoStudioEditComponent = Class.LightClass("PhotoStudioEditComponent", UIComponent)

PhotoStudioEditComponent.messages = {
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onStudioChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CONTENT_CHANGED] = {
		"onStudioContentChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_ACTIVE_MEMBERS_CHANGED] = {
		"onStudioActiveMembersChanged",
		true
	}
}
PhotoStudioEditComponent.TINDEX = {
	ADDABLE = 2,
	LOCKED = 1,
	STUDIO = 0
}
PhotoStudioEditComponent.TAG = {
	MINE = 0,
	JOINED = 1
}

local function getUidKey(uid)
	if uid == nil then
		return nil
	end

	return tostring(uid)
end

local IMPORT_PLAYER_LAYOUT_FIELDS = {
	"playerPos",
	"playerRot",
	"playerPoseId",
	"gazeType",
	"gazePos"
}

local function getOrderedStudioPlayerSegments(content, masterUid)
	local result = {}

	if type(content) ~= "table" or type(content.players) ~= "table" then
		return result
	end

	local players = content.players
	local masterKey = getUidKey(masterUid)
	local usedUidSet = {}

	if masterKey then
		for uid, playerData in pairs(players) do
			if getUidKey(uid) == masterKey and type(playerData) == "table" then
				result[#result + 1] = playerData
				usedUidSet[masterKey] = true

				break
			end
		end
	end

	local otherPlayers = {}

	for uid, playerData in pairs(players) do
		local uidKey = getUidKey(uid)

		if uidKey and not usedUidSet[uidKey] and type(playerData) == "table" then
			usedUidSet[uidKey] = true
			otherPlayers[#otherPlayers + 1] = {
				uid = uidKey,
				data = playerData
			}
		end
	end

	table.sort(otherPlayers, function(left, right)
		return left.uid < right.uid
	end)

	for _, player in ipairs(otherPlayers) do
		result[#result + 1] = player.data
	end

	return result
end

local function buildImportedStudioPets(sourcePets)
	local importedPets = {}

	if type(sourcePets) ~= "table" or type(pg.me.pets) ~= "table" then
		return importedPets
	end

	local ownedPetsByTemplateId = {}

	for petId, petInfo in pairs(pg.me.pets) do
		local templateId = petInfo and petInfo.templateId

		if templateId then
			local templateKey = tostring(templateId)
			local ownedPets = ownedPetsByTemplateId[templateKey]

			if not ownedPets then
				ownedPets = {}
				ownedPetsByTemplateId[templateKey] = ownedPets
			end

			ownedPets[#ownedPets + 1] = {
				petId = petId,
				petInfo = petInfo
			}
		end
	end

	for _, ownedPets in pairs(ownedPetsByTemplateId) do
		table.sort(ownedPets, function(left, right)
			return tostring(left.petId) < tostring(right.petId)
		end)
	end

	local usedCountByTemplateId = {}

	for _, sourcePetData in ipairs(sourcePets) do
		local templateId = type(sourcePetData) == "table" and sourcePetData.templateId or nil
		local templateKey = templateId and tostring(templateId) or nil
		local ownedPets = templateKey and ownedPetsByTemplateId[templateKey] or nil

		if ownedPets then
			local usedCount = usedCountByTemplateId[templateKey] or 0
			local ownedPet = ownedPets[usedCount + 1]

			if ownedPet then
				usedCountByTemplateId[templateKey] = usedCount + 1

				local importedPetData = Utils.deepCopyTable(sourcePetData)
				local petId = ownedPet.petId
				local petInfo = ownedPet.petInfo
				local petJewelryInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[petId]

				importedPetData.petId = petId
				importedPetData.ownerUid = pg.me.uid
				importedPetData.templateId = petInfo.templateId
				importedPetData.label = petInfo.label
				importedPetData.gender = petInfo.gender
				importedPetData.shinyStyle = petInfo.shinyStyle
				importedPetData.petJewelryInfo = PhotographyStudioUtils.serializePetJewelryInfo(petJewelryInfo, petId)
				importedPetData.selectTransmogScheme = PhotographyStudioUtils.toRawTable(PetTransmogUtils.getSelectedScheme(petInfo))
				importedPets[#importedPets + 1] = importedPetData
			end
		end
	end

	return importedPets
end

local function buildImportedStudioPlayers(sourceContent, targetContent, targetMasterUid)
	local targetPlayers = {}

	if type(targetContent) == "table" and type(targetContent.players) == "table" then
		targetPlayers = Utils.deepCopyTable(targetContent.players)
	end

	local targetPlayerContent = {
		players = targetPlayers
	}
	local sourcePlayers = getOrderedStudioPlayerSegments(sourceContent, sourceContent.masterUid)
	local targetPlayerSegments = getOrderedStudioPlayerSegments(targetPlayerContent, targetMasterUid)
	local applyCount = math.min(#sourcePlayers, #targetPlayerSegments)

	for index = 1, applyCount do
		local sourcePlayerData = sourcePlayers[index]
		local targetPlayerData = targetPlayerSegments[index]

		for _, fieldName in ipairs(IMPORT_PLAYER_LAYOUT_FIELDS) do
			local value = sourcePlayerData[fieldName]

			if type(value) == "table" then
				targetPlayerData[fieldName] = Utils.deepCopyTable(value)
			else
				targetPlayerData[fieldName] = value
			end
		end

		if index == 1 and getUidKey(targetMasterUid) == getUidKey(pg.me.uid) then
			targetPlayerData.pets = buildImportedStudioPets(sourcePlayerData.pets)
		end
	end

	return targetPlayers
end

function PhotoStudioEditComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listPlanUList = self.objectReference:GetRefValue("listPlanUList")
	self.btnImportUButton = self.objectReference:GetRefValue("btnImportUButton")
	self.txtBtnImportNameUBaseText = self.objectReference:GetRefValue("txtBtnImportNameUBaseText")
	self.btnEditUButton = self.objectReference:GetRefValue("btnEditUButton")
	self.txtBtnEditUBaseText = self.objectReference:GetRefValue("txtBtnEditUBaseText")
	self.btnRenameUButton = self.objectReference:GetRefValue("btnRenameUButton")
	self.btnShareUButton = self.objectReference:GetRefValue("btnShareUButton")
	self.dIYPreviewRootRectTransform = self.objectReference:GetRefValue("dIYPreviewRootRectTransform")
end

function PhotoStudioEditComponent:initView()
	self.isDestroyed = false
	self.isPageActive = false
	self.previewRequestId = 0
	self.selectedStudioUid = nil
	self.pendingEditStudioUid = nil
	self.isRefreshingListSelection = false
	self.studioContentLoading = {}
	self.studioContentLoaded = {}
	self.studioActiveRequested = {}

	ClientTextUtils.setText(self.txtBtnImportNameUBaseText, pg.getGameString("PHOTO_STUDIO_IMPORT"))
	ClientTextUtils.setText(self.txtBtnEditUBaseText, pg.getGameString("PHOTO_STUDIO_EDIT"))
	self:initList()
end

function PhotoStudioEditComponent:onEnterPage()
	self.isPageActive = true
	self.previewRequestId = self.previewRequestId + 1
	self.studioActiveRequested = {}

	self:addListener()

	local scene = self:getAvatarScene()

	if scene then
		scene:setPhotographyStudioCharactersVisible(true)

		local enterStudioUid = self.ctrl.enterPhotographyStudioUid

		if enterStudioUid and pg.me:getStudioInfo(enterStudioUid) then
			self.selectedStudioUid = enterStudioUid

			scene:setCurrentPhotographyStudioUid(enterStudioUid)
		else
			self.selectedStudioUid = nil
		end

		self.ctrl.enterPhotographyStudioUid = nil

		local selectedInfo = self.selectedStudioUid and pg.me:getStudioInfo(self.selectedStudioUid)

		self.selectedIsMine = selectedInfo and selectedInfo.masterUid == pg.me.uid or nil

		local needRefreshPreviewAfterAvatarLoaded = scene:getEntity(self.ctrl.curPresetKey) == nil

		scene:showAvatar(self.ctrl.curPresetKey, needRefreshPreviewAfterAvatarLoaded and function()
			if self.isDestroyed or not self.isPageActive or self.ctrl.curComponentName ~= "photoStudioEdit" then
				return
			end

			scene:setEntityRot(scene:getCurEntityId(), 0)

			if self.ctrl.delayRefreshDecal then
				self.ctrl:delayRefreshDecal()
			end

			if self.selectedStudioUid then
				self:previewSelectedStudio()
			end
		end or nil)
		scene:setEntityRot(scene:getCurEntityId(), 0)

		if self.ctrl.delayRefreshDecal then
			self.ctrl:delayRefreshDecal()
		end
	end

	self:refreshList()
	self:refreshButtons()
end

function PhotoStudioEditComponent:onLeavePage()
	if self.ctrl.curComponentName ~= "photoStudioEdit" then
		return
	end

	self.isPageActive = false
	self.previewRequestId = self.previewRequestId + 1

	self:removeListener()

	local scene = self:getAvatarScene()

	if scene then
		self:cleanupStudioPreview(scene, true)
	end

	self:clearPreviewDIY()
end

function PhotoStudioEditComponent:getAvatarScene()
	return pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function PhotoStudioEditComponent:onDestroy()
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true
	self.isPageActive = false
	self.previewRequestId = self.previewRequestId + 1

	local scene = self:getAvatarScene()

	if scene then
		if self.ctrl.curComponentName == "photoStudioEdit" then
			self:cleanupStudioPreview(scene, false)
		else
			scene:clearStudioPlayers()
			scene:disableStudioFreeCamera()
		end
	end

	self:clearPreviewDIY()
	UIComponent.onDestroy(self)
end

function PhotoStudioEditComponent:restorePlayerBackgroundSelection(scene)
	local studioUid = pg.me.themePhotographyStudioUid

	if studioUid and studioUid ~= "" and scene:applyPhotographyStudioDisplayPreset(studioUid) then
		return
	end

	scene:clearPhotographyStudioDisplayPreset()

	local bgRes, bgId = AvatarUtils.getCurSetBgRes(Const.APPEARANCE_BACKGROUND_TYPE.Player)

	scene:setBackground(bgRes, bgId)
end

function PhotoStudioEditComponent:cleanupStudioPreview(scene, restoreBackground)
	local curEntityId = scene:getCurEntityId()

	if curEntityId then
		scene:applyStudioPlayerPose(curEntityId, nil)
		scene:applyStudioPlayerGaze(curEntityId, nil)
		self:restoreSelfEntityTransform(scene)
		scene:hideEntityWithId(curEntityId)
	end

	scene:clearStudioPlayers()
	scene:disableStudioFreeCamera()

	if restoreBackground then
		self:restorePlayerBackgroundSelection(scene)
	end
end

function PhotoStudioEditComponent:initList()
	function self.listPlanUList.luaCheckCanSelected(data)
		return data ~= nil and data.tIndex == self.TINDEX.STUDIO
	end

	function self.listPlanUList.luaRenderItem(button, index, data)
		if data.tIndex == self.TINDEX.STUDIO then
			self:renderStudioItem(button, data)
		elseif data.tIndex == self.TINDEX.LOCKED then
			self:renderLockedItem(button, data)
		end
	end

	function self.listPlanUList.luaSelectedChanged(list, isSelected)
		if self.isRefreshingListSelection then
			return
		end

		self:onListSelectChanged()
	end

	function self.listPlanUList.luaClick(button, data)
		self:onItemClicked(data)
	end
end

function PhotoStudioEditComponent:buildListData()
	local selfUid = pg.me.uid
	local studios = pg.me:getAllStudios() or {}
	local mineBySlot = {}
	local joinedStudios = {}

	for uid, info in pairs(studios) do
		if info.masterUid == selfUid then
			if info.slotId then
				mineBySlot[info.slotId] = {
					uid = uid,
					info = info
				}
			end
		else
			joinedStudios[#joinedStudios + 1] = {
				uid = uid,
				info = info
			}
		end
	end

	local mine = {}
	local joined = {}
	local addable = {}
	local locked = {}
	local unlockCount = pg.me.photographyUnlockCount or 0
	local totalSlot = #PhotographyStudioSlotData

	for slotId = 1, totalSlot do
		local studio = mineBySlot[slotId]

		if studio then
			local cachedContent = pg.me:getCachedPhotographyStudioContent(studio.uid)
			local coverVersion

			if type(cachedContent) == "table" then
				coverVersion = tonumber(cachedContent.coverVersion) or 0
			end

			mine[#mine + 1] = {
				tIndex = self.TINDEX.STUDIO,
				tag = self.TAG.MINE,
				slotId = slotId,
				studioUid = studio.uid,
				info = studio.info,
				coverVersion = coverVersion
			}
		elseif slotId <= unlockCount then
			addable[#addable + 1] = {
				tIndex = self.TINDEX.ADDABLE,
				slotId = slotId
			}
		elseif #locked == 0 then
			local slotCfg = PhotographyStudioSlotData[slotId] or {}

			locked[#locked + 1] = {
				tIndex = self.TINDEX.LOCKED,
				slotId = slotId,
				costType = slotCfg.costType,
				costNum = slotCfg.costNum
			}
		end
	end

	for _, studio in ipairs(joinedStudios) do
		local cachedContent = pg.me:getCachedPhotographyStudioContent(studio.uid)
		local coverVersion

		if type(cachedContent) == "table" then
			coverVersion = tonumber(cachedContent.coverVersion) or 0
		end

		joined[#joined + 1] = {
			tIndex = self.TINDEX.STUDIO,
			tag = self.TAG.JOINED,
			studioUid = studio.uid,
			info = studio.info,
			coverVersion = coverVersion
		}
	end

	local list = {}

	for _, seg in ipairs({
		mine,
		joined,
		addable,
		locked
	}) do
		for _, item in ipairs(seg) do
			list[#list + 1] = item
		end
	end

	return list
end

function PhotoStudioEditComponent:refreshList()
	local list = self:buildListData()

	self:requestStudioActives(list)

	local firstStudioIndex, selectedStudioIndex
	local selectedStillValid = false

	for i, data in ipairs(list) do
		if data.tIndex == self.TINDEX.STUDIO then
			firstStudioIndex = firstStudioIndex or i

			if data.studioUid == self.selectedStudioUid then
				selectedStillValid = true
				selectedStudioIndex = i
				data.selected = true
			end
		end
	end

	if not selectedStillValid then
		local scene = self:getAvatarScene()

		if scene and self.selectedStudioUid then
			scene:clearPhotographyStudioDisplayPreset()
		end

		self.selectedStudioUid = nil
		self.selectedIsMine = nil
	end

	self.isRefreshingListSelection = true

	self.listPlanUList:SetList(list)

	self.isRefreshingListSelection = false

	if self.selectedStudioUid == nil and firstStudioIndex then
		self.listPlanUList:SelectItem(firstStudioIndex - 1)
	elseif selectedStudioIndex then
		self.listPlanUList:SelectItem(selectedStudioIndex - 1)
	end
end

function PhotoStudioEditComponent:requestStudioActives(list)
	for _, data in ipairs(list) do
		if data.tIndex == self.TINDEX.STUDIO then
			local studioUid = data.studioUid

			if studioUid ~= nil and not self.studioActiveRequested[studioUid] then
				self.studioActiveRequested[studioUid] = true

				pg.me:reqPhotographyStudioActives(studioUid)
			end
		end
	end
end

function PhotoStudioEditComponent:renderStudioItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	local textNumUBaseText = objectReference:GetRefValue("textNumUBaseText")
	local textTagUBaseText = objectReference:GetRefValue("textTagUBaseText")
	local imgPhotoUImage = objectReference:GetRefValue("imgPhotoUImage")
	local adaptationBoxUXAdaptionRect = objectReference:GetRefValue("adaptationBoxUXAdaptionRect")

	ClientTextUtils.setText(textNameUBaseText, self:getStudioDisplayName(data.info))

	local studioUid = data.studioUid

	button:TryChangePage("RoomState", pg.me:getPhotographyStudioActiveMemberCount(studioUid) > 0 and 1 or 0)

	imgPhotoUImage.url = nil

	imgPhotoUImage:SetUrlWithCallback(STUDIO_DEFAULT_COVER_URL, function()
		local function updateDefaultCoverAdaptation()
			local currentData = button.dataFromUList

			if self.isDestroyed or not currentData or currentData.studioUid ~= studioUid or imgPhotoUImage.url ~= STUDIO_DEFAULT_COVER_URL then
				return
			end

			local sprite = imgPhotoUImage.sprite

			if IsNil(sprite) or IsNil(sprite.texture) then
				return
			end

			CS.XGUI.LayoutMgr.ForceRebuildLayoutImmediate(button)

			local texture = sprite.texture

			adaptationBoxUXAdaptionRect.useCustomResolution = true
			adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

			adaptationBoxUXAdaptionRect:UpdateAdaptation()
		end

		updateDefaultCoverAdaptation()
		self:startFrameTimer(updateDefaultCoverAdaptation, 1)
	end, nil, true)

	local cachedContent = pg.me:getCachedPhotographyStudioContent(studioUid)

	if type(cachedContent) == "table" then
		self.studioContentLoaded[studioUid] = true
		data.coverVersion = tonumber(cachedContent.coverVersion) or 0
	elseif self.studioContentLoaded[studioUid] then
		data.coverVersion = 0
	else
		data.coverVersion = nil

		self:requestStudioContentForCover(studioUid)
	end

	if data.coverVersion ~= nil then
		self:loadStudioItemCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)
	end

	local members = data.info.members
	local curNum = members and #members or 0
	local maxNum = AppearanceVariableData.STUDIO_INVITE_FRIEND_NUM

	ClientTextUtils.setText(textNumUBaseText, string.format("%d/%d", curNum, maxNum))
	button:TryChangePage("Tag", data.tag)

	local tagStr = data.tag == self.TAG.MINE and "PHOTO_STUDIO_TAG_MINE" or "PHOTO_STUDIO_TAG_JOINED"

	ClientTextUtils.setText(textTagUBaseText, pg.getGameString(tagStr))
end

function PhotoStudioEditComponent:loadStudioItemCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)
	local studioUid = data.studioUid
	local coverVersion = data.coverVersion

	PhotographyStudioUtils.loadPhotographyStudioCover(studioUid, coverVersion, function(sprite, success)
		if self.isDestroyed or not success then
			return
		end

		local currentData = button.dataFromUList

		if currentData and currentData.studioUid == studioUid and currentData.coverVersion == coverVersion then
			imgPhotoUImage.url = nil
			imgPhotoUImage.sprite = sprite

			local texture = sprite.texture

			adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

			adaptationBoxUXAdaptionRect:UpdateAdaptation()
		end
	end)
end

function PhotoStudioEditComponent:requestStudioContentForCover(studioUid)
	if self.studioContentLoading[studioUid] then
		return
	end

	self.studioContentLoading[studioUid] = true

	pg.me:fetchStudioContent(studioUid, function(content, ok)
		self.studioContentLoading[studioUid] = nil

		if self.isDestroyed or not ok then
			return
		end

		self.studioContentLoaded[studioUid] = true

		local buttons = self.listPlanUList:GetAllButtons()

		for index = 0, buttons.Length - 1 do
			local button = buttons[index]
			local data = button.dataFromUList

			if data and data.studioUid == studioUid then
				self:renderStudioItem(button, data)
			end
		end
	end)
end

function PhotoStudioEditComponent:renderLockedItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local textMoneyUBaseText = oc:GetRefValue("textMoneyUBaseText")
	local moneyIconUImage = oc:GetRefValue("moneyIconUImage")
	local costNum = data.costNum or 0

	ClientTextUtils.setText(textMoneyUBaseText, tostring(costNum))

	if data.costType then
		moneyIconUImage.url = LuaUIUtils.getIconByItemId(data.costType)
	end
end

function PhotoStudioEditComponent:onStudioChanged(createdStudioUid)
	if createdStudioUid and self:selectStudioByUid(createdStudioUid) then
		return
	end

	self:refreshList()
	self:refreshButtons()
end

function PhotoStudioEditComponent:onStudioActiveMembersChanged(message)
	local studioUid = type(message) == "table" and message.studioUid

	if studioUid == nil then
		return
	end

	local roomState = pg.me:getPhotographyStudioActiveMemberCount(studioUid) > 0 and 1 or 0
	local buttons = self.listPlanUList:GetAllButtons()

	for index = 0, buttons.Length - 1 do
		local button = buttons[index]
		local data = button.dataFromUList

		if data and getUidKey(data.studioUid) == getUidKey(studioUid) then
			button:TryChangePage("RoomState", roomState)

			return
		end
	end
end

function PhotoStudioEditComponent:onStudioContentChanged(message)
	local studioUid = message and message.studioUid
	local content = message and message.content

	if not studioUid or type(content) ~= "table" then
		return
	end

	self.studioContentLoaded[studioUid] = true

	local coverVersion = tonumber(content.coverVersion) or 0
	local buttons = self.listPlanUList:GetAllButtons()

	for index = 0, buttons.Length - 1 do
		local button = buttons[index]
		local data = button.dataFromUList

		if data and data.studioUid == studioUid then
			data.coverVersion = coverVersion

			self:renderStudioItem(button, data)
		end
	end
end

function PhotoStudioEditComponent:onListSelectChanged()
	local selectedData = self.listPlanUList.selectedItem

	self.selectedStudioUid = selectedData and selectedData.studioUid or nil
	self.selectedIsMine = selectedData ~= nil and selectedData.tag == self.TAG.MINE

	self:refreshButtons()
	self:previewSelectedStudio()
end

function PhotoStudioEditComponent:previewSelectedStudio()
	local scene = self:getAvatarScene()

	if not scene or not self.isPageActive or self.ctrl.curComponentName ~= "photoStudioEdit" then
		return
	end

	self.previewRequestId = self.previewRequestId + 1

	local requestId = self.previewRequestId
	local studioUid = self.selectedStudioUid

	if not studioUid then
		scene:clearStudioPlayers()
		scene:disableStudioFreeCamera()
		scene:clearPhotographyStudioDisplayPreset()
		self:restoreSelfEntityTransform(scene)
		self:clearPreviewDIY()

		return
	end

	scene:setCurrentPhotographyStudioUid(studioUid)

	local content = pg.me:getCachedPhotographyStudioContent(studioUid)

	if content then
		self:applyStudioPreview(scene, studioUid, content)
	else
		pg.me:fetchStudioContent(studioUid, function(fetched)
			if fetched and not self.isDestroyed and self.isPageActive and self.ctrl.curComponentName == "photoStudioEdit" and self.previewRequestId == requestId and self.selectedStudioUid == studioUid then
				self:applyStudioPreview(scene, studioUid, fetched)
			end
		end)
	end
end

function PhotoStudioEditComponent:applyStudioPreview(scene, studioUid, content)
	local curEntityId = scene:getCurEntityId()
	local memberSet = self:getStudioMemberSet(studioUid)
	local common = scene:applyPhotographyStudioFullPreview(studioUid, content, {
		mainPlayerUid = pg.me.uid,
		mainEntityId = curEntityId,
		memberSet = memberSet
	})

	self:refreshPreviewDIY(common.diyInfo)
end

function PhotoStudioEditComponent:refreshPreviewDIY(diyInfo)
	self:clearPreviewDIY()

	if IsNil(self.dIYPreviewRootRectTransform) then
		return
	end

	self.previewDIYObjs = PhotographyStudioUtils.renderReadonlyDIY(self.view, self.dIYPreviewRootRectTransform, diyInfo)
end

function PhotoStudioEditComponent:clearPreviewDIY()
	if self.previewDIYObjs then
		PhotographyStudioUtils.clearReadonlyDIY(self.view, self.previewDIYObjs)

		self.previewDIYObjs = nil
	end
end

function PhotoStudioEditComponent:restoreSelfEntityTransform(scene)
	local curEntityId = scene:getCurEntityId()

	if curEntityId then
		scene:setStudioEntityLocalPos(curEntityId, Vector3.zero)
		scene:setStudioEntityLocalRotY(curEntityId, 0)
		scene:setEntityPos(curEntityId, Vector3.zero)
		scene:setEntityRot(curEntityId, 0)
	end
end

function PhotoStudioEditComponent:onItemClicked(data)
	if not data then
		return
	end

	if data.tIndex == self.TINDEX.ADDABLE then
		self:onClickCreate()
	elseif data.tIndex == self.TINDEX.LOCKED then
		self:onClickUnlock(data)
	end
end

function PhotoStudioEditComponent:addListener()
	function self.btnImportUButton.luaClick()
		self:onClickImport()
	end

	function self.btnEditUButton.luaClick()
		self:onClickEdit()
	end

	function self.btnRenameUButton.luaClick()
		self:onClickRename()
	end

	function self.btnShareUButton.luaClick()
		self:onClickShare()
	end
end

function PhotoStudioEditComponent:removeListener()
	self.btnImportUButton.luaClick = nil
	self.btnEditUButton.luaClick = nil
	self.btnRenameUButton.luaClick = nil
	self.btnShareUButton.luaClick = nil
end

function PhotoStudioEditComponent:isImportSupported()
	local platform = pg.global.platform

	return platform:isXboxPC() or not platform:isConsole()
end

function PhotoStudioEditComponent:refreshButtons()
	local hasStudio = self.selectedStudioUid ~= nil
	local canImport = hasStudio and self.selectedIsMine and self:isImportSupported()

	self.btnImportUButton:SetActive(canImport)
	self.btnEditUButton:SetActive(hasStudio)
	self.btnRenameUButton:SetActive(hasStudio and self.selectedIsMine)
	self.btnShareUButton:SetActive(hasStudio and self.selectedIsMine)
end

function PhotoStudioEditComponent:canImportStudioContent(studioUid)
	return self:isImportSupported() and not self.isDestroyed and studioUid ~= nil and self.selectedStudioUid == studioUid and pg.me:isStudioMaster(studioUid)
end

function PhotoStudioEditComponent:getStudioDisplayName(info)
	local name = info and info.name

	if not name or name == "" then
		return pg.getGameString("PHOTO_STUDIO_DEFAULT_NAME")
	end

	return name
end

function PhotoStudioEditComponent:getStudioMemberSet(studioUid)
	local set = {}
	local info = pg.me:getStudioInfo(studioUid)

	if not info then
		return set
	end

	if info.masterUid then
		set[getUidKey(info.masterUid)] = true
	end

	for _, member in ipairs(info.members or EMPTY_TABLE) do
		if member.uid then
			set[getUidKey(member.uid)] = true
		end
	end

	return set
end

function PhotoStudioEditComponent:onClickCreate()
	pg.me:reqCreatePhotographyStudio()
end

function PhotoStudioEditComponent:onClickUnlock(data)
	if not data.costType then
		return
	end

	local costText = LuaUIUtils.getItemCountConsumeShowText(data.costType, data.costNum, true)

	pg.global.ui.commonUseConfirm:open({
		type = 4,
		title = pg.getGameString("PHOTO_STUDIO_UNLOCK_TITLE"),
		tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
		data = {
			{
				data.costType,
				data.costNum
			}
		},
		confirmCb = function()
			pg.global.ui.commonUseConfirm:close()
			pg.me:reqPhotographyStudioUnlock(function(ok)
				if ok then
					self:refreshList()
				end
			end)
		end,
		cancelCb = function()
			pg.global.ui.commonUseConfirm:close()
		end
	})
end

function PhotoStudioEditComponent:onClickImport()
	local targetStudioUid = self.selectedStudioUid

	if not self:canImportStudioContent(targetStudioUid) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PHOTO_SCAN_CODE, {
		isPhotographyStudio = true,
		codeCallback = function(qrText, notDecode)
			self:onImportStudioCode(targetStudioUid, qrText, notDecode)
		end
	})
end

function PhotoStudioEditComponent:onImportStudioCode(targetStudioUid, qrText, notDecode)
	if not self:canImportStudioContent(targetStudioUid) then
		return
	end

	local errorGameString = notDecode and "PHOTO_STUDIO_ERROR_CODE" or "PHOTO_SCAN_FAILED"
	local sourceStudioCode = qrText

	if not notDecode then
		sourceStudioCode = Utils.decodeFromStr(qrText)
	end

	local sourceStudioUid = PhotographyStudioUtils.getPhotographyStudioUidByShareCode(sourceStudioCode)

	if not sourceStudioUid then
		pg.global.showBubbleMessageRaw(pg.getGameString(errorGameString))

		return
	end

	pg.me:fetchStudioContent(sourceStudioUid, function(sourceContent, sourceOk)
		if not self:canImportStudioContent(targetStudioUid) then
			return
		end

		if not sourceOk or type(sourceContent) ~= "table" or next(sourceContent) == nil then
			pg.global.showBubbleMessageRaw(pg.getGameString(errorGameString))

			return
		end

		self:checkImportStudioOverwrite(targetStudioUid, sourceStudioUid, sourceContent, errorGameString)
	end)
end

function PhotoStudioEditComponent:checkImportStudioOverwrite(targetStudioUid, sourceStudioUid, sourceContent, errorGameString)
	pg.me:fetchStudioContent(targetStudioUid, function(targetContent, targetOk)
		if not self:canImportStudioContent(targetStudioUid) then
			return
		end

		if not targetOk then
			pg.global.showBubbleMessageRaw(pg.getGameString(errorGameString))

			return
		end

		local currentVersion = PhotographyStudioUtils.CONTENT_VERSION

		currentVersion = type(targetContent) == "table" and tonumber(targetContent.version) or currentVersion

		pg.global.ui:close(UIConst.UI_ID_PHOTO_SCAN_CODE)

		local function importFunc()
			self:confirmImportedStudioLockedAssets(targetStudioUid, sourceStudioUid, sourceContent, targetContent, currentVersion)
		end

		if currentVersion > PhotographyStudioUtils.CONTENT_VERSION then
			PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.ImportOverwrite, pg.getGameString("PHOTO_STUDIO_IMPORT_OVERWRITE_TITLE"), pg.getGameString("PHOTO_STUDIO_IMPORT_OVERWRITE_DESC"), importFunc)
		else
			importFunc()
		end
	end)
end

function PhotoStudioEditComponent:confirmImportedStudioLockedAssets(targetStudioUid, sourceStudioUid, sourceContent, targetContent, currentVersion)
	if not self:canImportStudioContent(targetStudioUid) then
		return
	end

	local importedContent, lockedAssetIds = PhotographyStudioUtils.filterLockedStudioAssets(sourceContent, AvatarUtils.isBgUnlocked)

	if #lockedAssetIds == 0 then
		self:applyImportedStudioContent(targetStudioUid, sourceStudioUid, importedContent, targetContent, currentVersion)

		return
	end

	local itemList = {}

	for _, assetId in ipairs(lockedAssetIds) do
		itemList[#itemList + 1] = {
			assetId,
			1,
			hideNum = true,
			ownNum = 1
		}
	end

	pg.global.ui.commonUseConfirm:open({
		hideCurrency = true,
		muteCheckEnough = true,
		title = pg.getGameString("PHOTO_STUDIO_LOCKED_CONTENT_TITLE"),
		tipTop = pg.getGameString("PHOTO_STUDIO_LOCKED_CONTENT_DESC"),
		data = itemList,
		confirmCb = function()
			if self:canImportStudioContent(targetStudioUid) then
				self:applyImportedStudioContent(targetStudioUid, sourceStudioUid, importedContent, targetContent, currentVersion)
			end
		end
	})
end

function PhotoStudioEditComponent:applyImportedStudioContent(targetStudioUid, sourceStudioUid, sourceContent, targetContent, currentVersion)
	if not self:canImportStudioContent(targetStudioUid) then
		return
	end

	local importedContent = Utils.deepCopyTable(sourceContent)

	importedContent.version = currentVersion

	if type(targetContent) == "table" then
		importedContent.coverImageId = targetContent.coverImageId
		importedContent.coverVersion = targetContent.coverVersion
	else
		importedContent.coverImageId = nil
		importedContent.coverVersion = nil
	end

	local targetMasterUid = pg.me:getStudioMasterUid(targetStudioUid)

	importedContent.masterUid = targetMasterUid
	importedContent.players = buildImportedStudioPlayers(sourceContent, targetContent, targetMasterUid)

	pg.me:saveStudioContent(targetStudioUid, importedContent, nil, true)
	pg.me:waitPhotographyStudioContentSynced(targetStudioUid, importedContent.version, function()
		local logData = {
			studio_code_id = sourceStudioUid
		}

		LuaUIUtils.sendCustomLog(Const.BILogName.STUDIO_SHARE, logData)
	end)
	self:previewSelectedStudio()
end

function PhotoStudioEditComponent:onClickEdit()
	local studioUid = self.selectedStudioUid

	if not studioUid then
		return
	end

	self:openStudioEditor(studioUid)
end

function PhotoStudioEditComponent:openStudioEditor(studioUid)
	pg.global.ui:open(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT, {
		studioUid = studioUid,
		switchStudioCb = function(targetStudioUid)
			if not targetStudioUid or targetStudioUid == studioUid then
				return
			end

			self.pendingEditStudioUid = targetStudioUid

			pg.global.ui:close(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT)
		end
	}, nil, function()
		local targetStudioUid = self.pendingEditStudioUid

		self.pendingEditStudioUid = nil

		if targetStudioUid and pg.me:getStudioInfo(targetStudioUid) then
			self:selectStudioByUid(targetStudioUid)
			self:openStudioEditor(targetStudioUid)

			return
		end

		self:previewSelectedStudio()
	end)
end

function PhotoStudioEditComponent:selectStudioByUid(studioUid)
	local info = pg.me:getStudioInfo(studioUid)

	if not info then
		return false
	end

	self.selectedStudioUid = studioUid
	self.selectedIsMine = info.masterUid == pg.me.uid

	self:refreshList()
	self:refreshButtons()
	self:previewSelectedStudio()

	return true
end

function PhotoStudioEditComponent:onClickRename()
	local studioUid = self.selectedStudioUid

	if not studioUid then
		return
	end

	local info = pg.me:getStudioInfo(studioUid)
	local curName = self:getStudioDisplayName(info)

	pg.global.ui:open(UIConst.UI_ID_PLAYER_RENAME, {
		mode = "Rename",
		title = pg.getGameString("PHOTO_STUDIO_RENAME_TITLE"),
		maxLen = STUDIO_NAME_MAX_LEN,
		initialText = curName,
		placeholder = pg.getGameString("PHOTO_STUDIO_RENAME_PLACEHOLDER"),
		sensitiveWordsCheckExtraInfo = {
			DetailType = "Studio_Name",
			Level = pg.me.level
		},
		confirmCallback = function(newName)
			pg.me:reqUpdatePhotographyStudioName(studioUid, newName)
		end
	})
end

function PhotoStudioEditComponent:onClickShare()
	local studioUid = self.selectedStudioUid

	if not studioUid then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PHOTO_DOWNLOAD_TEMPLATE, {
		isPhotographyStudioShare = true,
		templateInfo = self:buildShareTemplateInfo(studioUid)
	})
end

function PhotoStudioEditComponent:buildShareTemplateInfo(studioUid)
	local info = pg.me:getStudioInfo(studioUid) or {}
	local cachedContent = pg.me:getCachedPhotographyStudioContent(studioUid)
	local coverVersion = 0

	if type(cachedContent) == "table" then
		coverVersion = tonumber(cachedContent.coverVersion) or 0
	end

	return {
		id = studioUid,
		studioName = self:getStudioDisplayName(info),
		title = self:getStudioDisplayName(info),
		uid = info.masterUid,
		coverVersion = coverVersion
	}
end

return PhotoStudioEditComponent
