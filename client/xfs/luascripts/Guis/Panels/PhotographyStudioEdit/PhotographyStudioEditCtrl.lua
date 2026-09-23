-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\PhotographyStudioEditCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotographyStudioEditCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local StudioFuncMenuUIComponent = require("Guis.Panels.PhotographyStudioEdit.Component.StudioFuncMenuUIComponent")
local StudioPlacePetUIComponent = require("Guis.Panels.PhotographyStudioEdit.Component.StudioPlacePetUIComponent")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AppearanceVariableData = require("Data.appearance_variable_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientUtils = require("Utils.ClientUtils")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyStudioEditBIUtils = require("Utils.PhotographyStudioEditBIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PhotographyStudioEditCtrl = Class.LightClass("PhotographyStudioEditCtrl", UICtrl)
local EMPTY_TABLE = {}
local READONLY_EMPTY_TABLE = require("Core.Common.EmptyTable")
local STUDIO_SELECTED_OUTLINE_MATERIALS = {
	AddressDataConst.UI_SELECT_MODEL_2,
	AddressDataConst.UI_SELECT_MODEL
}
local STUDIO_SELECTED_ORNAMENT_OUTLINE_MATERIALS = {
	AddressDataConst.HOMELAND_OUTLINE_GREEN,
	AddressDataConst.HOMELAND_OUTLINE_BASE
}
local STUDIO_SELECTED_ORNAMENT_OUTLINE_NC_MATERIALS = {
	AddressDataConst.HOMELAND_OUTLINE_GREEN_NC,
	AddressDataConst.HOMELAND_OUTLINE_BASE_NC
}
local STUDIO_COVER_MAX_SIZE = 1280
local STUDIO_COVER_QUALITY = 90
local STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE = 3
local LOCAL_LENS_FIELDS = {
	"fov",
	"dof",
	"dofRange",
	"exposure",
	"saturation",
	"brightness",
	"contrast",
	"vignette",
	"rotate"
}
local COMMON_HISTORY_FIELDS = {
	"lightId",
	"lightValue",
	"customLightSlot",
	"customLightScheme",
	"filterId",
	"filterValue",
	"backgroundId",
	"ornaments",
	"diyInfo",
	"npcGazeType"
}
local PLAYER_HISTORY_FIELDS = {
	"playerPos",
	"playerRot",
	"playerPoseId",
	"visible",
	"gazeType",
	"gazePos",
	"pets"
}

local function getUidKey(uid)
	if uid == nil then
		return nil
	end

	return tostring(uid)
end

local function getStudioCoverResolution(texture)
	local sourceWidth = texture.width
	local sourceHeight = texture.height

	if sourceHeight <= sourceWidth then
		local height = math.max(1, math.floor(sourceHeight * STUDIO_COVER_MAX_SIZE / sourceWidth + 0.5))

		return STUDIO_COVER_MAX_SIZE, height
	end

	local width = math.max(1, math.floor(sourceWidth * STUDIO_COVER_MAX_SIZE / sourceHeight + 0.5))

	return width, STUDIO_COVER_MAX_SIZE
end

local function destroyStudioCoverTaskSprite(task)
	if task and task.coverSprite then
		pg.global.mobileCameraMgr:DestroySpriteTexture(task.coverSprite)

		task.coverSprite = nil
	end
end

local function copyVector3(value)
	if not value then
		return nil
	end

	return {
		x = value.x,
		y = value.y,
		z = value.z
	}
end

local function getPlayerSegment(players, uid)
	if type(players) ~= "table" then
		return nil
	end

	local segment = players[uid]

	if segment then
		return segment
	end

	return players[getUidKey(uid)]
end

local function setPlayerSegment(players, uid, playerData)
	local uidKey = getUidKey(uid)

	for existingUid in pairs(players) do
		if getUidKey(existingUid) == uidKey then
			players[existingUid] = nil

			break
		end
	end

	players[uid] = playerData
end

local function copyFields(source, target, fields)
	if type(source) ~= "table" then
		return
	end

	for _, field in ipairs(fields) do
		target[field] = source[field]
	end
end

local function copyHistoryValue(value)
	if type(value) == "table" then
		return Utils.deepCopyTable(value)
	end

	return value
end

local function captureHistoryFields(source, fields)
	local result = {}

	if type(source) ~= "table" then
		return result
	end

	for _, field in ipairs(fields) do
		result[field] = copyHistoryValue(source[field])
	end

	return result
end

local function applyHistoryFields(source, target, fields)
	for _, field in ipairs(fields) do
		target[field] = copyHistoryValue(source[field])
	end
end

PhotographyStudioEditCtrl.moveSpeedRate = 3
PhotographyStudioEditCtrl.mouseLookPixelRate = 30
PhotographyStudioEditCtrl.mobileLookPixelRate = 60
PhotographyStudioEditCtrl.gamepadLookYawRate = 90
PhotographyStudioEditCtrl.gamepadLookPitchRate = 67.5
PhotographyStudioEditCtrl.messages = {
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onStudioMemberChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CONTENT_CHANGED] = {
		"onStudioContentChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_ACTIVE_MEMBERS_CHANGED] = {
		"onStudioActiveMembersChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_INVITATIONS_CHANGED] = {
		"onStudioInvitationsChanged",
		true
	},
	[MessageName.PHOTO_ASSET_UNLOCK_CHANGED] = {
		"onPhotoAssetUnlockChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PhotographyStudioEditCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.studioUid = info.studioUid
	self.isMaster = self.studioUid ~= nil and pg.me:isStudioMaster(self.studioUid)
	self.isMobilePlatform = pg.global.ui:runPlatformByMobile()
	self.switchStudioCb = info.switchStudioCb
	self.moveX, self.moveY, self.moveZ = 0, 0, 0
	self.gamepadLookX, self.gamepadLookY = 0, 0
	self.isLeftShoulderPressed = false
	self.mouseLookActive = false
	self.lastTakePhotoTime = 0
	self.takePhotoInterval = 1000
	self.historyInitialized = false
	self.cameraWasMoving = false
	self.saveRequestSerial = 0
	self.coverCaptureSerial = 0
	self.coverUploadInProgress = false
	self.ornamentEditing = false
	self.pendingSyncCoverTask = nil

	local studioInfo = self.studioUid and pg.me:getStudioInfo(self.studioUid)

	self.studioEditSlotId = studioInfo and studioInfo.slotId or 0
	self.studioEditInfo = type(studioInfo) == "table" and Utils.deepCopyTable(studioInfo) or nil
	self.studioEditLogReported = false

	local emitter = pg.global.eventEmitter

	if emitter and emitter.addEventListener then
		self._platformPrivacyEventEmitter = emitter

		function self._platformPrivacyChangedListener()
			self:onPlatformPrivacyChanged()
		end

		emitter:addEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self._platformPrivacyChangedListener)
		emitter:addEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, self._platformPrivacyChangedListener)
	end

	pg.global.ui:open(UIConst.UI_ID_PHOTO_LOGO)
end

function PhotographyStudioEditCtrl:getAvatarScene()
	return pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function PhotographyStudioEditCtrl:setPhotoLightDiyUIHidden(hidden)
	if hidden then
		if self.photoLightDiyUIHidden then
			return
		end

		self.photoLightDiyUIHidden = true
		self.photoLightDiyRootOpacity = self.view.rootComponent.renderOpacity
		self.photoLightDiyLogoVisible = pg.global.ui:checkUIVisible(UIConst.UI_ID_PHOTO_LOGO) == true
		self.view.rootComponent.renderOpacity = 0

		if self.photoLightDiyLogoVisible then
			pg.global.ui:hide(UIConst.UI_ID_PHOTO_LOGO)
		end

		return
	end

	if not self.photoLightDiyUIHidden then
		return
	end

	self.photoLightDiyUIHidden = false
	self.view.rootComponent.renderOpacity = self.photoLightDiyRootOpacity
	self.photoLightDiyRootOpacity = nil

	local logoWasVisible = self.photoLightDiyLogoVisible

	self.photoLightDiyLogoVisible = nil

	if logoWasVisible and pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LOGO) then
		pg.global.ui:show(UIConst.UI_ID_PHOTO_LOGO)
	end
end

function PhotographyStudioEditCtrl:closePhotoLightDiy()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LIGHT_DIY) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_PHOTO_LIGHT_DIY)
	end

	self:setPhotoLightDiyUIHidden(false)
end

function PhotographyStudioEditCtrl:setStudioEditSavedContent(content)
	if type(content) == "table" then
		self.studioEditSavedContent = Utils.deepCopyTable(content)
	end
end

function PhotographyStudioEditCtrl:mergeStudioEditSavedContent(content)
	if type(content) ~= "table" or type(content.players) ~= "table" then
		return
	end

	local mergedContent

	if type(self.studioEditSavedContent) == "table" then
		mergedContent = Utils.deepCopyTable(self.studioEditSavedContent)
	else
		mergedContent = {}
	end

	if type(mergedContent.players) ~= "table" then
		mergedContent.players = {}
	end

	for uid, playerData in pairs(content.players) do
		mergedContent.players[uid] = Utils.deepCopyTable(playerData)
	end

	self.studioEditSavedContent = mergedContent
end

function PhotographyStudioEditCtrl:sendStudioEditLog()
	if self.studioEditLogReported then
		return
	end

	self.studioEditLogReported = true

	local studioInfo = pg.me:getStudioInfo(self.studioUid)

	if type(studioInfo) ~= "table" then
		studioInfo = self.studioEditInfo
	end

	local editStartTime = self.studioEditStartTime or Time.realSecondCache
	local editTime = math.max(0, math.floor(Time.realSecondCache - editStartTime))
	local logData = PhotographyStudioEditBIUtils.buildLogData(self.studioEditSavedContent, studioInfo, {
		studioId = self.studioEditSlotId,
		studioIdentity = self.isMaster and 1 or 2,
		duration = editTime
	})

	LuaUIUtils.sendCustomLog(Const.BILogName.STUDIO_EDIT, logData)
end

function PhotographyStudioEditCtrl:getStudioCamera()
	local scene = self:getAvatarScene()

	return scene and scene.camera
end

function PhotographyStudioEditCtrl:getStudioFreeCameraMode()
	local scene = self:getAvatarScene()

	return scene and scene.studioFreeCameraMode
end

function PhotographyStudioEditCtrl:getPlacePetUIRoot()
	return self.funcMenu and self.funcMenu.petPoseRootRectTransform
end

function PhotographyStudioEditCtrl:getStudioSelfEntity()
	local scene = self:getAvatarScene()

	return scene and scene:getCurEntity()
end

function PhotographyStudioEditCtrl:getStudioEntityRoot()
	local scene = self:getAvatarScene()

	return scene and scene.entityRootTransform
end

