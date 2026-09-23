-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Avatar\\AvatarSystem.lua

local ClientUtils = require("Utils.ClientUtils")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local AppearancePointEnum = require("Data.appearance_point_enum")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceData = require("Data.appearance_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientModelUtils = require("Utils.ClientModelUtils")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local AvatarData = require("Data.avatar_data")
local MessageName = require("Const.MessageName")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarSystem = Class.LightClass("AvatarSystem", SystemBase)

AvatarSystem.BODY = {
	GIRL = 11,
	BOY = 21
}
AvatarSystem.TEMPLATE_ID = {
	[AvatarSystem.BODY.GIRL] = 3,
	[AvatarSystem.BODY.BOY] = 4
}
AvatarSystem.ANIM_CONTROLLER = {
	[AvatarSystem.BODY.GIRL] = "Map_Avatar_Girl",
	[AvatarSystem.BODY.BOY] = "Map_Avatar_Boy"
}

function AvatarSystem:getMessageBindMap()
	return {
		[MessageName.CUR_COMBAT_PET_CHANGED] = "onCurCombatPetChanged"
	}
end

function AvatarSystem:getAvatarPresetData(presetKey)
	local presetData = AvatarPresetData[presetKey]

	if presetData then
		return presetData
	end

	local function getBody(v)
		local s = tostring(v)

		if not s:match("^%d%d%d%d%d%d$") then
			return
		end

		local prefix = s:sub(1, 2)

		if prefix == "11" or prefix == "71" then
			return AvatarSystem.BODY.GIRL
		elseif prefix == "21" or prefix == "72" then
			return AvatarSystem.BODY.BOY
		else
			return
		end
	end

	local body = getBody(presetKey)

	if not body then
		return
	end

	presetData = {
		templateId = AvatarSystem.TEMPLATE_ID[body],
		body = body,
		defaultSuit = body == AvatarSystem.BODY.GIRL and 710069 or 720069,
		animController = AvatarSystem.ANIM_CONTROLLER[body],
		sort = math.maxInt
	}

	return presetData
end

function AvatarSystem:getGenderByPresetKey(presetKey)
	local presetData = self:getAvatarPresetData(presetKey)

	return presetData and AvatarData[presetData.templateId].gender
end

function AvatarSystem:onCurCombatPetChanged(info)
	return
end

function AvatarSystem:getPresetKey(entity)
	if not entity then
		return
	end

	if entity.avatarPresetKey and entity.avatarPresetKey ~= 0 then
		return entity.avatarPresetKey
	end

	local templateId = self:getTemplateId(entity)
	local avatarData = AvatarData[templateId] or {}

	return avatarData.presetKey or entity.eModel.modelModelView.modelInfo:GetPresetKey()
end

function AvatarSystem:getTemplateId(entity)
	if not entity then
		return
	end

	return entity.templateId or entity.eModel.modelModelView.modelInfo:GetTemplateId()
end

function AvatarSystem:onInit()
	self.hairSelection = {}
	self.jewelryInfo = {}
	self.ctxPreload = {
		iStatus = 0,
		iEnable = 0,
		iTimerID = 0,
		arrPFBConfig = {},
		arrPFBResult = {},
		arrETTConfig = {},
		arrETTResult = {}
	}

	self:preloadCreateContext()

	self.createPlayerSceneBgId = nil
	self.eyeNormalFixEntity = nil
	self.jumpToCreateRoleTimelineEnd = false
end

function AvatarSystem:tick()
	if not self.eyeNormalFixEntity then
		return
	end

	if not self.eyeNormalFixEntity.eModel or not self.eyeNormalFixEntity:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end
end

function AvatarSystem:updateHairSelection(partId, configId, reason)
	self.hairSelection[partId] = configId
end

function AvatarSystem:recordHairCustomData()
	self.hairCustomData = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairCustomDataStr = pg.global.avatarMgr:GetHairCustomDataString(partId, true)

		self.hairCustomData[partId] = compressToStr(hairCustomDataStr)
	end
end

function AvatarSystem:recordAppearance(presetKey, avatarConfig, curShow)
	self.originPresetKey = presetKey
	self.originAvatarConfig = avatarConfig
	self.originCurShow = curShow
end

function AvatarSystem:recordHairSnapshotKey(imageKey)
	self.hairSnapshotKey = imageKey
end

function AvatarSystem:getHairSnapshotKey()
	return self.hairSnapshotKey or ""
end

function AvatarSystem:backToHome()
	pg.game.uiScene:switchOutScene(UISceneConst.AVATAR_SCENE)
	pg.global.avatarMgr:ClearAvatar()
	self:setFusionData(nil)
end

function AvatarSystem:preloadCreateContext()
	local ctx = self.ctxPreload

	self:preloadClearTable(ctx.arrPFBConfig)
	self:preloadClearTable(ctx.arrPFBResult)
	self:preloadClearTable(ctx.arrETTConfig)
	self:preloadClearTable(ctx.arrETTResult)
	self:preloadAddPrefabLoadItem("$UI_Avatar_Scene_Accessory.prefab", nil)
	self:preloadAddPrefabLoadItem("$UI_Pb_Avatar_PinchFace_Entrance.prefab", nil)

	local hashTypeItem = self:preloadGetEntityConfigList()

	for i, v in pairs(hashTypeItem) do
		local item = v

		self:preloadAddEntityLoadItem(item.key, item)
	end
end

function AvatarSystem:preloadAddPrefabLoadItem(skey, param)
	local ctx = self.ctxPreload
	local count = #ctx.arrPFBConfig
	local index = count + 1

	ctx.arrPFBConfig[index] = {
		Index = index,
		Param = param,
		Key = skey
	}
	ctx.arrPFBResult[index] = {
		Index = index,
		Param = param,
		Key = skey
	}
end

function AvatarSystem:preloadGetEntityConfigList()
	local arrTypeID = {}
	local hashTypeItem = {}

	for i, v in pairs(AvatarPresetData) do
		local typeID = v.body
		local typeItem = hashTypeItem[typeID]

		if typeItem == nil then
			table.insert(arrTypeID, typeID)

			hashTypeItem[typeID] = {
				key = i,
				type = typeID,
				val = v
			}
		end
	end

	return hashTypeItem
end

function AvatarSystem:preloadAddEntityLoadItem(ikey, item)
	local ctx = self.ctxPreload

	ctx.arrETTConfig[ikey] = {
		Index = ikey,
		Param = item,
		Key = ikey
	}
	ctx.arrETTResult[ikey] = {
		Index = ikey,
		Param = item,
		Key = ikey
	}
end

function AvatarSystem:preloadClearTable(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

function AvatarSystem:preloadStartDelayed(delaySec)
	if UNITY_EDITOR then
		-- block empty
	end

	local ctx = self.ctxPreload

	if ctx.iEnable ~= 1 then
		return
	end

	if ctx.iStatus ~= 0 then
		return
	end

	if ctx.iTimerID ~= 0 then
		TimerManager.removeTimer(ctx.iTimerID)

		ctx.iTimerID = 0
	end

	print("@fjs preloadStartDelayed: delaySec=", delaySec)

	ctx.iStatus = 1
	ctx.iTimerID = TimerManager.addTimer(delaySec, function()
		pg.game.avatar:preloadDelayTimerFunc()
	end)
end

function AvatarSystem:preloadDelayTimerFunc()
	local ctx = self.ctxPreload

	if ctx.iStatus <= 0 then
		return
	end

	ctx.iStatus = 2
	ctx.iTimerID = 0

	for k, v in pairs(ctx.arrPFBConfig) do
		local index = k
		local item = v
		local resId = item.Key

		print("@fjs preloadDelayTimerFunc.preload prefab start, resId=", resId)
		pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, userData)
			print("@fjs preloadDelayTimerFunc.preload prefab compl, resId=", resId)
			pg.game.avatar:preloadOnPrefabLoadCallback(index, item, gameObj)
		end)
	end

	for k, v in pairs(ctx.arrETTConfig) do
		local index = k
		local item = v
		local resultItem = ctx.arrETTResult[index]

		print("@fjs preloadDelayTimerFunc.preload entity start, index=", index)

		resultItem.Result = self:preloadAvatarEntity(index, function()
			print("@fjs preloadDelayTimerFunc.preload entity compl, index=", index)
			pg.game.avatar:preloadOnEntityLoadCallback(index, item)
		end)
	end
