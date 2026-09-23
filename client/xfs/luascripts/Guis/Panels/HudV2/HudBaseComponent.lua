-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\HudBaseComponent.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local CommonSwitch = require("Common.CommonSwitch")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local HudBaseComponent = Class.LightClass("HudBaseComponent", UIComponent)

local function buildNameSet(list)
	if not list or #list == 0 then
		return nil
	end

	local map = {}

	for _, name in ipairs(list) do
		if type(name) == "string" and name ~= "" then
			map[name] = true
		end
	end

	return map
end

local function mergeWithSelf(selfName, extraList)
	local whiteList = {}
	local length = 0

	if selfName then
		length = length + 1
		whiteList[length] = selfName
	end

	if extraList then
		for _, name in ipairs(extraList) do
			length = length + 1
			whiteList[length] = name
		end
	end

	return whiteList
end

function HudBaseComponent:ctor(ctrl, trans, extInfo)
	extInfo = extInfo or {}

	if extInfo.needLoadRes == nil then
		extInfo.needLoadRes = true
	end

	UIComponent.ctor(self, ctrl, trans, extInfo)

	self.compName = self.extInfo.compName

	if self.extInfo.isFixRoot then
		self:_loadNodeRes()
	elseif self.extInfo.isContainer and self.extInfo.isAutoLoad then
		if self.uWidget:CheckURLLoaded() then
			self:onRootNodeLoaded(self.uWidget.content.transform)
		else
			self.uWidget:LoadDefaultUrlManually(function(uwidget)
				self:onRootNodeLoaded(uwidget.transform)
			end)
		end
	elseif self.extInfo.isAutoLoad then
		local resId
		local isMobile = pg.global.ui:runPlatformByMobile()

		if isMobile then
			resId = HudSplicingCfg.resConfig[self.compName].mobileResId or HudSplicingCfg.resConfig[self.compName].resId
		else
			resId = HudSplicingCfg.resConfig[self.compName].resId
		end

		self.view:addPrefabWithPathAsync(self.extInfo.parentTrans, resId, function(item)
			self:onRootNodeLoaded(item.transform)
		end)
	end
end

function HudBaseComponent:addPrefabWithPathAsync(parent, resID, callback, urgent, ignoreWhileNoParent, priority)
	self.view:addPrefabWithPathAsync(parent, resID, callback, urgent, ignoreWhileNoParent, priority)
end

function HudBaseComponent:tryShowComponent()
	if self.transform then
		return true
	end

	if not self._resLoading then
		self._resLoading = true

		self:_loadNodeRes()
	end

	return false
end

function HudBaseComponent:tryCloseComponent()
	self._visible = false

	pg.global.ui:unRegisterComponentMessages(self)
	self:_setExcludedComponentsHidden(false)

	if self.transform then
		self.view:destroyInstance(self.transform.gameObject)
	end

	self.transform = nil
	self._resLoading = false

	self:onClose()
end

function HudBaseComponent:onClose()
	return
end

function HudBaseComponent:_getExcludedComponentList()
	if not self.compName then
		return nil
	end

	local resConfig = HudSplicingCfg.resConfig[self.compName]
	local excludedList = resConfig and resConfig.excludedComponent

	if type(excludedList) ~= "table" or #excludedList == 0 then
		return nil
	end

	return excludedList
end

function HudBaseComponent:_getExcludedReasonKey()
	if not self.compName then
		return nil
	end

	return self.compName
end

function HudBaseComponent:_setExcludedComponentsHidden(hidden)
	local excludedList = self:_getExcludedComponentList()

	if not excludedList then
		return
	end

	local reasonKey = self:_getExcludedReasonKey()

	if not reasonKey then
		return
	end

	local targetSet = buildNameSet(excludedList)

	if not targetSet then
		return
	end

	if not self.ctrl or not self.ctrl.uiComponents then
		return
	end

	for _, component in ipairs(self.ctrl.uiComponents) do
		if component and component ~= self and component.compName and targetSet[component.compName] and component.view then
			if hidden then
				component:tryHide(reasonKey)
			else
				component:tryShow(reasonKey)
			end
		end
	end
end

function HudBaseComponent:tryHideComponent(reason)
	UIComponent.onDestroy(self)
end

function HudBaseComponent:_loadNodeRes()
	local resId, parentNode
	local resConfig = HudSplicingCfg.resConfig[self.compName]
	local isMobile = pg.global.ui:runPlatformByMobile()

	if resConfig then
		resId = isMobile and resConfig.mobileResId or resConfig.resId
		parentNode = resConfig.parentNode
	else
		local hudName = self.extInfo.hudName
		local hudTypeName = self.extInfo.hudTypeName
		local configData = HudSplicingCfg.SceneConfig[hudName][hudTypeName] or HudSplicingCfg.SceneConfig[HudSplicingCfg.HudType.World][hudTypeName]

		resId = isMobile and configData.mobileResId or configData.resId
		parentNode = configData.parentNode
	end

	if resId then
		self:addPrefabWithPathAsync(self.view[parentNode].transform, resId, function(item)
			self:onRootNodeLoaded(item.transform)
		end)
	else
		self:onRootNodeLoaded(self.view[parentNode].transform)
	end
end

function HudBaseComponent:bindHotKeyOverride(funcId, funcName, actionPath, special, func)
	actionPath = actionPath or LuaUIUtils.getFuncActionPath(funcId)

	if not actionPath then
		return
	end

	local openSetupBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, actionPath)

	openSetupBind.actionPath = actionPath
	openSetupBind.isVirtual = true
	openSetupBind.bindingBehavior = KeyBindingPro.KeyBindingBehavior.ResetModelWidget

	function openSetupBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and pg.me:checkFunctionUnlock(funcName) and CommonSwitch[funcName] then
			if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
				return
			end

			if LuaUIUtils.checkFuncForbidden(funcId) then
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
					pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))
				end

				return
			end

			return func()
		end
	end
