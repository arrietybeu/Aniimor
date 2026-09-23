-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemFocusUIComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("FocusUI")
local TopLogoItemFocusUIComponent = {}

TopLogoItemFocusUIComponent.__index = TopLogoItemFocusUIComponent

local DEFAULT_TRIANGLE_RES = "$UI_Node_Toplogo_Triangle.prefab"
local DEFAULT_PARENT_NAME = "FocusTriRoot"
local DEFAULT_HEAD_FALLBACK_OFFSET = 0.5
local DEFAULT_WORLD_GAP = 0
local DEFAULT_UPDATE_INTERVAL = 0.02
local DEFAULT_HEAD_BONE_NAME = "Bip001 Head"
local DEFAULT_HEAD_BONE_OFFSET_Y = 0.5
local DEFAULT_HEAD_RATIO = 0.5
local PIVOT_AT_FEET_EPSILON_RATIO = 0.1
local CanvasType, RendererType, GraphicType

local function _ensureCSTypes()
	if CanvasType then
		return
	end

	CanvasType = typeof(CS.UnityEngine.Canvas)
	RendererType = typeof(CS.UnityEngine.Renderer)
	GraphicType = typeof(CS.UnityEngine.UI.Graphic)
end

local Vector2 = Vector2
local Vector3 = Vector3
local Color = Color
local RectTransformUtility = CS.UnityEngine.RectTransformUtility

local function findChildRecursive(root, name)
	if IsNil(root) or not name then
		return nil
	end

	local ok, direct = pcall(function()
		return root:Find(name)
	end)

	if ok and direct and NotNil(direct) then
		return direct
	end

	local okc, count = pcall(function()
		return root.childCount
	end)

	if not okc or not count or count <= 0 then
		return nil
	end

	for i = 0, count - 1 do
		local child = root:GetChild(i)

		if child and NotNil(child) then
			if child.name == name then
				return child
			end

			local found = findChildRecursive(child, name)

			if found then
				return found
			end
		end
	end

	return nil
end

function TopLogoItemFocusUIComponent.new(ctrl, config)
	local self = setmetatable({}, TopLogoItemFocusUIComponent)

	config = config or {}
	self._ctrl = ctrl
	self._triangleRes = config.triangleRes or DEFAULT_TRIANGLE_RES
	self._parentName = config.parentName or DEFAULT_PARENT_NAME
	self._headFallback = config.headFallback or DEFAULT_HEAD_FALLBACK_OFFSET
	self._worldGap = config.worldGap or DEFAULT_WORLD_GAP
	self._updateInterval = config.updateInterval or DEFAULT_UPDATE_INTERVAL
	self._headBoneName = config.headBoneName or DEFAULT_HEAD_BONE_NAME
	self._headBoneOffsetY = config.headBoneOffsetY or DEFAULT_HEAD_BONE_OFFSET_Y
	self._headRatioOverride = config.headRatio
	self._worldOffsetXOverride = config.worldOffsetX
	self._worldOffsetZOverride = config.worldOffsetZ
	self._worldPoint = Vector3.GetFromPool(0, 0, 0)

	function self.m_safeUpdateTick()
		self:_safeUpdate()
	end

	return self
end

function TopLogoItemFocusUIComponent:destroy()
	self:hide()

	if self._worldPoint then
		Vector3.returnToPool(self._worldPoint)

		self._worldPoint = nil
	end

	self._focusTri = nil
	self._teamCam = nil
	self._autoHeadRatio = nil
	self._autoOffX = nil
	self._autoOffZ = nil
	self._ctrl = nil
	self.m_safeUpdateTick = nil
end

function TopLogoItemFocusUIComponent:show(uid, slotIndex)
	local model = self:_findModel(uid, slotIndex)

	if not model or not model.eModel then
		self:hide()

		return
	end

	self._autoHeadRatio = nil
	self._autoOffX = nil
	self._autoOffZ = nil
	self._debuggedOnce = nil

	local tri = self:_ensureFocusTri()

	if not tri then
		return
	end

	self._focusTarget = model

	tri:SetActiveEx(true)
	self:_safeUpdate()

	local ctrl = self._ctrl

	if self._focusTick then
		ctrl:killTimer(self._focusTick)
	end

	self._focusTick = ctrl:startTimer(self.m_safeUpdateTick, self._updateInterval, true)
end

function TopLogoItemFocusUIComponent:hide()
	self._focusTarget = nil

	if self._focusTick and self._ctrl then
		self._ctrl:killTimer(self._focusTick)

		self._focusTick = nil
	end

	if self._focusTri and NotNil(self._focusTri) then
		self._focusTri:SetActiveEx(false)
	end
