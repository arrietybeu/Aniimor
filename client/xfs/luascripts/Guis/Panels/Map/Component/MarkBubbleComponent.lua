-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MarkBubbleComponent.lua

local Class = require("Core.Framework.Class")
local UIObjectPool = require("Utils.UIObjectPool")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local UIComponent = require("Guis.Helper.UIComponent")
local QuestConst = require("Common.Const.QuestConst")
local UIConst = require("Const.UIConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local MapUtils = require("Guis.Utils.MapUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local GrabEggMapMarkUtils = require("GameApp.GrabEgg.GrabEggMapMarkUtils")
local MapMarkPrefabPoolManager = require("Guis.Utils.MapMarkPrefabPoolManager")
local MarkBubbleComponent = Class.LightClass("MarkBubbleComponent", UIComponent)

function MarkBubbleComponent:findObjects()
	self.SCALE_COE = 0.9
	self.SEMI_MAJOR_LEN = Screen.width * self.SCALE_COE / 2
	self.SEMI_MINOR_LEN = Screen.height * self.SCALE_COE / 2
	self.SCREEN_CENTER_X = Screen.width / 2
	self.SCREEN_CENTER_Y = Screen.height / 2
	self.SCREEN_CENTER = Vector2(self.SCREEN_CENTER_X, self.SCREEN_CENTER_Y)
	self.mapCenterX = nil
	self.mapCenterY = nil
	self.sceneMarkPointData = self.ctrl.sceneMarkPointData
	self.tempMarkPointData = self.ctrl.tempMarkPointData
	self.mineMark = self.view.mineMarkTrans
	self.markCaches = self.ctrl.markCaches
	self.bubbleMarks = {}
	self.bubbleMarksObjCaches = {}
	self.tempVector3 = Vector3(0, 0, 0)
	self.leftBotX, self.leftBotY = self.ctrl:getPointerPos({
		0,
		0
	})
	self.rightTopX, self.rightTopY = self.ctrl:getPointerPos({
		Screen.width,
		Screen.height
	})
	self.objPool = UIObjectPool.new(AddressDataConst.UI_NODE_BUBBLE_TRACK_RES, self.view.bubbleGroupTransform, 5, 1, 1, 1)
end

function MarkBubbleComponent:initView()
	self.timer = self.ctrl:startTimer(function()
		self:tick()
	end, 0, true)
end

function MarkBubbleComponent:tick()
	self.centerX, self.centerY = self.ctrl:getPointerPos({
		self.SCREEN_CENTER_X,
		self.SCREEN_CENTER_Y
	})
	self.SCREEN_CENTER[1] = self.centerX
	self.SCREEN_CENTER[2] = self.centerY
	self.leftBotX, self.leftBotY = self.ctrl:getPointerPos({
		0,
		0
	})
	self.rightTopX, self.rightTopY = self.ctrl:getPointerPos({
		Screen.width,
		Screen.height
	})

	self:updateBubbleMarksTableData()
	self:updateBubbleMarksObjCaches()
	self:showOrHideQuestMarkBubbles()
end

function MarkBubbleComponent:updateBubbleMarksTableData()
	if not pg.me.space then
		return
	end

	if not self.ctrl:isDifferentScene() then
		local pos = {
			self.ctrl.mineMarkMapPosX,
			self.ctrl.mineMarkMapPosY
		}

		if self:isOutOfViewPort(pos[1], pos[2]) then
			if not self.bubbleMarks.mine then
				self.bubbleMarks.mine = {
					isMine = true,
					pos = pos
				}

				self:onBubbleMarksAdded("mine", {
					isMine = true,
					pos = pos
				})
			else
				self.bubbleMarks.mine.pos = pos
			end
		else
			if self.bubbleMarks.mine then
				self:onBubbleMarksDeleted("mine")
			end

			self.bubbleMarks.mine = nil
		end
	end

	for spawnerId, spawnerTable in pairs(self.sceneMarkPointData) do
		if self.markCaches[spawnerId] and (DefaultMapMarkData[spawnerTable.markConfigId] and DefaultMapMarkData[spawnerTable.markConfigId].globalBubble == 1 or self.ctrl:_checkTrackMarkExists(spawnerId)) and self:isValidMark(spawnerTable.markType, spawnerId) then
			local pos = {
				self.markCaches[spawnerId].anchoredPositionX,
				self.markCaches[spawnerId].anchoredPositionY
			}

			if self:isOutOfViewPort(pos[1], pos[2]) then
				if not self.bubbleMarks[spawnerId] then
					self.bubbleMarks[spawnerId] = {
						pos = pos,
						markType = spawnerTable.markType
					}

					self:onBubbleMarksAdded(spawnerId, {
						pos = pos,
						markType = spawnerTable.markType,
						type = spawnerTable.type
					})
				else
					self.bubbleMarks[spawnerId].pos = pos
				end
			else
				if self.bubbleMarks[spawnerId] then
					self:onBubbleMarksDeleted(spawnerId)
				end

				self.bubbleMarks[spawnerId] = nil
			end
		else
			if self.bubbleMarks[spawnerId] then
				self:onBubbleMarksDeleted(spawnerId)
			end

			self.bubbleMarks[spawnerId] = nil
		end
	end

	for spawnerId, spawnerTable in pairs(self.tempMarkPointData) do
		if self.markCaches[spawnerId] and (DefaultMapMarkData[spawnerTable.markConfigId] and DefaultMapMarkData[spawnerTable.markConfigId].globalBubble == 1 or self.ctrl:_checkTrackMarkExists(spawnerId)) and self:isValidMark(spawnerTable.markType, spawnerId) then
			local pos = {
				self.markCaches[spawnerId].anchoredPositionX,
				self.markCaches[spawnerId].anchoredPositionY
			}

			if self:isOutOfViewPort(pos[1], pos[2]) then
				if not self.bubbleMarks[spawnerId] then
					self.bubbleMarks[spawnerId] = {
						pos = pos,
						markType = spawnerTable.markType
					}

					self:onBubbleMarksAdded(spawnerId, {
						pos = pos,
						markType = spawnerTable.markType,
						type = spawnerTable.type
					})
				else
					self.bubbleMarks[spawnerId].pos = pos
				end
			else
				if self.bubbleMarks[spawnerId] then
					self:onBubbleMarksDeleted(spawnerId)
				end

				self.bubbleMarks[spawnerId] = nil
			end
		else
			if self.bubbleMarks[spawnerId] then
				self:onBubbleMarksDeleted(spawnerId)
			end

			self.bubbleMarks[spawnerId] = nil
		end
	end
end

function MarkBubbleComponent:isValidMark(markType, spawnerId)
	return true
end

function MarkBubbleComponent:updateBubbleMarksObjCaches()
	for k, v in pairs(self.bubbleMarksObjCaches) do
		local dir = self.bubbleMarks[k].pos - self.SCREEN_CENTER
		local angle = math.deg(math.atan2(dir.y, dir.x))
		local radians = math.rad(angle)
		local r = self.SEMI_MAJOR_LEN * self.SEMI_MINOR_LEN / math.sqrt(math.pow(self.SEMI_MAJOR_LEN * math.sin(radians), 2) + math.pow(self.SEMI_MINOR_LEN * math.cos(radians), 2))
		local posX = r * math.cos(radians) + self.SCREEN_CENTER_X
		local posY = r * math.sin(radians) + self.SCREEN_CENTER_Y

		self.tempVector3:Set(posX, posY, 0)

		local newPos = UIUtils.ScreenPointToUIPoint(v.rt, self.tempVector3)

		v.rt.position = newPos
		v.arrowRt.rotation = Quaternion.Euler(0, 0, angle + 90)
	end
end

function MarkBubbleComponent:onBubbleMarksAdded(key, info)
	self.objPool:createFromPool({}, key, function(objInfo)
		local objectReference = objInfo.gameObject:GetComponent("ObjectReference")
		local imgArrowUImage = objectReference:GetRefValue("imgArrowUImage").transform
		local markPointTransform = objectReference:GetRefValue("markPointTransform")
		local btn = objInfo.gameObject:GetComponent("UButton")

		self:renderMark(key, info, btn)

		if info.isMine then
			self.bubbleMarksObjCaches[key] = {
				rt = objInfo.gameObject:GetComponent("RectTransform"),
				arrowRt = imgArrowUImage
			}
		else
			local tableData = self.markCaches[key]

			btn:TryChangePage("MapFilterHide", not pg.game.map:isEnabledByFilter(self.ctrl.sceneId, tableData.markConfigId, tableData.markStatus, tableData.spawnerId, {
				finishStateAlwaysShow = tableData.finishStateAlwaysShow
			}) and 1 or 0)

			btn.renderOpacity = pg.game.map:isEnabledByTotalFilter(self.ctrl.sceneId, tableData.markConfigId) and 1 or 0

			local obj = self.view:addPrefabWithPathSync(markPointTransform, AddressDataConst.UI_MARK_1)

			self.bubbleMarksObjCaches[key] = {
				rt = objInfo.gameObject:GetComponent("RectTransform"),
				arrowRt = imgArrowUImage,
				innerMark = obj.gameObject,
				button = btn
			}

			self:renderInnerMark(obj.gameObject:GetComponent("UButton"), key)
			self:renderTeamTrackBadge(key)
		end
	end)
end

function MarkBubbleComponent:onBubbleMarksDeleted(key)
	local cache = self.bubbleMarksObjCaches[key]

	if cache then
		self:_clearBubbleCommonIcon(key)
		self:_clearTeamTrackBadge(key)

		if cache.innerMark then
			self.view:destroyInstance(cache.innerMark)
		end
	end

	self.objPool:recycleToPool(key, function()
		self.bubbleMarksObjCaches[key] = nil
	end)
end

function MarkBubbleComponent:_bindBubbleCommonIcon(key, parent, iconUrl)
	local cache = self.bubbleMarksObjCaches[key]

	if not cache then
		return
	end

	cache.commonIconUrl = iconUrl

	if cache.commonIconLease then
		if NotNil(cache.commonIconObj) then
			cache.commonIconObj:GetComponent("UImage").url = iconUrl or ""

			return
		end

		MapMarkPrefabPoolManager:Release(cache.commonIconLease, cache, true)

		cache.commonIconLease = nil
		cache.commonIconObj = nil
	end

	if cache.commonIconRequest then
		return
	end

	cache.commonIconGeneration = (cache.commonIconGeneration or 0) + 1

	local generation = cache.commonIconGeneration
	local request = MapMarkPrefabPoolManager:Acquire(AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON, cache, generation, parent, function(gameObject, lease)
		cache.commonIconRequest = nil

		if not lease or IsNil(gameObject) then
			return
		end

		if self.bubbleMarksObjCaches[key] ~= cache or cache.commonIconGeneration ~= generation then
			MapMarkPrefabPoolManager:Release(lease, cache)

			return
		end

		cache.commonIconLease = lease
		cache.commonIconObj = gameObject
		gameObject:GetComponent("UImage").url = cache.commonIconUrl or ""
	end, MapMarkPrefabPoolManager.OwnerTag.BIG_MAP_BUBBLE_COMMON_ICON)

	if request and not request.completed then
		cache.commonIconRequest = request
	end
end

function MarkBubbleComponent:_clearBubbleCommonIcon(key, forceDiscard)
	local cache = self.bubbleMarksObjCaches[key]

	if not cache then
		return
	end

	cache.commonIconGeneration = (cache.commonIconGeneration or 0) + 1

	if cache.commonIconRequest then
		MapMarkPrefabPoolManager:CancelRequest(cache.commonIconRequest, cache)

		cache.commonIconRequest = nil
	end

	if cache.commonIconLease then
		MapMarkPrefabPoolManager:Release(cache.commonIconLease, cache, forceDiscard)
	end

	cache.commonIconLease = nil
	cache.commonIconObj = nil
	cache.commonIconUrl = nil
end

function MarkBubbleComponent:showOrHideQuestMarkBubbles()
	local closestDist = math.maxFloat
	local closestKey
	local tempKey = {}

	for key, _ in pairs(self.bubbleMarksObjCaches) do
		if key ~= "mine" and self.markCaches[key] and self.markCaches[key].markType == Const.MAP_MARK_QUEST then
			tempKey[key] = false

			local x = self.markCaches[key].anchoredPositionX
			local y = self.markCaches[key].anchoredPositionY
			local dis = Vector2.Distance(x, y, self.centerX, self.centerY)

			if dis < closestDist then
				closestDist = dis
				closestKey = key
			end
		end
	end

	if closestKey then
		tempKey[closestKey] = true
	end

	for key, v in pairs(tempKey) do
		self.bubbleMarksObjCaches[key].rt:GetComponent("UButton").visibility = v and CS.XGUI.EVisibility.Visible or CS.XGUI.EVisibility.Hidden
	end
end

function MarkBubbleComponent:renderMark(key, value, uButton)
	if key == "mine" then
		function uButton.luaClick()
			self.ctrl:centralizeMark("BtnMine")
		end

		uButton:TryChangePage("isMine", 1)
	else
		function uButton.luaClick()
			self.ctrl:centralizeMark("mark_" .. tostring(value.markType) .. "_" .. tostring(key))
		end

		uButton:TryChangePage("isMine", 0)
	end
end

function MarkBubbleComponent:renderInnerMark(markButton, key)
	local temp = Vector2(0.5, 0.5)

	markButton.gameObject.transform.anchorMin = temp
	markButton.gameObject.transform.anchorMax = temp
	markButton.gameObject.transform.pivot = temp

	local recTrans = markButton.gameObject:GetComponent("RectTransform")

	recTrans.anchoredPosition = Vector2.zero

	local tableData = self.markCaches[key]
	local objectReference = markButton:GetComponent("ObjectReference")
	local btnRectTransform = objectReference:GetRefValue("btnRectTransform")
	local upperDynamicLoadTransform = objectReference:GetRefValue("upperDynamicLoadTransform")
	local markLevel = DefaultMapMarkData[tableData.markConfigId].markLevel or 1

	btnRectTransform.localScale = UIConst.MAP_CONST.SIZE_DELTA[markLevel]

	if tableData.inAreaRange > 0 then
		local obj = self.view:addPrefabWithPathSync(upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_LAYER_ICON)

		obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC[markLevel]
		obj.gameObject:GetComponent("UImage").url = tableData.inAreaRange == 2 and AddressDataConst.UI_MARK_IMG_LAYER_ACTIVE or AddressDataConst.UI_MARK_IMG_LAYER_INACTIVE
	end

	if tableData.markStatus >= Const.MAP_MARK_STATUS_CLOSED then
		local obj = self.view:addPrefabWithPathSync(upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COMPLETE)

		obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC[markLevel]
	end

	local imgPath = pg.game.map.extraSharedInfoByMarkId[key].imgPath

	if tableData.type == Const.MAP_CONST.TYPE.NORMAL then
		self:_bindBubbleCommonIcon(key, btnRectTransform, imgPath)
	elseif tableData.type == Const.MAP_CONST.TYPE.SINGLE_PUPPET then
		if tableData.markStatus == Const.MAP_MARK_STATUS_LOCKED then
			local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE)
			local objRef1 = obj.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS2
		else
			local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE)
			local objRef1 = obj.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS
		end
	elseif tableData.type == Const.MAP_CONST.TYPE.BOSS then
		if tableData.markStatus == Const.MAP_MARK_STATUS_LOCKED then
			local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE)
			local objRef1 = obj.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
		else
			local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE)
			local objRef1 = obj.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
		end
	elseif tableData.type == Const.MAP_CONST.TYPE.NPC then
		self:_bindBubbleCommonIcon(key, btnRectTransform, imgPath)
	elseif tableData.type == Const.MAP_CONST.TYPE.QUEST then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_QUEST)
		local questCmp = obj.gameObject:GetComponent("UComponent")
		local objRef1 = obj.gameObject:GetComponent("ObjectReference")
		local questNumberUComponent = objRef1:GetRefValue("questNumberUComponent")
		local questNumberUComponentObj = questNumberUComponent.gameObject:GetComponent("ObjectReference")
		local iconUImage = questNumberUComponentObj:GetRefValue("iconUImage")
		local markInfo = self.ctrl:getMarkInfo(key)
		local taskType = QuestUtils.getCurSideQuestShowType(tableData.questId)

		if taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
			questNumberUComponent:TryChangePage("OtherTask", 0)
			questNumberUComponent:TryChangePage("TaskType", taskType.taskType)
		elseif taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
			questNumberUComponent:TryChangePage("OtherTask", 1)

			iconUImage.url = taskType.deliverIcon
		end

		questNumberUComponent:TryChangePage("Arrow", 1)
		questCmp:TryChangePage("showQuest", 1)
		questCmp:TryChangePage("showCircle", 0)
	elseif tableData.type == Const.MAP_CONST.TYPE.CUSTOM then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_CUSTOM)

		obj.gameObject:GetComponent("UButton"):TryChangePage("IconType", self.ctrl:getMarkInfo(key).markIconIndex)
	elseif tableData.type == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_PLENTY)

		MapUtils.renderLeylineFlowerMark(obj.gameObject, imgPath, false)

		local cache = self.bubbleMarksObjCaches[key]

		if cache then
			cache.leylineFlowerMarkObj = obj.gameObject
		end
	elseif tableData.type == Const.MAP_CONST.TYPE.ECO_TRACE then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_ECO_TRACE)
		local objRef1 = obj.gameObject:GetComponent("ObjectReference")
		local imgGlowUImage = objRef1:GetRefValue("imgGlowUImage")
		local bgUImage = objRef1:GetRefValue("bgUImage")

		bgUImage.url = imgPath

		imgGlowUImage.gameObject:SetActiveEx(false)
	elseif tableData.type == Const.MAP_CONST.TYPE.GOLD then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_GOLD_TRACE)
		local objRef1 = obj.gameObject:GetComponent("ObjectReference")
		local imgGlowUImage = objRef1:GetRefValue("imgGlowUImage")
		local bgUImage = objRef1:GetRefValue("bgUImage")

		bgUImage.url = imgPath

		imgGlowUImage.gameObject:SetActiveEx(false)
	elseif tableData.type == Const.MAP_CONST.TYPE.DYNAMIC then
		local bubbleIcon = self.ctrl.dynamicMarkComponent:getBubbleIcon(key)

		if bubbleIcon then
			self:_bindBubbleCommonIcon(key, btnRectTransform, bubbleIcon)
		end
	elseif tableData.type == Const.MAP_CONST.TYPE.ALLY then
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_ALLY)
		local uComponent = obj.gameObject:GetComponent("UComponent")
		local ent = pg.getEntity(key)

		if ent and ent.uid and pg.me:getCurTeamInfo().sortList then
			local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, ent.uid)

			if contain and NotNil(uComponent) then
				uComponent:TryChangePage("Teammate", idx - 1)
			end
		end
	elseif tableData.type == Const.MAP_CONST.TYPE.GRAB_EGG then
		local defaultRes = MapMarkResourceData[tableData.markConfigId][self.ctrl.sceneId] or MapMarkResourceData[tableData.markConfigId][0]
		local eggIconPath = defaultRes and defaultRes.icon
		local eggView = GrabEggMapMarkUtils.getEggView(key)
		local obj = self.view:addPrefabWithPathSync(btnRectTransform, AddressDataConst.UI_MARK_NODE_GRAB_EGG_HUGE_EGG)
		local eggObjRef = obj.gameObject:GetComponent("ObjectReference")

		GrabEggMapMarkUtils.applyEggMarkView(eggObjRef, eggView, eggIconPath)
	elseif tableData.type == Const.MAP_CONST.TYPE.DUEL then
		self:_bindBubbleCommonIcon(key, btnRectTransform, imgPath)
	end

	local cache = self.bubbleMarksObjCaches[key]

	if cache then
		cache.upperDynamicLoadTransform = upperDynamicLoadTransform
	end
