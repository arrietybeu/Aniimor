-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioFuncPlayerPoseUIComponent.lua

local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AppearanceAction = require("Data.appearance_action_data")
local PhotoFuncPlayerPoseUIComponent = require("Guis.Panels.Photo.Component.PhotoFuncPlayerPoseUIComponent")
local PhotoFuncPetPoseUIComponent = require("Guis.Panels.Photo.Component.PhotoFuncPetPoseUIComponent")
local PlayerViewModeConfig = {
	{
		id = PhotoFuncPetPoseUIComponent.ViewMode.Camera
	},
	{
		id = PhotoFuncPetPoseUIComponent.ViewMode.Player
	}
}

local function getUidKey(uid)
	return uid and tostring(uid) or nil
end

local function isSelfUid(uid)
	return getUidKey(uid) == getUidKey(pg.me.uid)
end

local function getPoseAnimation(config)
	if not config then
		return nil
	end

	local aniLoop
	local res = config.res1

	if res and #res > 0 then
		aniLoop = #res == 3 and res[2] or res[1]
	end

	if config.photo == 2 then
		return aniLoop or config.resLoop and PlayableConst[config.resLoop] or PlayableConst[config.res]
	end

	return aniLoop or PlayableConst[config.res]
end

local StudioFuncPlayerPoseUIComponent = Class.LightClass("StudioFuncPlayerPoseUIComponent", PhotoFuncPlayerPoseUIComponent)

function StudioFuncPlayerPoseUIComponent:findObjects()
	PhotoFuncPlayerPoseUIComponent.findObjects(self)

	self.listPlayerUList = self.objectReference:GetRefValue("listPlayerUList")
	self.listPlayerModeUList = self.objectReference:GetRefValue("listPlayerModeUList")
end

function StudioFuncPlayerPoseUIComponent:initView()
	self:setupPlayerModeListRender()
	self:setupPlayerListRender()
	PhotoFuncPlayerPoseUIComponent.initView(self)
end

function StudioFuncPlayerPoseUIComponent:setupPlayerModeListRender()
	function self.listPlayerModeUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.id - 1)

		function button.luaSelectChanged(isSelected)
			if not isSelected then
				return
			end

			local isPlayerMode = data.id == PhotoFuncPetPoseUIComponent.ViewMode.Player

			self.view.widget:TryChangePage("PetMode", isPlayerMode and 1 or 0)
			self.listPlayerUList:SetActive(isPlayerMode)
		end
	end
end

function StudioFuncPlayerPoseUIComponent:getStudioScene()
	return self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()
end

function StudioFuncPlayerPoseUIComponent:isStudioMaster()
	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()

	return studioUid ~= nil and pg.me:isStudioMaster(studioUid) == true
end

function StudioFuncPlayerPoseUIComponent:getPlayerUid(entity)
	if not entity then
		return nil
	end

	if entity.getStudioPlayerUid then
		return entity:getStudioPlayerUid()
	end

	return entity.studioPlayerUid
end

function StudioFuncPlayerPoseUIComponent:isStudioPlayerEntity(entity)
	if not entity then
		return false
	end

	local scene = self:getStudioScene()

	return self:getPlayerUid(entity) ~= nil or scene and scene:getCurEntity() == entity
end

function StudioFuncPlayerPoseUIComponent:getPlayerEntityId(entity)
	local scene = self:getStudioScene()

	if not scene or not entity then
		return nil
	end

	if scene:getCurEntity() == entity then
		return scene:getCurEntityId()
	end

	local uid = self:getPlayerUid(entity)

	if uid and scene:getEntity(uid) == entity then
		return uid
	end

	return nil
end

function StudioFuncPlayerPoseUIComponent:getTargetPlayerEntity()
	local entity = self.selectedPlayerEntity
	local scene = self:getStudioScene()

	if entity and scene and self:getPlayerEntityId(entity) then
		return entity
	end

	return self.ctrl:getSelfEntity()
end

function StudioFuncPlayerPoseUIComponent:getPlayerListData(uid)
	local uidKey = getUidKey(uid)

	if not uidKey or type(self.studioPlayerListData) ~= "table" then
		return nil
	end

	for index, data in ipairs(self.studioPlayerListData) do
		if getUidKey(data.uid) == uidKey then
			return index, data
		end
	end

	return nil
end

