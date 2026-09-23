-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\InteractionSign\\UIView\\InteractionSignUIBase.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SetRectLocalPosByWorldPos = UIUtils.SetRectLocalPosByWorldPos
local InteractionSignUIBase = Class.LightClass("InteractionSignUIBase")

InteractionSignUIBase.AnimePipeline = {
	vx_loop = 2,
	vx_in = 1,
	vx_out = 3
}
InteractionSignUIBase.AnimeInteractIdx = 9999
InteractionSignUIBase.CHECK_TICK = 0.15
InteractionSignUIBase.BLOCK_FORCE_REFRESH_INTERVAL = 1
InteractionSignUIBase.BLOCK_MOVE_THRESHOLD_SQR = 0.01
InteractionSignUIBase.AnimationClipLengthCache = {}

function InteractionSignUIBase:ctor(info)
	self.unitData = info.unitData
	self.defaultUrlPath = info.defaultUrlPath
	self.root = info.root
	self.globalId = info.globalId
	self.owner = info.owner
	self.curDistanceGroupIdx = -1
	self.curAnime = nil
	self.componentVisible = true
	self.logicVisible = false
	self.blockEligible = false
	self.blockStateKnown = false
	self.exitAnimating = false
	self.enterAnimationPending = false
	self.nextCheckTime = 0
	self.lastHasSightBlock = false
	self.lastBlockCheckTime = 0
	self._onResourceLoaded = CallbackHandler(self, "onResourceLoaded")
	self._onLoopTimer = CallbackHandler(self, "onLoopTimer")
	self._onExitTimer = CallbackHandler(self, "onExitTimer")
end

function InteractionSignUIBase:onEnter()
	self.left = false
	self.resMgr = pg.global.resMgr

	local urlPath

	if self.unitData and self.unitData.prefabPath then
		urlPath = self.unitData.prefabPath
	else
		urlPath = self.defaultUrlPath
	end

	self.resourceUrlPath = urlPath
	self.resLoadReqId = self.resMgr:GetInstanceFromCacheByLua(urlPath, self._onResourceLoaded)
end

function InteractionSignUIBase:onResourceLoaded(gameObj, userData)
	self.resLoadReqId = nil

	if IsNil(gameObj) then
		return
	end

	if self.left then
		local resMgr = pg.global and pg.global.resMgr

		if resMgr then
			resMgr:RemoveInstanceToCache(gameObj)
		end

		return
	end

	gameObj.transform:SetParent(self.root, false)

	self.gameObj = gameObj

	local signTransform = gameObj.transform

	self.signRectTransform = signTransform:GetComponent("RectTransform")

	local objRef = signTransform:GetComponent("ObjectReference")

	if objRef then
		self.animRoot = objRef:GetRefValue("animationRoot")
	end

	if self.animRoot == nil then
		self.hasAnimCmp, self.animRoot = gameObj:TryGetComponentEx("Animation")
	else
		self.hasAnimCmp = true
	end

	self.signUWidget = signTransform:GetComponent("UWidget")

	self.signUWidget:SetActiveQuickly(false)

	self.signShow = false

	if self.owner then
		self.owner:onUnitViewResourceReady(self)
	end
end

function InteractionSignUIBase:onLeave()
	self.left = true

	self:stopLoopTimer()
	self:stopExitTimer()

	if self.animRoot then
		self.animRoot:Stop()
	end

	if self.resMgr and self.resLoadReqId then
		self.resMgr:TryCancelGOLoadAsyncTask(self.resLoadReqId)
	end

	self:_setSignShow(false)

	if self.resMgr and self.gameObj then
		self.resMgr:RemoveInstanceToCache(self.gameObj)
	end

	self.resMgr = nil
	self.gameObj = nil
	self.resLoadReqId = nil
	self.signRectTransform = nil
	self.animRoot = nil
	self.signUWidget = nil
	self.root = nil
	self.unitData = nil
	self.owner = nil
	self._onResourceLoaded = nil
	self._onLoopTimer = nil
	self._onExitTimer = nil
end

