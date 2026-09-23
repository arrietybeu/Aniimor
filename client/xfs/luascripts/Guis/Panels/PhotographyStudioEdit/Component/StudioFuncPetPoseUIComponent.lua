-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioFuncPetPoseUIComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local PhotoFuncPetPoseUIComponent = require("Guis.Panels.Photo.Component.PhotoFuncPetPoseUIComponent")
local StudioPetPlaceAdapter = require("Guis.Panels.PhotographyStudioEdit.Component.StudioPetPlaceAdapter")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")

local function getUidKey(uid)
	return uid and tostring(uid) or nil
end

local function isSelfUid(uid)
	return getUidKey(uid) == getUidKey(pg.me.uid)
end

local StudioFuncPetPoseUIComponent = Class.LightClass("StudioFuncPetPoseUIComponent", PhotoFuncPetPoseUIComponent)

StudioFuncPetPoseUIComponent.MASTER_MAX_PETS = 4
StudioFuncPetPoseUIComponent.MIN_PETS = 1

function StudioFuncPetPoseUIComponent:createPlacePetComp()
	return StudioPetPlaceAdapter.new(self)
end

function StudioFuncPetPoseUIComponent:initDefaultPets()
	self.studioPetOrder = {}
	self.studioPetOwnerUids = {}
end

function StudioFuncPetPoseUIComponent:onDestroy()
	for _, poseState in pairs(self.curDynamicPoseState) do
		poseState:SetSpeed(1)
	end

	PhotoFuncPetPoseUIComponent.onDestroy(self)
end

function StudioFuncPetPoseUIComponent:getStudioScene()
	return self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()
end

function StudioFuncPetPoseUIComponent:isStudioMaster()
	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()

	return studioUid ~= nil and pg.me:isStudioMaster(studioUid) == true
end

function StudioFuncPetPoseUIComponent:buildStudioPetEntityId(ownerUid, petId)
	return PhotographyStudioUtils.buildStudioPetEntityId(ownerUid or pg.me.uid, petId)
end

function StudioFuncPetPoseUIComponent:getStudioPetIdentity(petIdOrEntityId, ownerUid)
	local parsedOwnerUid, parsedPetId = PhotographyStudioUtils.parseStudioPetEntityId(petIdOrEntityId)

	if parsedPetId then
		return petIdOrEntityId, parsedOwnerUid, parsedPetId
	end

	if not petIdOrEntityId then
		return nil, nil, nil
	end

	local realOwnerUid = ownerUid or pg.me.uid

	return self:buildStudioPetEntityId(realOwnerUid, petIdOrEntityId), realOwnerUid, petIdOrEntityId
end

function StudioFuncPetPoseUIComponent:getStudioPetRawPetId(entityId)
	local _, petId = PhotographyStudioUtils.parseStudioPetEntityId(entityId)

	return petId or entityId
end

function StudioFuncPetPoseUIComponent:getStudioPetOwnerUid(entityId)
	local ownerUid = PhotographyStudioUtils.parseStudioPetEntityId(entityId)

	return ownerUid or self.studioPetOwnerUids[entityId] or pg.me.uid
end

function StudioFuncPetPoseUIComponent:getOtherMemberCount()
	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()

	if not studioUid then
		return 0
	end

	local info = pg.me:getStudioInfo(studioUid)

	if not info then
		return 0
	end

	local count = 0

	for _, member in ipairs(info.members or EMPTY_TABLE) do
		if member.uid and member.uid ~= info.masterUid then
			count = count + 1
		end
	end

	return count
end

function StudioFuncPetPoseUIComponent:getPlacablePetQuota()
	local isMaster = self:isStudioMaster()
	local playerCount = self:getOtherMemberCount() + 1

	if not isMaster and playerCount == 1 then
		return self.MIN_PETS
	end

	local quota = math.floor(self.MASTER_MAX_PETS / playerCount)

	if isMaster then
		quota = quota + self.MASTER_MAX_PETS % playerCount
	end

	if quota < self.MIN_PETS then
		quota = self.MIN_PETS
	elseif quota > self.MASTER_MAX_PETS then
		quota = self.MASTER_MAX_PETS
	end

	return quota
end

function StudioFuncPetPoseUIComponent:getPlacedPetCount()
	return #self.studioPetOrder
end

function StudioFuncPetPoseUIComponent:enforceQuota()
	local quota = self:getPlacablePetQuota()

	while quota < #self.studioPetOrder do
		local entityId = table.remove(self.studioPetOrder)

		self:retrieveStudioPet(entityId, true)
	end
end

