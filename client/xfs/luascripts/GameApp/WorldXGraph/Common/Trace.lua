-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\Trace.lua

local Trace = {}
local enabled = false
local delegate

function Trace.setDelegate(value)
	delegate = value
end

function Trace.setEnabled(value)
	enabled = value == true
end

function Trace.isEnabled()
	return enabled
end

function Trace.beginRun(mode, dialogueId)
	if Trace.isEnabled() and delegate ~= nil and delegate.beginRun then
		delegate.beginRun(mode, dialogueId)
	end
end

function Trace.record(eventType, payload)
	if Trace.isEnabled() and delegate ~= nil and delegate.record then
		delegate.record(eventType, payload)
	end
end

function Trace.summarizeParam(value)
	if Trace.isEnabled() and delegate ~= nil and delegate.summarizeParam then
		return delegate.summarizeParam(value)
	end

	return tostring(value)
end

function Trace.endRun(code)
	if Trace.isEnabled() and delegate ~= nil and delegate.endRun then
		delegate.endRun(code)
	end
end

return Trace
