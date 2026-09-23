-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\PlatformDisplayNameInjector.lua

local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformDisplayNameInjector = {}

PlatformDisplayNameInjector.COMMON_BLANK = " "
PlatformDisplayNameInjector.MOBILE_SPRITE = {
	bw = "UI_CharID_Mobile",
	color = "UI_CharID_Mobile_C"
}
PlatformDisplayNameInjector.CONSOLE_SPRITE = {
	bw = "UI_CharID_Console",
	color = "UI_CharID_Console_C"
}
PlatformDisplayNameInjector.SPRITE_MAP = {
	[PlatformIdentityUtils.Family.Xbox] = {
		bw = "UI_CharID_XBOX",
		color = "UI_CharID_XBOX_C"
	},
	[PlatformIdentityUtils.Family.PlayStation] = {
		bw = "UI_CharID_PS",
		color = "UI_CharID_PS_C"
	},
	[PlatformIdentityUtils.Family.Pc] = {
		bw = "UI_CharID_PC",
		color = "UI_CharID_PC_C"
	},
	[PlatformIdentityUtils.Family.Android] = PlatformDisplayNameInjector.MOBILE_SPRITE,
	[PlatformIdentityUtils.Family.Ios] = PlatformDisplayNameInjector.MOBILE_SPRITE
}

function PlatformDisplayNameInjector.normalizeTargetFamily(playerInfo)
	if type(playerInfo) ~= "table" then
		return nil
	end

	local family = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	if family and family ~= PlatformIdentityUtils.Family.Other then
		return family
	end

	return nil
end

function PlatformDisplayNameInjector.pickSprite(spriteDef, useColorLogo)
	return useColorLogo and spriteDef.color or spriteDef.bw
end

function PlatformDisplayNameInjector.getSpriteName(targetFamily, viewerFamily, useColorLogo)
	if PlatformIdentityUtils.isConsoleFamily(targetFamily) and PlatformIdentityUtils.isConsoleFamily(viewerFamily) and targetFamily ~= viewerFamily then
		return PlatformDisplayNameInjector.pickSprite(PlatformDisplayNameInjector.CONSOLE_SPRITE, useColorLogo)
	end

	local spriteDef = PlatformDisplayNameInjector.SPRITE_MAP[targetFamily] or PlatformDisplayNameInjector.SPRITE_MAP[PlatformIdentityUtils.Family.Pc]

	if not spriteDef then
		return nil
	end

	return PlatformDisplayNameInjector.pickSprite(spriteDef, useColorLogo)
end

function PlatformDisplayNameInjector.isUnityNil(value)
	return value == nil or type(IsNil) == "function" and IsNil(value)
end

function PlatformDisplayNameInjector.safeGetRefValue(objectReference, refName)
	if PlatformDisplayNameInjector.isUnityNil(objectReference) or string.isNilOrEmpty(refName) or not objectReference.GetRefValue then
		return nil
	end

	local ok, value = pcall(function()
		return objectReference:GetRefValue(refName)
	end)

	if ok and not PlatformDisplayNameInjector.isUnityNil(value) then
		return value
	end

	return nil
end

function PlatformDisplayNameInjector.enableRichText(textNode)
	if PlatformDisplayNameInjector.isUnityNil(textNode) then
		return false
	end

	textNode.supportRichText = true

	return true
end

function PlatformDisplayNameInjector.enableRichTextRefs(objectReference, refNames)
	if type(refNames) ~= "table" then
		return 0
	end

	local enabledCount = 0

	for _, refName in ipairs(refNames) do
		local textNode = PlatformDisplayNameInjector.safeGetRefValue(objectReference, refName)

		if PlatformDisplayNameInjector.enableRichText(textNode) then
			enabledCount = enabledCount + 1
		end
	end

	return enabledCount
end

function PlatformDisplayNameInjector.safeGetObjectReference(node)
	if PlatformDisplayNameInjector.isUnityNil(node) or not node.GetComponent then
		return nil
	end

	local ok, objectReference = pcall(function()
		return node:GetComponent("ObjectReference")
	end)

	if ok and not PlatformDisplayNameInjector.isUnityNil(objectReference) then
		return objectReference
	end

	return nil
end