function StudioFuncPetPoseUIComponent:buildReplacePetContext(entityId)
	local index, list = self:getStudioPetListIndex(entityId)

	if not index or list ~= self.listPetUList then
		return nil
	end

	local _, ownerUid, petId = self:getStudioPetIdentity(entityId)
	local scene = self:getStudioScene()
	local entity = self.placePetComp:getPetEntity(entityId)

	return {
		oldEntityId = entityId,
		oldPetId = petId,
		orderIndex = index,
		ownerUid = ownerUid or self.studioPetOwnerUids[entityId] or pg.me.uid,
		pos = scene and scene:getStudioPetLocalPos(entityId) or nil,
		rotY = scene and scene:getStudioPetLocalRotY(entityId) or 0,
		petPoseId = entity and self.curPlayPetPoseId[entity.id] or nil
	}
end

function StudioFuncPetPoseUIComponent:restoreReplacePreviewPet(replaceCtx)
	if not replaceCtx or self.replacePreviewHiddenPetId ~= replaceCtx.oldEntityId then
		return
	end

	self.replacePreviewHiddenPetId = nil

	local oldEntityId = replaceCtx.oldEntityId

	if self.placePetComp:getPetEntity(oldEntityId) then
		return
	end

	local entity = self.placePetComp:createPet(replaceCtx.oldPetId, replaceCtx.ownerUid)

	if not entity then
		return
	end

	local scene = self:getStudioScene()

	if scene then
		if replaceCtx.pos then
			scene:setStudioPetLocalPos(oldEntityId, replaceCtx.pos)
		end

		scene:setStudioPetLocalRotY(oldEntityId, replaceCtx.rotY or 0)
	end

	self:clearCurPlayingPetAni(entity)

	self.curPlayPetPoseId[entity.id] = nil

	if replaceCtx.petPoseId then
		self:applyPetPose(entity.id, replaceCtx.petPoseId)
	end

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.curSelectedStudioPetId == oldEntityId then
		self:selectStudioPetEntity(entity)
	end
end

function StudioFuncPetPoseUIComponent:hideReplacePreviewPet(replaceCtx)
	if not replaceCtx or self.replacePreviewHiddenPetId == replaceCtx.oldEntityId then
		return
	end

	local oldEntityId = replaceCtx.oldEntityId
	local entity = self.placePetComp:getPetEntity(oldEntityId)

	if entity then
		self:clearCurPlayingPetAni(entity)

		self.curPlayPetPoseId[entity.id] = nil
	end

	if self.curSelectedStudioPetId == oldEntityId and self.ctrl and self.ctrl.selectStudioEntity then
		self.ctrl:selectStudioEntity(nil)
	end

	self.placePetComp:retrievePet(oldEntityId)

	self.replacePreviewHiddenPetId = oldEntityId

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end
end

function StudioFuncPetPoseUIComponent:clearPreviewPet(replaceCtx)
	if self.previewPetId then
		self.placePetComp:retrievePet(self.previewPetId)

		self.previewPetId = nil
	end

	self:restoreReplacePreviewPet(replaceCtx)
end

function StudioFuncPetPoseUIComponent:openPetBox(replaceEntityId)
	local replaceCtx = self:buildReplacePetContext(replaceEntityId)

	if replaceEntityId and not replaceCtx then
		return
	end

	if not replaceCtx and self:getPlacedPetCount() >= self:getPlacablePetQuota() then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_PET_QUOTA_FULL"))

		return
	end

	local confirmed = false

	local function closeCallback()
		if not confirmed then
			self:clearPreviewPet(replaceCtx)
		end
	end

	pg.global.ui:open(UIConst.UI_ID_ACCESS_PET_BOX, {
		disableScenePreview = true,
		sceneType = UISceneConst.AVATAR_SCENE,
		curPetId = replaceCtx and replaceCtx.oldPetId or replaceEntityId,
		browseCallback = function(petId)
			self:previewStudioPet(petId, replaceCtx)
		end,
		selectCallback = function(petId)
			confirmed = true

			self:onSelectPet(petId, replaceCtx)
		end
	}, nil, closeCallback)
end