end

function AvatarSystem:preloadOnPrefabLoadCallback(index, item, gameObj)
	local ctx = self.ctxPreload

	if gameObj ~= nil then
		gameObj:SetActiveEx(false)
	end

	if ctx.iStatus <= 0 then
		pg.global.resMgr:RemoveInstanceToCache(gameObj, true)

		return
	end

	local resultItem = ctx.arrPFBResult[index]

	resultItem.Result = gameObj
end

function AvatarSystem:preloadOnEntityLoadCallback(index, item)
	local ctx = self.ctxPreload
	local resultItem = ctx.arrETTResult[index]
	local entity

	if resultItem ~= nil then
		entity = resultItem.Result
	end

	print("@fjs preloadOnEntityLoadCallback: loaded index=", index)

	if ctx.iStatus <= 0 then
		if entity ~= nil then
			print("@fjs preloadOnEntityLoadCallback: destroy index=", index)

			resultItem.Result = nil

			ClientUtils.safeDestroy(entity)
		end

		return
	end
end

function AvatarSystem:preloadShutdown()
	local ctx = self.ctxPreload

	if ctx.iEnable ~= 1 then
		return
	end

	if ctx.iStatus <= 0 then
		return
	end

	print("@fjs preloadShutdown: iStatus=", ctx.iStatus)

	ctx.iStatus = -1

	if ctx.iTimerID ~= 0 then
		TimerManager.removeTimer(ctx.iTimerID)

		ctx.iTimerID = 0
	end

	for k, v in pairs(ctx.arrPFBConfig) do
		local index = k
		local item = v
		local resultItem = ctx.arrPFBResult[index]
		local gameObj = resultItem.Result

		resultItem.Result = nil

		if gameObj ~= nil then
			print("@fjs preloadShutdown: destroy prefab Key=", item.Key)
			pg.global.resMgr:RemoveInstanceToCache(gameObj, true)
		end
	end

	for k, v in pairs(ctx.arrETTConfig) do
		local index = k
		local item = v
		local resultItem = ctx.arrETTResult[index]
		local entityObj = resultItem.Result

		resultItem.Result = nil

		if entityObj ~= nil then
			print("@fjs preloadShutdown: destroy entity Key=", item.Key)
			ClientUtils.safeDestroy(entityObj)
		end
	end
