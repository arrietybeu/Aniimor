-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\UIScene\\UISceneSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local UISceneSystem = Class.LightClass("UISceneSystem", SystemBase)
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")

function UISceneSystem:onCtor()
	self.mainSceneLight = nil
end

function UISceneSystem:onInit()
	pg.global.cameraMgr:SetGateCameraEnable(false)

	self.attachScenes = {}
	self.uiSceneStack = {}
end

function UISceneSystem:formatPetBlurTraceStack()
	local stack = {}

	for i, v in ipairs(self.uiSceneStack or EMPTY_TABLE) do
		stack[#stack + 1] = string.format("%d:%s/%s/disableMainCamera=%s", i, tostring(v.name), tostring(v.ownerKey), tostring(v.disableMainCamera))
	end

	if #stack == 0 then
		return "<empty>"
	end

	return table.concat(stack, " -> ")
end

function UISceneSystem:clearUIScenes()
	local scenes = {}

	for _, scene in pairs(self.attachScenes) do
		if scene ~= nil then
			scenes[#scenes + 1] = scene
		end
	end

	for _, scene in ipairs(scenes) do
		ClientUtils.tryWithLogErrorEx(scene.destroy, scene)
	end

	self.attachScenes = {}
	self.uiSceneStack = {}

	self:setMainSceneActive(true)
	pg.global.lightMgr:ActiveLightByLayer(false, ClientConst.LayerDefine.LAYER_UI_SCENE)
	pg.global.uiMgr:ClearStreamingAnchor()
end

function UISceneSystem:onClear()
	self:clearUIScenes()
end

function UISceneSystem:onDestroy()
	self:clearUIScenes()
end

function UISceneSystem:registerUIScene(name, sceneIns)
	if self.attachScenes[name] ~= nil then
		return
	end

	self.attachScenes[name] = sceneIns
end

function UISceneSystem:unRegisterUIScene(name)
	self.attachScenes[name] = nil
end

function UISceneSystem:switchToScene(targetName, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera, ownerKey)
	local curScene = self.attachScenes[targetName]

	if curScene == nil then
		return
	end

	pg.global.uiMgr:AddStreamingAnchor()

	for name, sceneInfo in pairs(self.attachScenes) do
		local active = false

		if openAdditive then
			if name == targetName then
				sceneInfo:setActive(true)

				active = true
			end
		else
			active = name == targetName

			sceneInfo:setActive(active)
		end

		if active then
			sceneInfo:onEnabled()
		else
			sceneInfo:onDisabled()
		end
	end

	curScene:onEnter()

	local disableMainCamera = not ignoreDisableMainCamera

	if disableMainCamera then
		self:setMainSceneActive(false)
		pg.global.lightMgr:ActiveLightByLayer(true, ClientConst.LayerDefine.LAYER_UI_SCENE)
	end

	local stackKey = ownerKey or targetName
	local idx = -1

	for i, v in ipairs(self.uiSceneStack) do
		if v.ownerKey == stackKey and v.name == targetName then
			idx = i

			break
		end
	end

	local topScene

	if idx > 0 then
		topScene = table.remove(self.uiSceneStack, idx)
	else
		topScene = {
			name = targetName,
			ownerKey = stackKey
		}
	end

	topScene.disableMainCamera = disableMainCamera

	table.insert(self.uiSceneStack, topScene)

	local resetUICamera = not ignoreResetUICamera

	if resetUICamera then
		pg.game.camera:resetUICameraBlendStack()
	end
end

function UISceneSystem:checkNeedPawnHide()
	for name, sceneInfo in pairs(self.attachScenes) do
		if sceneInfo:hidePawnModel() then
			return true
		end
	end

	return false
end

function UISceneSystem:switchOutScene(targetName, keepOnExit, ignoreSetMainCamera, ownerKey)
	local atScene = self.attachScenes[targetName]

	if not atScene then
		-- block empty
	end

	if atScene then
		atScene:onDisabled()
		atScene:onExit()
	end

	local removedTop = false
	local stackLen = #self.uiSceneStack

	if not keepOnExit then
		for i = stackLen, 1, -1 do
			if self.uiSceneStack[i].name == targetName then
				if i == #self.uiSceneStack then
					removedTop = true
				end

				table.remove(self.uiSceneStack, i)
			end
		end
	else
		local stackKey = ownerKey
		local curIndex = 0

		if stackKey then
			for i = stackLen, 1, -1 do
				local v = self.uiSceneStack[i]

				if v.ownerKey == stackKey and v.name == targetName then
					curIndex = i

					break
				end
			end
		else
			for i = stackLen, 1, -1 do
				if self.uiSceneStack[i].name == targetName then
					curIndex = i

					break
				end
			end
		end

		if curIndex ~= 0 then
			if curIndex == #self.uiSceneStack then
				removedTop = true
			end

			table.remove(self.uiSceneStack, curIndex)
		end
	end

	if atScene and not keepOnExit then
		atScene:destroy()
	end

	local showMainCamera = true

	if removedTop then
		if #self.uiSceneStack > 0 then
			local topScene = self.uiSceneStack[#self.uiSceneStack]

			showMainCamera = not topScene.disableMainCamera

			if keepOnExit and atScene and topScene.name ~= targetName then
				atScene:setActive(false)
			end

			local uiScene = self.attachScenes[topScene.name]

			if uiScene then
				uiScene:setActive(true)
			end
		elseif keepOnExit and atScene then
			atScene:setActive(false)
		end

		if showMainCamera then
			self:setMainSceneActive(true)
			pg.global.lightMgr:ActiveLightByLayer(false, ClientConst.LayerDefine.LAYER_UI_SCENE)
		end

		if #self.uiSceneStack == 0 then
			pg.global.uiMgr:ClearStreamingAnchor()
		end
	end
end

function UISceneSystem:getScene(targetName)
	return self.attachScenes[targetName]
end

function UISceneSystem:getUISceneInst(name, resId, additionRes, paramsTable, className)
	local cls

	if className then
		cls = require("GameApp.Scenes.UIScenes." .. className)
	else
		cls = require("GameApp.Scenes.UIScenes." .. name)
	end

	local inst = cls.new(name, resId, additionRes, paramsTable)

	return inst
end

function UISceneSystem:beforeAnimation()
	for _, scene in pairs(self.attachScenes) do
		if scene ~= nil then
			scene:beforeAnimation()
		end
	end
end

function UISceneSystem:setMainSceneActive(isActive)
	pg.game.camera:setWorldCameraEnable(isActive, ClientConst.CameraDisableReason.UIScene)
end

return UISceneSystem