function StudioFuncPetPoseUIComponent:previewStudioPet(petId, replaceCtx)
	local ownerUid = replaceCtx and replaceCtx.ownerUid or pg.me.uid
	local previewEntityId = self:buildStudioPetEntityId(ownerUid, petId)

	if self.previewPetId and self.previewPetId ~= previewEntityId then
		self.placePetComp:retrievePet(self.previewPetId)

		self.previewPetId = nil
	end

	if not petId or self:isPetPlaced(petId, ownerUid) and (not replaceCtx or replaceCtx.oldPetId ~= petId) then
		self:restoreReplacePreviewPet(replaceCtx)

		return
	end

	if replaceCtx and replaceCtx.oldPetId == petId then
		self:restoreReplacePreviewPet(replaceCtx)

		return
	end

	self:hideReplacePreviewPet(replaceCtx)

	local entity = self.placePetComp:createPet(petId, ownerUid)

	if not entity then
		self:restoreReplacePreviewPet(replaceCtx)

		return
	end

	self.previewPetId = previewEntityId

	local scene = self:getStudioScene()

	if replaceCtx and scene then
		if replaceCtx.pos then
			scene:setStudioPetLocalPos(previewEntityId, replaceCtx.pos)
		end

		scene:setStudioPetLocalRotY(previewEntityId, replaceCtx.rotY or 0)
	elseif self.ctrl and self.ctrl.placeStudioPetAtScreenCenter then
		self.ctrl:placeStudioPetAtScreenCenter(previewEntityId)
	end
end

