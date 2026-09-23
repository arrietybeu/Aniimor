-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\GuideUtils.lua

local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("GuideUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local GuideUtils = {}

function GuideUtils.getChildSafely(targetTrans, childIndex)
	if IsNil(targetTrans) then
		return nil
	end

	local childCount = targetTrans.childCount

	if childIndex < 0 or childCount <= childIndex then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("引导: [%s] 共 %d 个子物体, 在查找其第 %d 个子物体出现问题 !!! ", targetTrans.name, childCount, childIndex)
		end

		return nil
	end

	return targetTrans:GetChild(childIndex)
end

function GuideUtils.getFocusTarget(directionParams)
	if directionParams == nil or not Utils.isTable(directionParams) then
		return nil
	end

	local btnTrans

	ClientUtils.tryWithLogError(function()
		local panelId = directionParams[1]
		local uiCtrl = pg.global.ui:tryGetCtrlByUid(panelId)

		if uiCtrl == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("找不到对应的UICtrl！", inspect(directionParams))
			end

			return nil
		end

		if uiCtrl.view == nil then
			return nil
		end

		local viewTrans = uiCtrl.view.transform
		local targetPath = directionParams[2]
		local targetFlag = directionParams[3]
		local targetTrans = viewTrans

		if type(targetPath) ~= "string" then
			for i = 1, #targetPath do
				if IsNil(targetTrans) then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("找不到对应的聚焦组件 ", inspect(targetPath))
					end

					return nil
				end

				local orKey = targetPath[i]
				local orCom = targetTrans:GetComponent("ObjectReference")

				if orCom == nil then
					local containerCom = targetTrans:GetComponent("UContainer")

					if containerCom ~= nil then
						if IsNil(containerCom.content) then
							return nil
						end

						orCom = containerCom.content:GetComponent("ObjectReference")
					else
						local uScollRect = targetTrans:GetComponent("UScrollRect")

						if uScollRect ~= nil then
							orCom = uScollRect.content:GetComponent("ObjectReference")
						end
					end
				end

				if orCom == nil then
					local ulist = targetTrans:GetComponent("UList")

					if ulist ~= nil then
						if type(orKey) == "string" then
							targetTrans = targetTrans:Find(orKey)

							if IsNil(targetTrans) then
								targetTrans = ulist.content.transform:Find(orKey)
							end
						else
							targetTrans = GuideUtils.getChildSafely(targetTrans, orKey)

							if IsNil(targetTrans) then
								targetTrans = GuideUtils.getChildSafely(ulist.content.transform, orKey)
							end
						end
					elseif type(orKey) == "string" then
						targetTrans = targetTrans:Find(orKey)
					else
						targetTrans = GuideUtils.getChildSafely(targetTrans, orKey)
					end
				else
					local orValue = orCom:GetRefValue(orKey)

					if orValue then
						targetTrans = orValue.transform
					elseif type(orKey) == "string" then
						targetTrans = targetTrans:Find(orKey)

						if IsNil(targetTrans) then
							targetTrans = orCom.transform:Find(orKey)
						end
					else
						targetTrans = GuideUtils.getChildSafely(targetTrans, orKey)

						if IsNil(targetTrans) then
							targetTrans = GuideUtils.getChildSafely(orCom.transform, orKey)
						end
					end
				end
			end
		elseif string.find(targetPath, "/") then
			if string.sub(targetPath, -1) == "/" then
				targetPath = string.sub(targetPath, 1, -2)
			end

			targetTrans = viewTrans:Find(targetPath)
		else
			targetTrans = viewTrans:GetComponent("ObjectReference"):GetRefValue(targetPath).transform
		end

		if targetFlag ~= nil and targetTrans ~= nil then
			local list = targetTrans:GetComponent("UList")

			if NotNil(list) then
				targetTrans = list.content.transform
			end

			if type(targetFlag) == "string" then
				btnTrans = targetTrans:Find(targetFlag)
			else
				btnTrans = GuideUtils.getChildSafely(targetTrans, targetFlag)
			end
		else
			btnTrans = targetTrans
		end
	end)

	return btnTrans
end

function GuideUtils.checkUIVisible(stepCfg, checkTop)
	if stepCfg and stepCfg.directionMethod ~= nil then
		local curPanelUID = GuideUtils.getPanelId(stepCfg)
		local isShow = pg.global.ui:checkUIVisible(curPanelUID)

		if isShow and checkTop then
			local topPanelUID = pg.global.ui:getTopFirstPanel()

			if topPanelUID and topPanelUID ~= curPanelUID then
				local curCtrl = pg.global.ui:tryGetCtrlByUid(curPanelUID)
				local topFullUICtrl = pg.global.ui:tryGetCtrlByUid(topPanelUID)

				if curCtrl and topFullUICtrl and not GuideUtils.isHigherUILayer(curCtrl, topFullUICtrl) then
					return false
				end
			end
		end

		return isShow
	else
		return true
	end
end

function GuideUtils.isHigherUILayer(uctrl_1, uctrl_2)
	local uiType_1 = uctrl_1.uiConfig.uiType
	local uiType_2 = uctrl_2.uiConfig.uiType

	if uiType_1 == uiType_2 then
		return uctrl_1:getOrderWidget() > uctrl_2:getOrderWidget()
	end

	if uiType_1 == UIConst.INFOS_LAYER or uiType_2 == UIConst.INFOS_LAYER then
		return uiType_1 == UIConst.INFOS_LAYER
	end

	if uiType_1 == UIConst.POPUP_LAYER or uiType_2 == UIConst.POPUP_LAYER then
		return uiType_1 == UIConst.POPUP_LAYER
	end

	if uiType_1 == UIConst.PANEL_LAYER or uiType_2 == UIConst.PANEL_LAYER then
		return uiType_1 == UIConst.PANEL_LAYER
	end

	if uiType_1 == UIConst.SCENE_LAYER or uiType_2 == UIConst.SCENE_LAYER then
		return uiType_1 == UIConst.SCENE_LAYER
	end

	return false
end

function GuideUtils.checkFocusTargetVisible(stepCfg)
	if not GuideUtils.checkUIVisible(stepCfg, true) then
		return false
	end

	local function isFocusTargetVisible(targetTrans)
		if not LuaUIUtils.isUIViewVisible(targetTrans) then
			return false
		end

		local targetWidget = targetTrans:GetComponent("UWidget")

		return NotNil(targetWidget) and targetWidget.actualRenderOpacity > 0
	end

	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG then
		local btnTrans_1 = GuideUtils.getFocusTarget(stepCfg.directionParams[1])
		local btnTrans_2 = GuideUtils.getFocusTarget(stepCfg.directionParams[2])

		return isFocusTargetVisible(btnTrans_1) and isFocusTargetVisible(btnTrans_2), btnTrans_1, btnTrans_2
	else
		local btnTrans = GuideUtils.getFocusTarget(stepCfg.directionParams)

		return isFocusTargetVisible(btnTrans), btnTrans
	end
end

function GuideUtils.checkStepCondition(stepId, stepCfg)
	if not GuideUtils.checkSceneLimit(stepCfg) then
		return false
	end

	if self.curStepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if not GuideUtils.checkUIVisible(stepCfg, true) then
			return false
		end
	elseif self.curStepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM and not GuideUtils.checkItemExist(stepId, stepCfg) then
		return false
	end

	return true
end

function GuideUtils.checkStepDetailCondition(stepId, stepConfig)
	if not GuideUtils.checkSceneLimit(stepConfig) then
		return false
	end

	if stepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if not GuideUtils.checkFocusTargetVisible(stepConfig) then
			return false
		end
	elseif stepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM and not GuideUtils.checkItemExist(stepId, stepConfig) then
		return false
	end

	return true
end

function GuideUtils.checkItemExist(stepId, stepConfig)
	if stepConfig.directionMethod ~= Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM then
		return true
	end

	local itemId = stepConfig.directionParams[0]

	if itemId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%d指向道具引导步骤中的参数directionParams不包含道具ID！", stepId)
		end

		return false
	end

	local itemCount = ClientUtils.getItemCountById(itemId)

	if itemCount < 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%d指向道具引导步骤中的道具在背包中不存在！", stepId)
		end

		return false
	end

	return true
end

function GuideUtils.checkSceneLimit(stepCfg)
	if stepCfg == nil then
		return false
	end

	local sceneId = stepCfg.sceneId

	if not sceneId then
		return true
	else
		local curSceneId = pg.me.space.sceneId

		if not curSceneId then
			logger:error("现在可能在切场景")

			return false
		end

		return true
	end
end

function GuideUtils.checkPlatformLimit(stepCfg)
	if stepCfg == nil then
		return false
	end

	if stepCfg.platform == nil then
		return true
	end

	local curPlatform = ClientUtils.getAdaptionPlatform()

	return table.contains(stepCfg.platform, curPlatform)
end

function GuideUtils.endCheckContains(stepCfg, endCheckType)
	if stepCfg == nil then
		return false
	end

	return table.contains(stepCfg.endCheck, endCheckType)
end

function GuideUtils.canShowFloatingAutoFinishedAni(stepCfg)
	return stepCfg.animation == 1 and (stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO or stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI)
end

function GuideUtils.exeCustomFunc(stepCfg)
	local args = stepCfg.customFunction

	if args == nil then
		return
	end

	local uiCtrl = pg.global.ui:tryGetCtrlByUid(args[1])

	if uiCtrl == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("customFunction出错，界面找不到", tostring(args[1]))
		end

		return
	end

	local func = args[2]
	local ret, error = pcall(function()
		uiCtrl[func](uiCtrl, args[3])
	end)

	if not ret and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("customFunction执行出错", error, func)
	end
end

function GuideUtils.setCameraBlendToFixed(stepCfg)
	if not stepCfg.cameraPosition and not stepCfg.cameraRotation and not stepCfg.cameraFov then
		return
	end

	local pos = Vector3(stepCfg.cameraPosition[1], stepCfg.cameraPosition[2], stepCfg.cameraPosition[3])
	local rot = Quaternion(stepCfg.cameraRotation[1], stepCfg.cameraRotation[2], stepCfg.cameraRotation[3], stepCfg.cameraRotation[4])

	pg.game.camera:cameraBlendToFixed(pos, rot, stepCfg.cameraFov)
end

function GuideUtils.resetCameraBlendToFixed(stepCfg)
	if stepCfg == nil or not stepCfg.cameraPosition and not stepCfg.cameraRotation and not stepCfg.cameraFov then
		return
	end

	pg.game.camera:cancelBlendToFixed(0.5)
end

function GuideUtils.canEnterTwoStep(stepCfg)
	if stepCfg.stepOneTime == nil then
		return false
	end

	if table.contains(stepCfg.endCheck, Const.GUIDE_STEP_END.GSC_CLICK_BTN) or table.contains(stepCfg.endCheck, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED) then
		return true
	end

	return false
end

function GuideUtils.isLastStep(curStepId, stepCfg)
	return curStepId == stepCfg.step[#stepCfg.step]
end

function GuideUtils.getPanelId(stepCfg)
	local panelId

	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if stepCfg.directionParams ~= nil then
			if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG then
				panelId = stepCfg.directionParams[1][1]
			else
				panelId = stepCfg.directionParams[1]
			end
		end
	elseif stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM then
		-- block empty
	end

	return panelId
end

function GuideUtils.getPanelName(stepCfg)
	local panelName

	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG then
			panelName = stepCfg.directionParams[1][1]
		else
			panelName = stepCfg.directionParams[1]
		end
	elseif stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM then
		-- block empty
	end

	return panelName
end

function GuideUtils.rectSameAs(curRectTrans, targetRectTrans)
	local center = CS.UnityEngine.Vector2(0.5, 0.5)

	curRectTrans.pivot = targetRectTrans.pivot
	curRectTrans.anchorMin = center
	curRectTrans.anchorMax = center

	local targetSize = targetRectTrans.rect.size
	local targetLossyScale = targetRectTrans.lossyScale
	local virtualLossyScale = curRectTrans.lossyScale
	local sx, sy = targetLossyScale.x, targetLossyScale.y
	local dx, dy = virtualLossyScale.x, virtualLossyScale.y

	curRectTrans.sizeDelta = CS.UnityEngine.Vector2(targetSize.x * sx / dx, targetSize.y * sy / dy)
	curRectTrans.position = targetRectTrans.position
end

function GuideUtils.setGameTime(speed)
	if pg.space then
		speed = speed or 1

		pg.space:startGameTime(speed, Const.GameTimeScaleType.GUIDE)
	end
end

function GuideUtils.isGuidePlayed(guideId)
	if pg.me.guidanceRecords[guideId] ~= nil then
		local times = pg.me.guidanceRecords[guideId]

		return times and times >= 1
	end

	return false
end

local function syncGuideStepData(oldData, newData, visited)
	visited = visited or {}

	if visited[newData] then
		return
	end

	visited[newData] = oldData

	local deletedKeys = {}

	for key in pairs(oldData) do
		if newData[key] == nil then
			deletedKeys[#deletedKeys + 1] = key
		end
	end

	for _, key in ipairs(deletedKeys) do
		oldData[key] = nil
	end

	local AccessControl = require("Core.Framework.AccessControl")

	for key, newValue in pairs(newData) do
		local oldValue = oldData[key]

		if type(newValue) == "table" and type(oldValue) == "table" then
			syncGuideStepData(oldValue, newValue, visited)
		elseif type(newValue) == "table" then
			oldData[key] = AccessControl.readOnly(newValue)
		else
			oldData[key] = newValue
		end
	end
end

function GuideUtils.reloadGuideStepData()
	local Switch = require("Core.Common.Switch")

	if not Switch.ReadLuaData then
		local BddDataMgr = require("Core.Framework.BddDataMgr")
		local reloadOk, reloadError = xpcall(function()
			BddDataMgr.GetInstance():init()
		end, debug.traceback)

		if not reloadOk then
			logger:error("reloadGuideStepData BDD reload failed: %s", tostring(reloadError))

			return false
		end

		logger:info("reloadGuideStepData BDD reload success")

		return true
	end

	local moduleName = "Data.guide_step_data"
	local guideStepData = require(moduleName)

	if type(guideStepData) ~= "table" then
		logger:error("reloadGuideStepData failed: cached guide_step_data is not a Lua table")

		return false
	end

	local filePath = string.format("%s/Data/guide_step_data.lua", LUA_ROOT_PATH)
	local loader, loadError = loadfile(filePath)

	if not loader then
		logger:error("reloadGuideStepData load failed: %s", tostring(loadError))

		return false
	end

	local loadOk, newData = xpcall(loader, debug.traceback)

	if not loadOk or type(newData) ~= "table" then
		logger:error("reloadGuideStepData execute failed: %s", tostring(newData))

		return false
	end

	local oldReloading = pg.isReloading

	pg.isReloading = true

	local syncOk, syncError = xpcall(function()
		syncGuideStepData(guideStepData, newData)
	end, debug.traceback)

	pg.isReloading = oldReloading

	if not syncOk then
		logger:error("reloadGuideStepData sync failed: %s", tostring(syncError))

		return false
	end

	logger:info("reloadGuideStepData Lua reload success")

	return true
end

return GuideUtils