function PhotographyStudioEditCtrl:getStudioSelectableEntities()
	local scene = self:getAvatarScene()

	return scene and scene:getStudioSelectableEntities() or {}
end

function PhotographyStudioEditCtrl:canOperateStudioEntity(entity)
	if not entity then
		return false
	end

	if self.funcMenu and self.funcMenu.isStudioPlayerEntityVisible then
		local playerVisible = self.funcMenu:isStudioPlayerEntityVisible(entity)

		if playerVisible == false then
			return false
		end
	end

	if self.funcMenu and self.funcMenu.isStudioPetEntityVisible then
		local petVisible = self.funcMenu:isStudioPetEntityVisible(entity)

		if petVisible == false then
			return false
		end
	end

	if entity == self:getStudioSelfEntity() then
		return true
	end

	if self.isMaster then
		return true
	end

	local ownerUid = entity.getOwnerUid and entity:getOwnerUid()

	return ownerUid ~= nil and getUidKey(ownerUid) == getUidKey(pg.me.uid)
end

function PhotographyStudioEditCtrl:refreshPlaceHotspots()
	if self.placePetComp then
		self.placePetComp:refreshHotspots()
	end
end

function PhotographyStudioEditCtrl:selectStudioEntity(entity)
	if entity and not self:canOperateStudioEntity(entity) then
		return
	end

	local previousEntity = self.placePetComp and self.placePetComp:getSelectedEntity()

	if previousEntity and previousEntity ~= entity then
		self:setStudioEntityOutline(previousEntity, false)
	end

	if self.placePetComp then
		self.placePetComp:selectEntity(entity)
	end

	if entity then
		self:setStudioEntityOutline(entity, true)

		self.selectedOutlineModelLoaded = entity.eModel ~= nil and entity.eModel.isModelLoaded == true
	else
		self.selectedOutlineModelLoaded = false
		self.selectedOutlineMeshCompressedState = nil
	end

	if self.funcMenu and self.funcMenu.onStudioEntitySelected then
		self.funcMenu:onStudioEntitySelected(entity)
	end

	self:refreshOrnamentMakeState(entity)
end

function PhotographyStudioEditCtrl:clearSelectedStudioCharacterOrPet()
	local entity = self.placePetComp and self.placePetComp:getSelectedEntity()

	if not entity or entity.studioOrnamentId then
		return false
	end

	self:selectStudioEntity(nil)

	return true
end

function PhotographyStudioEditCtrl:setStudioEntityOutline(entity, visible)
	local scene = self:getAvatarScene()

	if not visible and scene then
		scene:setStudioOutlineVolumeActive(false)
	end

	if not entity or not entity.eModel then
		return false
	end

	local shaderView = entity.eModel.shaderView

	if IsNil(shaderView) then
		return false
	end

	if visible then
		local outlineMaterials = STUDIO_SELECTED_OUTLINE_MATERIALS

		if entity.studioOrnamentId then
			self.selectedOutlineMeshCompressedState = shaderView:GetMeshCompressedState()

			if self.selectedOutlineMeshCompressedState == 0 then
				outlineMaterials = STUDIO_SELECTED_ORNAMENT_OUTLINE_NC_MATERIALS
			else
				outlineMaterials = STUDIO_SELECTED_ORNAMENT_OUTLINE_MATERIALS
			end
		else
			self.selectedOutlineMeshCompressedState = nil
		end

		shaderView:ChangeEffectMaterial(outlineMaterials)

		if scene then
			scene:setStudioOutlineVolumeActive(true)
		end
	else
		shaderView:ResetMaterial()

		self.selectedOutlineMeshCompressedState = nil
	end

	return true
end

function PhotographyStudioEditCtrl:refreshSelectedStudioEntityOutline()
	if not self.placePetComp then
		return
	end

	local entity = self.placePetComp:getSelectedEntity()

	if not entity or not entity.eModel then
		self.selectedOutlineModelLoaded = false
		self.selectedOutlineMeshCompressedState = nil

		return
	end

	local isModelLoaded = entity.eModel.isModelLoaded == true
	local outlineNeedsRefresh = isModelLoaded and not self.selectedOutlineModelLoaded

	if entity.studioOrnamentId and not IsNil(entity.eModel.shaderView) then
		local meshCompressedState = entity.eModel.shaderView:GetMeshCompressedState()

		if meshCompressedState ~= -1 and meshCompressedState ~= self.selectedOutlineMeshCompressedState then
			outlineNeedsRefresh = true
		end
	end

	if outlineNeedsRefresh and not self.isStudioCapturing then
		self:setStudioEntityOutline(entity, true)
	end

	self.selectedOutlineModelLoaded = isModelLoaded
end

function PhotographyStudioEditCtrl:refreshOrnamentMakeState(entity)
	local isOrnament = entity ~= nil and entity.studioOrnamentId ~= nil
	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()
	local isPreview = isOrnament and ornament and ornament:isPreviewOrnament(entity) or false

	self.view.widget:TryChangePage("Make", isOrnament and 1 or 0)
	self.view.btnOKUButton:SetActive(isPreview)
	self.view.btnRecycleUButton:SetActive(isOrnament and not isPreview)
end

function PhotographyStudioEditCtrl:isOrnamentEditing()
	return self.ornamentEditing == true
end

function PhotographyStudioEditCtrl:enterOrnamentEdit(entity)
	if not entity or not entity.studioOrnamentId then
		return
	end

	self.ornamentEditing = true

	self:selectStudioEntity(entity)

	if self.funcMenu and self.funcMenu.setOrnamentEditingInputBlocked then
		self.funcMenu:setOrnamentEditingInputBlocked(true)
	end

	if self.placePetComp and self.placePetComp.refreshSelectedEntityUI then
		self.placePetComp:refreshSelectedEntityUI()
		self.placePetComp:setOrnamentEditingModalActive(true)
	end

	self:refreshOrnamentConsoleBarState()
end

function PhotographyStudioEditCtrl:exitOrnamentEdit(restoreFocus)
	if not self.ornamentEditing then
		return
	end

	self:flushPendingHistoryStep()

	if self.placePetComp then
		self.placePetComp:setOrnamentEditingModalActive(false)
	end

	self.ornamentEditing = false

	if self.funcMenu and self.funcMenu.setOrnamentEditingInputBlocked then
		self.funcMenu:setOrnamentEditingInputBlocked(false)
	end

	local entity = self:getSelectedStudioOrnament()

	self:refreshOrnamentMakeState(entity)

	if self.placePetComp and self.placePetComp.refreshSelectedEntityUI then
		self.placePetComp:refreshSelectedEntityUI()
	end

	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

	if ornament and ornament.onOrnamentEditExited then
		ornament:onOrnamentEditExited(restoreFocus)
	end

	self:refreshLeftConsoleBarState()
end

function PhotographyStudioEditCtrl:getSelectedStudioOrnament()
	if not self.placePetComp then
		return nil
	end

	local entity = self.placePetComp:getSelectedEntity()

	if entity and entity.studioOrnamentId then
		return entity
	end

	return nil
end

function PhotographyStudioEditCtrl:onClickConfirmOrnament()
	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

	if ornament and ornament.commitPreviewOrnament then
		ornament:commitPreviewOrnament()
	end
end

function PhotographyStudioEditCtrl:onClickRecycleOrnament()
	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

	if ornament and ornament.deleteFocusedOrnament and ornament:deleteFocusedOrnament() then
		return
	end

	local entity = self:getSelectedStudioOrnament()

	if not entity then
		return
	end

	self:flushPendingHistoryStep()

	local scene = self:getAvatarScene()

	if not scene or not scene:removeStudioOrnament(entity.studioOrnamentId) then
		return
	end

	self:exitOrnamentEdit(false)
	self:selectStudioEntity(nil)
	self:refreshPlaceHotspots()
	self:recordStudioHistoryStep("ornament_remove")
end

function PhotographyStudioEditCtrl:placeStudioEntityAtScreenCenter(entityId)
	local scene = self:getAvatarScene()
	local camera = self:getStudioCamera()
	local mode = self:getStudioFreeCameraMode()
	local root = self:getStudioEntityRoot()

	if not scene or IsNil(camera) or not mode or IsNil(root) then
		return
	end

	local planeY = 0
	local selfEntity = self:getStudioSelfEntity()

	if selfEntity and selfEntity.eModel then
		local _, wy = selfEntity.eModel:GetPositionAgentPosEx()

		planeY = wy or 0
	end

	local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
	local valid, worldPos = mode:getPlanePos(camera, screenCenter, planeY)
	local cameraTransform = camera.transform
	local cameraPos = cameraTransform.position
	local targetWorldX, targetWorldZ

	if valid then
		targetWorldX, targetWorldZ = worldPos.x, worldPos.z
	else
		local horizontalForward = Quaternion.Euler(0, cameraTransform.eulerAngles.y, 0) * Vector3.forward

		targetWorldX = cameraPos.x + horizontalForward.x * STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE
		targetWorldZ = cameraPos.z + horizontalForward.z * STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE
	end

	local dx, dz = targetWorldX - cameraPos.x, targetWorldZ - cameraPos.z
	local cameraDistSq = dx * dx + dz * dz
	local maxCameraDistSq = STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE * STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE

	if maxCameraDistSq < cameraDistSq then
		local scale = STUDIO_ENTITY_SPAWN_CAMERA_DISTANCE / math.sqrt(cameraDistSq)

		targetWorldX = cameraPos.x + dx * scale
		targetWorldZ = cameraPos.z + dz * scale
	end

	local localPos = root:InverseTransformPoint(Vector3(targetWorldX, planeY, targetWorldZ))
	local lx, ly, lz = localPos.x, localPos.y, localPos.z
	local r = AppearanceVariableData.STUDIO_CHARACTER_ADJUST
	local distSq = lx * lx + lz * lz

	if distSq > r * r then
		local s = r / math.sqrt(distSq)

		lx, lz = lx * s, lz * s
	end

	scene:setStudioEntityLocalPos(entityId, Vector3(lx, ly, lz))
end

function PhotographyStudioEditCtrl:placeStudioPetAtScreenCenter(petId)
	local scene = self:getAvatarScene()

	if not scene then
		return
	end

	local entityId = scene:getStudioPetEntityId(petId)

	if entityId then
		self:placeStudioEntityAtScreenCenter(entityId)
	end
end

function PhotographyStudioEditCtrl:onStudioMemberChanged()
	if not pg.me:getStudioInfo(self.studioUid) then
		self:close()

		return
	end

	if self.funcMenu and self.funcMenu.enforceStudioPetQuota then
		self.funcMenu:enforceStudioPetQuota()
	end

	if self.funcMenu then
		self.funcMenu:refreshStudioMode()
	end

	if self.funcMenu and self.funcMenu.refreshStudioPlayerList then
		self.funcMenu:refreshStudioPlayerList()
	end

	self:refreshPlaceHotspots()
	self:refreshInviteNum()