function InteractionSignUIBase:onLogicTick(frameContext, ent)
	if self.gameObj == nil or ent == nil or frameContext.pawn == nil or not self.componentVisible or not frameContext.signVisible then
		self.blockEligible = false

		self:refreshLogicVisibility(false)

		return
	end

	local distance = self.owner:getFrameEntityDistance(frameContext, self.unitData, ent)

	if distance == nil then
		self.blockEligible = false

		self:refreshLogicVisibility(false)

		return
	end

	local groupIdx = self.unitData:getDistanceGroupIdx(distance)

	self.curDistanceGroupIdx = groupIdx

	if groupIdx < 0 then
		self.blockEligible = false

		self:hideWithExitAnimation()

		return
	end

	local inInteractDist = false

	if self.unitData.funcId and ent.interactiveDist and distance < ent.interactiveDist and self.unitData.isShowInInteractDist ~= true then
		inInteractDist = self:checkInteractIsShow(self.unitData.funcId, frameContext.activeInteractFuncIds)
	end

	local anime

	if inInteractDist then
		anime = self.unitData.interactAnimeGroup
	else
		anime = self.unitData.animeGroup[groupIdx]
	end

	self:refreshAnimation(anime)

	local targetPos = self.owner:getFrameTargetPos(frameContext, self.unitData, ent)

	if targetPos == nil then
		self.blockEligible = false

		self:refreshLogicVisibility(false)

		return
	end

	self.lastTargetPos = targetPos

	if not frameContext.cameraSystem:checkInViewportFull(targetPos) then
		self.blockEligible = false
		self.blockStateKnown = false

		self:refreshLogicVisibility(false)

		return
	end

	if self.unitData.checkBlock == true then
		self.blockEligible = true

		self:refreshLogicVisibility(self.blockStateKnown and not self.lastHasSightBlock)
	else
		self.blockEligible = false

		self:refreshLogicVisibility(true)
	end
end

function InteractionSignUIBase:onLayoutTick(frameContext, ent)
	if not self.signShow or ent == nil or self.signRectTransform == nil then
		return
	end

	local targetPos = self.owner:getFrameTargetPos(frameContext, self.unitData, ent)

	if targetPos == nil then
		self:refreshLogicVisibility(false)

		return
	end

	self.lastTargetPos = targetPos

	SetRectLocalPosByWorldPos(targetPos, self.signRectTransform)
end

function InteractionSignUIBase:onVisibleChange(visible)
	if not visible then
		self:stopExitTimer()
	end

	self.componentVisible = visible

	self:refreshDisplayState()
end

function InteractionSignUIBase:refreshLogicVisibility(visible)
	if not visible then
		self:stopExitTimer()
	end

	self.logicVisible = visible

	self:refreshDisplayState()
end

function InteractionSignUIBase:hideWithExitAnimation()
	self.logicVisible = false

	self:refreshAnimation(nil)
	self:refreshDisplayState()
end

function InteractionSignUIBase:refreshDisplayState()
	local shouldHide = not self.componentVisible or not self.logicVisible and not self.exitAnimating

	self:setSignHide(shouldHide)
end

function InteractionSignUIBase:_setSignShow(isShow)
	if self.signUWidget == nil or self.signShow == isShow then
		return
	end

	self.signUWidget:SetActiveQuickly(isShow)

	self.signShow = isShow

	if isShow then
		self:restoreAnimationAfterShow()
	end

	if self.owner then
		self.owner:setUnitViewLayoutActive(self, isShow)
	end
end

function InteractionSignUIBase:restoreAnimationAfterShow()
	if not self.enterAnimationPending then
		return
	end

	self.enterAnimationPending = false

	if self.hasAnimCmp and self.curAnime then
		self:playEnterAnimation(self.curAnime, true)
	end
end

function InteractionSignUIBase:refreshAnimation(anime)
	if not self.hasAnimCmp or self.curAnime == anime then
		return
	end

	local previousAnime = self.curAnime

	self:stopExitTimer()

	self.enterAnimationPending = false

	if anime then
		if self.signShow then
			self:playEnterAnimation(anime)
		elseif previousAnime ~= nil then
			self:playEnterAnimation(anime)
		else
			self:stopLoopTimer()

			self.enterAnimationPending = true
		end
	elseif previousAnime then
		local animeName = previousAnime[InteractionSignUIBase.AnimePipeline.vx_out]

		self:stopLoopTimer()

		if animeName and self.signShow then
			self:startExitAnimation(animeName)
		elseif self.animRoot then
			self.animRoot:Stop()
		end
	end

	self.curAnime = anime
end

function InteractionSignUIBase:playEnterAnimation(anime, sampleImmediately)
	local animeName = anime[InteractionSignUIBase.AnimePipeline.vx_in]

	self:stopLoopTimer()

	if animeName == nil then
		return
	end

	self.animRoot:Play(animeName)

	if sampleImmediately then
		self.animRoot:Sample()
	end

	local loopAnimeName = anime[InteractionSignUIBase.AnimePipeline.vx_loop]

	if loopAnimeName == nil then
		return
	end

	local animLength = self:getAnimationClipLength(animeName)

	if animLength and animLength > 0 then
		self.pendingLoopAnimeName = loopAnimeName
		self.loopTimer = TimerManager.addTimer(animLength, self._onLoopTimer)
	else
		self.animRoot:Play(loopAnimeName)
	end
end

function InteractionSignUIBase:startExitAnimation(animeName)
	self.animRoot:Play(animeName)

	local animLength = self:getAnimationClipLength(animeName)

	if animLength and animLength > 0 then
		self.exitAnimating = true
		self.exitTimer = TimerManager.addTimer(animLength, self._onExitTimer)
	end
end