end

function MarkBubbleComponent:refreshLeylineFlowerMark(key, imgPath)
	local cache = self.bubbleMarksObjCaches[key]

	if not cache or not cache.leylineFlowerMarkObj then
		return
	end

	MapUtils.renderLeylineFlowerMark(cache.leylineFlowerMarkObj, imgPath, false)
end

function MarkBubbleComponent:renderTeamTrackBadge(key)
	local tableData = self.markCaches[key]

	if not tableData then
		return
	end

	if tableData.type == Const.MAP_CONST.TYPE.FAST_TARGET then
		return
	end

	if tableData.type == Const.MAP_CONST.TYPE.ALLY then
		return
	end

	local cache = self.bubbleMarksObjCaches[key]

	if not cache then
		return
	end

	local parent = cache.upperDynamicLoadTransform

	if not parent then
		return
	end

	local markType = tableData.type
	local isTrack, firstTrackUid = pg.game.map:getTrackInfo(pg.game.map.mainSceneId, markType, key)

	if isTrack then
		if cache._teamTrackObj then
			self:_updateTeamTrackBadgeUI(key, firstTrackUid)
		else
			if cache._teamTrackTaskId then
				pg.global.uiMgr:CancelUIAsyncTask(cache._teamTrackTaskId)

				cache._teamTrackTaskId = nil
			end

			cache._teamTrackTaskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.UI_MARK_NODE_PLAYER_NUM, function(obj)
				cache._teamTrackTaskId = nil

				if not self.bubbleMarksObjCaches[key] then
					pg.global.uiMgr:DestroyItem(obj.gameObject)

					return
				end

				if cache._teamTrackObj then
					pg.global.uiMgr:DestroyItem(obj.gameObject)

					return
				end

				local td = self.markCaches[key]
				local freshTrack, freshUid = pg.game.map:getTrackInfo(pg.game.map.mainSceneId, td and td.type, key)

				if not freshTrack then
					pg.global.uiMgr:DestroyItem(obj.gameObject)

					return
				end

				cache._teamTrackObj = obj.gameObject

				local uComponent = obj.gameObject:GetComponent("UComponent")
				local objectReference = obj.gameObject:GetComponent("ObjectReference")

				cache._teamTrackRootCmp = uComponent
				cache._teamTrackTxtNum = objectReference and objectReference:GetRefValue("txtPlayerNum")
				obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_TARCKLOC

				self:_updateTeamTrackBadgeUI(key, freshUid)
			end, false, false, 0)
		end
	else
		self:_clearTeamTrackBadge(key)
	end
