-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\NavEffect\\NavEffectSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local NavMeshServiceUtils = require("Common.Utils.NavMeshServiceUtils")
local AiConst = require("Common.Const.AiConst")
local MessageName = require("Const.MessageName")
local MIN_GAP = 2
local PLAYER_HEIGHT = 2
local GUIDING_LINE_REFRESH_DISTANCE = 10
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local NavEffectSystem = Class.LightClass("NavEffectSystem", SystemBase)

function NavEffectSystem:onCtor()
	SystemBase.onCtor(self)
	self:init()
end

function NavEffectSystem:getMessageBindMap()
	return {
		[MessageName.ON_HIDE_ALL_UI] = "onAllUIStateChanged",
		[MessageName.ON_RESTORE_ALL_UI] = "onAllUIStateChanged"
	}
end

function NavEffectSystem:onSceneUnloaded(sceneId, sceneName)
	self:unPathForce()
	self:clearGuidingLineRender()
end

function NavEffectSystem:onSceneLoaded(sceneId, sceneName)
	self:unPathForce()
	self:clearGuidingLineRender()
end

function NavEffectSystem:onSceneReset(sceneId, sceneName)
	self:onSceneLoaded(sceneId, sceneName)
end

function NavEffectSystem:clearGuidingLineRender()
	if NotNil(self.guidingLineGameObject) then
		local guidingLine = self.guidingLineGameObject:GetComponent("GenerateGuidingLinePoints")

		guidingLine:SetPoints({})
	end

	facade:SendMessageCommand(MessageName.DRAW_NAV_EFF_LINE, {})
end

function NavEffectSystem:init()
	self.pathPointsGameObject = GameObject("NavPath")

	Object.DontDestroyOnLoad(self.pathPointsGameObject)

	self.guidingLineGameObject = nil
	self.guidingLineData = nil
	self.temp1Vector3 = Vector3.zero
	self.temp2Vector3 = Vector3.zero
	self.temp3Vector3 = Vector3(0, 0, 0)
	self.temp4Vector3 = Vector3(0, 0, 0)
	self.lastPlayerPosition = Vector3(-9999, -9999, -9999)
	self.recordPath = nil
end

function NavEffectSystem:onTick()
	if not pg.me or not self.guidingLineData or IsNil(self.pathPointsGameObject) then
		return
	end

	if not self.guidingLineData.firstPoint then
		return
	end

	local playerPosition = pg.me:getPosition()

	if Vector3.HasChanged(playerPosition, self.lastPlayerPosition, 1) and Vector3.SqrDistance(self.guidingLineData.firstPoint, playerPosition) > GUIDING_LINE_REFRESH_DISTANCE * GUIDING_LINE_REFRESH_DISTANCE then
		self.lastPlayerPosition:Copy(playerPosition)
		self.temp4Vector3:Copy(playerPosition)

		if self.guidingLineData.isolatedIslandLinkPos then
			self.guidingLineData.processedEndPos = {
				{
					self.guidingLineData.isolatedIslandLinkPos[1],
					self.guidingLineData.isolatedIslandLinkPos[2],
					self.guidingLineData.isolatedIslandLinkPos[3]
				}
			}
			self.guidingLineData.endPos = self.guidingLineData.isolatedIslandLinkPos
		end

		NavMeshServiceUtils.findPath(self.guidingLineData.sceneId, self.temp4Vector3, self.guidingLineData.processedEndPos, function(aiConstReqState, path)
			if aiConstReqState ~= AiConst.AUTO_PATH_REQ_STATE.Success and aiConstReqState ~= AiConst.AUTO_PATH_REQ_STATE.PartialSuccess or not path then
				print("Inner Nav failed")

				return
			end

			self:innerUnPath(self.guidingLineData.id)
			self:internalPath(self.guidingLineData.sceneId, self.guidingLineData.endPos, self.guidingLineData.processedEndPos, self.guidingLineData.id, self.guidingLineData.successCallback, path, nil, nil, self.guidingLineData.isolatedIslandLinkPos)
		end)
	end
end