function PlatformDisplayNameInjector.resolveOnlineIDNodes(objectReference, config, refName)
	local onlineIDRefName = refName or config.onlineIDRefName or "OnlineID"
	local onlineIDNode, activeNode

	if not string.isNilOrEmpty(config.onlineIDContainer) then
		local containerNode = PlatformDisplayNameInjector.safeGetRefValue(objectReference, config.onlineIDContainer)

		activeNode = containerNode

		local containerObjectReference = PlatformDisplayNameInjector.safeGetObjectReference(containerNode)
		local childOnlineIDNode = PlatformDisplayNameInjector.safeGetRefValue(containerObjectReference, onlineIDRefName)

		if not PlatformDisplayNameInjector.isUnityNil(childOnlineIDNode) then
			onlineIDNode = childOnlineIDNode
		end
	end

	if PlatformDisplayNameInjector.isUnityNil(onlineIDNode) then
		onlineIDNode = PlatformDisplayNameInjector.safeGetRefValue(objectReference, onlineIDRefName)
	end

	if PlatformDisplayNameInjector.isUnityNil(activeNode) then
		activeNode = onlineIDNode
	end

	return onlineIDNode, activeNode
end

function PlatformDisplayNameInjector.setNodeActive(node, active)
	if PlatformDisplayNameInjector.isUnityNil(node) then
		return false
	end

	if node.SetActive then
		node:SetActive(active)

		return true
	end

	local gameObject = node.gameObject

	if PlatformDisplayNameInjector.isUnityNil(gameObject) then
		return false
	end

	if gameObject.SetActiveEx then
		gameObject:SetActiveEx(active)

		return true
	end

	if gameObject.SetActive then
		gameObject:SetActive(active)

		return true
	end

	return false
end

function PlatformDisplayNameInjector.formatNameWithLogo(playerName, platformFamily, config)
	local viewerFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local spriteName = PlatformDisplayNameInjector.getSpriteName(platformFamily, viewerFamily, config and config.useColorLogo == true)

	if string.isNilOrEmpty(spriteName) then
		return playerName
	end

	local tag = string.format("<sprite name=\"%s\">", spriteName)

	if config and config.logoPosition == "after" then
		return tostring(playerName or "") .. PlatformDisplayNameInjector.COMMON_BLANK .. tag
	end

	return tag .. PlatformDisplayNameInjector.COMMON_BLANK .. tostring(playerName or "")
end

function PlatformDisplayNameInjector.getDisplayName(params)
	local playerInfo = params and params.playerInfo or {}
	local config = params and params.config or {}
	local rawName = tostring(params and params.rawName or "")
	local targetFamily = PlatformDisplayNameInjector.normalizeTargetFamily(playerInfo)

	return PlatformDisplayNameInjector.formatNameWithLogo(rawName, targetFamily, config)
end

function PlatformDisplayNameInjector.getOnlineIDText(params)
	local config = params and params.config or {}

	if not config.showOnlineID then
		return ""
	end

	local playerInfo = params and params.playerInfo or {}
	local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo) or {}

	return tostring(identity.platformDisplayName or "")
end

function PlatformDisplayNameInjector.applyOnlineID(params)
	local objectReference = params and params.objectReference
	local config = params and params.config or {}
	local onlineIDNode, activeNode = PlatformDisplayNameInjector.resolveOnlineIDNodes(objectReference, config, params and params.refName)

	if PlatformDisplayNameInjector.isUnityNil(onlineIDNode) then
		logger:warn("[platform_online_id][injector] online_id_node_missing refName=%s container=%s objectReferenceNil=%s configShow=%s", tostring(params and params.refName or config.onlineIDRefName or "OnlineID"), tostring(config.onlineIDContainer), tostring(PlatformDisplayNameInjector.isUnityNil(objectReference)), tostring(config.showOnlineID))

		return "", false
	end

	local text = PlatformDisplayNameInjector.getOnlineIDText({
		playerInfo = params and params.playerInfo,
		config = config
	})
	local hasText = not string.isNilOrEmpty(text)
	local setActive = PlatformDisplayNameInjector.setNodeActive(activeNode, hasText)

	ClientTextUtils.setText(onlineIDNode, hasText and text or "")
	logger:info("[platform_online_id][injector] apply_done hasText=%s activeNodeNil=%s setActive=%s onlineIDNodeNil=%s", tostring(hasText), tostring(PlatformDisplayNameInjector.isUnityNil(activeNode)), tostring(setActive), tostring(PlatformDisplayNameInjector.isUnityNil(onlineIDNode)))

	return text, hasText
end

return PlatformDisplayNameInjector