end

function PhotographyStudioEditCtrl:buildRemotePlayerMergedContent(scene, fullContent, changedPlayers)
	if type(fullContent) ~= "table" or type(changedPlayers) ~= "table" then
		return nil, nil
	end

	local content

	if self.isMaster then
		content = self:gatherContent(scene)
	else
		content = Utils.deepCopyTable(fullContent)

		if type(content.players) ~= "table" then
			content.players = {}
		end

		local localContent = self:gatherPlayerContent(scene)

		for uid, playerData in pairs(localContent.players) do
			setPlayerSegment(content.players, uid, playerData)
		end
	end

	if type(content.players) ~= "table" then
		content.players = {}
	end

	local fullPlayers = fullContent.players
	local changedFullPlayers = {}

	for uid in pairs(changedPlayers) do
		local playerData = getPlayerSegment(fullPlayers, uid)

		if type(playerData) == "table" then
			setPlayerSegment(content.players, uid, Utils.deepCopyTable(playerData))

			changedFullPlayers[uid] = playerData
		end
	end

	return content, changedFullPlayers
end

function PhotographyStudioEditCtrl:buildChangedPlayerUidSet(previousContent, fullContent, candidatePlayers)
	local changedPlayerUidSet = {}

	if type(candidatePlayers) ~= "table" then
		return changedPlayerUidSet
	end

	local previousPlayers = type(previousContent) == "table" and previousContent.players
	local fullPlayers = type(fullContent) == "table" and fullContent.players

	for uid in pairs(candidatePlayers) do
		local previousPlayer = getPlayerSegment(previousPlayers, uid)
		local currentPlayer = getPlayerSegment(fullPlayers, uid)

		if not Utils.isTableEqual(previousPlayer, currentPlayer) then
			changedPlayerUidSet[uid] = true
		end
	end

	return changedPlayerUidSet
end

function PhotographyStudioEditCtrl:onStudioContentChanged(data)
	if type(data) ~= "table" or getUidKey(data.studioUid) ~= getUidKey(self.studioUid) then
		return
	end

	local changedContent = data.changedContent

	if type(changedContent) == "table" and changedContent.coverVersion ~= nil then
		local coverOnly = true

		for key in pairs(changedContent) do
			if key ~= "coverImageId" and key ~= "coverVersion" then
				coverOnly = false

				break
			end
		end

		if coverOnly then
			return
		end
	end

	local changedPlayers

	if type(changedContent) == "table" then
		changedPlayers = self:buildChangedPlayerUidSet(self.studioEditSavedContent, data.content, changedContent.players)
	end

	self:setStudioEditSavedContent(data.content)

	local isSelfSender = getUidKey(data.senderUid) == getUidKey(pg.me.uid)
	local isRemotePlayerIncremental = not isSelfSender and type(changedContent) == "table" and type(changedContent.players) == "table" and type(changedContent.common) ~= "table"

	if isRemotePlayerIncremental then
		self:flushPendingHistoryStep()

		local scene = self:getAvatarScene()

		if not scene then
			return
		end

		local mergedContent, changedFullPlayers = self:buildRemotePlayerMergedContent(scene, data.content, changedContent.players)

		if not mergedContent then
			return
		end

		self.model.isApplyingHistory = true

		local ok, err = xpcall(function()
			self:applySyncedStudioContent(mergedContent, true, false, changedPlayers)
		end, debug.traceback)

		self.model.isApplyingHistory = false

		if not ok then
			logger:error("onStudioContentChanged apply remote player incremental failed", err)

			return
		end

		if self.isMaster then
			self.model:mergeRemotePlayerHistory(self:capturePlayerHistoryState(changedFullPlayers))
		end

		self:refreshHistoryButtonState()

		return
	end

	if isSelfSender and self.pendingSaveSnapshot then
		local currentSnapshot = self:captureStudioWorkingState()

		if not Utils.isTableEqual(currentSnapshot, self.pendingSaveSnapshot) then
			self.model:markHistorySaved(self.pendingSaveSnapshot)

			self.pendingSaveSnapshot = nil
			self.pendingSaveSerial = nil

			return
		end
	end

	if not isSelfSender then
		self.pendingSaveSnapshot = nil
		self.pendingSaveSerial = nil

		self:cancelPendingHistoryStep()
	end

	self.model.isApplyingHistory = true

	local ok, err = xpcall(function()
		local applyCommon = type(changedContent) ~= "table" or type(changedContent.common) == "table"
		local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()
		local preserveOrnamentPreview = isSelfSender and ornament and ornament:hasPreviewOrnament() or false

		self:applySyncedStudioContent(data.content, true, applyCommon, changedPlayers, preserveOrnamentPreview)
	end, debug.traceback)

	self.model.isApplyingHistory = false

	if not ok then
		logger:error("onStudioContentChanged failed", err)

		return
	end

	if not isSelfSender then
		self:initStudioHistory()
	elseif self.pendingSaveSnapshot then
		self.model:replaceCurrentHistorySnapshot(self:captureStudioWorkingState())
		self.model:markHistorySaved(self.pendingSaveSnapshot)

		self.pendingSaveSnapshot = nil
		self.pendingSaveSerial = nil
	end
end

function PhotographyStudioEditCtrl:applySyncedStudioContent(content, preserveLocalCamera, applyCommon, changedPlayers, preserveOrnamentPreview)
	if type(content) ~= "table" then
		return
	end

	local scene = self:getAvatarScene()

	if not scene then
		return
	end

	self:selectStudioEntity(nil)

	local common = type(content.common) == "table" and content.common or EMPTY_TABLE
	local players = type(content.players) == "table" and content.players or EMPTY_TABLE

	if applyCommon == nil then
		applyCommon = not preserveLocalCamera
	end

	if applyCommon then
		local bgRes, bgId = AvatarUtils.getPhotographyStudioBackgroundRes(common.backgroundId)

		scene:setBackground(bgRes, bgId)
	end

	local selfUid = pg.me.uid
	local selfUidKey = getUidKey(selfUid)
	local selfData = players[selfUid]

	selfData = selfData or players[selfUidKey]

	local selfEntityId = scene:getCurEntityId()

	if selfEntityId then
		if selfData then
			scene:setStudioEntityLocalPos(selfEntityId, selfData.playerPos)
			scene:setStudioEntityLocalRotY(selfEntityId, selfData.playerRot and selfData.playerRot.y)
		end

		local playerPoseId = selfData and selfData.playerPoseId or common.playerPoseId
		local selfEntity = scene:getEntity(selfEntityId)

		if not selfEntity or selfEntity.studioPlayerPoseId ~= playerPoseId then
			scene:applyStudioPlayerPose(selfEntityId, playerPoseId)
		end

		scene:applyStudioPlayerGaze(selfEntityId, selfData and selfData.gazeType or common.gazeType, selfData and selfData.gazePos or common.gazePos)
		scene:setStudioPlayerVisible(selfEntityId, not selfData or selfData.visible ~= false)
	end

	local memberSet = scene:getPhotographyStudioMemberSet(self.studioUid)
	local masterUid = content.masterUid

	if masterUid == nil then
		masterUid = pg.me:getStudioMasterUid(self.studioUid)
	end

	local masterUidKey = getUidKey(masterUid)
	local refreshUidSet

	if type(changedPlayers) == "table" then
		refreshUidSet = {}

		for uid in pairs(changedPlayers) do
			local uidKey = getUidKey(uid)

			if uidKey then
				refreshUidSet[uidKey] = true
			end
		end
	end

	local studioPlayers = {}

	for uid, playerData in pairs(players) do
		local uidKey = getUidKey(uid)

		if type(playerData) == "table" and uidKey ~= selfUidKey and memberSet[uidKey] then
			studioPlayers[#studioPlayers + 1] = {
				uid = uid,
				templateId = playerData.templateId,
				avatarPresetKey = playerData.avatarPresetKey,
				avatarConfig = playerData.avatarConfig,
				curShow = playerData.curShow,
				jewelryLastInfos = playerData.jewelryLastInfos,
				model = playerData.model,
				appearance = playerData.appearance,
				pos = playerData.playerPos,
				rot = playerData.playerRot and playerData.playerRot.y,
				playerPoseId = playerData.playerPoseId,
				gazeType = playerData.gazeType or common.gazeType,
				gazePos = playerData.gazePos or common.gazePos,
				visible = playerData.visible
			}
		end
	end

	scene:syncStudioPlayers(studioPlayers, function(entity)
		if scene.studioFreeCameraMode and getUidKey(entity.studioPlayerUid) == masterUidKey and entity.eModel then
			scene.studioFreeCameraMode:initPhotoCamera(scene.camera, entity.eModel.transform)
			scene:applyStudioCameraCommon(common)
		end

		self:refreshPlaceHotspots()

		if self.funcMenu and self.funcMenu.refreshStudioPlayerList then
			self.funcMenu:refreshStudioPlayerList()
		end
	end, refreshUidSet)

	if self.funcMenu and self.funcMenu.refreshStudioPlayerList then
		self.funcMenu:refreshStudioPlayerList()
	end

	if not preserveLocalCamera then
		if common.cameraPos and common.cameraRot then
			scene:setStudioFreeCameraPose(common.cameraPos, common.cameraRot)
		else
			scene:resetStudioFreeCameraToDefault()
		end
	end

	if applyCommon then
		scene:applyStudioCameraCommon(common)
	end

	self:loadFuncMenuFromContent(content, applyCommon, refreshUidSet, preserveOrnamentPreview)
	self:refreshPlaceHotspots()

	if preserveOrnamentPreview then
		local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

		if ornament then
			ornament:selectPreviewOrnament()
		end
	end
end

function PhotographyStudioEditCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.studioEditStartTime = Time.realSecondCache

	self:setStudioEditSavedContent(pg.me:getCachedPhotographyStudioContent(self.studioUid))

	if self.view.cameraMenuPanelUComponent then
		self.funcMenu = StudioFuncMenuUIComponent.new(self, self.view.cameraMenuPanelUComponent.transform)

		self:loadFuncMenuFromContent()
	end

	self:addListener()
	self:refreshUI()

	self.placePetComp = StudioPlacePetUIComponent.new(self)

	if self.funcMenu and self.funcMenu.curSelectTab == self.funcMenu.Funcs.PlayerPose then
		self.funcMenu:refreshStudioPlayerList(true)
	end

	self:refreshPlaceHotspots()

	if self.funcMenu and not self.funcUpdateTimer then
		self.funcUpdateTimer = self:startTimer(function()
			if self.funcMenu then
				self.funcMenu:update()
			end

			self:refreshSelectedStudioEntityOutline()
		end, 0.1, true)
	end

	self:initStudioHistory()
	pg.me:enterPhotographyStudioEdit(self.studioUid)

	self.hasEnteredPhotographyStudio = true
end