function NavEffectSystem:path(sceneId, endPos, id, successCallback, hidePath, overrideStartPosInfo, duplicateCall, isolatedIslandLinkPos)
	self:unPathForce()

	if hidePath then
		return
	end

	self.guidingLineData = {
		id = id
	}

	self.lastPlayerPosition:Copy(pg.me:getPosition())
	self:internalPath(sceneId, endPos, {
		{
			endPos[1],
			endPos[2],
			endPos[3]
		}
	}, id, successCallback, nil, overrideStartPosInfo, duplicateCall, isolatedIslandLinkPos)
end

function NavEffectSystem:internalPath(sceneId, endPos, processedEndPos, id, successCallback, alreadyPath, overrideStartPosInfo, duplicateCall, isolatedIslandLinkPos)
	local newSceneId = pg.game.map:convertSceneId(sceneId)
	local pos = pg.me:getPosition()

	if pg.space.sceneId == ClientConst.SCENE_ROOKIE then
		newSceneId = ClientConst.SCENE_ROOKIE
	end

	if alreadyPath then
		self:pathProcess(newSceneId, id, endPos, processedEndPos, alreadyPath, successCallback, alreadyPath ~= nil, isolatedIslandLinkPos)

		self.recordPath = {
			isInner = true,
			sceneId = newSceneId,
			path = alreadyPath,
			overrideStartPosInfo = overrideStartPosInfo,
			duplicateCall = duplicateCall
		}

		facade:SendMessageCommand(MessageName.DRAW_NAV_EFF_LINE, self.recordPath)
	else
		if overrideStartPosInfo then
			pos = overrideStartPosInfo.startPos
		end

		NavMeshServiceUtils.findPath(newSceneId, pos, processedEndPos, function(aiConstReqState, path)
			if not self.guidingLineData or self.guidingLineData.id ~= id then
				return
			end

			if aiConstReqState ~= AiConst.AUTO_PATH_REQ_STATE.Success and aiConstReqState ~= AiConst.AUTO_PATH_REQ_STATE.PartialSuccess or not path then
				print("Nav failed")
				self.temp3Vector3:Copy(pg.me:getPosition())

				self.guidingLineData = {
					id = id,
					firstPoint = self.temp3Vector3,
					sceneId = newSceneId,
					endPos = endPos,
					processedEndPos = processedEndPos,
					successCallback = successCallback,
					isolatedIslandLinkPos = isolatedIslandLinkPos
				}

				pg.global.showBubbleMessageById(2128)
				facade:SendMessageCommand(MessageName.DRAW_NAV_EFF_LINE, {})

				return
			end

			self.recordPath = {
				sceneId = newSceneId,
				path = path,
				overrideStartPosInfo = overrideStartPosInfo,
				duplicateCall = duplicateCall
			}

			facade:SendMessageCommand(MessageName.DRAW_NAV_EFF_LINE, self.recordPath)
			self:pathProcess(newSceneId, id, endPos, processedEndPos, path, successCallback, alreadyPath ~= nil, isolatedIslandLinkPos)
		end)
	end
end

