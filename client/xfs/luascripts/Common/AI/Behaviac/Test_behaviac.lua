-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Test_behaviac.lua

local pg = require("Lib.Pg")
local luaCodeRootDir

if pg.component == "client" then
	luaCodeRootDir = CS.LuaInterface.LuaConst.luaCodeRootDir
else
	luaCodeRootDir = pg.script_dir
end

local behaviac = require("Common.AI.Behaviac.Init")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = behaviac.enums.EBTStatus
local AgentMeta = behaviac.AgentMeta
local BehaviorTreeFactory = behaviac.BehaviorTreeFactory
local MyRobotClass = functions.class("Robot", behaviac.BaseAgent)

function MyRobotClass:ctor(unit)
	MyRobotClass.super.ctor(self)

	self.unit = unit
	self.count = 0
end

function MyRobotClass:doLogin()
	print("Do Login ...")
	msg_dispatcher.registerMessageCb()
	pressTestManager.startTest(1)

	return EBTStatus.BT_RUNNING
end

function MyRobotClass:LogMessage(msg)
	print("Say: ")
	print(msg)
end

function MyRobotClass:doTask(taskId)
	self.count = self.count + 1

	if self.count >= 2 then
		print("doTask...success")

		self.count = 0

		return EBTStatus.BT_SUCCESS
	else
		print("doTask...running")

		return EBTStatus.BT_RUNNING
	end
end

function MyRobotClass:doLogPlayerInfo(param1, param2)
	print("doLogPlayerInfo...")

	return EBTStatus.BT_SUCCESS
end

function MyRobotClass:GetP1s1()
	return tonumber(self.p1.s1)
end

function MyRobotClass:Start(a, b, c)
	self.count = 0
end

function MyRobotClass:Wait()
	self.count = self.count + 1

	print("p1 =", p1)

	if self.count == 10000 then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_RUNNING
end

assert(_M == nil)

local myRobot = MyRobotClass.new()

AgentMeta.setBehaviorTreeFolder(luaCodeRootDir .. "/Common/Data/BehaviacData")

local path_demo = AgentMeta.getBehaviorTreePath("testAIFile")

AgentMeta.registerEnumType("FirstEnum", {
	e1 = 0,
	e2 = 1
})
myRobot:btSetCurrent(path_demo)
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
myRobot:btExec()