function PhotographyStudioEditCtrl:onShow()
	local camera = self:getStudioCamera()

	if camera then
		pg.global.cameraMgr:SetUISceneCamera(camera)
	end

	self:enableCameraControl(true)

	if self.funcMenu then
		self.funcMenu:setInputStateEnabled(true)
	end

	self:refreshLeftConsoleBarState()
end

function PhotographyStudioEditCtrl:onHide()
	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

	if ornament and ornament.onDeselected then
		ornament:onDeselected()
	end

	self:resetGamepadInput(true)

	if self.funcMenu then
		self.funcMenu:setInputStateEnabled(false)
	end

	self:enableCameraControl(false)
	self:clearLeftConsoleBarState()
	pg.global.cameraMgr:ClearUISceneCamera()
end

function PhotographyStudioEditCtrl:requestClose()
	if not self:hasUnsavedChanges() then
		self:close()

		return
	end

	PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.Unsaved, pg.getGameString("PHOTO_STUDIO_UNSAVED_TITLE"), pg.getGameString("PHOTO_STUDIO_UNSAVED_EXIT_DESC"), function()
		self:close()
	end)
end

function PhotographyStudioEditCtrl:addListener()
	local closeBtn = self.view.btnBackMainUButton or self.view.closeBtn

	if closeBtn then
		function closeBtn.luaClick()
			self:requestClose()
		end
	end

	self.view.btnBackMainUButton:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadCancel, self.view.backKeyHotkeyContent.GameObject)
	self.view.btnBackMainUButton:SetHotkeyBypassModalBlocking(true)

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = -1
	closeCommonBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.ClosePanelCommon

	function closeCommonBind.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if inputInfo.phase == "Performed" then
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:closePanel(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			local buttonPoppingUpTooltip = pg.global.inputMgr:GetButtonPoppingUpToolTip()

			if buttonPoppingUpTooltip then
				buttonPoppingUpTooltip:ClosePopup()
			else
				self:requestClose()
			end
		end
	end

	if self.view.btnSaveUButton then
		function self.view.btnSaveUButton.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self:onClickSave()
		end
	end

	if self.view.btnUndoUButton then
		function self.view.btnUndoUButton.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self:onClickUndo()
		end
	end

	if self.view.btnRedoUButton then
		function self.view.btnRedoUButton.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self:onClickRedo()
		end
	end

	function self.view.btnOKUButton.luaClick()
		self:onClickConfirmOrnament()
	end

	function self.view.btnRecycleUButton.luaClick()
		self:onClickRecycleOrnament()
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect, function()
		if not pg.game.input:isUsingGamepad() or self:isOrnamentEditing() then
			return true
		end

		local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

		if ornament and ornament:isOrnamentItemFocused() then
			return not ornament:editFocusedOrnament()
		end

		return true
	end, self.view.widget.gameObject, "StudioOrnamentEdit")

	if self.view.takePhotoBtn then
		function self.view.takePhotoBtn.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self:takePhoto()
		end
	end

	self:bindHotKeyPerform("Photo/Space", function()
		self:takePhoto()

		return true
	end)

	function self.view.btnInviteUButton.luaClick()
		if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_PHOTOGRAPHY_INVITE, {
			studioUid = self.studioUid,
			isMaster = self.isMaster,
			switchStudioCb = self.switchStudioCb
		})
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITE_ROOT, self.view.btnInviteUButton, function()
		local invitedCount = pg.me:getUnreadPhotographyStudioInvitationCount()

		if invitedCount > 0 then
			return RedDotConst.RedDotStyle.NUM
		end

		if self.isMaster and pg.me:getUnreadPhotographyStudioAcceptedInviteCount(self.studioUid) > 0 then
			return RedDotConst.RedDotStyle.NEW
		end

		return RedDotConst.RedDotStyle.NONE
	end, function()
		return pg.me:getUnreadPhotographyStudioInvitationCount()
	end)

	function self.view.btnMulEditUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.PHOTOGRAPH_INVITE_INFO)
	end

	if self.view.btnMenuUButton and self.funcMenu then
		function self.view.btnMenuUButton.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self.funcMenu:openMenu()
		end
	end

	if self.view.btnPoseUButton and self.funcMenu then
		function self.view.btnPoseUButton.luaClick()
			if pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
				return
			end

			self.funcMenu:openMenuAt(self.funcMenu.Funcs.PlayerPose)
		end
	end

	local bgClickUButton = self.view.bgClickUButton

	bgClickUButton.luaClick = nil

	function bgClickUButton.luaClickWithEventData(eventData)
		if self.placePetComp and self.placePetComp:selectEntityAtScreenPosition(eventData.position) then
			return
		end

		self:onClickBackground()
	end

	function bgClickUButton.luaBeginDrag(screenPos)
		self.studioEntityPointerDragging = self.placePetComp and self.placePetComp:onDragStart(screenPos) == true
	end

	function bgClickUButton.luaDrag(screenPos)
		if self.studioEntityPointerDragging and self.placePetComp then
			self.placePetComp:onDragUpdate(screenPos)
		end
	end

	function bgClickUButton.luaEndDrag(screenPos)
		if not self.studioEntityPointerDragging or not self.placePetComp then
			return
		end

		self.placePetComp:onDragEnd(screenPos)

		self.studioEntityPointerDragging = false
	end

	local mobileCameraCtrlUButton = self.view.mobileCameraCtrlUButton

	if self.isMobilePlatform then
		mobileCameraCtrlUButton.enabledDraggingClick = false
		mobileCameraCtrlUButton.draggable = true
		mobileCameraCtrlUButton.luaClick = nil

		function mobileCameraCtrlUButton.luaClickWithEventData(eventData)
			if self.placePetComp and self.placePetComp:selectEntityAtScreenPosition(eventData.position) then
				return
			end

			self:onClickBackground()
		end

		function mobileCameraCtrlUButton.luaBeginDrag(screenPos)
			local placePetComp = self.placePetComp

			self.studioEntityPointerDragging = placePetComp ~= nil and placePetComp:selectEntityAtScreenPosition(screenPos) and placePetComp:onDragStart(screenPos) == true
		end

		function mobileCameraCtrlUButton.luaDrag(screenPos)
			if self.studioEntityPointerDragging and self.placePetComp then
				self.placePetComp:onDragUpdate(screenPos)
			end
		end

		function mobileCameraCtrlUButton.luaEndDrag(_, _, screenPos)
			if not self.studioEntityPointerDragging or not self.placePetComp then
				return
			end

			self.placePetComp:onDragEnd(screenPos)

			self.studioEntityPointerDragging = false
		end
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT, function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		self:onLensScroll(true)
	end, function()
		if not self:isGamepadCameraInputEnabled() then
			return true
		end

		self:onLensScroll(true)
	end)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT, function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		self:onLensScroll(false)
	end, function()
		if not self:isGamepadCameraInputEnabled() then
			return true
		end

		self:onLensScroll(false)
	end)
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
	self:bindGamepadCameraControl()
	self:bindMobileCameraControl()
end

function PhotographyStudioEditCtrl:onStudioInvitationsChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITE_ROOT)
end

function PhotographyStudioEditCtrl:onPlatformPrivacyChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITE_ROOT)
end

function PhotographyStudioEditCtrl:onPhotoAssetUnlockChanged()
	if self.funcMenu then
		self.funcMenu:onPhotoAssetUnlockChanged()
	end
end

function PhotographyStudioEditCtrl:onInputDeviceChanged(deviceType)
	self:resetGamepadInput(true)

	if not pg.game.input:isUsingGamepad() and self:isOrnamentEditing() then
		self:exitOrnamentEdit(false)
	end

	if self.funcMenu then
		self.funcMenu:onInputDeviceChanged(deviceType)
	end

	self:refreshLeftConsoleBarState()
end

function PhotographyStudioEditCtrl:resetStudioEntityGamepadInput(recordHistory)
	if self.placePetComp and self.placePetComp.resetGamepadInput then
		self.placePetComp:resetGamepadInput(recordHistory)
	end
end

function PhotographyStudioEditCtrl:resetGamepadInput(recordHistory)
	self.moveX, self.moveY, self.moveZ = 0, 0, 0
	self.gamepadLookX, self.gamepadLookY = 0, 0
	self.isLeftShoulderPressed = false

	local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

	if photoProcessor then
		photoProcessor:reset()
	end

	self:resetStudioEntityGamepadInput(recordHistory)
end

function PhotographyStudioEditCtrl:onStudioMenuInputStateChanged(shouldBlock)
	self:resetGamepadInput(true)
	self:refreshCanMoveCameraState()

	if self.funcMenu then
		self.funcMenu:refreshDIYCanFocusStick()
	end
end

function PhotographyStudioEditCtrl:isFocusOnDIYFrame()
	local focused = pg.global.navMgr.CurrentFocusedUContent
	local diyRoot = self.funcMenu and self.funcMenu.dIYRootRectTransform

	if IsNil(focused) or IsNil(diyRoot) then
		return false
	end

	local transform = focused.transform

	while not IsNil(transform) do
		if transform == diyRoot then
			return true
		end

		transform = transform.parent
	end

	return false
end

function PhotographyStudioEditCtrl:isInGamepadModalGroup()
	return pg.game.input:isUsingGamepad() and pg.global.navMgr:IsInModalGroup()
end

function PhotographyStudioEditCtrl:isOrnamentFocusActive()
	if self:isOrnamentEditing() then
		return true
	end

	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()

	return ornament and ornament:isOrnamentItemFocused() or false
end

function PhotographyStudioEditCtrl:onNavFocusChange()
	if self.funcMenu and self.funcMenu.onOrnamentNavFocusChange then
		self.funcMenu:onOrnamentNavFocusChange()
	end

	local isInStick = self:isFocusOnDIYFrame()
	local isInModal = self:isInGamepadModalGroup()
	local isOrnamentEditing = self:isOrnamentEditing()

	self.view.keyLeftConsoleUWidget:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, isInModal and not self:isOrnamentEditing())
	pg.global.navMgr:SetConsoleBarState("FocusInStick", isInStick)
	pg.global.navMgr:SetConsoleBarState("CanExcuteOpenCloseMenu", false)

	if self.funcMenu then
		self.funcMenu:refreshDIYCanFocusStick()
	end

	self:refreshOrnamentConsoleBarState()
end

function PhotographyStudioEditCtrl:refreshCanMoveCameraState()
	local raised = self.funcMenu and self.funcMenu:isMenuRaised()

	pg.global.navMgr:SetConsoleBarState("CanMoveCamera", not raised and not self:isOrnamentEditing())
end