end

function TopLogoItemFocusUIComponent:_findModel(uid, slotIndex)
	local uiScene = self._ctrl and self._ctrl.uiScene

	if not uiScene then
		return nil
	end

	local models = uiScene.playerModels

	if not models then
		return nil
	end

	if slotIndex and models[slotIndex] then
		return models[slotIndex]
	end

	local uids = uiScene.playerModelUids

	if not uids or not uid then
		return nil
	end

	for i, u in pairs(uids) do
		if u == uid then
			return models[i]
		end
	end

	return nil
end

function TopLogoItemFocusUIComponent:_findModelByUid(uid)
	return self:_findModel(uid, nil)
end

function TopLogoItemFocusUIComponent:_getTeamCamera()
	if self._teamCam and NotNil(self._teamCam) then
		return self._teamCam
	end

	local uiScene = self._ctrl and self._ctrl.uiScene

	if not uiScene then
		return nil
	end

	local cam = uiScene.camera

	if IsNil(cam) then
		return nil
	end

	self._teamCam = cam

	return self._teamCam
end

function TopLogoItemFocusUIComponent:_ensureFocusTri()
	if self._focusTri and NotNil(self._focusTri) then
		return self._focusTri
	end

	local view = self._ctrl and self._ctrl.view

	if not view or not view.transform then
		return nil
	end

	local parent = findChildRecursive(view.transform, self._parentName) or view.transform

	if IsNil(parent) then
		return nil
	end

	local info = view:addPrefabWithPathSync(parent, self._triangleRes)

	if not info then
		return nil
	end

	local go = info.transform and NotNil(info.transform) and info.transform.gameObject or info.gameObject

	if IsNil(go) then
		return nil
	end

	self._focusTri = go

	go:SetActiveEx(false)

	local DEFAULT_TRIANGLE_COLOR = Color(0.53, 0.81, 0.92, 1)

	self:_applyTriangleColor(go, DEFAULT_TRIANGLE_COLOR)

	return go
end

function TopLogoItemFocusUIComponent:_applyTriangleColor(go, color)
	if IsNil(go) or not color then
		return
	end

	_ensureCSTypes()
	pcall(function()
		local graphics = go:GetComponentsInChildren(GraphicType, true)

		if IsNil(graphics) then
			return
		end

		for i = 0, graphics.Length - 1 do
			local g = graphics[i]

			if g and NotNil(g) then
				g.color = color
			end
		end
	end)
end

function TopLogoItemFocusUIComponent:_tryBoneTopY(model)
	local eModel = model.eModel

	if not eModel then
		return nil
	end

	local skeletonView = eModel.modelSkeletonView

	if IsNil(skeletonView) then
		return nil
	end

	local ok, valid, bonePos = pcall(function()
		return skeletonView:TryGetBonePos(self._headBoneName)
	end)

	if not ok or not valid or not bonePos then
		return nil
	end

	if bonePos.x == 0 and bonePos.y == 0 and bonePos.z == 0 then
		return nil
	end

	local rootPosX, rootPosY, rootPosZ = eModel:GetTransformPosition()

	self._autoOffX = bonePos.x - rootPosX
	self._autoOffZ = bonePos.z - rootPosZ

	return bonePos
end

function TopLogoItemFocusUIComponent:_sampleRendererBounds(model)
	_ensureCSTypes()

	local ok, renderers = pcall(function()
		return model.eModel:GetComponentsInChildren(RendererType, true)
	end)

	if not ok or IsNil(renderers) or renderers.Length <= 0 then
		return nil
	end

	local bounds

	for i = 0, renderers.Length - 1 do
		local r = renderers[i]

		if r and NotNil(r) and r.enabled then
			if not bounds then
				bounds = r.bounds
			else
				bounds:Encapsulate(r.bounds)
			end
		end
	end

	return bounds
end