function StudioFuncPlayerPoseUIComponent:buildStudioPlayerList()
	local list = {}
	local scene = self:getStudioScene()

	if not scene then
		self.studioPlayerListData = list

		return list
	end

	local added = {}

	local function addPlayer(uid, entity, entityId)
		local uidKey = getUidKey(uid)

		if not uidKey or not entity or not entityId or added[uidKey] then
			return
		end

		added[uidKey] = true
		list[#list + 1] = {
			uid = uid,
			entity = entity,
			entityId = entityId,
			visible = scene:isStudioPlayerVisible(entityId)
		}
	end

	local selfEntity = scene:getCurEntity()

	addPlayer(self:getPlayerUid(selfEntity) or pg.me.uid, selfEntity, scene:getCurEntityId())

	if type(scene.studioPlayerIds) == "table" then
		for uid, _ in pairs(scene.studioPlayerIds) do
			local entity = scene:getEntity(uid)

			addPlayer(self:getPlayerUid(entity) or uid, entity, uid)
		end
	end

	local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()
	local masterUid = studioUid and pg.me:getStudioMasterUid(studioUid)

	table.sort(list, function(left, right)
		local leftMaster = getUidKey(left.uid) == getUidKey(masterUid)
		local rightMaster = getUidKey(right.uid) == getUidKey(masterUid)

		if leftMaster ~= rightMaster then
			return leftMaster
		end

		return tostring(left.uid) < tostring(right.uid)
	end)

	self.studioPlayerListData = list

	return list
end

function StudioFuncPlayerPoseUIComponent:resetTrackedPlayerPose()
	self.curPlayPlayerPoseAni = nil
	self.curPlayPoseAni = nil
	self.curPlayerDynamicPoseState = nil
	self.curDynamicPoseState = nil
	self.curPlayPoseEnt = nil
	self.autoPlayDynamicPose = false

	self.focalLengthSliderUWidget:SetActive(false)
end

function StudioFuncPlayerPoseUIComponent:refreshSelectedPlayerPose()
	self:resetTrackedPlayerPose()

	local entity = self:getTargetPlayerEntity()

	self:refreshTargetPlayerBodyType()

	self.curPlayPlayerPoseId = entity and entity.studioPlayerPoseId

	local config = self.curPlayPlayerPoseId and AppearanceAction[self.curPlayPlayerPoseId]

	if not config then
		return
	end

	local ani = getPoseAnimation(config)

	self.curPlayPoseAni = ani
	self.curPlayPlayerPoseAni = ani
	self.curAnimName = config.res

	if config.photo ~= self.CameraPoseType.Dynamic then
		return
	end

	local scene = self:getStudioScene()
	local entityId = self:getPlayerEntityId(entity)
	local state = scene and scene.studioPlayerPoseStates and scene.studioPlayerPoseStates[entityId]

	if not state then
		return
	end

	self.curPlayPoseEnt = entity
	self.curDynamicPoseState = state
	self.curPlayerDynamicPoseState = state

	self:setDynamicPoseUSliderMaxValue(state.Length)
	self.dynamicPoseUSlider:SetValueWithoutCallback(state.Time)

	self.autoPlayDynamicPose = state:GetSpeed() ~= 0

	self.btnPlayOrStopUButton:TryChangePage("IsPlay", self.autoPlayDynamicPose and 1 or 0)
	self.focalLengthSliderUWidget:SetActive(true)
end

function StudioFuncPlayerPoseUIComponent:selectStudioPlayer(entity, selectSceneEntity)
	if not self:isStudioPlayerEntity(entity) then
		return
	end

	self.selectedPlayerEntity = entity
	self.selectedPlayerUid = self:getPlayerUid(entity) or pg.me.uid

	self:refreshSelectedPlayerPose()

	if self.haveRefreshed then
		self:refreshPoseTabs()
	end

	if selectSceneEntity and self.ctrl and self.ctrl.selectStudioEntity then
		local scene = self:getStudioScene()
		local entityId = self:getPlayerEntityId(entity)

		if scene and entityId and scene:isStudioPlayerVisible(entityId) then
			self.ctrl:selectStudioEntity(entity)
		end
	end
end

