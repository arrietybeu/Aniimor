-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossTitleProfiler.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("BossTitleProfiler")
local globalDeclare = require("Core.Framework.Global")
local Time = require("Core.Common.Time")
local CSSampleUtils = CS.FunPlus.WorldX.Utils.SampleUtils
local LuaSampleUtils = require("Utils.SampleUtils")
local LOG_DIR = "E:\\log"
local BossTitleProfiler = {
	_recording = false,
	_startTime = 0,
	_startGcKb = 0,
	enabled = false
}
local C = {}

function BossTitleProfiler.reset()
	C.hpMsg = 0
	C.hpApplied = 0
	C.breakMsg = 0
	C.ecsMsg = 0
	C.buffRefresh = 0
	C.fxAccumulate = 0
	C.fxRetract = 0
	C.fxTweenUpdate = 0
	C.breakTweenUpdate = 0
	C.fxRefreshLines = 0
	C.perFrameHist = {}
	C._lastFrame = -1
	C._frameHpCount = 0
	BossTitleProfiler._startGcKb = collectgarbage("count")
	BossTitleProfiler._startTime = os.clock()
end

BossTitleProfiler.reset()

function BossTitleProfiler.setEnabled(on)
	on = on and true or false
	BossTitleProfiler.enabled = on

	if on then
		BossTitleProfiler.reset()
		BossTitleProfiler._startRecording()
		logger:warn("[BossTitleProf] 已开启(V2=%s), 开始采集 + Profiler 录制。打 boss, 结束调用 off()/dump()", tostring(require("Const.UIConst").USE_BOSS_TITLE_V2))
	else
		BossTitleProfiler._stopRecording()
	end
end

function BossTitleProfiler._startRecording()
	if BossTitleProfiler._recording then
		return
	end

	local ok, err = pcall(function()
		LuaSampleUtils.enableSample(false)
		CSSampleUtils.StartProfileRecord(0)

		BossTitleProfiler._recording = true

		logger:warn("[BossTitleProf] Profiler 录制已开始, .raw 输出到 Assets/ProfileDatas")
	end)

	if not ok then
		BossTitleProfiler._recording = false

		logger:error("[BossTitleProf] 启动 Profiler 录制失败(可能非 Development Build): " .. tostring(err))
	end
end

function BossTitleProfiler._stopRecording()
	if not BossTitleProfiler._recording then
		return
	end

	pcall(function()
		CSSampleUtils.StopProfileRecord(0)
	end)

	BossTitleProfiler._recording = false

	logger:warn("[BossTitleProf] Profiler 录制已停止。.raw 在 Assets/ProfileDatas, 回 Editor 用 Profiler 窗口 Load")
end

function BossTitleProfiler.count(key, n)
	if not BossTitleProfiler.enabled then
		return
	end

	C[key] = (C[key] or 0) + (n or 1)
end

function BossTitleProfiler.markHpFrame(frame)
	if not BossTitleProfiler.enabled then
		return
	end

	frame = frame or Time.frameCount
	C.hpMsg = C.hpMsg + 1

	if frame ~= C._lastFrame then
		if C._lastFrame >= 0 then
			local k = C._frameHpCount

			C.perFrameHist[k] = (C.perFrameHist[k] or 0) + 1
		end

		C._lastFrame = frame
		C._frameHpCount = 0
	end

	C._frameHpCount = C._frameHpCount + 1
end

function BossTitleProfiler.beginSample(name)
	if not BossTitleProfiler.enabled then
		return
	end

	LuaSampleUtils.beginSample(name)
end

function BossTitleProfiler.endSample()
	if not BossTitleProfiler.enabled then
		return
	end

	LuaSampleUtils.endSample()
end

local function ensureLogDir()
	if lfs and lfs.attributes(LOG_DIR, "mode") == nil then
		lfs.mkdir(LOG_DIR)
	end

	return true
end