function PhotographyStudioEditCtrl:refreshOrnamentConsoleBarState()
	local editing = self:isOrnamentEditing()
	local ornament = self.funcMenu and self.funcMenu:getOrnamentComponent()
	local focusedPlaced = ornament and ornament:isFocusedOrnamentPlaced() or false

	pg.global.navMgr:SetConsoleBarState("CanDeleteOrnament", editing)
	pg.global.navMgr:SetConsoleBarState("CanEditOrnament", not editing and focusedPlaced)
	pg.global.navMgr:SetConsoleBarState("NotInOrnamentEditing", not editing)

	if editing then
		pg.global.navMgr:SetConsoleBarState("NotInFollowMode", false)
	end
end

function PhotographyStudioEditCtrl:refreshLeftConsoleBarState()
	pg.global.navMgr:SetConsoleBarState("NotInFollowMode", true)
	self:onNavFocusChange()
	self:refreshCanMoveCameraState()
end

function PhotographyStudioEditCtrl:clearLeftConsoleBarState()
	self.view.keyLeftConsoleUWidget:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, false)
	pg.global.navMgr:SetConsoleBarState("FocusInStick", false)
	pg.global.navMgr:SetConsoleBarState("CanFocusStick", false)
	pg.global.navMgr:SetConsoleBarState("CanMoveCamera", false)
	pg.global.navMgr:SetConsoleBarState("CanExcuteOpenCloseMenu", false)
	pg.global.navMgr:SetConsoleBarState("NotInFollowMode", false)
	pg.global.navMgr:SetConsoleBarState("CanDeleteOrnament", false)
	pg.global.navMgr:SetConsoleBarState("CanEditOrnament", false)
	pg.global.navMgr:SetConsoleBarState("NotInOrnamentEditing", false)
end

function PhotographyStudioEditCtrl:bindMobileCameraControl()
	function self.view.joyStick.luaValueChangedWhileDragging()
		self:setJoyStickVisible(true)

		if self.view.joyStickArea.gameObject.activeInHierarchy then
			self.view.joyStick.transform:SetSiblingIndex(-1)
		end
	end

	function self.view.joyStick.luaValueChanged(x, y)
		if not self.cameraControlEnabled then
			return
		end

		self.moveX = x
		self.moveY = y
	end

	function self.view.joyStick.luaJoyStickEndDrag()
		self:setJoyStickVisible(false)

		if self.view.joyStickArea.gameObject.activeInHierarchy then
			self.view.boxSlider.transform:SetSiblingIndex(-1)
		end

		self.moveX = 0
		self.moveY = 0
	end

	function self.view.btnUpUButton.luaPress()
		if self.cameraControlEnabled then
			self.moveZ = 1
		end
	end

	function self.view.btnUpUButton.luaRelease()
		self.moveZ = 0
	end

	function self.view.btnDownUButton.luaPress()
		if self.cameraControlEnabled then
			self.moveZ = -1
		end
	end

	function self.view.btnDownUButton.luaRelease()
		self.moveZ = 0
	end

	function self.view.cameraCtrlDragUpdateListener.luaDragUpdate(x, y)
		if not self.isMobilePlatform or not self.cameraControlEnabled or self.placePetComp and self.placePetComp.isDragging then
			return
		end

		local scene = self:getAvatarScene()

		if scene then
			local lookX, lookY = pg.game.input:applyLookInversion(x, y)
			local rotateX, rotateY = self:getCameraRotateDelta(lookX, lookY)

			scene:rotateStudioFreeCamera(rotateX, rotateY)
		end
	end
end

function PhotographyStudioEditCtrl:setJoyStickVisible(visible)
	self.view.boxSlider.renderOpacity = visible and 0 or 1
	self.view.btnJS.renderOpacity = visible and 0 or 1
end

function PhotographyStudioEditCtrl:onClickBackground()
	self:selectStudioEntity(nil)

	if self.funcMenu then
		self.funcMenu:deselectAllDIY()
	end
end

function PhotographyStudioEditCtrl:refreshUI()
	self:refreshOrnamentMakeState(nil)
	self.view.btnUpUButton:SetActive(self.isMobilePlatform)
	self.view.btnDownUButton:SetActive(self.isMobilePlatform)
	self.view.keys:SetActive(not self.isMobilePlatform)

	if self.view.btnSaveUButton then
		self.view.btnSaveUButton:SetActive(true)
	end

	self.view.btnInviteUButton:SetActive(true)
	self:refreshInviteNum()
	self:refreshMultiEditState()
	self:refreshHistoryButtonState()
end

function PhotographyStudioEditCtrl:refreshMultiEditState()
	local activeCount = pg.me:getPhotographyStudioActiveMemberCount(self.studioUid)

	self.view.widget:TryChangePage("TopInfo", activeCount > 1 and 1 or 0)
	ClientTextUtils.setText(self.view.txtMulEditUBaseText, pg.getGameString("PHOTO_STUDIO_MULTI_EDITING"))
end

function PhotographyStudioEditCtrl:onStudioActiveMembersChanged(data)
	if type(data) ~= "table" or getUidKey(data.studioUid) ~= getUidKey(self.studioUid) then
		return
	end

	self:refreshMultiEditState()

	if self.funcMenu then
		self.funcMenu:refreshStudioActiveEditState()
	end
end

function PhotographyStudioEditCtrl:refreshInviteNum()
	if not self.view.inviteNumUBaseText then
		return
	end

	local studioInfo = self.studioUid and pg.me:getStudioInfo(self.studioUid) or nil
	local memberCount = 0

	if studioInfo and studioInfo.members then
		memberCount = #studioInfo.members
	end

	local memberLimit = tonumber(AppearanceVariableData.STUDIO_INVITE_FRIEND_NUM) or 0

	ClientTextUtils.setText(self.view.inviteNumUBaseText, string.format("%s/%s", memberCount, memberLimit))
end

function PhotographyStudioEditCtrl:enableCameraControl(enable)
	if not enable and self.cameraWasMoving then
		self.cameraWasMoving = false

		self:recordStudioHistoryStep("camera_move")
	end

	self.cameraControlEnabled = enable
	self.moveX, self.moveY, self.moveZ = 0, 0, 0

	if enable then
		pg.game.input:enablePhotoInput(true)
		pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.Photo)

		local processor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

		if processor then
			processor:reset()
		end

		if not self.isMobilePlatform then
			self:enterMouseLook()
		end

		local scene = self:getAvatarScene()

		if scene then
			scene:setStudioFreeCameraMoveRange(AppearanceVariableData.STUDIO_CAMERA_ADJUST_BOTTOM, AppearanceVariableData.STUDIO_CAMERA_ADJUST_TOP, AppearanceVariableData.STUDIO_CAMERA_ADJUST_HEIGHT)
		end

		if not self.cameraUpdateTimer then
			self.cameraUpdateTimer = self:startTimer(function()
				self:updateCamera()
			end, 0, true)
		end
	else
		pg.game.input:enablePhotoInput(false)
		pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
		self:exitMouseLook()

		if self.cameraUpdateTimer then
			self:killTimer(self.cameraUpdateTimer)

			self.cameraUpdateTimer = nil
		end
	end
end

function PhotographyStudioEditCtrl:updateCamera()
	if not self.cameraControlEnabled then
		return
	end

	local scene = self:getAvatarScene()

	if not scene then
		return
	end

	scene:moveStudioFreeCamera(self.moveX * self.moveSpeedRate, self.moveY * self.moveSpeedRate, self.moveZ * self.moveSpeedRate)

	if self:isGamepadCameraInputEnabled() and (self.gamepadLookX ~= 0 or self.gamepadLookY ~= 0) then
		local deltaTime = Time.unscaledDeltaTime
		local lookX, lookY = pg.game.input:applyLookInversion(self.gamepadLookX, self.gamepadLookY)

		scene:rotateStudioFreeCamera(lookX * deltaTime, lookY * deltaTime)
	elseif self.gamepadLookX ~= 0 or self.gamepadLookY ~= 0 then
		self.gamepadLookX, self.gamepadLookY = 0, 0
	end

	local isMoving = self.moveX ~= 0 or self.moveY ~= 0 or self.moveZ ~= 0

	if isMoving then
		self.cameraWasMoving = true
	elseif self.cameraWasMoving then
		self.cameraWasMoving = false

		self:recordStudioHistoryStep("camera_move")
	end
end

function PhotographyStudioEditCtrl:isGamepadCameraInputEnabled()
	if not self.cameraControlEnabled or not pg.game.input:isUsingGamepad() then
		return false
	end

	return not self.funcMenu or not self.funcMenu:isMenuRaised()
end

function PhotographyStudioEditCtrl:getCameraRotateDelta(deltaX, deltaY)
	if Screen.height <= 0 then
		return 0, 0
	end

	local pixelRate = self.mouseLookPixelRate

	if self.isMobilePlatform then
		pixelRate = self.mobileLookPixelRate * SysConfigData.MAIN_CAMERA_RATE_MOBILE
	end

	return deltaX * pixelRate / Screen.height, deltaY * pixelRate / Screen.height
end

function PhotographyStudioEditCtrl:bindGamepadCameraControl()
	if self.gamepadViewAxisBind or self.leftShoulderBind then
		return
	end

	local root = self.view.transform.gameObject
	local viewAxisBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "StudioGamepadViewAxis")

	viewAxisBind.isVirtual = true
	viewAxisBind.priority = 0
	viewAxisBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadCamera_ViewAxis

	function viewAxisBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self.gamepadLookX, self.gamepadLookY = 0, 0
		elseif inputInfo.phase == "Performed" then
			if self:isGamepadCameraInputEnabled() then
				if self.isLeftShoulderPressed then
					self.gamepadLookX, self.gamepadLookY = 0, 0
				else
					local value = inputInfo.valueVec2

					self.gamepadLookX = value.x * self.gamepadLookYawRate
					self.gamepadLookY = value.y * self.gamepadLookPitchRate
				end
			else
				self.gamepadLookX, self.gamepadLookY = 0, 0
			end
		end

		return true
	end

	self.gamepadViewAxisBind = viewAxisBind

	local leftShoulderBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "StudioLeftShoulder")

	leftShoulderBind.isVirtual = true
	leftShoulderBind.priority = 99999
	leftShoulderBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftShoulder

	function leftShoulderBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.isLeftShoulderPressed = self:isGamepadCameraInputEnabled()
		elseif inputInfo.phase == "Canceled" then
			self.isLeftShoulderPressed = false

			local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

			if photoProcessor then
				photoProcessor.moveZWeight = 0

				photoProcessor:handleMoveWeight()
			end
		end

		return true
	end

	self.leftShoulderBind = leftShoulderBind
end

function PhotographyStudioEditCtrl:unbindGamepadCameraControl()
	if self.gamepadViewAxisBind then
		self.gamepadViewAxisBind.luaTrigger = nil
		self.gamepadViewAxisBind = nil
	end

	if self.leftShoulderBind then
		self.leftShoulderBind.luaTrigger = nil
		self.leftShoulderBind = nil
	end
end