function StudioFuncPlayerPoseUIComponent:syncPlayerListButtonSelection()
	local buttons = self.listPlayerUList:GetAllButtons()

	for index = 0, buttons.Length - 1 do
		local button = buttons[index]
		local data = button.dataFromUList
		local objectReference = button:GetComponent("ObjectReference")
		local nodeButtonsRectTransform = objectReference:GetRefValue("nodeButtonsRectTransform")
		local showButtons = button.isSelected == true and data and data.canOperate ~= false

		nodeButtonsRectTransform.gameObject:SetActiveEx(showButtons == true)
	end
end

function StudioFuncPlayerPoseUIComponent:selectStudioPlayerListItem(entity, selectSceneEntity)
	local uid = self:getPlayerUid(entity)
	local index = self:getPlayerListData(uid)

	if not index then
		return
	end

	self.listPlayerUList:DeselectAll(false)
	self.listPlayerUList:SelectItem(index - 1, false)
	self:selectStudioPlayer(entity, selectSceneEntity)
	self:syncPlayerListButtonSelection()
end

function StudioFuncPlayerPoseUIComponent:refreshStudioPlayerList(selectSelfEntity)
	if not self.listPlayerUList then
		return
	end

	local selectedUid = selectSelfEntity and pg.me.uid or self.selectedPlayerUid or pg.me.uid

	self.listPlayerUList:SetList(self:buildStudioPlayerList())
	self.listPlayerUList:DeselectAll(false)

	local index, data = self:getPlayerListData(selectedUid)

	if not data then
		index, data = self:getPlayerListData(pg.me.uid)
	end

	if data then
		self.listPlayerUList:SelectItem(index - 1, false)
		self:selectStudioPlayer(data.entity, selectSelfEntity == true)
	else
		self.selectedPlayerEntity = nil
		self.selectedPlayerUid = nil

		self:refreshSelectedPlayerPose()
	end

	self:syncPlayerListButtonSelection()
end

function StudioFuncPlayerPoseUIComponent:refreshStudioPlayerEditState()
	self.listPlayerUList:RefreshList(true)
end

function StudioFuncPlayerPoseUIComponent:setStudioPlayerVisible(data, visible)
	local scene = self:getStudioScene()

	if not scene or not data or not data.entity then
		return
	end

	scene:setStudioPlayerVisible(data.entityId, visible)

	data.visible = visible ~= false

	if visible == false and self.ctrl and self.ctrl.selectStudioEntity then
		self.ctrl:selectStudioEntity(nil)
		self.listPlayerUList:DeselectAll(false)
	end

	local index = self:getPlayerListData(data.uid)

	if index then
		self.listPlayerUList:RefreshElement(index - 1)
		self:syncPlayerListButtonSelection()
	end

	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end

	if self.ctrl and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep(visible and "player_release" or "player_retrieve")
	end
end

function StudioFuncPlayerPoseUIComponent:isStudioPlayerEntityVisible(entity)
	if not self:isStudioPlayerEntity(entity) then
		return nil
	end

	local scene = self:getStudioScene()
	local entityId = self:getPlayerEntityId(entity)

	return scene and entityId and scene:isStudioPlayerVisible(entityId) or false
end

function StudioFuncPlayerPoseUIComponent:onStudioEntitySelected(entity)
	if not self:isStudioPlayerEntity(entity) then
		self.selectedPlayerEntity = nil
		self.selectedPlayerUid = nil

		self:refreshSelectedPlayerPose()

		if self.haveRefreshed then
			self:refreshPoseTabs()
		end

		self.listPlayerUList:DeselectAll(false)
		self:syncPlayerListButtonSelection()

		return
	end

	self:selectStudioPlayerListItem(entity, false)
end