end

function MarkBubbleComponent:_updateTeamTrackBadgeUI(key, firstTrackUid)
	local cache = self.bubbleMarksObjCaches[key]

	if not cache or not NotNil(cache._teamTrackRootCmp) then
		return
	end

	local sortList = pg.me:getCurTeamInfo().sortList

	if not sortList then
		self:_clearTeamTrackBadge(key)

		return
	end

	local contain, idx = LuaUIUtils.tableContains(sortList, firstTrackUid)

	if contain then
		cache._teamTrackRootCmp:TryChangePage("Teammate", idx - 1)

		if cache._teamTrackTxtNum then
			ClientTextUtils.setText(cache._teamTrackTxtNum, idx)
		end
	else
		self:_clearTeamTrackBadge(key)
	end
end

function MarkBubbleComponent:_clearTeamTrackBadge(key)
	local cache = self.bubbleMarksObjCaches[key]

	if not cache then
		return
	end

	if cache._teamTrackTaskId then
		pg.global.uiMgr:CancelUIAsyncTask(cache._teamTrackTaskId)

		cache._teamTrackTaskId = nil
	end

	if cache._teamTrackObj then
		pg.global.uiMgr:DestroyItem(cache._teamTrackObj)

		cache._teamTrackObj = nil
	end

	cache._teamTrackRootCmp = nil
	cache._teamTrackTxtNum = nil
end

function MarkBubbleComponent:onTeamMarkTrackChange()
	for key in pairs(self.bubbleMarksObjCaches) do
		if key ~= "mine" then
			self:renderTeamTrackBadge(key)
		end
	end
end

function MarkBubbleComponent:isOutOfViewPort(x, y)
	if not x or not y or not self.leftBotX or not self.rightTopX or not self.leftBotY or not self.rightTopY then
		return true
	end

	return x < self.leftBotX or x > self.rightTopX or y < self.leftBotY or y > self.rightTopY
end

function MarkBubbleComponent:destroy()
	if self.timer then
		self.ctrl:killTimer(self.timer)
	end

	self.timer = nil

	for key, cache in pairs(self.bubbleMarksObjCaches) do
		self:_clearBubbleCommonIcon(key, true)
		self:_clearTeamTrackBadge(key)

		if cache.innerMark then
			self.view:destroyInstance(cache.innerMark)
		end
	end

	if self.objPool ~= nil then
		self.objPool:recycleAll()
		self.objPool:destroy()

		self.objPool = nil
	end

	self.bubbleMarks = {}
	self.bubbleMarksObjCaches = {}
end

function MarkBubbleComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return MarkBubbleComponent