function PhotographyStudioEditCtrl:onLensScroll(isAdd)
	if not self.isMaster then
		return
	end

	if self.funcMenu and self.funcMenu.scrollLens then
		self.funcMenu:scrollLens(isAdd)
		self:scheduleStudioHistoryStep("lens_scroll", 0.2)
	end
end

function PhotographyStudioEditCtrl:checkUILockCursor()
	if self.mouseLookActive then
		return true
	end

	return PhotographyStudioEditCtrl.super.checkUILockCursor(self)
end

function PhotographyStudioEditCtrl:enterMouseLook()
	self.mouseLookActive = false

	self:bindShowCursorBlock()
	self:bindMouseRightLook()
	self:bindMouseViewAxis()
	pg.global.ui:refreshLockCursor()
end

function PhotographyStudioEditCtrl:exitMouseLook()
	self.mouseLookActive = false

	pg.game.input:setViewAxis(0, 0)
	self:unbindShowCursorBlock()
	self:unbindMouseRightLook()
	self:unbindMouseViewAxis()
	pg.global.ui:refreshLockCursor()
end

function PhotographyStudioEditCtrl:bindMouseViewAxis()
	if self.viewAxisBind then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "StudioMouseViewAxis")

	bind.isVirtual = true
	bind.priority = 0
	bind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_ViewAxis

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self.mouseLookActive and not pg.game.input:getShowCursor() then
			local scene = self:getAvatarScene()

			if scene then
				local v = inputInfo.valueVec2

				if v.x ~= 0 or v.y ~= 0 then
					local lookX, lookY = pg.game.input:applyLookInversion(v.x, v.y)
					local rotateX, rotateY = self:getCameraRotateDelta(lookX, lookY)

					scene:rotateStudioFreeCamera(rotateX, rotateY)
				end
			end
		end
	end

	self.viewAxisBind = bind
end

function PhotographyStudioEditCtrl:unbindMouseViewAxis()
	if self.viewAxisBind then
		self.viewAxisBind.luaTrigger = nil
		self.viewAxisBind = nil
	end
end

function PhotographyStudioEditCtrl:bindShowCursorBlock()
	if self.showCursorBlockBind then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "StudioShowCursorBlock")

	bind.isVirtual = true
	bind.priority = -1
	bind.actionPath = "Camera/ShowCursor"

	function bind.luaTrigger()
		return false
	end

	self.showCursorBlockBind = bind
end

function PhotographyStudioEditCtrl:unbindShowCursorBlock()
	if self.showCursorBlockBind then
		self.showCursorBlockBind.luaTrigger = nil
		self.showCursorBlockBind = nil
	end
end

function PhotographyStudioEditCtrl:bindMouseRightLook()
	if self.mouseRightLookBind then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "StudioMouseRightLook")

	bind.isVirtual = true
	bind.priority = -1
	bind.actionPath = "Raw/MouseRight"

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:setMouseLookActive(true)
		elseif inputInfo.phase == "Canceled" then
			self:setMouseLookActive(false)
		end

		return true
	end

	self.mouseRightLookBind = bind
end

function PhotographyStudioEditCtrl:unbindMouseRightLook()
	if self.mouseRightLookBind then
		self.mouseRightLookBind.luaTrigger = nil
		self.mouseRightLookBind = nil
	end
end

function PhotographyStudioEditCtrl:setMouseLookActive(active)
	if self.mouseLookActive == active then
		return
	end

	self.mouseLookActive = active

	if not active then
		pg.game.input:setViewAxis(0, 0)
	end

	pg.global.ui:refreshLockCursor()
end

function PhotographyStudioEditCtrl:isApplyingStudioHistory()
	return self.model and self.model.isApplyingHistory == true
end

function PhotographyStudioEditCtrl:capturePlayerHistoryState(players)
	local result = {}
	local selfUidKey = getUidKey(pg.me.uid)

	for uid, playerData in pairs(players) do
		if type(playerData) == "table" and (self.isMaster or getUidKey(uid) == selfUidKey) then
			result[uid] = captureHistoryFields(playerData, PLAYER_HISTORY_FIELDS)
		end
	end

	return result
end

function PhotographyStudioEditCtrl:captureStudioWorkingState()
	local scene = self:getAvatarScene()

	if not scene or not self.funcMenu then
		return nil
	end

	local cameraPos = scene:getStudioFreeCameraPose()
	local localLens = {}

	self.funcMenu:saveLocalViewToPreset(localLens)

	local snapshot = {
		localView = {
			cameraPos = copyVector3(cameraPos),
			lens = localLens
		}
	}

	if self.isMaster then
		local content = self:gatherContent(scene)

		snapshot.common = captureHistoryFields(content.common, COMMON_HISTORY_FIELDS)
		snapshot.players = self:capturePlayerHistoryState(content.players)
	else
		local content = self:gatherPlayerContent(scene)

		snapshot.players = self:capturePlayerHistoryState(content.players)
	end

	return snapshot
end

function PhotographyStudioEditCtrl:initStudioHistory()
	local snapshot = self:captureStudioWorkingState()

	self.historyInitialized = self.model:initHistory(snapshot)

	self:refreshHistoryButtonState()
end

function PhotographyStudioEditCtrl:recordStudioHistoryStep(operationType)
	if not self.historyInitialized or self:isApplyingStudioHistory() then
		return false
	end

	local snapshot = self:captureStudioWorkingState()
	local recorded = self.model:recordHistoryStep(snapshot)

	if recorded then
		self.lastHistoryOperationType = operationType

		self:refreshHistoryButtonState()
	end

	return recorded
end

function PhotographyStudioEditCtrl:scheduleStudioHistoryStep(operationType, delay)
	if self:isApplyingStudioHistory() then
		return
	end

	if self.pendingHistoryTimer then
		self:killTimer(self.pendingHistoryTimer)

		self.pendingHistoryTimer = nil
	end

	self.pendingHistoryOperationType = operationType

	local timerId

	timerId = self:startTimer(function()
		if self.pendingHistoryTimer ~= timerId then
			return
		end

		self.pendingHistoryTimer = nil
		self.pendingHistoryOperationType = nil

		self:recordStudioHistoryStep(operationType)
	end, delay)
	self.pendingHistoryTimer = timerId
end

function PhotographyStudioEditCtrl:flushPendingHistoryStep()
	if not self.pendingHistoryTimer then
		return
	end

	self:killTimer(self.pendingHistoryTimer)

	self.pendingHistoryTimer = nil

	local operationType = self.pendingHistoryOperationType

	self.pendingHistoryOperationType = nil

	self:recordStudioHistoryStep(operationType)
end

function PhotographyStudioEditCtrl:cancelPendingHistoryStep()
	if self.pendingHistoryTimer then
		self:killTimer(self.pendingHistoryTimer)

		self.pendingHistoryTimer = nil
	end

	self.pendingHistoryOperationType = nil
	self.cameraWasMoving = false
end

function PhotographyStudioEditCtrl:refreshHistoryButtonState()
	if self.view.btnUndoUButton then
		self.view.btnUndoUButton.interactable = self.model:canUndoHistory()
	end

	if self.view.btnRedoUButton then
		self.view.btnRedoUButton.interactable = self.model:canRedoHistory()
	end
end

function PhotographyStudioEditCtrl:buildHistoryContent(snapshot, cameraRot)
	local cachedContent = pg.me:getCachedPhotographyStudioContent(self.studioUid)
	local content

	if type(cachedContent) == "table" then
		content = Utils.deepCopyTable(cachedContent)
	else
		content = {
			version = PhotographyStudioUtils.CONTENT_VERSION,
			masterUid = pg.me:getStudioMasterUid(self.studioUid),
			common = {},
			players = {}
		}
	end

	if type(content.common) ~= "table" then
		content.common = {}
	end

	if type(content.players) ~= "table" then
		content.players = {}
	end

	if self.isMaster then
		applyHistoryFields(snapshot.common, content.common, COMMON_HISTORY_FIELDS)
		copyFields(snapshot.localView.lens, content.common, LOCAL_LENS_FIELDS)
	end

	for uid, historyPlayerData in pairs(snapshot.players) do
		local playerData = getPlayerSegment(content.players, uid)

		if not playerData then
			playerData = {}
			content.players[uid] = playerData
		end

		applyHistoryFields(historyPlayerData, playerData, PLAYER_HISTORY_FIELDS)
	end

	local localView = snapshot.localView

	if localView.cameraPos then
		content.common.cameraPos = copyVector3(localView.cameraPos)
		content.common.cameraRot = copyVector3(cameraRot)
	end

	return content
end

function PhotographyStudioEditCtrl:applyStudioWorkingState(snapshot)
	if type(snapshot) ~= "table" or type(snapshot.localView) ~= "table" or self:isApplyingStudioHistory() then
		return false
	end

	local scene = self:getAvatarScene()

	if not scene then
		return false
	end

	self:cancelPendingHistoryStep()

	self.model.isApplyingHistory = true

	local ok, err = xpcall(function()
		self:selectStudioEntity(nil)

		if self.funcMenu then
			self.funcMenu:deselectAllDIY()
		end

		local _, cameraRot = scene:getStudioFreeCameraPose()
		local content = self:buildHistoryContent(snapshot, cameraRot)

		self:applySyncedStudioContent(content, not self.isMaster)

		local localView = snapshot.localView

		if localView.cameraPos and cameraRot then
			scene:setStudioFreeCameraPose(localView.cameraPos, cameraRot)
		end

		if self.funcMenu and type(localView.lens) == "table" then
			self.funcMenu:applyLocalViewPreset(localView.lens)
		end

		self:refreshPlaceHotspots()
	end, debug.traceback)

	self.model.isApplyingHistory = false

	if not ok then
		logger:error("applyStudioWorkingState failed", err)

		return false
	end

	return true
end

function PhotographyStudioEditCtrl:onClickUndo()
	self:flushPendingHistoryStep()

	local snapshot, targetIndex = self.model:getUndoHistoryTarget()

	if not snapshot or not self:applyStudioWorkingState(snapshot) then
		return
	end

	self.model:commitHistoryIndex(targetIndex)
	self:refreshHistoryButtonState()
end

function PhotographyStudioEditCtrl:onClickRedo()
	self:flushPendingHistoryStep()

	local snapshot, targetIndex = self.model:getRedoHistoryTarget()

	if not snapshot or not self:applyStudioWorkingState(snapshot) then
		return
	end

	self.model:commitHistoryIndex(targetIndex)
	self:refreshHistoryButtonState()
end

function PhotographyStudioEditCtrl:hasUnsavedChanges()
	if not self.historyInitialized then
		return false
	end

	self:flushPendingHistoryStep()

	return self.model:hasUnsavedChanges(self.model:getCurrentHistorySnapshot())
end