function BossTitleProfiler.dump()
	if C._lastFrame >= 0 then
		local k = C._frameHpCount

		C.perFrameHist[k] = (C.perFrameHist[k] or 0) + 1
	end

	local UIConst = require("Const.UIConst")
	local gcNow = collectgarbage("count")
	local gcDelta = gcNow - BossTitleProfiler._startGcKb
	local elapsed = os.clock() - BossTitleProfiler._startTime
	local allocPerSec = elapsed > 0 and gcDelta / elapsed or 0
	local allocPerHp = C.hpMsg > 0 and gcDelta / C.hpMsg or 0
	local lines = {}

	lines[#lines + 1] = "==================== BossTitle Profiler Dump ===================="
	lines[#lines + 1] = string.format("版本: %s   采集时长: %.2fs", UIConst.USE_BOSS_TITLE_V2 and "V2(拆分)" or "原始", elapsed)
	lines[#lines + 1] = "---- GC / 内存 ----"
	lines[#lines + 1] = string.format("Lua 分配增量: %.1f KB  (净增, 期间可能已 GC)", gcDelta)
	lines[#lines + 1] = string.format("分配速率: %.2f KB/s", allocPerSec)
	lines[#lines + 1] = string.format("每次血量刷新平均分配: %.3f KB/次", allocPerHp)
	lines[#lines + 1] = "---- 受击刷新链 调用计数 ----"
	lines[#lines + 1] = string.format("血量消息(refreshHealthPoint): %d  | 实际刷条: %d", C.hpMsg, C.hpApplied)
	lines[#lines + 1] = string.format("击破刷新(refreshBreakBar): %d", C.breakMsg)
	lines[#lines + 1] = string.format("元素量(refreshEcsAmount): %d  | Buff刷新(refreshBuffs): %d", C.ecsMsg, C.buffRefresh)
	lines[#lines + 1] = "---- 累计扣血 FX(核心热点 #1) ----"
	lines[#lines + 1] = string.format("accumulate: %d  | retract(收缩起): %d  | refreshLines: %d", C.fxAccumulate, C.fxRetract, C.fxRefreshLines)
	lines[#lines + 1] = string.format("血条FX Tween 每帧回调: %d  (÷时长≈平均并发Tween数)", C.fxTweenUpdate)
	lines[#lines + 1] = "---- 击破条 FX(核心热点 #3) ----"
	lines[#lines + 1] = string.format("击破FX Tween 每帧回调: %d", C.breakTweenUpdate)
	lines[#lines + 1] = "---- 每帧血量刷新拥挤度(帧内刷新数 -> 帧数) ----"

	local keys = {}

	for k in pairs(C.perFrameHist) do
		keys[#keys + 1] = k
	end

	table.sort(keys)

	for _, k in ipairs(keys) do
		lines[#lines + 1] = string.format("  同帧 %2d 次刷新: 出现 %d 帧", k, C.perFrameHist[k])
	end

	lines[#lines + 1] = "================================================================="

	local out = table.concat(lines, "\n")

	logger:warn(out)
	BossTitleProfiler._writeToFile(out)

	return out
end

function BossTitleProfiler._writeToFile(content)
	ensureLogDir()

	local UIConst = require("Const.UIConst")
	local tag = UIConst.USE_BOSS_TITLE_V2 and "V2" or "orig"
	local fileName = os.date("BossTitleProf_" .. tag .. "_%Y%m%d_%H%M%S.txt")
	local path = LOG_DIR .. "\\" .. fileName
	local ok, err = pcall(function()
		local file = io.open(path, "w")

		if not file then
			logger:error("[BossTitleProf] 无法写入文件: " .. path)

			return
		end

		file:write(content)
		file:close()
		logger:warn("[BossTitleProf] 汇总已写入: " .. path)
	end)

	if not ok then
		logger:error("[BossTitleProf] 写文件异常: " .. tostring(err))
	end
end

globalDeclare("BossTitleProf", {
	on = function()
		BossTitleProfiler.setEnabled(true)
	end,
	off = function()
		BossTitleProfiler.setEnabled(false)
	end,
	dump = function()
		return BossTitleProfiler.dump()
	end,
	reset = function()
		BossTitleProfiler.reset()
	end
})

return BossTitleProfiler