function StudioFuncPetPoseUIComponent:onSelectPet(petId, replaceCtx)
	if not petId then
		return
	end

	if replaceCtx then
		self:replaceStudioPet(replaceCtx, petId)

		return
	end

	local entityId = self:buildStudioPetEntityId(pg.me.uid, petId)

	if self:isPetPlaced(petId, pg.me.uid) then
		self.previewPetId = nil

		return
	end

	if self:getPlacedPetCount() >= self:getPlacablePetQuota() then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_PET_QUOTA_FULL"))

		return
	end

	local entity = self.placePetComp:createPet(petId, pg.me.uid)

	if not entity then
		return
	end

	self.previewPetId = nil
	self.studioPetOrder[#self.studioPetOrder + 1] = entityId
	self.studioPetOwnerUids[entityId] = pg.me.uid

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.selected then
		self:refreshStudioPetList()
	end

	self:selectStudioPetEntity(entity)

	if self.ctrl and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep("pet_add")
	end
end

function StudioFuncPetPoseUIComponent:replaceStudioPet(replaceCtx, newPetId)
	if not replaceCtx or not newPetId then
		return
	end

	local oldPetId = replaceCtx.oldPetId
	local oldEntityId = replaceCtx.oldEntityId
	local newEntityId = self:buildStudioPetEntityId(replaceCtx.ownerUid or pg.me.uid, newPetId)

	if newPetId == oldPetId then
		self:clearPreviewPet(replaceCtx)

		return
	end

	if self:isPetPlaced(newPetId, replaceCtx.ownerUid) then
		self:clearPreviewPet(replaceCtx)
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_PET_DUPLICATE"))

		return
	end

	local entity = self.placePetComp:createPet(newPetId, replaceCtx.ownerUid)

	if not entity then
		self:restoreReplacePreviewPet(replaceCtx)

		return
	end

	local scene = self:getStudioScene()

	if scene then
		if replaceCtx.pos then
			scene:setStudioPetLocalPos(newEntityId, replaceCtx.pos)
		end

		scene:setStudioPetLocalRotY(newEntityId, replaceCtx.rotY or 0)
	end

	local oldEntity = self.placePetComp:getPetEntity(oldEntityId)

	if oldEntity then
		self:clearCurPlayingPetAni(oldEntity)

		self.curPlayPetPoseId[oldEntity.id] = nil
	end

	self.placePetComp:retrievePet(oldEntityId)

	self.studioPetOrder[replaceCtx.orderIndex] = newEntityId
	self.studioPetOwnerUids[oldEntityId] = nil
	self.studioPetOwnerUids[newEntityId] = replaceCtx.ownerUid or pg.me.uid
	self.previewPetId = nil
	self.replacePreviewHiddenPetId = nil
	self.curSelectedStudioPetId = newEntityId

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.selected then
		self:refreshStudioPetList()
	end

	self:selectStudioPetEntity(entity)

	if self.ctrl and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep("pet_replace")
	end
end

function StudioFuncPetPoseUIComponent:retrieveStudioPet(entityId, fromQuota)
	if not entityId then
		return
	end

	if not fromQuota then
		for i = #self.studioPetOrder, 1, -1 do
			if self.studioPetOrder[i] == entityId then
				table.remove(self.studioPetOrder, i)

				break
			end
		end
	end

	self.placePetComp:retrievePet(entityId)

	self.studioPetOwnerUids[entityId] = nil

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.selected then
		self:refreshStudioPetList()
	end

	if not fromQuota and self.ctrl and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep("pet_remove")
	end
end

function StudioFuncPetPoseUIComponent:isPetPlaced(petId, ownerUid)
	local entityId = self:buildStudioPetEntityId(ownerUid or pg.me.uid, petId)

	for _, id in ipairs(self.studioPetOrder) do
		if id == entityId then
			return true
		end
	end

	return false
end

function StudioFuncPetPoseUIComponent:getCreatedPets()
	local ret = {}

	for _, entityId in ipairs(self.studioPetOrder) do
		local entity = self.placePetComp:getPetEntity(entityId)

		if entity then
			ret[#ret + 1] = entity
		end
	end

	return ret
end

function StudioFuncPetPoseUIComponent:isCurrentStudioMember(uid)
	local uidKey = getUidKey(uid)

	if not uidKey then
		return false
	end

	if uidKey == getUidKey(pg.me.uid) then
		return true
	end

	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()
	local info = studioUid and pg.me:getStudioInfo(studioUid)

	if not info then
		return true
	end

	if uidKey == getUidKey(info.masterUid) then
		return true
	end

	for _, member in ipairs(info.members or EMPTY_TABLE) do
		if uidKey == getUidKey(member.uid) then
			return true
		end
	end

	return false
end

function StudioFuncPetPoseUIComponent:buildStudioPetList()
	local list = {}

	self.petEntities = {}
	self.petVisible = {}

	for index, entityId in ipairs(self.studioPetOrder) do
		local _, ownerUid, petId = self:getStudioPetIdentity(entityId)
		local petInfo = pg.me:getPetInfo(petId)

		if petInfo then
			list[#list + 1] = {
				entityId = entityId,
				petId = petId,
				ownerUid = ownerUid or self.studioPetOwnerUids[entityId] or pg.me.uid,
				config = PetData[petInfo.templateId],
				templateId = petInfo.templateId
			}

			local entity = self.placePetComp:getPetEntity(entityId)
			local visible = entity ~= nil

			if entity and self.placePetComp.isPetVisible then
				visible = self.placePetComp:isPetVisible(entityId)
			end

			list[#list].entity = entity
			list[#list].visible = visible
			self.petEntities[index] = entity
			self.petVisible[index] = visible
		end
	end

	if self:getPlacedPetCount() < self:getPlacablePetQuota() then
		list[#list + 1] = {
			isEmpty = true
		}
	end

	self.studioPetListData = list

	return list
end

function StudioFuncPetPoseUIComponent:buildStudioPetMiniList()
	local list = {}
	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()
	local content = studioUid and pg.me:getCachedPhotographyStudioContent(studioUid)
	local players = content and content.players or {}
	local scene = self:getStudioScene()

	for uid, data in pairs(players) do
		if type(data) == "table" and not isSelfUid(uid) and self:isCurrentStudioMember(uid) and type(data.pets) == "table" then
			local ownerUid = getUidKey(uid)

			for _, petData in ipairs(data.pets) do
				local petId = petData.petId
				local templateId = petData.templateId

				if petId and templateId then
					local ownerUid = petData.ownerUid or ownerUid
					local entityId = self:buildStudioPetEntityId(ownerUid, petId)
					local entity = scene and scene:getStudioPet(entityId)

					if entity and self.placePetComp.registerPetEntity then
						self.placePetComp:registerPetEntity(entityId, entity)
					end

					local visible = entity ~= nil

					if entity and self.placePetComp.isPetVisible then
						visible = self.placePetComp:isPetVisible(entityId)
					end

					list[#list + 1] = {
						entityId = entityId,
						petId = petId,
						ownerUid = ownerUid,
						config = PetData[templateId],
						templateId = templateId,
						entity = entity,
						visible = visible
					}
				end
			end
		end
	end

	self.studioPetMiniListData = list

	return list
end

function StudioFuncPetPoseUIComponent:removeHiddenPetsFromPlayers(players)
	if not self:isStudioMaster() or type(players) ~= "table" or type(self.studioPetMiniListData) ~= "table" then
		return
	end

	for _, data in ipairs(self.studioPetMiniListData) do
		if data.visible == false then
			local ownerData = players[data.ownerUid]

			if not ownerData then
				for uid, playerData in pairs(players) do
					if getUidKey(uid) == getUidKey(data.ownerUid) then
						ownerData = playerData

						break
					end
				end
			end

			local pets = type(ownerData) == "table" and ownerData.pets or nil

			if type(pets) == "table" then
				for index = #pets, 1, -1 do
					if tostring(pets[index].petId) == tostring(data.petId) then
						table.remove(pets, index)

						break
					end
				end
			end
		end
	end
end

function StudioFuncPetPoseUIComponent:refreshUI()
	self:refreshStudioPetList()
	self.view.widget:TryChangePage("PetMode", 0)
	self.listPetModeUList:SetList(self.ViewModeConfig)
	self.listPetModeUList:DeselectAll()

	if self.ctrl:checkCanPetChangePos() and pg.game.input:isUsingGamepad() then
		self:switchViewMode(self.ViewMode.Pet)
	elseif self.ctrl:checkCanPetChangePos() then
		self.listPetModeUList:SelectItem(1)
	else
		self.listPetModeUList:SelectItem(0)
	end

	self.selected = true

	self:selectCurrentStudioPetEntity()
end

function StudioFuncPetPoseUIComponent:refreshStudioPetList()
	self:refreshPoseTabs()
	self.listPetUList:SetList(self:buildStudioPetList())
	self.listPetMiniUList:SetList(self:buildStudioPetMiniList())
	self.listPetUList:DeselectAll(false)
	self.listPetMiniUList:DeselectAll(false)
	self:selectStudioPetListItemByPetId(self.curSelectedStudioPetId, false)
end

function StudioFuncPetPoseUIComponent:refreshStudioPetEditState()
	self.listPetUList:RefreshList(true)
	self.listPetMiniUList:RefreshList(true)
end

function StudioFuncPetPoseUIComponent:findStudioPetListItem(entityId)
	if not entityId then
		return nil
	end

	for index, data in ipairs(self.studioPetListData or EMPTY_TABLE) do
		if data.entityId == entityId then
			return index, self.listPetUList, data
		end
	end

	for index, data in ipairs(self.studioPetMiniListData or EMPTY_TABLE) do
		if data.entityId == entityId then
			return index, self.listPetMiniUList, data
		end
	end

	return nil
end

function StudioFuncPetPoseUIComponent:getStudioPetListIndex(entityId)
	return self:findStudioPetListItem(entityId)
end

function StudioFuncPetPoseUIComponent:getStudioPetIdByEntityId(entityId)
	if not entityId or not self.placePetComp or not self.placePetComp.getRealEntityId then
		return nil
	end

	return self.placePetComp:getRealEntityId(entityId)
end

function StudioFuncPetPoseUIComponent:getStudioPetIdByEntity(entity)
	if not entity then
		return nil
	end

	return self:getStudioPetIdByEntityId(entity.id) or entity.studioPetEntityId
end

function StudioFuncPetPoseUIComponent:isStudioPetVisibleByPetId(entityId)
	if not entityId or not self.placePetComp then
		return false
	end

	local _, _, data = self:findStudioPetListItem(entityId)

	if data and data.visible ~= nil then
		return data.visible == true
	end

	if self.placePetComp.isPetVisible then
		return self.placePetComp:isPetVisible(entityId)
	end

	if self.placePetComp:getPetEntity(entityId) ~= nil then
		return true
	end

	local scene = self:getStudioScene()

	return scene and scene:getStudioPet(entityId) ~= nil or false
end

function StudioFuncPetPoseUIComponent:syncStudioPetListButtonSelection(uList)
	local function syncList(list)
		if not list then
			return
		end

		local buttons = list:GetAllButtons()

		for i = 0, buttons.Length - 1 do
			local button = buttons[i]
			local data = button.dataFromUList
			local objectReference = button:GetComponent("ObjectReference")
			local nodeButtonsRectTransform = objectReference:GetRefValue("nodeButtonsRectTransform")
			local showButtons = button.isSelected == true and data and not data.isEmpty and data.canOperate ~= false

			nodeButtonsRectTransform.gameObject:SetActiveEx(showButtons == true)
		end
	end

	if uList then
		syncList(uList)

		return
	end

	syncList(self.listPetUList)
	syncList(self.listPetMiniUList)
end

function StudioFuncPetPoseUIComponent:deselectStudioPetLists()
	self.listPetUList:DeselectAll(false)
	self.listPetMiniUList:DeselectAll(false)

	self.curSelectedStudioPetId = nil
	self.curSelectPetId = nil

	self.focalLengthSliderUWidget:SetActive(false)
	self:syncStudioPetListButtonSelection()
end

function StudioFuncPetPoseUIComponent:selectStudioPetListItem(list, index, sendCallback)
	if list == self.listPetUList then
		self.listPetMiniUList:DeselectAll(false)
	elseif list == self.listPetMiniUList then
		self.listPetUList:DeselectAll(false)
	end

	list:SelectItem(index - 1, sendCallback ~= false)

	if sendCallback == false then
		self:syncStudioPetListButtonSelection()
	end
end

function StudioFuncPetPoseUIComponent:selectStudioPetListItemByPetId(entityId, sendCallback)
	if not self.listPetUList then
		return
	end

	if not entityId or not self:isStudioPetVisibleByPetId(entityId) then
		self:deselectStudioPetLists()

		return
	end

	local index, list = self:getStudioPetListIndex(entityId)

	if index and list then
		self:selectStudioPetListItem(list, index, sendCallback)
	else
		self:deselectStudioPetLists()
	end
end

function StudioFuncPetPoseUIComponent:selectStudioPetListItemByEntity(entity, sendCallback)
	self:selectStudioPetListItemByPetId(self:getStudioPetIdByEntity(entity), sendCallback)
end

function StudioFuncPetPoseUIComponent:findObjects()
	PhotoFuncPetPoseUIComponent.findObjects(self)

	self.listPetMiniUList = self.objectReference:GetRefValue("listPetMiniUList")
end

function StudioFuncPetPoseUIComponent:onChangeToCameraMode()
	PhotoFuncPetPoseUIComponent.onChangeToCameraMode(self)
	self.listPetMiniUList:SetActive(false)
end

function StudioFuncPetPoseUIComponent:onChangeToPetMode()
	PhotoFuncPetPoseUIComponent.onChangeToPetMode(self)
	self.listPetMiniUList:SetActive(true)
end

function StudioFuncPetPoseUIComponent:onChangePetSelect(entityId)
	self.poseTypeId = self.poseTypeId or self.CameraPoseType.Static

	PhotoFuncPetPoseUIComponent.onChangePetSelect(self, entityId)
end

function StudioFuncPetPoseUIComponent:selectStudioPetEntity(entity)
	if not entity then
		return
	end

	self.curSelectedStudioPetId = self:getStudioPetIdByEntity(entity)

	if self.ctrl and self.ctrl.selectStudioEntity then
		self.ctrl:selectStudioEntity(entity)
	end

	if self.curSelectPetId ~= entity.id then
		self:onChangePetSelect(entity.id)
	end

	self:selectStudioPetListItemByEntity(entity, false)
end

function StudioFuncPetPoseUIComponent:selectCurrentStudioPetEntity()
	local _, _, data = self:findStudioPetListItem(self.curSelectedStudioPetId)

	if not data or data.visible ~= true or not data.entity then
		data = nil

		local petList = self.studioPetListData

		if petList then
			for _, petData in ipairs(petList) do
				if not petData.isEmpty and petData.visible == true and petData.entity then
					data = petData

					break
				end
			end
		end
	end

	if not data and self:isStudioMaster() then
		local petList = self.studioPetMiniListData

		if petList then
			for _, petData in ipairs(petList) do
				if petData.visible == true and petData.entity then
					data = petData

					break
				end
			end
		end
	end

	if data then
		self:selectStudioPetEntity(data.entity)
	end
end

function StudioFuncPetPoseUIComponent:onStudioEntitySelected(entity)
	local entityId = self:getStudioPetIdByEntity(entity)

	if not entityId or not self:isStudioPetVisibleByPetId(entityId) then
		self.curSelectedStudioPetId = nil

		if self.listPetUList then
			self:deselectStudioPetLists()
		end

		return
	end

	self.curSelectedStudioPetId = entityId

	if not self.selected then
		return
	end

	if self.curSelectPetId ~= entity.id then
		self:onChangePetSelect(entity.id)
	end

	self:selectStudioPetListItemByPetId(entityId, false)
end

function StudioFuncPetPoseUIComponent:setStudioPetVisible(entityId, visible)
	if not entityId or not self.placePetComp or not self.placePetComp.setPetVisible then
		return
	end

	self.placePetComp:setPetVisible(entityId, visible)

	local index, list, data = self:getStudioPetListIndex(entityId)

	if data then
		data.entity = self.placePetComp:getPetEntity(entityId)
		data.visible = visible == true and data.entity ~= nil
	end

	if visible == false and self.ctrl and self.ctrl.selectStudioEntity then
		if self.curSelectedStudioPetId == entityId then
			self.curSelectedStudioPetId = nil
		end

		self.ctrl:selectStudioEntity(nil)
	end

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.selected then
		if index and list then
			if visible == false then
				self:deselectStudioPetLists()
			end

			list:RefreshElement(index - 1)
			self:syncStudioPetListButtonSelection()
		else
			self:refreshStudioPetList()
		end
	end

	if visible == true then
		local entity = data and data.entity or self.placePetComp:getPetEntity(entityId)

		self:selectStudioPetEntity(entity)
	end

	if self.ctrl and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep(visible and "pet_release" or "pet_retrieve")
	end
end

function StudioFuncPetPoseUIComponent:isStudioPetEntityVisible(entity)
	if not entity then
		return nil
	end

	local entityId = self:getStudioPetIdByEntity(entity)

	if not entityId then
		return nil
	end

	return self:isStudioPetVisibleByPetId(entityId)
end

function StudioFuncPetPoseUIComponent:setupPetListRender()
	local function renderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local btnRetrieveUButton = objectReference:GetRefValue("btnRetrieveUButton")
		local btnReleaseUButton = objectReference:GetRefValue("btnReleaseUButton")
		local petUImage = objectReference:GetRefValue("petUImage")
		local btnChangeUButton = objectReference:GetRefValue("btnChangeUButton")
		local iconHeadUImage = objectReference:GetRefValue("iconHeadUImage")
		local nodeButtonsRectTransform = objectReference:GetRefValue("nodeButtonsRectTransform")

		index = index + 1

		local canManageAllPets = self:isStudioMaster()
		local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()
		local masterUid = studioUid and pg.me:getStudioMasterUid(studioUid)
		local isMultiple = self:getOtherMemberCount() > 0
		local isMultiEditing = studioUid ~= nil and pg.me:getPhotographyStudioActiveMemberCount(studioUid) > 1

		button:TryChangePage("master", 0)
		button:TryChangePage("multiple", isMultiple and 1 or 0)
		button:TryChangePage("type", 0)
		button:TryChangePage("state", 0)
		button:TryChangePage("Edit", 0)

		btnChangeUButton.luaClick = nil

		btnChangeUButton:SetActive(false)

		btnReleaseUButton.luaClick = nil
		btnRetrieveUButton.luaClick = nil

		nodeButtonsRectTransform.gameObject:SetActiveEx(false)

		if data.isEmpty then
			data.canOperate = true
			button.visibility = CS.XGUI.EVisibility.Visible

			button:TryChangePage("Empty", 1)

			button.luaSelectChanged = nil

			function button.luaClick(isFromNavigation)
				if isFromNavigation then
					return
				end

				self:openPetBox()
			end

			return
		end

		button:TryChangePage("Empty", 0)

		local isMasterPet = masterUid ~= nil and getUidKey(data.ownerUid) == getUidKey(masterUid)

		button:TryChangePage("master", isMultiple and isMasterPet and 1 or 0)

		local isEditing = isMultiEditing and not isSelfUid(data.ownerUid) and pg.me:isPhotographyStudioMemberActive(studioUid, data.ownerUid)

		button:TryChangePage("Edit", isEditing and 1 or 0)

		local isSelfPet = isSelfUid(data.ownerUid)
		local canOperate = canManageAllPets or isSelfPet

		data.canOperate = canOperate
		button.visibility = canOperate and CS.XGUI.EVisibility.Visible or CS.XGUI.EVisibility.HitTestInvisible

		local config = data.config

		if config then
			petUImage.url = LuaUIUtils.getPetIcon(config.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)
		end

		if isMultiple then
			iconHeadUImage.url = LuaUIUtils.getHeadIcon(data.ownerUid or data.uid or pg.me.uid)
		end

		local entity = data.entity
		local isHidden = entity ~= nil and data.visible == false
		local isVisible = entity ~= nil and not isHidden

		button:TryChangePage("state", isHidden and 1 or 0)
		button:TryChangePage("type", isVisible and 1 or 0)
		nodeButtonsRectTransform.gameObject:SetActiveEx(canOperate and button.isSelected == true)

		button.luaClick = nil
		button.luaSelectChanged = canOperate and function(isSelected)
			nodeButtonsRectTransform.gameObject:SetActiveEx(isSelected)

			if not isSelected then
				return
			end

			if entity and isVisible then
				self:selectStudioPetEntity(entity)
			end
		end or nil

		btnChangeUButton:SetActive(isSelfPet)

		btnChangeUButton.luaClick = isSelfPet and function()
			self:openPetBox(data.entityId)
		end or nil
		btnReleaseUButton.luaClick = canOperate and function()
			self:setStudioPetVisible(data.entityId, true)
		end or nil
		btnRetrieveUButton.luaClick = canOperate and function()
			self:setStudioPetVisible(data.entityId, false)
		end or nil
	end

	self.listPetUList.luaRenderItem = renderItem
	self.listPetMiniUList.luaRenderItem = renderItem
end

function StudioFuncPetPoseUIComponent:saveCameraTransform()
	return
end

function StudioFuncPetPoseUIComponent:restoreCameraTransform()
	return
end

function StudioFuncPetPoseUIComponent:tryTriggerAllPetsAction()
	return
end

function StudioFuncPetPoseUIComponent:saveToPreset(preset)
	return preset
end

function StudioFuncPetPoseUIComponent:applyPreset(preset)
	return
end

function StudioFuncPetPoseUIComponent:createPresetPets(preset)
	return
end

function StudioFuncPetPoseUIComponent:savePets()
	local scene = self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()
	local pets = {}

	if not scene then
		return pets
	end

	for _, entityId in ipairs(self.studioPetOrder) do
		local _, ownerUid, petId = self:getStudioPetIdentity(entityId)
		local pInfo = pg.me.pets and pg.me.pets[petId]
		local entity = self.placePetComp:getPetEntity(entityId)
		local isVisible = entity ~= nil

		if isVisible and self.placePetComp.isPetVisible then
			isVisible = self.placePetComp:isPetVisible(entityId)
		end

		if pInfo and isVisible then
			local pos = scene:getStudioPetLocalPos(entityId)
			local ry = scene:getStudioPetLocalRotY(entityId)
			local petJewelryInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[petId]
			local petData = {
				petId = petId,
				ownerUid = ownerUid or self.studioPetOwnerUids[entityId] or pg.me.uid,
				templateId = pInfo.templateId,
				label = pInfo.label,
				gender = pInfo.gender,
				shinyStyle = pInfo.shinyStyle,
				shinyEffectReplace = pInfo.shinyEffectReplace or "",
				petJewelryInfo = PhotographyStudioUtils.serializePetJewelryInfo(petJewelryInfo, petId),
				selectTransmogScheme = PhotographyStudioUtils.toRawTable(PetTransmogUtils.getSelectedScheme(pInfo)),
				pos = pos and {
					x = pos.x,
					y = pos.y,
					z = pos.z
				} or nil,
				rotY = ry or 0,
				petPoseId = entity and self.curPlayPetPoseId[entity.id] or nil
			}
			local gazeData = entity and self.ctrl:getStudioPetGazeData(entity)

			if gazeData then
				petData.gazeType = gazeData.gazeType

				if gazeData.gazePos and NotNil(scene.entityRootTransform) then
					local worldPos = gazeData.gazePos
					local localPos = scene.entityRootTransform:InverseTransformPoint(Vector3(worldPos.x, worldPos.y, worldPos.z))

					petData.gazePos = {
						x = localPos.x,
						y = localPos.y,
						z = localPos.z
					}
				end
			end

			pets[#pets + 1] = petData
		end
	end

	return pets
end

function StudioFuncPetPoseUIComponent:applyPets(pets)
	local targetPetSet = {}
	local targetPets = {}

	if type(pets) == "table" then
		for _, data in ipairs(pets) do
			local petId = data.petId
			local ownerUid = data.ownerUid or data.uid or pg.me.uid
			local entityId = self:buildStudioPetEntityId(ownerUid, petId)

			if petId and not targetPetSet[entityId] and #targetPets < self:getPlacablePetQuota() then
				targetPetSet[entityId] = true
				targetPets[#targetPets + 1] = data
			end
		end
	end

	for i = #self.studioPetOrder, 1, -1 do
		local entityId = self.studioPetOrder[i]

		if not targetPetSet[entityId] then
			local entity = self.placePetComp:getPetEntity(entityId)

			if entity then
				self:clearCurPlayingPetAni(entity)

				self.curPlayPetPoseId[entity.id] = nil
			end

			self.placePetComp:retrievePet(entityId)
		end
	end

	self.studioPetOrder = {}
	self.studioPetOwnerUids = {}
	self.previewPetId = nil

	local scene = self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()

	for _, data in ipairs(targetPets) do
		local petId = data.petId
		local ownerUid = data.ownerUid or data.uid or pg.me.uid
		local entityId = self:buildStudioPetEntityId(ownerUid, petId)
		local entity = self.placePetComp:createPet(petId, ownerUid, data)

		if entity then
			self.studioPetOrder[#self.studioPetOrder + 1] = entityId
			self.studioPetOwnerUids[entityId] = ownerUid

			if scene then
				if data.pos then
					scene:setStudioPetLocalPos(entityId, Vector3(data.pos.x, data.pos.y, data.pos.z))
				end

				scene:setStudioPetLocalRotY(entityId, data.rotY or 0)
			end

			if self.curPlayPetPoseId[entity.id] ~= data.petPoseId then
				self:clearCurPlayingPetAni(entity)

				self.curPlayPetPoseId[entity.id] = nil

				if data.petPoseId then
					self:applyPetPose(entity.id, data.petPoseId)
				end
			end

			local gazePos

			if data.gazePos and scene and NotNil(scene.entityRootTransform) then
				local localPos = data.gazePos
				local worldPos = scene.entityRootTransform:TransformPoint(Vector3(localPos.x, localPos.y, localPos.z))

				gazePos = {
					x = worldPos.x,
					y = worldPos.y,
					z = worldPos.z
				}
			end

			self.ctrl:applyStudioPetGaze(entity, data.gazeType, gazePos)
		end
	end

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.selected then
		self:refreshStudioPetList()
	end
end

return StudioFuncPetPoseUIComponent