function PhotographyStudioEditCtrl:loadFuncMenuFromContent(content, applyCommon, refreshUidSet, preserveOrnamentPreview)
	if not self.funcMenu or not self.studioUid then
		return
	end

	content = content or pg.me:getCachedPhotographyStudioContent(self.studioUid)

	if not content then
		return
	end

	PhotographyStudioUtils.ensureInitialCameraPreset(content)

	local players = content.players

	if type(players) ~= "table" then
		players = EMPTY_TABLE
	end

	local selfUid = pg.me.uid
	local selfUidKey = getUidKey(selfUid)
	local selfSeg = players[selfUid] or players[tostring(selfUid)]
	local preset

	if type(content.common) == "table" then
		preset = Utils.deepCopyTable(content.common)
	else
		preset = {}
	end

	preset.playerPoseId = selfSeg and selfSeg.playerPoseId or preset.playerPoseId
	preset.gazeType = selfSeg and selfSeg.gazeType or preset.gazeType

	if selfSeg and selfSeg.gazePos then
		local scene = self:getAvatarScene()
		local root = scene and scene.entityRootTransform

		if NotNil(root) then
			local localPos = selfSeg.gazePos
			local worldPos = root:TransformPoint(Vector3(localPos.x, localPos.y, localPos.z))

			preset.gazePos = {
				x = worldPos.x,
				y = worldPos.y,
				z = worldPos.z
			}
		end
	end

	if applyCommon ~= false and (content.common or preset.playerPoseId or preset.gazeType) then
		self.funcMenu:applyPreset(preset, preserveOrnamentPreview)
	elseif applyCommon == false then
		self.funcMenu:applyPlayerPreset(preset)
	end

	local info = pg.me:getStudioInfo(self.studioUid)
	local memberSet = {}

	if info then
		if info.masterUid then
			memberSet[getUidKey(info.masterUid)] = true
		end

		for _, member in ipairs(info.members or READONLY_EMPTY_TABLE) do
			if member.uid then
				memberSet[getUidKey(member.uid)] = true
			end
		end
	end

	local function isCurrentStudioMember(uid)
		local uidKey = getUidKey(uid)

		return uidKey and (uidKey == selfUidKey or memberSet[uidKey])
	end

	local scene = self:getAvatarScene()

	if scene then
		local studioPets = {}

		for uid, data in pairs(players) do
			if type(data) == "table" and isCurrentStudioMember(uid) and type(data.pets) == "table" then
				local ownerUid = getUidKey(uid)

				for _, petData in ipairs(data.pets) do
					local petId = petData.petId

					if petId then
						studioPets[#studioPets + 1] = {
							petId = petId,
							ownerUid = ownerUid,
							pos = petData.pos,
							rotY = petData.rotY,
							petData = petData
						}
					end
				end
			end
		end

		scene:syncStudioPets(studioPets, refreshUidSet)
	end

	if self.funcMenu.applyPets and (not refreshUidSet or refreshUidSet[selfUidKey]) then
		self.funcMenu:applyPets(selfSeg and selfSeg.pets)
	end
end

function PhotographyStudioEditCtrl:onClickSave()
	if not self.studioUid then
		return
	end

	local scene = self:getAvatarScene()

	if not scene then
		return
	end

	self:flushPendingHistoryStep()

	local submittedSnapshot = self:captureStudioWorkingState()

	self.saveRequestSerial = self.saveRequestSerial + 1

	local requestSerial = self.saveRequestSerial
	local submittedContent
	local submittedIncremental = false

	local function onSaved(ok)
		if self.pendingSaveSerial ~= requestSerial then
			return
		end

		if not ok then
			self.pendingSaveSnapshot = nil
			self.pendingSaveSerial = nil

			return
		end

		if submittedIncremental then
			self:mergeStudioEditSavedContent(submittedContent)
		else
			self:setStudioEditSavedContent(submittedContent)
		end

		self.model:markHistorySaved(submittedSnapshot)
	end

	self.pendingSaveSnapshot = submittedSnapshot
	self.pendingSaveSerial = requestSerial

	if self.isMaster then
		local content = self:gatherContent(scene)

		submittedContent = content
		self.coverCaptureSerial = self.coverCaptureSerial + 1

		destroyStudioCoverTaskSprite(self.pendingSyncCoverTask)

		local coverTask = {
			serial = self.coverCaptureSerial,
			studioUid = self.studioUid,
			coverImageId = PhotographyStudioUtils.genPhotographyStudioCoverImageId(self.studioUid)
		}

		self.pendingSyncCoverTask = coverTask

		pg.me:saveStudioContent(self.studioUid, content, onSaved, true)

		coverTask.saveVersion = content.version

		pg.me:waitPhotographyStudioContentSynced(self.studioUid, coverTask.saveVersion, function()
			if self.pendingSyncCoverTask == coverTask then
				self.pendingSyncCoverTask = nil
			end

			coverTask.contentSynced = true

			self:tryQueueStudioCoverUpload(coverTask)
		end)
		self:captureStudioCover(coverTask)
	else
		local content = self:gatherPlayerContent(scene)

		submittedContent = content
		submittedIncremental = true

		pg.me:saveStudioIncrementalContent(self.studioUid, content, onSaved, true)
	end
end

function PhotographyStudioEditCtrl:beginStudioCapture(showLogo)
	if self.restoreCaptureUI then
		self.restoreCaptureUI()
	end

	local selectedEntity = self.placePetComp and self.placePetComp:getSelectedEntity()

	self.isStudioCapturing = true

	local outlineHidden = self:setStudioEntityOutline(selectedEntity, false)

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO, {
		[UIConst.UI_ID_PHOTO_LOGO] = true
	}, 5)

	local photoLogo = pg.global.ui.photoLogo
	local photoLogoReady = photoLogo and photoLogo.view

	if photoLogoReady then
		if showLogo and not GmToolUtils.closePhotoMark then
			photoLogo:showLogo()
		else
			photoLogo:hideLogo()
		end
	end

	if self.funcMenu and photoLogoReady then
		self.funcMenu:onBeginPhoto(photoLogo.view.transform)
	end

	local restored = false

	local function restorePhotoUI()
		if restored then
			return
		end

		restored = true
		self.isStudioCapturing = false

		local currentEntity = self.placePetComp and self.placePetComp:getSelectedEntity()

		if outlineHidden and currentEntity == selectedEntity then
			self:setStudioEntityOutline(selectedEntity, true)
		end

		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO)

		if photoLogoReady then
			photoLogo:hideLogo()
		end

		if self.funcMenu then
			self.funcMenu:onEndPhoto(self.funcMenu.dIYRootRectTransform)
		end

		if self.restoreCaptureUI == restorePhotoUI then
			self.restoreCaptureUI = nil
		end
	end

	self.restoreCaptureUI = restorePhotoUI

	return restorePhotoUI
end

function PhotographyStudioEditCtrl:captureStudioCover(task)
	if not task.coverImageId then
		return
	end

	local restorePhotoUI = self:beginStudioCapture(false)

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, _, success)
		restorePhotoUI()

		if not success then
			pg.global.mobileCameraMgr:DestroyCapturedSprite()

			return
		end

		local coverWidth, coverHeight = getStudioCoverResolution(sprite.texture)
		local createOk, coverSprite = pcall(pg.global.mobileCameraMgr.GetSpriteCover, pg.global.mobileCameraMgr, sprite, coverWidth, coverHeight)

		pg.global.mobileCameraMgr:DestroyCapturedSprite()

		if not createOk or not coverSprite then
			logger:error("captureStudioCover create cover failed, studioUid=%s", tostring(task.studioUid))

			return
		end

		task.coverSprite = coverSprite

		self:tryQueueStudioCoverUpload(task)
	end)
end

function PhotographyStudioEditCtrl:tryQueueStudioCoverUpload(task)
	if task.serial ~= self.coverCaptureSerial then
		destroyStudioCoverTaskSprite(task)

		return
	end

	if not task.contentSynced or not task.coverSprite then
		return
	end

	if self.coverUploadInProgress then
		if not self.pendingCoverUploadTask or task.serial > self.pendingCoverUploadTask.serial then
			destroyStudioCoverTaskSprite(self.pendingCoverUploadTask)

			self.pendingCoverUploadTask = task
		elseif self.pendingCoverUploadTask ~= task then
			destroyStudioCoverTaskSprite(task)
		end

		return
	end

	self:startStudioCoverUpload(task)
end

function PhotographyStudioEditCtrl:startStudioCoverUpload(task)
	self.coverUploadInProgress = true

	ClientUtils.uploadPicture(task.coverImageId, task.coverSprite, function(_, success)
		destroyStudioCoverTaskSprite(task)

		self.coverUploadInProgress = false

		if success and pg.me then
			PhotographyStudioUtils.invalidatePhotographyStudioCover(task.studioUid)
			pg.me:saveStudioIncrementalContent(task.studioUid, {
				coverImageId = task.coverImageId,
				coverVersion = task.saveVersion
			}, nil, false)
		elseif not success then
			logger:error("startStudioCoverUpload failed, studioUid=%s", tostring(task.studioUid))
		end

		local pendingTask = self.pendingCoverUploadTask

		self.pendingCoverUploadTask = nil

		if pendingTask then
			self:tryQueueStudioCoverUpload(pendingTask)
		end
	end, STUDIO_COVER_QUALITY)
end