function NavEffectSystem:pathProcess(sceneId, id, endPos, processedEndPos, path, successCallback, isInner, isolatedIslandLinkPos)
	if not self.guidingLineGameObject then
		self.guidingLineGameObject = pg.global.uiMgr:SyncInstantiateItem(AddressDataConst.Guiding_Line, self.pathPointsGameObject.transform)
	end

	self.guidingLineGameObject.name = "GuidingLine" .. id

	local guidingLine = self.guidingLineGameObject:GetComponent("GenerateGuidingLinePoints")

	guidingLine:Init()

	self.guidingLineData = {
		id = id,
		firstPoint = path[1],
		sceneId = sceneId,
		endPos = endPos,
		processedEndPos = processedEndPos,
		successCallback = successCallback,
		isolatedIslandLinkPos = isolatedIslandLinkPos
	}
	path[#path] = endPos

	local lerpPath = self:lerpPathPoints(path)
	local points = {}
	local length = #lerpPath > 32 and 32 or #lerpPath

	for i = 1, length do
		local iC = #points + 1

		points[iC] = Vector3(lerpPath[i][1], lerpPath[i][2], lerpPath[i][3])
	end

	guidingLine:SetPoints(points, function()
		if not isInner then
			guidingLine:PlayGuidingLine(10)
		end

		if self.navPathDisplayFlag == nil then
			guidingLine:SetVisible(1)
		else
			guidingLine:SetVisible(self.navPathDisplayFlag and 1 or 0)
		end
	end)

	self.pathPointsGameObject.transform.position = pg.me:getPosition()

	if successCallback then
		successCallback()
	end
end

function NavEffectSystem:innerUnPath(id, successCallback)
	if self.guidingLineData and self.guidingLineData.id ~= id then
		return
	end

	if successCallback then
		successCallback()
	end

	self.recordPath = nil
end

function NavEffectSystem:unPath(id, successCallback)
	if self.guidingLineData and self.guidingLineData.id ~= id then
		return
	end

	self:unPathForce()

	if NotNil(self.guidingLineGameObject) then
		local guidingLine = self.guidingLineGameObject:GetComponent("GenerateGuidingLinePoints")

		guidingLine:SetPoints({})
	end

	if successCallback then
		successCallback()
	end

	self.recordPath = nil

	facade:SendMessageCommand(MessageName.DRAW_NAV_EFF_LINE, {})
end

function NavEffectSystem:unPathForce()
	self.guidingLineData = nil
	self.recordPath = nil

	if pg.game and pg.game.map then
		pg.game.map:setTrackPathStart("nav", nil)
	end

	self.lastPlayerPosition:Set(-9999, -9999, -9999)
end

function NavEffectSystem:cutRoutePointsByClosetPointFromPlayer(routePoint, playerPos)
	local closetDistance = math.maxInt
	local closetPointKey

	for k, v in pairs(routePoint) do
		local dis = Vector3.Distance(v, playerPos)

		if dis < closetDistance then
			closetDistance = dis
			closetPointKey = k
		end
	end

	if not closetPointKey then
		return nil
	end

	local result = {}

	for i = closetPointKey, #routePoint do
		result[#result + 1] = routePoint[i]
	end

	return result
end

function NavEffectSystem:distance(point1, point2)
	local dx = point2[1] - point1[1]
	local dy = point2[2] - point1[2]
	local dz = point2[3] - point1[3]

	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function NavEffectSystem:lerpPathPoints(path)
	local newPoints = {}

	for i = 1, #path - 1 do
		local startPoint = path[i]
		local endPoint = path[i + 1]

		table.insert(newPoints, startPoint)

		local dist = self:distance(startPoint, endPoint)
		local numSegments = math.floor(dist / MIN_GAP)

		for j = 1, numSegments do
			local t = j * MIN_GAP / dist
			local addX = startPoint[1] + t * (endPoint[1] - startPoint[1])
			local addY = startPoint[2] + t * (endPoint[2] - startPoint[2])
			local addZ = startPoint[3] + t * (endPoint[3] - startPoint[3])
			local _, calX, calY, calZ = UIUtils.GetStickGroundPos(addX, addY, addZ, PLAYER_HEIGHT)
			local interpolatedPoint = {
				calX,
				calY,
				calZ
			}

			table.insert(newPoints, interpolatedPoint)
		end
	end

	local finalPoint = path[#path]
	local _, calX, calY, calZ = UIUtils.GetStickGroundPos(finalPoint[1], finalPoint[2], finalPoint[3], PLAYER_HEIGHT)
	local interpolatedPoint = {
		calX,
		calY,
		calZ
	}

	table.insert(newPoints, interpolatedPoint)

	return newPoints
end

function NavEffectSystem:onAllUIStateChanged(info)
	local hide = next(pg.global.ui.uiHideConfig) ~= nil

	self.navPathDisplayFlag = not hide

	if IsNil(self.guidingLineGameObject) then
		return
	end

	local guidingLine = self.guidingLineGameObject:GetComponent("GenerateGuidingLinePoints")

	guidingLine:SetVisible(self.navPathDisplayFlag and 1 or 0)
end

function NavEffectSystem:onDestroy()
	SystemBase.onDestroy(self)
	self:unPathForce()

	if NotNil(self.guidingLineGameObject) then
		pg.global.uiMgr:DestroyItem(self.guidingLineGameObject)
	end

	self.guidingLineGameObject = nil

	if self.pathPointsGameObject then
		GameObject.Destroy(self.pathPointsGameObject)
	end

	self.pathPointsGameObject = nil
end

return NavEffectSystem
