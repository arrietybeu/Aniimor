-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\NormalTrackComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("NormalTrackComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NormalTrackComponent = Class.LightClass("NormalTrackComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TrackDistanceUtils = require("Utils.TrackDistanceUtils")
local Vector2 = Vector2
local DefaultMapMarkData = require("Data.default_map_mark_data")
local AddressDataConst = require("Const.AddressDataConst")
local UI_Node_Track = AddressDataConst.UI_Node_Track
local Vector3 = Vector3

function NormalTrackComponent:findObjects()
	return
end

function NormalTrackComponent:initView()
	self.relatedScreenWidth = 3840
	self.relatedScreenHeight = 2160

	local widthRatio = self.ctrl.width / self.relatedScreenWidth
	local heightRatio = self.ctrl.height / self.relatedScreenHeight

	self.ratioX = widthRatio * 0.5
	self.ratioY = heightRatio * 0.5
	self.sqrX = math.pow(self.ratioX, 2)
	self.sqrY = math.pow(self.ratioY, 2)

	local minDistance, maxDistance = TrackDistanceUtils.getDistanceRange()

	self.distRange = {
		minDistance,
		maxDistance
	}
	self.currentTargetPos = Vector3(0, 0, 0)
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN
end

function NormalTrackComponent:onDestroy()
	UIComponent.onDestroy(self)
	self:clearUpdateTimer()
end

function NormalTrackComponent:_setDistanceTextVisible(visible)
	if self.distanceUBaseText == nil then
		return
	end

	self.distanceUBaseText:SetActiveFastest(visible == true)
end

function NormalTrackComponent:_refreshDistanceText(distance)
	if self.distanceUBaseText == nil then
		return
	end

	local distanceText = TrackDistanceUtils.formatDistanceText(distance)

	if distanceText == nil then
		self:_setDistanceTextVisible(false)

		return
	end

	self:_setDistanceTextVisible(true)
	ClientTextUtils.setText(self.distanceUBaseText, distanceText)
end

function NormalTrackComponent:instantiateRes()
	if self.load then
		return
	end

	self.load = true

	self.view:addPrefabWithPathAsync(self.view.transform, UI_Node_Track, function(obj)
		local trans = obj.transform

		self.trackNode = trans:GetComponent("UWidget")
		self.trackRectTrans = trans:GetComponent("RectTransform")

		local objectReference = trans:GetComponent("ObjectReference")

		self.iconTrackUImage = objectReference:GetRefValue("iconTrackUImage")
		self.iconArrowImage = objectReference:GetRefValue("imgArrowUWidget")
		self.imgArrowTrans = objectReference:GetRefValue("imgArrowUWidget").transform
		self.distanceUBaseText = objectReference:GetRefValue("distanceUBaseText")

		self:_setDistanceTextVisible(false)

		self.iconTrackUImage.url = self.icon

		self.trackNode:SetActiveFastest(false)
		self.trackNode:TryChangePage("Size", self.sizeSmall == true and 1 or 0)
	end)
end

function NormalTrackComponent:_isEdgeOnlyTopLogoVisible(targetEnt)
	if self._edgeOnlyTopLogoComponent == nil then
		return true
	end

	if targetEnt == nil or targetEnt.getToplogoComponent == nil then
		return false
	end

	local toplogo = targetEnt:getToplogoComponent(self._edgeOnlyTopLogoComponent)

	return toplogo ~= nil and toplogo:checkSelfVisible() and toplogo:checkFinalVisible()
end

function NormalTrackComponent:tryTrackTargetPos(targetPos, targetEnt)
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN

	if targetPos == nil then
		return
	end

	self.currentTargetPos = self.currentTargetPos or Vector3(0, 0, 0)

	local trackTargetPos = targetEnt and targetEnt.getPosition and targetEnt:getPosition() or targetPos

	self.currentTargetPos:Copy(trackTargetPos)

	if pg.me == nil then
		if self.trackNode then
			self.trackNode:SetActiveFastest(false)
		end

		return
	end

	local distance = TrackDistanceUtils.getDistance(targetPos)
	local isInScreen = self.ctrl.questArrowComponent:checkPosInScreenGuidanceRegion(targetPos)

	if self._edgeOnly == true and isInScreen and self:_isEdgeOnlyTopLogoVisible(targetEnt) then
		if self.trackNode then
			self.trackNode:SetActiveFastest(false)
		end

		self:_setDistanceTextVisible(false)

		return
	end

	local canShowTrack = TrackDistanceUtils.canShowTrack(distance)

	if canShowTrack ~= true then
		if self.trackNode then
			self.trackNode:SetActiveFastest(false)
		end

		self:_setDistanceTextVisible(false)

		return
	end

	if self.trackNode == nil then
		self:instantiateRes()

		return
	end

	if not self.ctrl:canShowTrack(self.ctrl.TRACK_PRIORITY.NORMAL_TRACK, trackTargetPos) then
		self.trackNode:SetActiveFastest(false)
		self:_setDistanceTextVisible(false)

		return
	end

	self.trackNode:SetActiveFastest(true)
	self:_refreshDistanceText(distance)

	if isInScreen ~= true then
		self:showArrow(targetPos)
	else
		self:showMark(targetPos)
	end

	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.VISIBLE
end

function NormalTrackComponent:startUpdateTimer()
	if self.updateTimer or self.trackFuncName == nil and self.trackEntityId == nil or pg.game.setting:getHideAllHudArrowType() or not self:checkUIShow() then
		return
	end

	self.updateTimer = pg.game.camera:addLateUpdateTimer(function()
		self:updateTrackEnt()
	end)
end

function NormalTrackComponent:onShow()
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN

	if self.trackFuncName ~= nil or self.trackEntityId ~= nil then
		self:startUpdateTimer()
		self:updateTrackEnt()
	end
end

function NormalTrackComponent:onHide()
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN

	self:clearUpdateTimer()

	if self.trackNode then
		self.trackNode:SetActiveFastest(false)
	end
end

function NormalTrackComponent:isTrackDisplayActiveAt(targetPos)
	return self.trackNode ~= nil and self.displayState == self.ctrl.TRACK_DISPLAY_STATE.VISIBLE and self.ctrl:isSameTrackTarget(self.currentTargetPos, targetPos)
end

function NormalTrackComponent:showArrow(targetPos)
	LuaUIUtils.setArrowTipRtPosAndRot(self.trackRectTrans, self.imgArrowTrans, targetPos, self.ratioX, self.ratioY, -90)
	self.iconArrowImage:SetActiveFastest(true)
	self:_setDistanceTextVisible(false)
end

function NormalTrackComponent:showMark(targetPos)
	pg.global.uiMgr:SetRectTransformViewportPos(self.trackRectTrans, targetPos.x, targetPos.y, targetPos.z)

	self.imgArrowTrans.rotation = Quaternion.Euler(0, 0, 0)

	self.iconArrowImage:SetActiveFastest(false)
end

function NormalTrackComponent:setTrackTarget(func, icon, edgeOnly, edgeOnlyTopLogoComponent, sizeSmall)
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN

	if func ~= nil then
		self.trackFunc = pg.me[func]
		self.trackFuncName = func
		self.trackEntityId = nil
		self._edgeOnly = edgeOnly == true
		self._edgeOnlyTopLogoComponent = edgeOnlyTopLogoComponent

		if self.iconTrackUImage then
			self.iconTrackUImage.url = icon
		else
			self.icon = icon
		end

		if self.trackNode then
			self.trackNode:SetActiveFastest(false)
			self.trackNode:TryChangePage("Size", sizeSmall == true and 1 or 0)
		else
			self.sizeSmall = sizeSmall == true
		end

		if not pg.game.setting:getHideAllHudArrowType() then
			self:show()
			self:startUpdateTimer()
		end
	else
		self:clearTrack()
	end
end

function NormalTrackComponent:setTrackTargetByEntityId(entityId, icon, edgeOnly, edgeOnlyTopLogoComponent, sizeSmall)
	if entityId == nil then
		return
	end

	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN
	self.trackFunc = nil
	self.trackFuncName = nil
	self.trackEntityId = entityId
	self._edgeOnly = edgeOnly == true
	self._edgeOnlyTopLogoComponent = edgeOnlyTopLogoComponent

	if self.iconTrackUImage ~= nil then
		self.iconTrackUImage.url = icon
	else
		self.icon = icon
	end

	if self.trackNode then
		self.trackNode:SetActiveFastest(false)
		self.trackNode:TryChangePage("Size", sizeSmall == true and 1 or 0)
	else
		self.sizeSmall = sizeSmall == true
	end

	if not pg.game.setting:getHideAllHudArrowType() then
		self:show()
		self:startUpdateTimer()
	end
end

function NormalTrackComponent:updateTrackEnt()
	local targetEnt

	if self.trackEntityId ~= nil then
		targetEnt = pg.getEntity(self.trackEntityId)
	elseif self.trackFunc ~= nil and pg.me ~= nil then
		targetEnt = self.trackFunc(pg.me)
	end

	if targetEnt then
		if targetEnt.isLevelItem then
			self:tryTrackTargetPos(targetEnt.targetPos, targetEnt)
		else
			self:tryTrackTargetPos(targetEnt:getPosition(), targetEnt)
		end
	else
		self:cancelTrack(self.trackFuncName)
	end
end

function NormalTrackComponent:cancelTrackByEntityId(entityId)
	if self.trackEntityId ~= nil and entityId == self.trackEntityId then
		self:clearTrack()
	end
end

function NormalTrackComponent:cancelTrack(funcName)
	if not self.trackFuncName or funcName == self.trackFuncName then
		self:clearTrack()
	end
end

function NormalTrackComponent:clearTrack()
	self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN
	self.trackEntityId = nil
	self.trackFunc = nil
	self.trackFuncName = nil
	self._edgeOnly = false
	self._edgeOnlyTopLogoComponent = nil

	self:clearUpdateTimer()
	self:hide()
end

function NormalTrackComponent:clearUpdateTimer()
	if self.updateTimer then
		pg.game.camera:removeLateUpdateTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function NormalTrackComponent:refreshAllArrowHideState()
	if pg.game.setting:getHideAllHudArrowType() then
		self.displayState = self.ctrl.TRACK_DISPLAY_STATE.HIDDEN

		if self.trackNode then
			self.trackNode:SetActiveFastest(false)
		end

		self:clearUpdateTimer()
	else
		self:startUpdateTimer()
	end
end

return NormalTrackComponent