function PhotographyStudioEditCtrl:takePhoto()
	if self.lastTakePhotoTime + self.takePhotoInterval > Time.millisecondCache then
		return
	end

	self.lastTakePhotoTime = Time.millisecondCache

	local captureTime = os.time()
	local restorePhotoUI = self:beginStudioCapture(true)

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, imgUrl, success)
		if not success then
			restorePhotoUI()

			return
		end

		local logData = {
			studio_id = tonumber(self.studioEditSlotId) or 0
		}

		LuaUIUtils.sendCustomLog(Const.BILogName.STUDIO_CODE, logData)

		local px, py, pz = pg.me.eModel:GetPositionAgentPosEx()
		local playerPos = Vector3.New(px, py, pz)
		local saveInfo = pg.global.mobileCameraMgr:GetPetPhotoInfo(captureTime, playerPos, pg.me.space.sceneId)
		local studioInfo = pg.me:getStudioInfo(self.studioUid)
		local studioName = studioInfo and studioInfo.name

		if not studioName or studioName == "" then
			studioName = pg.getGameString("PHOTO_STUDIO_DEFAULT_NAME")
		end

		local saved = false
		local saving = false
		local photoInfo = {
			onlySave = true,
			needSave = true,
			timeStamp = saveInfo.ts,
			position = saveInfo.pos,
			sceneId = saveInfo.sceneId,
			locationName = studioName,
			sprite = sprite
		}

		function photoInfo.saveCallback()
			if saved then
				pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_HAS_SAVED"))

				return
			end

			if saving then
				return
			end

			saving = true

			local storageMode = ClientSettingUtils.getPhotoStorageMode()
			local saveToLocal = ClientSettingUtils.shouldSavePhotoToLocal(storageMode)
			local saveToCloud = ClientSettingUtils.shouldSavePhotoToCloud(storageMode)

			if not saveToLocal then
				Utils.uploadPhotoToOSS(imgUrl, saveInfo.ts, function(success, failureReason)
					saving = false

					if success then
						saved = true

						pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSaveSuccessText(storageMode))
					else
						local failureText = ClientSettingUtils.getPhotoSaveFailureText(failureReason)

						if failureText then
							pg.global.showBubbleMessageRaw(failureText)
						end
					end
				end)

				return
			end

			pg.global.mobileCameraMgr:SaveImageToAlbum(saveInfo, function(photoPath)
				saving = false

				if photoPath and photoPath ~= "" then
					saved = true

					if saveToCloud then
						Utils.uploadPhotoToOSS(imgUrl, saveInfo.ts, function(success, failureReason)
							local resultText

							if success then
								resultText = ClientSettingUtils.getPhotoSaveSuccessText(storageMode, photoPath)
							else
								resultText = ClientSettingUtils.getPhotoSaveFailureText(failureReason, photoPath) or ClientSettingUtils.getPhotoSaveSuccessText(ClientConst.PhotoStorageMode.Local, photoPath)
							end

							pg.global.showBubbleMessageRaw(resultText)
						end)
					else
						pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSaveSuccessText(storageMode, photoPath))
					end
				else
					pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)
				end
			end)
		end

		pg.global.ui.albumPhoto:open({
			photoInfo = photoInfo
		})
		restorePhotoUI()
	end)
end

function PhotographyStudioEditCtrl:gatherPlayerSegment(scene, preset, basePlayers)
	local selfUid = pg.me.uid
	local curEntityId = scene:getCurEntityId()
	local selfSegKey = getUidKey(selfUid)

	selfSegKey = selfSegKey or selfUid

	local cachedSelfSeg

	if type(basePlayers) == "table" then
		cachedSelfSeg = basePlayers[selfUid]
		cachedSelfSeg = cachedSelfSeg or basePlayers[selfSegKey]
	end

	local selfSeg

	if type(cachedSelfSeg) == "table" then
		selfSeg = Utils.deepCopyTable(cachedSelfSeg)
	else
		selfSeg = {}
	end

	local curEntity = curEntityId and scene:getEntity(curEntityId)

	selfSeg.templateId = pg.me.templateId
	selfSeg.avatarPresetKey = pg.me.avatarPresetKey
	selfSeg.avatarConfig = pg.me.avatarConfig

	if curEntity and curEntity.getAppearanceConfigId then
		selfSeg.appearance = PhotographyStudioUtils.serializeUsableAppearance(curEntity)
	else
		local curShow = pg.me.curShow

		selfSeg.appearance = PhotographyStudioUtils.serializeAppearanceFromCustomShow(curShow and curShow.customShow)
	end

	selfSeg.curShow = PhotographyStudioUtils.serializeJsonSafeTable(pg.me.curShow)
	selfSeg.jewelryLastInfos = PhotographyStudioUtils.serializeJsonSafeTable(pg.me.jewelryLastInfos)
	selfSeg.playerPoseId = preset.playerPoseId
	selfSeg.visible = not curEntityId or scene:isStudioPlayerVisible(curEntityId)

	if preset.gazeType ~= nil then
		selfSeg.gazeType = preset.gazeType
	end

	selfSeg.gazePos = nil

	if preset.gazePos then
		local root = scene.entityRootTransform

		if NotNil(root) then
			local worldPos = preset.gazePos
			local localPos = root:InverseTransformPoint(Vector3(worldPos.x, worldPos.y, worldPos.z))

			selfSeg.gazePos = {
				x = localPos.x,
				y = localPos.y,
				z = localPos.z
			}
		end
	end

	if curEntityId then
		local p = scene:getStudioEntityLocalPos(curEntityId)
		local ry = scene:getStudioEntityLocalRotY(curEntityId)

		if p then
			selfSeg.playerPos = {
				x = p.x,
				y = p.y,
				z = p.z
			}
		end

		if ry ~= nil then
			selfSeg.playerRot = {
				z = 0,
				x = 0,
				y = ry
			}
		end
	end

	if self.funcMenu and self.funcMenu.savePets then
		selfSeg.pets = self.funcMenu:savePets()
	end

	return selfSegKey, selfSeg
end

function PhotographyStudioEditCtrl:refreshPlayerPetsFromScene(scene, ownerUid, playerData)
	if type(playerData.pets) ~= "table" then
		return
	end

	for _, petData in ipairs(playerData.pets) do
		local petId = petData.petId
		local realOwnerUid = petData.ownerUid

		if realOwnerUid == nil then
			realOwnerUid = ownerUid
		end

		local entityId = PhotographyStudioUtils.buildStudioPetEntityId(realOwnerUid, petId)
		local entity = entityId and scene:getEntity(entityId)

		if entity then
			local pos = scene:getStudioPetLocalPos(entityId)

			petData.pos = copyVector3(pos)
			petData.rotY = scene:getStudioPetLocalRotY(entityId) or 0
			petData.petPoseId = self.funcMenu:getStudioPetPoseId(entity)

			local gazeData = self.funcMenu:getStudioPetGazeData(entity)

			if gazeData then
				petData.gazeType = gazeData.gazeType
				petData.gazePos = nil

				if gazeData.gazePos and NotNil(scene.entityRootTransform) then
					local worldPos = gazeData.gazePos
					local localPos = scene.entityRootTransform:InverseTransformPoint(Vector3(worldPos.x, worldPos.y, worldPos.z))

					petData.gazePos = copyVector3(localPos)
				end
			else
				petData.gazeType = entity.studioPetGazeType
				petData.gazePos = copyVector3(entity.studioPetGazePos)
			end
		end
	end
end

function PhotographyStudioEditCtrl:refreshOtherPlayerSegments(scene, players)
	local selfUidKey = getUidKey(pg.me.uid)

	for uid, playerData in pairs(players) do
		if type(playerData) == "table" and getUidKey(uid) ~= selfUidKey then
			local entity = scene:getEntity(uid)

			if entity then
				local pos = scene:getStudioEntityLocalPos(uid)
				local rotY = scene:getStudioEntityLocalRotY(uid)

				playerData.playerPos = copyVector3(pos)

				if rotY ~= nil then
					playerData.playerRot = {
						z = 0,
						x = 0,
						y = rotY
					}
				end

				playerData.playerPoseId = entity.studioPlayerPoseId
				playerData.visible = scene:isStudioPlayerVisible(uid)
				playerData.gazeType = entity.studioPlayerGazeType
				playerData.gazePos = copyVector3(entity.studioPlayerGazePos)

				self:refreshPlayerPetsFromScene(scene, uid, playerData)
			end
		end
	end
end

function PhotographyStudioEditCtrl:gatherContent(scene)
	local cachedContent = pg.me:getCachedPhotographyStudioContent(self.studioUid)
	local base

	if type(cachedContent) == "table" then
		base = Utils.deepCopyTable(cachedContent)
	else
		base = {}
	end

	local common = base.common

	if type(common) ~= "table" then
		common = {}
		base.common = common
	end

	local players = base.players

	if type(players) ~= "table" then
		players = {}
		base.players = players
	end

	local camPos, camRot = scene:getStudioFreeCameraPose()

	if camPos and camRot then
		common.cameraPos = copyVector3(camPos)
		common.cameraRot = copyVector3(camRot)
	end

	if self.funcMenu then
		self.funcMenu:saveToPreset(common)
	end

	common.petInfo = nil

	local selfSegKey, selfSeg = self:gatherPlayerSegment(scene, common, players)

	common.playerPoseId = nil
	common.gazeType = nil
	common.gazePos = nil

	local selfUid = pg.me.uid

	players[selfUid] = nil
	players[selfSegKey] = selfSeg

	self:refreshOtherPlayerSegments(scene, players)

	if self.funcMenu then
		self.funcMenu:removeHiddenPetsFromPlayers(players)
	end

	return {
		version = base.version or PhotographyStudioUtils.CONTENT_VERSION,
		masterUid = pg.me:getStudioMasterUid(self.studioUid),
		coverImageId = base.coverImageId,
		coverVersion = base.coverVersion,
		common = common,
		players = players
	}
end

function PhotographyStudioEditCtrl:gatherPlayerContent(scene)
	local base = pg.me:getCachedPhotographyStudioContent(self.studioUid)
	local basePlayers = type(base) == "table" and base.players or nil
	local preset = {}

	if self.funcMenu then
		self.funcMenu:savePlayerToPreset(preset)
	end

	local selfSegKey, selfSeg = self:gatherPlayerSegment(scene, preset, basePlayers)
	local players = {}

	players[selfSegKey] = selfSeg

	return {
		players = players
	}
end

function PhotographyStudioEditCtrl:onDestroy()
	self:closePhotoLightDiy()

	local emitter = self._platformPrivacyEventEmitter

	if emitter and emitter.removeEventListener and self._platformPrivacyChangedListener then
		emitter:removeEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self._platformPrivacyChangedListener)
		emitter:removeEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, self._platformPrivacyChangedListener)
	end

	self._platformPrivacyEventEmitter = nil
	self._platformPrivacyChangedListener = nil

	if self.hasEnteredPhotographyStudio then
		self:sendStudioEditLog()

		self.hasEnteredPhotographyStudio = false

		pg.me:leavePhotographyStudioEdit(self.studioUid)
	end

	self.coverCaptureSerial = self.coverCaptureSerial + 1

	destroyStudioCoverTaskSprite(self.pendingCoverUploadTask)

	self.pendingCoverUploadTask = nil

	destroyStudioCoverTaskSprite(self.pendingSyncCoverTask)

	self.pendingSyncCoverTask = nil

	if self.restoreCaptureUI then
		self.restoreCaptureUI()
	end

	if self.placePetComp then
		self:setStudioEntityOutline(self.placePetComp:getSelectedEntity(), false)
	end

	self:cancelPendingHistoryStep()
	self.model:clearHistory()

	self.historyInitialized = false

	self:resetGamepadInput(true)
	self:unbindGamepadCameraControl()
	self:enableCameraControl(false)
	self:clearLeftConsoleBarState()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LOGO) then
		pg.global.ui:close(UIConst.UI_ID_PHOTO_LOGO)
	end

	if self.funcUpdateTimer then
		self:killTimer(self.funcUpdateTimer)

		self.funcUpdateTimer = nil
	end

	if self.funcMenu then
		self.funcMenu:destroy()

		self.funcMenu = nil
	end

	if self.placePetComp then
		self.placePetComp:destroy()

		self.placePetComp = nil
	end

	UICtrl.onDestroy(self)
end

return PhotographyStudioEditCtrl