function StudioFuncPlayerPoseUIComponent:setupPlayerListRender()
	function self.listPlayerUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local btnRetrieveUButton = objectReference:GetRefValue("btnRetrieveUButton")
		local btnReleaseUButton = objectReference:GetRefValue("btnReleaseUButton")
		local petUImage = objectReference:GetRefValue("petUImage")
		local btnChangeUButton = objectReference:GetRefValue("btnChangeUButton")
		local nodeButtonsRectTransform = objectReference:GetRefValue("nodeButtonsRectTransform")
		local studioUid = self.ctrl and self.ctrl.getStudioUid and self.ctrl:getStudioUid()
		local masterUid = studioUid and pg.me:getStudioMasterUid(studioUid)
		local isMultiple = #self.studioPlayerListData > 1
		local isMultiEditing = studioUid ~= nil and pg.me:getPhotographyStudioActiveMemberCount(studioUid) > 1
		local isMasterPlayer = getUidKey(data.uid) == getUidKey(masterUid)
		local canOperate = self:isStudioMaster() or isSelfUid(data.uid)

		data.canOperate = canOperate

		button:TryChangePage("Empty", 0)
		button:TryChangePage("master", isMultiple and isMasterPlayer and 1 or 0)
		button:TryChangePage("multiple", 1)
		button:TryChangePage("type", data.visible and 1 or 0)
		button:TryChangePage("state", data.visible and 0 or 1)

		local isEditing = isMultiEditing and not isSelfUid(data.uid) and pg.me:isPhotographyStudioMemberActive(studioUid, data.uid)

		button:TryChangePage("Edit", isEditing and 1 or 0)

		button.visibility = canOperate and CS.XGUI.EVisibility.Visible or CS.XGUI.EVisibility.HitTestInvisible
		petUImage.url = LuaUIUtils.getHeadIcon(data.uid)
		btnChangeUButton.luaClick = nil

		btnChangeUButton:SetActive(false)

		btnReleaseUButton.luaClick = canOperate and function()
			self:setStudioPlayerVisible(data, true)
		end or nil
		btnRetrieveUButton.luaClick = canOperate and function()
			self:setStudioPlayerVisible(data, false)
		end or nil

		nodeButtonsRectTransform.gameObject:SetActiveEx(canOperate and button.isSelected == true)

		button.luaClick = nil
		button.luaSelectChanged = canOperate and function(isSelected)
			nodeButtonsRectTransform.gameObject:SetActiveEx(isSelected)

			if isSelected then
				self:selectStudioPlayer(data.entity, true)
			end
		end or nil
	end
end

function StudioFuncPlayerPoseUIComponent:getPlayerAnimLayer()
	return PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY
end

function StudioFuncPlayerPoseUIComponent:shouldResetPlayerAnimOnDestroy()
	return false
end

function StudioFuncPlayerPoseUIComponent:playActionInner(config, entity)
	local scene = self:getStudioScene()

	if not scene or not entity then
		return
	end

	local entityId = self:getPlayerEntityId(entity)

	if not entityId then
		return
	end

	scene:applyStudioPlayerPose(entityId, self.curPlayPlayerPoseId)

	self.curAnimName = config and config.res
	self.curPlayPoseEnt = entity
	self.curPlayPoseAni = getPoseAnimation(config)
	self.curDynamicPoseState = nil
	self.curPlayerDynamicPoseState = nil

	self.focalLengthSliderUWidget:SetActive(false)

	if config and config.photo == self.CameraPoseType.Dynamic then
		local state = scene.studioPlayerPoseStates and scene.studioPlayerPoseStates[entityId]

		if state then
			self.curDynamicPoseState = state
			self.curPlayerDynamicPoseState = state

			self:setDynamicPoseUSliderMaxValue(state.Length)
			self.dynamicPoseUSlider:SetValueWithoutCallback(state.Time)

			self.autoPlayDynamicPose = true

			self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)
			self.focalLengthSliderUWidget:SetActive(true)
		end
	end

	return self.curPlayPoseAni
end

function StudioFuncPlayerPoseUIComponent:onPlayerDynamicPoseStateChanged(state)
	local scene = self:getStudioScene()
	local entityId = self:getPlayerEntityId(self.curPlayPoseEnt)

	if not scene or not entityId then
		return
	end

	if not scene.studioPlayerPoseStates then
		scene.studioPlayerPoseStates = {}
	end

	scene.studioPlayerPoseStates[entityId] = state
end

function StudioFuncPlayerPoseUIComponent:refreshUI()
	PhotoFuncPlayerPoseUIComponent.refreshUI(self)
	self.view.widget:TryChangePage("PetMode", 0)
	self.listPlayerModeUList:SetList(PlayerViewModeConfig)
	self.listPlayerModeUList:DeselectAll()
	self.listPlayerModeUList:SelectItem(1)
	self:refreshStudioPlayerList(true)
end

function StudioFuncPlayerPoseUIComponent:saveToPreset(preset)
	local selfEntity = self.ctrl:getSelfEntity()

	preset.playerPoseId = selfEntity and selfEntity.studioPlayerPoseId
end

function StudioFuncPlayerPoseUIComponent:applyPreset(preset)
	self:refreshStudioPlayerList()
end

return StudioFuncPlayerPoseUIComponent