function TopLogoItemFocusUIComponent:_calcModelTopY(model)
	local rootPosX, rootPosY, rootPosZ = model.eModel:GetTransformPosition()
	local baseY = rootPosY
	local bonePos = self:_tryBoneTopY(model)

	if bonePos then
		if not self._debuggedOnce and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self._debuggedOnce = true

			logger:debug(string.format("PATH=BONE bone=%s pos=(%.3f, %.3f, %.3f) baseY=%.3f offset=%.3f finalY=%.3f", self._headBoneName, bonePos.x, bonePos.y, bonePos.z, baseY, self._headBoneOffsetY, bonePos.y + self._headBoneOffsetY))
		end

		return bonePos.y + self._headBoneOffsetY
	end

	local bounds = self:_sampleRendererBounds(model)

	if bounds then
		local center = bounds.center

		self._autoOffX = center.x - rootPosX
		self._autoOffZ = center.z - rootPosZ

		local effectiveHeight = bounds.max.y - bounds.min.y

		if effectiveHeight > 0 and math.abs(bounds.min.y - baseY) < effectiveHeight * PIVOT_AT_FEET_EPSILON_RATIO then
			self._autoHeadRatio = 1
		else
			self._autoHeadRatio = DEFAULT_HEAD_RATIO
		end

		if not self._debuggedOnce and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self._debuggedOnce = true

			logger:debug(string.format("PATH=AABB bounds=(min=%.3f max=%.3f h=%.3f) baseY=%.3f finalY=%.3f (bone '%s' missing)", bounds.min.y, bounds.max.y, effectiveHeight, baseY, bounds.max.y, self._headBoneName))
		end

		return bounds.max.y
	end

	local modelHeight

	pcall(function()
		local cfg = model.getConfigData and model:getConfigData() or nil

		modelHeight = cfg and cfg.modelHeight
	end)

	local scale = model.curModelScale or 1
	local ratio = self._headRatioOverride or self._autoHeadRatio or DEFAULT_HEAD_RATIO

	if modelHeight and modelHeight > 0 then
		if not self._debuggedOnce and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self._debuggedOnce = true

			logger:debug(string.format("PATH=CFG  modelHeight=%.3f scale=%.3f ratio=%.3f baseY=%.3f finalY=%.3f", modelHeight, scale, ratio, baseY, baseY + modelHeight * scale * ratio))
		end

		return baseY + modelHeight * scale * ratio
	end

	if not self._debuggedOnce and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self._debuggedOnce = true

		logger:debug(string.format("PATH=FALLBACK baseY=%.3f headFallback=%.3f finalY=%.3f", baseY, self._headFallback, baseY + self._headFallback))
	end

	return baseY + self._headFallback
end

function TopLogoItemFocusUIComponent:_safeUpdate()
	local ok, err = pcall(self._updateFocusTriPos, self)

	if not ok then
		logger:error("update err: " .. tostring(err))
	end
end

function TopLogoItemFocusUIComponent:_updateFocusTriPos()
	local model = self._focusTarget
	local tri = self._focusTri

	if not model or not model.eModel or not NotNil(tri) then
		self:hide()

		return
	end

	if not pg or not pg.game or not pg.game.input or not pg.game.input:isUsingGamepad() then
		tri:SetActiveEx(false)

		return
	end

	local cam = self:_getTeamCamera()

	if not cam then
		tri:SetActiveEx(false)

		return
	end

	local wpX, wpY, wpZ = model.eModel:GetTransformPosition()
	local topY = self:_calcModelTopY(model)
	local offX = self._worldOffsetXOverride or self._autoOffX or 0
	local offZ = self._worldOffsetZOverride or self._autoOffZ or 0

	self._worldPoint:Set(wpX + offX, topY + self._worldGap, wpZ + offZ)

	local screenPt = cam:WorldToScreenPoint(self._worldPoint)

	if screenPt.z < 0 then
		tri:SetActiveEx(false)

		return
	end

	tri:SetActiveEx(true)

	local rt = tri:GetComponent("RectTransform")

	if IsNil(rt) then
		return
	end

	local parentRt = rt.parent and rt.parent:GetComponent("RectTransform") or nil

	if IsNil(parentRt) then
		return
	end

	local canvas = rt:GetComponentInParent(CanvasType)
	local uiCam = canvas and canvas.worldCamera or nil
	local ok, localPt = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRt, Vector2(screenPt.x, screenPt.y), uiCam)

	if not ok then
		return
	end

	local parentRect = parentRt.rect
	local parentPivot = parentRt.pivot
	local anchorMin = rt.anchorMin
	local anchorMax = rt.anchorMax
	local anchorRefX = ((anchorMin.x + anchorMax.x) * 0.5 - parentPivot.x) * parentRect.width
	local anchorRefY = ((anchorMin.y + anchorMax.y) * 0.5 - parentPivot.y) * parentRect.height
	local rect = rt.rect
	local pivot = rt.pivot

	rt:SetAnchoredPositionEx(localPt.x - anchorRefX, localPt.y - anchorRefY + rect.height * pivot.y)
end

return TopLogoItemFocusUIComponent
