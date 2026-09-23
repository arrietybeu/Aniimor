-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\WorldXEnv.lua

local Class = require("Core.Framework.Class")
local WorldXEnv = Class.LightClass("WorldXEnv")
local RunAfterProgramStart = require("Common.RunAfterProgramStart")

require("Core.Framework.BddIgnore")

local function load_luaData(module_name)
	local file_name = string.gsub(module_name, "%.", "/") .. ".lua"
	local module, err = loadfile(LUA_ROOT_PATH .. "/" .. file_name)

	if module == nil then
		module, err = loadfile(LUA_ROOT_PATH .. "/Common/" .. file_name)
	end

	if module == nil then
		return "\n\treadOnly_Data no file"
	end

	if IS_MOBILE then
		return module
	else
		local function loadFunc()
			local AccessControl = require("Core.Framework.AccessControl")

			return AccessControl.readOnly(module())
		end

		return loadFunc
	end
end

local BddDataMgr = require("Core.Framework.BddDataMgr")

local function load_bddData(module_name)
	local isData = string.startsWith(module_name, "Data")
	local isCommonData = string.startsWith(module_name, "Common.Data")

	if not isData and not isCommonData then
		return "\n\tbdd_Data no file"
	end

	local Switch = require("Core.Common.Switch")
	local dataPath = string.gsub(module_name, "Common.", "", 1)

	if Switch.ReadLuaData or pg.isBddIgnoreData(dataPath) then
		return load_luaData(module_name)
	else
		local tbl

		if isData then
			tbl = BddDataMgr.GetInstance():getTable(string.gsub(module_name, "Data.", "", 1))
		elseif isCommonData then
			tbl = BddDataMgr.GetInstance():getTable(string.gsub(module_name, "Common.Data.", "", 1))
		end

		if not tbl then
			local ret = load_luaData(module_name)

			if type(ret) == "string" then
				return "\n\tbdd_Data no file"
			end

			return ret
		end

		local function loadFunc()
			return tbl
		end

		return loadFunc
	end
end

function WorldXEnv.init()
	table.insert(package.loaders, 2, load_bddData)

	local Functions = require("Common.Functions")

	Functions.init()

	local globalDeclare = require("Core.Framework.Global")
	local LoggerManager = require("Core.Log.LoggerManager")
	local combatlog = LoggerManager.getLogger("Combat")

	combatlog.stackLen = combatlog.stackLen + 1

	globalDeclare("jit")
	globalDeclare("Switch")

	Switch = require("Core.Common.Switch")

	globalDeclare("appFacade")

	appFacade = CS.FunPlus.WorldX.AppFacade

	appFacade.luaManager:UpdateFunctionRef()
	require("Common.Math.math_ex")

	bit = require("bit")

	globalDeclare("inspect")

	inspect = require("Core.Common.inspect")

	globalDeclare("Vector2")

	Vector2 = require("Common.Math.vector2")

	globalDeclare("Vector3")

	Vector3 = require("Common.Math.vector3")

	globalDeclare("Vector4")

	Vector4 = require("Common.Math.vector4")

	globalDeclare("Quaternion")

	Quaternion = require("Common.Math.quaternion")

	globalDeclare("facade")

	facade = require("GameApp.Core.LuaFacade").new()

	globalDeclare("Matrix4x4")

	Matrix4x4 = CS.UnityEngine.Matrix4x4

	require("Pg")
	globalDeclare("UIUtils")

	UIUtils = CS.FunPlus.WorldX.Utils.UIUtils

	globalDeclare("vcCommand")

	vcCommand = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraCommand

	globalDeclare("UnityTime")

	UnityTime = CS.UnityEngine.Time

	globalDeclare("ClientEffectUtils")

	ClientEffectUtils = require("Utils.ClientEffectUtils")

	globalDeclare("SampleUtils")

	SampleUtils = require("Utils.SampleUtils")

	globalDeclare("ShareDataFactory")

	ShareDataFactory = CS.LuaCSMemory.ShareDataFactory

	globalDeclare("Screen")

	Screen = CS.UnityEngine.Screen

	globalDeclare("Camera")

	Camera = CS.UnityEngine.Camera

	globalDeclare("Physics")

	Physics = CS.UnityEngine.Physics

	globalDeclare("GameObject")

	GameObject = CS.UnityEngine.GameObject

	globalDeclare("Color")

	Color = CS.UnityEngine.Color

	globalDeclare("Application")

	Application = CS.UnityEngine.Application

	globalDeclare("pgI18N")

	pgI18N = CS.FunPlus.WorldX.I18N

	globalDeclare("GameObjectUtils")

	GameObjectUtils = CS.FunPlus.WorldX.Utils.GameObjectUtils

	globalDeclare("DoTweenAnimMgr")

	DoTweenAnimMgr = CS.XGUI.AnimMgr

	globalDeclare("MinMaxGradient")

	MinMaxGradient = CS.UnityEngine.ParticleSystem.MinMaxGradient

	globalDeclare("HandbookModelView")

	HandbookModelView = CS.FunPlus.WorldX.GUIS.HandbookModelView

	globalDeclare("CSEntityManager")

	CSEntityManager = CS.FunPlus.WorldX.AppFacade.entityManager

	globalDeclare("pgUtils")

	pgUtils = CS.FunPlus.WorldX.Utils.Utils

	globalDeclare("clientUtils")

	clientUtils = require("Utils.ClientUtils")

	globalDeclare("clientEcsUtils")

	clientEcsUtils = require("Utils.ClientEcsUtils")

	globalDeclare("clientLevelUtils")

	clientLevelUtils = require("Utils.ClientLevelUtils")

	globalDeclare("clientSandboxUtils")

	clientSandboxUtils = require("Utils.ClientSandboxUtils")

	globalDeclare("fingerGestures")

	fingerGestures = CS.FunPlus.WorldX.FingerGestures

	globalDeclare("UnityInput")

	UnityInput = CS.UnityEngine.Input

	globalDeclare("Swallower")

	Swallower = require("Common.Swallower")

	local EffectConst = require("Const.EffectConst")

	EffectConst.initEffectName2Index()

	local HotKeyConst = require("Const.HotkeyConst")

	HotKeyConst.init()

	local ResCacheConst = require("Const.ResCacheConst")

	ResCacheConst.applyAll()

	local ConsoleUtils = require("Utils.ConsoleUtils")

	ConsoleUtils.init()

	local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")

	ClientMotionComponent.initStatic()
	pg.global.sdkManager:init()

	local CppConfig = require("Config.CppConfig")

	for key, value in pairs(CppConfig) do
		pg.world.setConfig(key, tostring(value))
	end

	pg.lastReloadTime = os.time()
end

function WorldXEnv.posInit()
	RunAfterProgramStart.run()
end

function WorldXEnv.postReload()
	require("Common.Utils.AIUtils").clearCache()

	if ClientConfigCloudEnable == "true" then
		local sdkManager = pg.global.sdkManager

		if sdkManager and sdkManager.invalidateCloudSDKSessionCache then
			sdkManager:invalidateCloudSDKSessionCache()
		end
	end

	local ResCacheConst = require("Const.ResCacheConst")

	ResCacheConst.applyAll()

	local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")

	QuestCommonUtils.clearQuestTriggerConfigCache()
	pg.global.abilityMgr:clear()

	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		ent:postComponentMethod("EVENT_PostReload")
	end

	pg.game:EVENT_PostReload()
	RunAfterProgramStart.run(true)
	appFacade.PostReload()
end

return WorldXEnv
