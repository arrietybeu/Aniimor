-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapNavLineComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AddressDataConst = require("Const.AddressDataConst")
local MapNavLineComponent = Class.LightClass("MapNavLineComponent", UIComponent)

function MapNavLineComponent:findObjects()
	if pg.game.navEffect.recordPath and pg.game.navEffect.recordPath.sceneId == self.ctrl.sceneId and (not pg.game.navEffect.recordPath.overrideStartPosInfo or not pg.game.navEffect.recordPath.overrideStartPosInfo.startSpawnerId) then
		self:drawNavEffLine(pg.game.navEffect.recordPath)
	else
		for spawnerId, markRecordData in pairs(pg.game.map.trackMarksRecord) do
			if pg.game.map:convertSceneId(pg.me.space.sceneId) ~= markRecordData.sceneId then
				self:differentSceneTrack(spawnerId)

				break
			end
		end
	end
end

function MapNavLineComponent:initView()
	return
end

function MapNavLineComponent:destroy()
	self:destroyNavEffLine()
end

function MapNavLineComponent:drawNavEffLine(info, dependencyBtn, centralizeMark)
	self:destroyNavEffLine()

	if not info or not info.path then
		return
	end

	local path = info.path
	local vec2Table = {}

	for i = 1, #path do
		local pos = path[i]
		local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], info.sceneId, true)

		vec2Table[#vec2Table + 1] = Vector2(mapX, mapY)
	end

	self.taskId = self.view:addPrefabWithPathAsync(self.view.markerListTransform.parent, AddressDataConst.MAP_LINE_DRAWER, function(obj)
		self.taskObj = obj.gameObject

		obj.gameObject.transform:SetSiblingIndex(1)

		local objectReference = obj.gameObject:GetComponent("ObjectReference")
		local lineDrawerULineDrawer = objectReference:GetRefValue("lineDrawerULineDrawer")

		lineDrawerULineDrawer:SetPoints(vec2Table)
		lineDrawerULineDrawer:SetWidth(30 / self.ctrl.currentZoom)
	end, true)

	if dependencyBtn then
		if centralizeMark then
			dependencyBtn:OnClickSimulate()
		end
	else
		pg.global.ui.map:canCelScrollDisabled()
	end
end

function MapNavLineComponent:delayLoadDependencyBtn(dependencyBtn)
	return
end

function MapNavLineComponent:destroyNavEffLine()
	if self.taskId then
		self.view:cancelUIAsyncTask(self.taskId)

		self.taskId = nil
	end

	if self.taskObj then
		self.view:destroyInstance(self.taskObj)

		self.taskObj = nil
	end

	if self.trackTaskId then
		self.view:cancelUIAsyncTask(self.trackTaskId)

		self.trackTaskId = nil
	end

	if self.trackTaskObj then
		self.view:destroyInstance(self.trackTaskObj)

		self.trackTaskObj = nil
	end
end

function MapNavLineComponent:adjustLineWidth()
	if self.taskObj then
		local objectReference = self.taskObj:GetComponent("ObjectReference")
		local lineDrawerULineDrawer = objectReference:GetRefValue("lineDrawerULineDrawer")

		lineDrawerULineDrawer:SetWidth(30 / self.ctrl.currentZoom)
	end
end

function MapNavLineComponent:setVisible(visible)
	if self.taskObj then
		self.taskObj:SetActiveEx(visible)
	end
end

function MapNavLineComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

function MapNavLineComponent:grabEggSettlementOpen(sceneId, path, cb)
	self.grabEggPathPointTaskIdGroup = {}
	self.grabEggPathPointTaskObjGroup = {}

	for i = 1, #path do
		self.grabEggPathPointTaskIdGroup[i] = self.view:addPrefabWithPathAsync(self.view.markerListTransform.parent, AddressDataConst.UI_MapMisc_GrabEgg_Path_Point, function(obj)
			self.grabEggPathPointTaskObjGroup[i] = obj.gameObject

			obj.gameObject.transform:SetSiblingIndex(2)

			local pos = path[i]
			local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], sceneId, true)

			obj.gameObject.transform.anchoredPosition = Vector2(mapX, mapY)

			if i == #path and cb then
				cb(obj.gameObject.transform.position)
			end
		end, true)
	end

	self:drawNavEffLine({
		sceneId = sceneId,
		path = path
	})
	self.view.markerListTransform.gameObject:SetActiveEx(false)
	self.view.safeBoxMobileUWidget.gameObject:SetActiveEx(false)
	self.view.bubbleGroupTransform.gameObject:SetActiveEx(false)
end

function MapNavLineComponent:grabEggSettlementClose()
	if self.grabEggPathPointTaskIdGroup then
		for i = 1, #self.grabEggPathPointTaskIdGroup do
			self.view:cancelUIAsyncTask(self.grabEggPathPointTaskIdGroup[i])

			self.grabEggPathPointTaskIdGroup[i] = nil
		end

		self.grabEggPathPointTaskIdGroup = nil
	end

	if self.grabEggPathPointTaskObjGroup then
		for i = 1, #self.grabEggPathPointTaskObjGroup do
			self.view:destroyInstance(self.grabEggPathPointTaskObjGroup[i])

			self.grabEggPathPointTaskObjGroup[i] = nil
		end

		self.grabEggPathPointTaskObjGroup = nil
	end

	self:destroy()
end

function MapNavLineComponent:differentSceneTrack(spawnerId)
	if self.ctrl.differentSceneTrackMark and self.ctrl.differentSceneTrackMark == spawnerId then
		return
	end

	table.insert(self.ctrl.onMarkLoadedManualCallback, function(spawnerId1, spawnerTable)
		if spawnerId1 ~= spawnerId then
			return
		end

		self.ctrl.differentSceneTrackMark = spawnerId1

		pg.game.map:trackDiffSceneMark(self.ctrl.sceneId, spawnerId1, spawnerTable, function(result)
			self.ctrl:swapMarkLayer(spawnerId1, 99, nil)

			if self.ctrl.markCaches[spawnerId1] and self.ctrl.markCaches[spawnerId1].lowerDynamicLoadTransform then
				self.ctrl:checkTrackTaskAndObjStatus(true)

				self.ctrl.markCaches[spawnerId1].trackTaskId = self.view:addPrefabWithPathAsync(self.ctrl.markCaches[spawnerId1].lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_TRACK, function(obj)
					self.ctrl.markCaches[spawnerId1].trackObj = obj.gameObject
					self.ctrl.trackTaskObjTable[spawnerId1] = obj.gameObject
				end, false, false, 0)
				self.ctrl.trackTaskTable[spawnerId1] = self.ctrl.markCaches[spawnerId1].trackTaskId
			end

			if not result then
				-- block empty
			else
				local centralizeSpawnerId = not self.ctrl.openLocateIntent and result.startSpawnerId or nil

				self.ctrl:ensureStartMarkLoaded(result.startSpawnerId)

				if not self.ctrl.markCaches[result.startSpawnerId] then
					self.ctrl.diffSceneTrackDelayFlag = result.startSpawnerId

					self:drawNavEffLine({
						path = result.path,
						sceneId = result.sceneId
					})
				else
					self:drawNavEffLine({
						path = result.path,
						sceneId = result.sceneId
					}, self.ctrl.markCaches[result.startSpawnerId].button, centralizeSpawnerId)
				end
			end
		end)
	end)
end

return MapNavLineComponent
