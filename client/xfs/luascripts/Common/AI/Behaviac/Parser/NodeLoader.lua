-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\NodeLoader.lua

local _M = {}
local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils

function _M.loadProperties(selfNode, version, agentType, dataEntry)
	local thisEntry = dataEntry[constBaseKeyStrDef.kStrProperties]

	if not thisEntry then
		return
	end

	local properties = {}

	for _, oneProperty in ipairs(thisEntry) do
		for k, v in pairs(oneProperty) do
			table.insert(properties, {
				k,
				v
			})
		end
	end

	if #properties > 0 then
		selfNode:onLoading(version, agentType, properties)
	end
end

function _M.loadChildren(selfNode, version, agentType, dataEntry)
	local hasEvents = false
	local nodeEntry, newNode

	nodeEntry = dataEntry[constBaseKeyStrDef.kStrNode]

	if nodeEntry ~= nil then
		newNode = _M.loadNode(agentType, nodeEntry, version)
		hasEvents = hasEvents or newNode.m_bHasEvents

		selfNode:addChild(newNode)
	elseif dataEntry.children ~= nil then
		for _, oneChild in ipairs(dataEntry.children) do
			nodeEntry = oneChild[constBaseKeyStrDef.kStrNode]

			if nodeEntry ~= nil then
				newNode = _M.loadNode(agentType, nodeEntry, version)
				hasEvents = hasEvents or newNode.m_bHasEvents

				selfNode:addChild(newNode)
			else
				_M.loadCustom(selfNode, version, agentType, oneChild)
			end
		end
	end

	selfNode.m_bHasEvents = selfNode.m_bHasEvents or hasEvents
end

function _M.loadPars(selfNode, version, agentType, dataEntry)
	local thisEntry = dataEntry[constBaseKeyStrDef.kStrPars]

	if not thisEntry then
		return
	end

	for _, oneParNode in ipairs(thisEntry) do
		_M.loadLocal(selfNode, version, agentType, oneParNode)
	end
end

function _M.loadCustom(selfNode, version, agentType, dataEntry)
	local thisEntry = dataEntry[constBaseKeyStrDef.kStrCustom]

	if not thisEntry then
		return
	end

	local nodeEntry = thisEntry[constBaseKeyStrDef.kStrNode]

	selfNode.m_customCondition = _M.loadNode(agentType, nodeEntry, version)
end

function _M.loadAttachmentTransitionEffectors(selfNode, version, agentType, dataEntry)
	selfNode.m_loadAttachment = true

	_M.loadPropertiesParsAttachmentsChildren(selfNode, version, agentType, dataEntry, false)

	selfNode.m_loadAttachment = false
end

function _M.loadAttachment(selfNode, version, agentType, hasEvents, dataEntry)
	local attachClassName = dataEntry[constBaseKeyStrDef.kStrClass]

	if not attachClassName then
		_M.loadAttachmentTransitionEffectors(selfNode, version, agentType, dataEntry)

		return true
	end

	local NodeFactory = require("Common.AI.Behaviac.Parser.NodeFactory")
	local attachmentNode = NodeFactory[attachClassName].new()

	if attachmentNode then
		attachmentNode:setClassNameString(attachClassName)

		local id = dataEntry[constBaseKeyStrDef.kStrId]

		attachmentNode:setId(tonumber(id))

		local bIsPrecondition = dataEntry[constBaseKeyStrDef.kStrPrecondition] or false
		local bIsEffector = dataEntry[constBaseKeyStrDef.kStrEffector] or false
		local bIsTransition = dataEntry[constBaseKeyStrDef.kStrTransition] or false

		_M.loadPropertiesParsAttachmentsChildren(attachmentNode, version, agentType, dataEntry, bIsTransition)
		selfNode:attach(attachmentNode, bIsPrecondition, bIsEffector, bIsTransition)

		hasEvents = hasEvents or attachmentNode:isEvent()
	else
		macros.BEHAVIAC_ASSERT(attachmentNode, "attachment node is nil")
	end

	return hasEvents
end

function _M.loadAttachments(selfNode, version, agentType, dataEntry, isTransition)
	local hasEvents = false
	local thisEntry = dataEntry[constBaseKeyStrDef.kStrAttachments]

	if not thisEntry then
		return
	end

	for _, oneAtachement in ipairs(thisEntry) do
		hasEvents = _M.loadAttachment(selfNode, version, agentType, hasEvents, oneAtachement) or hasEvents
	end

	selfNode.m_bHasEvents = selfNode.m_bHasEvents or hasEvents
end

function _M.loadPropertiesParsAttachmentsChildren(selfNode, version, agentType, dataEntry, isTransition)
	selfNode:setAgentType(agentType)
	_M.loadPars(selfNode, version, agentType, dataEntry)
	_M.loadProperties(selfNode, version, agentType, dataEntry)
	_M.loadAttachments(selfNode, version, agentType, dataEntry, isTransition)
	_M.loadCustom(selfNode, version, agentType, dataEntry)
	_M.loadChildren(selfNode, version, agentType, dataEntry)
end

function _M.loadNode(agentType, dataEntry, version)
	local nodeClassName = dataEntry[constBaseKeyStrDef.kStrClass]

	if nodeClassName then
		local NodeFactory = require("Common.AI.Behaviac.Parser.NodeFactory")
		local newNode = NodeFactory[nodeClassName].new()

		if newNode then
			newNode:setClassNameString(nodeClassName)

			local idStr = dataEntry[constBaseKeyStrDef.kStrId]

			macros.BEHAVIAC_ASSERT(idStr, "node = %s no id", agentType)
			newNode:setId(tonumber(idStr))
			_M.loadPropertiesParsAttachmentsChildren(newNode, version, agentType, dataEntry, false)
		end

		return newNode
	end

	return nil
end

function _M.loadLocal(selfNode, version, agentType, parNode)
	table.insert(selfNode.m_localProps, {
		parNode.name,
		parNode.const
	})
end

function _M.addLocal(selfNode, agentType, typeName, name, valueStr)
	table.insert(selfNode.m_localProps, {
		name,
		ConstValueReader.readAnyType(typeName, valueStr)
	})
end

function _M.addPar(selfNode, agentType, typeName, name, valueStr)
	_M.addLocal(selfNode, agentType, typeName, name, valueStr)
end

return _M
