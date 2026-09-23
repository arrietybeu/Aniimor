-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\JoyStickDragRelay.lua

local DragEventListener = CS.XGUI.EventSystems.DragEventListener
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("JoyStickDragRelay")
local JoyStickDragRelay = {}
local m_baseJoystick
local m_overrides = {}
local m_dragOwner, m_dragJoystick
local m_handles = setmetatable({}, {
	__mode = "k"
})

function JoyStickDragRelay._getTargetJoyStick()
	for i = #m_overrides, 1, -1 do
		local joystick = m_overrides[i].joystick

		if NotNil(joystick) then
			return joystick
		end
	end

	if NotNil(m_baseJoystick) then
		return m_baseJoystick
	end

	return nil
end

function JoyStickDragRelay._cancelDrag()
	if m_dragOwner == nil then
		return
	end

	m_dragOwner = nil

	local joystick = m_dragJoystick

	m_dragJoystick = nil

	if NotNil(joystick) then
		joystick:DoEndDrag(nil)
	end
end

function JoyStickDragRelay._cancelDragOnTargetChanged()
	if m_dragOwner ~= nil and m_dragJoystick ~= JoyStickDragRelay._getTargetJoyStick() then
		JoyStickDragRelay._cancelDrag()
	end
end

function JoyStickDragRelay._removeOverride(owner)
	for i = #m_overrides, 1, -1 do
		if m_overrides[i].owner == owner then
			table.remove(m_overrides, i)
		end
	end
end

function JoyStickDragRelay.setJoyStick(joystick)
	m_baseJoystick = joystick

	JoyStickDragRelay._cancelDragOnTargetChanged()
end

function JoyStickDragRelay.clearJoyStick(joystick)
	if m_baseJoystick == joystick then
		m_baseJoystick = nil

		JoyStickDragRelay._cancelDragOnTargetChanged()
	end
end

function JoyStickDragRelay.pushJoyStick(owner, joystick)
	if owner == nil or IsNil(joystick) then
		return
	end

	JoyStickDragRelay._removeOverride(owner)
	table.insert(m_overrides, {
		owner = owner,
		joystick = joystick
	})
	JoyStickDragRelay._cancelDragOnTargetChanged()
end

function JoyStickDragRelay.popJoyStick(owner)
	if owner == nil then
		return
	end

	JoyStickDragRelay._removeOverride(owner)
	JoyStickDragRelay._cancelDragOnTargetChanged()
end

function JoyStickDragRelay.attach(gameObject)
	if IsNil(gameObject) then
		return nil
	end

	local listener = DragEventListener.Get(gameObject)
	local exist = m_handles[listener]

	if exist ~= nil then
		return exist
	end

	if (listener.onBeginDrag ~= nil or listener.onDrag ~= nil or listener.onEndDrag ~= nil) and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("UI [attach] node already has drag callbacks, they will be swallowed", gameObject.name)
	end

	local handle = {
		listener = listener,
		prevBeginDrag = listener.onBeginDrag,
		prevDrag = listener.onDrag,
		prevEndDrag = listener.onEndDrag
	}

	function listener.onBeginDrag(eventData)
		if m_dragOwner ~= nil and m_dragOwner ~= handle then
			return
		end

		local joystick = JoyStickDragRelay._getTargetJoyStick()

		if IsNil(joystick) then
			return
		end

		m_dragOwner = handle
		m_dragJoystick = joystick

		joystick:DoBeginDrag(eventData)
	end

	function listener.onDrag(eventData)
		if m_dragOwner ~= handle then
			return
		end

		if IsNil(m_dragJoystick) then
			return
		end

		m_dragJoystick:DoDrag(eventData)
	end

	function listener.onEndDrag(eventData)
		if m_dragOwner ~= handle then
			return
		end

		m_dragOwner = nil

		local joystick = m_dragJoystick

		m_dragJoystick = nil

		if IsNil(joystick) then
			return
		end

		joystick:DoEndDrag(eventData)
	end

	handle.ownBeginDrag = listener.onBeginDrag
	handle.ownDrag = listener.onDrag
	handle.ownEndDrag = listener.onEndDrag
	m_handles[listener] = handle

	return handle
end

function JoyStickDragRelay.detach(handle)
	if handle == nil then
		return
	end

	if m_dragOwner == handle then
		JoyStickDragRelay._cancelDrag()
	end

	local listener = handle.listener

	if IsNil(listener) then
		return
	end

	m_handles[listener] = nil

	if listener.onBeginDrag == handle.ownBeginDrag then
		listener.onBeginDrag = handle.prevBeginDrag
	end

	if listener.onDrag == handle.ownDrag then
		listener.onDrag = handle.prevDrag
	end

	if listener.onEndDrag == handle.ownEndDrag then
		listener.onEndDrag = handle.prevEndDrag
	end
end

return JoyStickDragRelay