function InteractionSignUIBase:getAnimationClipLength(animeName)
	local prefabCache = InteractionSignUIBase.AnimationClipLengthCache[self.resourceUrlPath]

	if prefabCache == nil then
		prefabCache = {}
		InteractionSignUIBase.AnimationClipLengthCache[self.resourceUrlPath] = prefabCache
	end

	local animLength = prefabCache[animeName]

	if animLength == nil then
		animLength = UIUtils.GetAnimationClipLength(self.animRoot, animeName)
		prefabCache[animeName] = animLength
	end

	return animLength
end

function InteractionSignUIBase:onLoopTimer()
	if self.animRoot and self.pendingLoopAnimeName then
		self.animRoot:Play(self.pendingLoopAnimeName)
	end

	self.pendingLoopAnimeName = nil
	self.loopTimer = nil
end

function InteractionSignUIBase:onExitTimer()
	self.exitTimer = nil
	self.exitAnimating = false

	if self.animRoot then
		self.animRoot:Stop()
	end

	self:refreshDisplayState()
end

function InteractionSignUIBase:stopLoopTimer()
	if self.loopTimer then
		TimerManager.removeTimer(self.loopTimer)

		self.loopTimer = nil
	end

	self.pendingLoopAnimeName = nil
end

function InteractionSignUIBase:stopExitTimer()
	if self.exitTimer then
		TimerManager.removeTimer(self.exitTimer)

		self.exitTimer = nil
	end

	self.exitAnimating = false
end

function InteractionSignUIBase:checkInteractIsShow(funcId, activeInteractFuncIds)
	return activeInteractFuncIds and activeInteractFuncIds[funcId] == true
end

function InteractionSignUIBase:setSignHide(isHide)
	if isHide then
		self:_setSignShow(false)
	elseif self.signShow == false and (not self.hasAnimCmp or self.curAnime ~= nil) then
		self:_setSignShow(true)
	end
end

function InteractionSignUIBase:hasBlockEndpointChanged(cameraPos, targetPos)
	if self.lastBlockCameraX == nil or self.lastBlockTargetX == nil then
		return true
	end

	local cameraDeltaX = cameraPos.x - self.lastBlockCameraX
	local cameraDeltaY = cameraPos.y - self.lastBlockCameraY
	local cameraDeltaZ = cameraPos.z - self.lastBlockCameraZ
	local targetDeltaX = targetPos.x - self.lastBlockTargetX
	local targetDeltaY = targetPos.y - self.lastBlockTargetY
	local targetDeltaZ = targetPos.z - self.lastBlockTargetZ
	local cameraMoveSqr = cameraDeltaX * cameraDeltaX + cameraDeltaY * cameraDeltaY + cameraDeltaZ * cameraDeltaZ
	local targetMoveSqr = targetDeltaX * targetDeltaX + targetDeltaY * targetDeltaY + targetDeltaZ * targetDeltaZ

	return cameraMoveSqr > InteractionSignUIBase.BLOCK_MOVE_THRESHOLD_SQR or targetMoveSqr > InteractionSignUIBase.BLOCK_MOVE_THRESHOLD_SQR
end

function InteractionSignUIBase:cacheBlockEndpoints(cameraPos, targetPos, now)
	self.lastBlockCameraX = cameraPos.x
	self.lastBlockCameraY = cameraPos.y
	self.lastBlockCameraZ = cameraPos.z
	self.lastBlockTargetX = targetPos.x
	self.lastBlockTargetY = targetPos.y
	self.lastBlockTargetZ = targetPos.z
	self.lastBlockCheckTime = now
end

function InteractionSignUIBase:tryRefreshCameraBlock(frameContext)
	if not self.blockEligible or self.unitData.checkBlock ~= true or self.lastTargetPos == nil or frameContext.now < self.nextCheckTime then
		return false
	end

	self.nextCheckTime = frameContext.now + InteractionSignUIBase.CHECK_TICK

	local worldCamera = frameContext.worldCamera

	if worldCamera == nil then
		return false
	end

	local cameraPos = worldCamera.transform.position
	local forceRefresh = frameContext.now - self.lastBlockCheckTime >= InteractionSignUIBase.BLOCK_FORCE_REFRESH_INTERVAL

	if self.blockStateKnown and not forceRefresh and not self:hasBlockEndpointChanged(cameraPos, self.lastTargetPos) then
		return false
	end

	local deltaX = cameraPos.x - self.lastTargetPos.x
	local deltaY = cameraPos.y - self.lastTargetPos.y
	local deltaZ = cameraPos.z - self.lastTargetPos.z
	local blockDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)

	self.lastHasSightBlock = pgUtils.IsBlocked(self.lastTargetPos, cameraPos, blockDistance, frameContext.blockLayerMask)
	self.blockStateKnown = true

	self:cacheBlockEndpoints(cameraPos, self.lastTargetPos, frameContext.now)
	self:refreshLogicVisibility(not self.lastHasSightBlock)

	return true
end

return InteractionSignUIBase