end

function HudBaseComponent:bindHotKeyPerform(path, func, obj, bindName)
	bindName = bindName or path
	obj = obj or self.view.gameObject

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, bindName)

	hotKeyBind.actionPath = path
	hotKeyBind.isVirtual = true

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and func then
			return func(self, inputInfo)
		end

		if inputInfo.phase == "Checked" then
			return false
		end

		return true
	end

	return hotKeyBind
end

function HudBaseComponent:getSubCanvasMode()
	if self.compName then
		local resConfig = HudSplicingCfg.resConfig[self.compName]

		return resConfig and resConfig.subCanvasMode
	end

	local hudName = self.extInfo.hudName
	local hudTypeName = self.extInfo.hudTypeName
	local sceneConfig = hudName and HudSplicingCfg.SceneConfig[hudName]
	local configData = sceneConfig and sceneConfig[hudTypeName]

	configData = configData or HudSplicingCfg.SceneConfig[HudSplicingCfg.HudType.World][hudTypeName]

	return configData and configData.subCanvasMode
end

function HudBaseComponent:setupDirectUiSubCanvas(trans)
	if IsNil(trans) or not self.view or IsNil(self.view.uiNode) then
		return
	end

	local uiNodeTransform = self.view.uiNode.transform

	if trans == uiNodeTransform or trans.parent ~= uiNodeTransform then
		return
	end

	local subCanvasMode = self:getSubCanvasMode()

	if not subCanvasMode then
		return
	end

	UIUtils.SetupHudSubCanvas(trans.gameObject, subCanvasMode == HudSplicingCfg.SubCanvasMode.Interactive)
end

function HudBaseComponent:onRootNodeLoaded(trans)
	self._resLoading = false

	self:setupDirectUiSubCanvas(trans)
	self:setTransform(trans)
	self:findObjects()
	self:registerObjects()
	self:bindComponent()
	self:initView()

	self._visible = self:checkActive(true)

	pg.global.ui:registerComponentMessages(self)

	if self._visible then
		self:_setExcludedComponentsHidden(true)
	end

	self:adjustSiblingOrder()
end

function HudBaseComponent:adjustSiblingOrder()
	if not self.transform then
		return
	end

	local myConfig = self.compName and HudSplicingCfg.resConfig[self.compName]

	if myConfig and myConfig.topSibling then
		self.transform:SetAsLastSibling()

		return
	end

	local hudV2 = pg.global.ui.hudV2

	if not hudV2 then
		return
	end

	for _, layoutName in pairs(HudSplicingCfg.LayoutName) do
		local layout = hudV2[layoutName]

		if layout and layout.uiComponents then
			for _, comp in ipairs(layout.uiComponents) do
				if comp and comp.transform and comp.compName then
					local cfg = HudSplicingCfg.resConfig[comp.compName]

					if cfg and cfg.topSibling then
						comp.transform:SetAsLastSibling()

						return
					end
				end
			end
		end
	end
end

function HudBaseComponent:show()
	UIComponent.show(self)

	if self._visible then
		self:_setExcludedComponentsHidden(true)
	end
end

function HudBaseComponent:hide()
	UIComponent.hide(self)

	if not self._visible then
		self:_setExcludedComponentsHidden(false)
	end
end

function HudBaseComponent:getBaseComponentCls(name)
	name = name:gsub("^%l", string.upper)

	local module = require(string.format("Guis.Panels.HudV2.BaseComponent.%sUIComponent", name))

	return module
end

function HudBaseComponent:bindComponent()
	return
end

function HudBaseComponent:open()
	return
end

function HudBaseComponent:close()
	self.view:destroyInstance()
end

function HudBaseComponent:_setChildComponentsVisible(visible, excludeList, reason)
	if not self.uiComponents or #self.uiComponents == 0 then
		return
	end

	local excludeSet = buildNameSet(excludeList)

	for _, component in ipairs(self.uiComponents) do
		if component and component ~= self and component.compName and component.tryHide and component.tryShow and (not excludeSet or not excludeSet[component.compName]) then
			if visible then
				component:tryShow(reason)
			else
				component:tryHide(reason)
			end
		end
	end
end

function HudBaseComponent:hideChildComponents(excludeList, reason)
	self:_setChildComponentsVisible(false, excludeList, reason)
end

function HudBaseComponent:showChildComponents(excludeList, reason)
	self:_setChildComponentsVisible(true, excludeList, reason)
end

function HudBaseComponent:hideSiblingComponents(excludeList, reason)
	if not self.ctrl or not self.ctrl.hideChildComponents then
		return
	end

	self.ctrl:hideChildComponents(mergeWithSelf(self.compName, excludeList), reason)
end

function HudBaseComponent:showSiblingComponents(excludeList, reason)
	if not self.ctrl or not self.ctrl.showChildComponents then
		return
	end

	self.ctrl:showChildComponents(mergeWithSelf(self.compName, excludeList), reason)
end

function HudBaseComponent:onDestroy()
	self:_setExcludedComponentsHidden(false)
end

function HudBaseComponent:showComponent()
	UIComponent.showComponent(self)
	self:playShowAnim()
end

function HudBaseComponent:hideComponent()
	UIComponent.hideComponent(self)
	self:playHideAnim()
end

function HudBaseComponent:playShowAnim()
	return
end

function HudBaseComponent:playHideAnim()
	return
end

return HudBaseComponent