end

function AvatarSystem:preloadAvatarEntity(presetKey, onAvatarLoaded)
	local templateId = self:getAvatarPresetData(presetKey).templateId
	local entity = ClientSimpleVirtualPlayer.new()
	local dict = {
		templateId = templateId,
		avatarPresetKey = presetKey
	}

	entity:init(dict)
	entity:postInit(dict)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	function entity.modelPartModelAllLoaded()
		entity.modelPartModelAllLoaded = nil

		if onAvatarLoaded then
			onAvatarLoaded()
		end
	end

	return entity
end

function AvatarSystem:setFusionData(info)
	if not info then
		self.fusionData = nil

		return
	end

	self.fusionData = info
end

function AvatarSystem:getFusionData()
	return self.fusionData
end

function AvatarSystem:getPreloadAssetList()
	local animationAssetPath = CS.FunPlus.WorldX.Animations.PlayableClipConfigSettings.GetAnimationAssetPreloadPath()
	local tAssetList = {
		{
			path = "$Ani_Avatar_Boy_Show_Idle.fbx[GenCoat_Ani_Avatar_Boy_Show_Idle]",
			type = "AnimationClip"
		},
		{
			path = "$Ani_Avatar_Boy_Show_Idle.fbx[GenSkirt_Ani_Avatar_Boy_Show_Idle]",
			type = "AnimationClip"
		},
		{
			path = "$AvatarRuntimeConfig/Body/Body102110001.bytes",
			type = "TextAsset"
		},
		{
			path = "$AvatarRuntimeConfig/Clothes/Clothes21.bytes",
			type = "TextAsset"
		},
		{
			path = "$AvatarRuntimeConfig/Face/Face202110002.bytes",
			type = "TextAsset"
		},
		{
			path = "$AvatarRuntimeConfig/Hair/Hair302110005.bytes",
			type = "TextAsset"
		},
		{
			path = "$AvatarRuntimeConfig/MakeUp/MakeUp402110001.bytes",
			type = "TextAsset"
		},
		{
			path = "$AvatarRuntimeConfig/avatar_210001.bytes",
			type = "TextAsset"
		},
		{
			type = "TextAsset",
			path = animationAssetPath
		},
		{
			path = "$Character_Playable/PlayableAsset/AnimationBakeInfoAsset.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableAsset/AnimationTagGroupAsset.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/BaseLocoController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/BossController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/CustomController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/HumanController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/NpcController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableControllerAsset/ParmonController.bytes",
			type = "TextAsset"
		},
		{
			path = "$Character_Playable/PlayableOverrideControllerAsset/Map_Avatar_Boy.bytes",
			type = "TextAsset"
		},
		{
			path = "Assets/Res/Adapter/ModelInfo/Avatar_Boy_Skin.bytes",
			type = "TextAsset"
		},
		{
			path = "$FacialDef_Boy.asset",
			type = "Object"
		},
		{
			path = "$FacialDef_Female.asset",
			type = "Object"
		},
		{
			path = "$FacialDef_Girl.asset",
			type = "Object"
		},
		{
			path = "$FacialDef_Male.asset",
			type = "Object"
		},
		{
			path = "$MaskA_Avatar_Boy_Face_.mask",
			type = "Object"
		},
		{
			path = "$Mask_Avatar_Boy_Upper.mask",
			type = "Object"
		},
		{
			path = "Assets/Res_Export/Environment/Mesh/PC/SM_LVUIC_Build_Background_Screen_01_LOD0_1422341271.asset",
			type = "Object"
		},
		{
			path = "Assets/Res_Export/Environment/Mesh/PC/SM_LVUIC_Build_Plane_01_LOD0_-375525590.asset",
			type = "Object"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/AniMask/MaskA_Avatar_Boy_Face_.mask",
			type = "Object"
		},
		{
			path = "$Entity.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Bg_1_Scene.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Bg_1_Scene.prefab",
			type = "GameObject"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Female/Avatar_Female_Decal/Texture/T_Avatar_Female_Decal_F00000_MOHR.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Female/Avatar_Female_Decal/Texture/T_Avatar_Female_Decal_F00000_N.tga",
			type = "Texture2D"
		},
		{
			path = "$UI_Avatar_Ball_BG1.png",
			type = "Texture2D"
		},
		{
			path = "$P_Avatar_Accessory_Scene.prefab",
			type = "GameObject"
		},
		{
			path = "$UI_Pb_Avatar_PinchFace_Entrance.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Skin.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Body_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Face_B10002.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Eyelash_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Hair_B10005.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Coat_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Trousers_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Gloves_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Sock_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Shoes_B10001.prefab",
			type = "GameObject"
		},
		{
			path = "$P_Avatar_Boy_Face_Show.prefab",
			type = "GameObject"
		},
		{
			path = "$Ani_Avatar_Boy_Idle.fbx[Ani_Avatar_Boy_Idle]",
			type = "AnimationClip"
		},
		{
			path = "$Ani_Avatar_Boy_Show_Idle.fbx[Ani_Avatar_Boy_Show_Idle]",
			type = "AnimationClip"
		},
		{
			path = "Assets/Res_Export/Character/Mesh/PC/M_Face_All_-1270544639.asset",
			type = "Mesh"
		},
		{
			path = "Assets/Res_Export/Character/Mesh/PC/M_Avatar_Boy_Body_B10001_-1014187452.asset",
			type = "Mesh"
		},
		{
			path = "Assets/Res_Export/Character/Mesh/PC/M_Avatar_Boy_Coat_B10001_-1547492060.asset",
			type = "Mesh"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Eyelash/Texture/T_Avatar_Boy_Eyelash_B10001_CA.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Eyebrow/Texture/T_Avatar_Boy_Eyebrow_B10002_CA.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Body/Texture/T_Avatar_Boy_Body_B10001_C.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Body/Texture/T_Avatar_Boy_Body_B10001_MOHR.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Common/Textures/TilingTexture/DetailNormal/T_Tiling_DetailNormal_03_N.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Face/Texture/T_Avatar_Boy_Face_B10002_CA.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res/Character/Avatar/Avatar_Boy/Avatar_Boy_Face/Texture/T_Avatar_Boy_Face_B10001_MOHR.tga",
			type = "Texture2D"
		},
		{
			path = "Assets/Res_Export/Character/Material/PC/MI_Avatar_Boy_Body_B10001_FFDB7B11.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Character/Material/PC/MI_Avatar_Boy_Coat_B10001_01a_7781C806.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Character/Material/PC/MI_Avatar_Boy_Coat_B10001_11511291.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Environment/Material/PC/MI_Avatar_Plane01_8E051F52.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Environment/Material/PC/MI_Avatar_Plane02_8E05228F.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Environment/Material/PC/MI_Avatar_Plane03_8E050650.mat",
			type = "Material"
		},
		{
			path = "Assets/Res_Export/Environment/Material/PC/MI_UIC_Plane02_38E94A4D.mat",
			type = "Material"
		}
	}

	return tAssetList
end

return AvatarSystem
