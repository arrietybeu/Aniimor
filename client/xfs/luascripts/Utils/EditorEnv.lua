-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\EditorEnv.lua

local EditorEnv = {}

function EditorEnv.init()
	local globalDeclare = require("Core.Framework.Global")

	globalDeclare("_G_IsDebugMode")
	globalDeclare("Switch")

	Switch = require("Core.Common.Switch")

	globalDeclare("appFacade")

	appFacade = CS.FunPlus.WorldX.AppFacade

	globalDeclare("UIUtils")

	UIUtils = CS.FunPlus.WorldX.Utils.UIUtils

	globalDeclare("vcCommand")

	vcCommand = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraCommand

	globalDeclare("UnityTime")

	UnityTime = CS.UnityEngine.Time

	globalDeclare("IsNil")

	function IsNil(uobj)
		return uobj == nil or type(uobj) == "userdata" and xlua.isNullObject(uobj)
	end

	globalDeclare("NotNil")

	function NotNil(uobj)
		return not IsNil(uobj)
	end

	require("Common.Math.math_ex")

	bit = require("bit")

	globalDeclare("Vector2")

	Vector2 = require("Common.Math.vector2")

	globalDeclare("Vector3")

	Vector3 = require("Common.Math.vector3")

	globalDeclare("Vector4")

	Vector4 = require("Common.Math.vector4")

	globalDeclare("Quaternion")

	Quaternion = require("Common.Math.quaternion")

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

	globalDeclare("pgUtils")

	pgUtils = CS.FunPlus.WorldX.Utils.Utils

	globalDeclare("ClientDebugUtils")

	ClientDebugUtils = require("Utils.ClientDebugUtils")
end

return EditorEnv
