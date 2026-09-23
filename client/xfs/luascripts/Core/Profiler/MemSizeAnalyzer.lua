-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\MemSizeAnalyzer.lua

local SIZE = {
	UPVAL_CLOSED = 32,
	PROTO_BASE = 128,
	THREAD_DEFAULT_STACK = 40,
	THREAD_SLOT = 16,
	THREAD_HEADER = 168,
	UDATA_UNKNOWN = 128,
	UDATA_HEADER = 32,
	STR_HEADER = 24,
	CFUNC_UPVAL = 16,
	CFUNC_HEADER = 24,
	LFUNC_UPVAL = 8,
	LFUNC_HEADER = 32,
	TAB_HASH_MIN = 1,
	TAB_HASH_NODE = 32,
	TAB_ARRAY_SLOT = 16,
	TAB_HEADER = 56,
	TVALUE = 16,
	GCHEADER = 8
}
local SKIP_NAMES = {
	BddDataMgr = true
}

local function isSkippedName(name)
	if SKIP_NAMES[name] then
		return true
	end

	local lastSeg = string.match(name, "%.([^%.]+)$") or name

	if SKIP_NAMES[lastSeg] then
		return true
	end

	for k in pairs(SKIP_NAMES) do
		if string.find(name, "%." .. k .. "$") or string.find(name, "%." .. k .. "%.") or string.sub(name, 1, #k) == k then
			return true
		end
	end

	return false
end

local function shallowSize(obj)
	local t = type(obj)

	if t == "nil" or t == "boolean" or t == "number" then
		return 0
	elseif t == "string" then
		return SIZE.STR_HEADER + #obj + 1
	elseif t == "table" then
		local narray = 0
		local nhash = 0
		local maxArrIdx = 0

		for k, _ in pairs(obj) do
			local kt = type(k)

			if kt == "number" and k == math.floor(k) and k >= 1 then
				if maxArrIdx < k then
					maxArrIdx = math.floor(k)
				end
			else
				nhash = nhash + 1
			end
		end

		narray = maxArrIdx

		local hashcap = 1

		while hashcap < nhash do
			hashcap = hashcap * 2
		end

		if nhash == 0 then
			hashcap = 0
		end

		return SIZE.TAB_HEADER + narray * SIZE.TAB_ARRAY_SLOT + hashcap * SIZE.TAB_HASH_NODE
	elseif t == "function" then
		local info = debug.getinfo(obj, "Su")

		if info and info.what == "Lua" then
			return SIZE.LFUNC_HEADER + (info.nups or 0) * SIZE.LFUNC_UPVAL
		else
			local nups = info and info.nups or 0

			return SIZE.CFUNC_HEADER + nups * SIZE.CFUNC_UPVAL
		end
	elseif t == "thread" then
		return SIZE.THREAD_HEADER + SIZE.THREAD_DEFAULT_STACK * SIZE.THREAD_SLOT
	elseif t == "userdata" then
		local mt = getmetatable(obj)

		if mt then
			local szFn = rawget(mt, "__size")

			if szFn and type(szFn) == "function" then
				local ok, sz = pcall(szFn, obj)

				if ok and type(sz) == "number" then
					return SIZE.UDATA_HEADER + sz
				end
			end

			local indexFn = rawget(mt, "__index")

			if indexFn and type(indexFn) == "table" then
				-- block empty
			end
		end

		return SIZE.UDATA_HEADER + SIZE.UDATA_UNKNOWN
	end

	return 0
end

local MemSizeAnalyzer = {}

MemSizeAnalyzer.__index = MemSizeAnalyzer

local WEAK_K = {
	__mode = "k"
}
local NODE_MARKER = {}

function MemSizeAnalyzer.new()
	local self = setmetatable({}, MemSizeAnalyzer)

	self._objToNode = setmetatable({}, WEAK_K)
	self._nodes = {}
	self._nextId = 1
	self._root = nil

	rawset(self._nodes, NODE_MARKER, true)

	return self
end

function MemSizeAnalyzer:_getNode(obj, name)
	local existing = self._objToNode[obj]

	if existing then
		return existing, true
	end

	local t = type(obj)
	local classname

	if t == "table" then
		local cn = rawget(obj, "__cname") or rawget(obj, "class") or rawget(obj, "_className") or rawget(obj, "typeName") or rawget(obj, "className")

		if cn and type(cn) == "string" then
			classname = cn
		end
	end

	local node = {
		domsize = 0,
		id = self._nextId,
		obj = obj,
		name = name or tostring(obj),
		typename = t,
		classname = classname,
		shallow = shallowSize(obj),
		children = {},
		parents = {},
		dominated = {},
		[NODE_MARKER] = true
	}

	self._nextId = self._nextId + 1
	self._objToNode[obj] = node
	self._nodes[#self._nodes + 1] = node

	return node, false
end

function MemSizeAnalyzer._addEdge(parentNode, childNode)
	for _, c in ipairs(parentNode.children) do
		if c == childNode then
			return
		end
	end

	parentNode.children[#parentNode.children + 1] = childNode
	childNode.parents[#childNode.parents + 1] = parentNode
end

function MemSizeAnalyzer:_traverse(rootName, rootObj, rootParent)
	local function expand(name, obj, node)
		local work = {}
		local t = type(obj)

		if t == "table" then
			local bWeakK, bWeakV = false, false
			local mt = getmetatable(obj)

			if mt and type(mt) == "table" then
				local mode = rawget(mt, "__mode")

				if mode and type(mode) == "string" then
					bWeakK = string.find(mode, "k") ~= nil
					bWeakV = string.find(mode, "v") ~= nil
				end
			end

			for k, v in pairs(obj) do
				local kt = type(k)

				if v == obj and kt == "string" and k == "self" then
					-- block empty
				elseif kt == "string" or kt == "number" or kt == "boolean" then
					if not bWeakV then
						work[#work + 1] = {
							name .. "." .. tostring(k),
							v,
							node
						}
					end
				else
					if not bWeakK then
						work[#work + 1] = {
							name .. ".[key]",
							k,
							node
						}
					end

					if not bWeakV then
						work[#work + 1] = {
							name .. ".[val]",
							v,
							node
						}
					end
				end
			end

			if mt then
				work[#work + 1] = {
					name .. ".[mt]",
					mt,
					node
				}
			end
		elseif t == "function" then
			local info = debug.getinfo(obj, "Su")

			if info then
				local nups = info.nups or 0

				for i = 1, nups do
					local upname, upval = debug.getupvalue(obj, i)

					if upval ~= nil then
						local upt = type(upval)

						if upt == "table" or upt == "function" or upt == "thread" or upt == "userdata" or upt == "string" then
							work[#work + 1] = {
								name .. ".[up:" .. (upname or tostring(i)) .. "]",
								upval,
								node
							}
						end
					end
				end
			end
		elseif t == "userdata" then
			local mt = getmetatable(obj)

			if mt and type(mt) == "table" then
				local pairsFn = rawget(mt, "__pairs")

				if pairsFn and type(pairsFn) == "function" then
					local ok, iter, state, init = pcall(pairsFn, obj)

					if ok and iter then
						local ok2, k, v = pcall(iter, state, init)

						while ok2 and k ~= nil do
							local kt = type(k)

							if kt == "string" or kt == "number" then
								work[#work + 1] = {
									name .. "." .. tostring(k),
									v,
									node
								}
							end

							ok2, k, v = pcall(iter, state, k)
						end
					end
				end

				work[#work + 1] = {
					name .. ".[ud:mt]",
					mt,
					node
				}
			end
		end

		return work
	end

	local stack = {
		{
			rootName,
			rootObj,
			rootParent
		}
	}
	local top = 1

	while top > 0 do
		local entry = stack[top]

		stack[top] = nil
		top = top - 1

		if not entry then
			break
		end

		local ename = entry[1]
		local eobj = entry[2]
		local eparentNode = entry[3]
		local et = type(eobj)
		local skip = eobj == nil or et == "boolean" or et == "number" or et == "table" and rawget(eobj, NODE_MARKER) or isSkippedName(ename)

		if not skip then
			local enode, existed = self:_getNode(eobj, ename)

			if eparentNode then
				MemSizeAnalyzer._addEdge(eparentNode, enode)
			end

			if not existed then
				local children = expand(ename, eobj, enode)

				for i = #children, 1, -1 do
					top = top + 1
					stack[top] = children[i]
				end
			end
		end
	end
end

local function bfsOrder(rootNode)
	local order = {}
	local visited = {}
	local queue = {
		rootNode
	}
	local head = 1

	while head <= #queue do
		local n = queue[head]

		head = head + 1

		if not visited[n] then
			visited[n] = true
			order[#order + 1] = n

			for _, c in ipairs(n.children) do
				if not visited[c] then
					queue[#queue + 1] = c
				end
			end
		end
	end

	return order
end

local function computeDominators(rootNode, _allNodes)
	local order = bfsOrder(rootNode)
	local idx = {}

	for i, n in ipairs(order) do
		idx[n] = i
	end

	local idom = {}

	idom[rootNode] = rootNode

	local function intersect(b1, b2)
		local f1, f2 = b1, b2

		while f1 ~= f2 do
			while (idx[f1] or math.huge) > (idx[f2] or math.huge) do
				f1 = idom[f1]

				if not f1 then
					return nil
				end
			end

			while (idx[f2] or math.huge) > (idx[f1] or math.huge) do
				f2 = idom[f2]

				if not f2 then
					return nil
				end
			end
		end

		return f1
	end

	local changed = true
	local iters = 0
	local MAX_ITERS = 50

	while changed and iters < MAX_ITERS do
		changed = false
		iters = iters + 1

		for i = 2, #order do
			local n = order[i]
			local newIdom

			for _, p in ipairs(n.parents) do
				if not idom[p] then
					-- block empty
				elseif newIdom == nil then
					newIdom = p
				else
					newIdom = intersect(p, newIdom)
				end
			end

			if newIdom and idom[n] ~= newIdom then
				idom[n] = newIdom
				changed = true
			end
		end
	end

	return idom
end

local function buildDominatorTree(_rootNode, idom)
	for n, _ in pairs(idom) do
		n.dominated = {}
		n.idom = nil
	end

	for n, d in pairs(idom) do
		n.idom = d

		if n ~= d then
			d.dominated[#d.dominated + 1] = n
		end
	end
end

local function computeDomSize(node, visited)
	if visited[node] then
		return node.domsize
	end

	visited[node] = true

	local total = node.shallow

	for _, child in ipairs(node.dominated) do
		total = total + computeDomSize(child, visited)
	end

	node.domsize = total

	return total
end

function MemSizeAnalyzer:analyze(rootName, rootObj)
	rootObj = rootObj or debug.getregistry()
	rootName = rootName or "registry"
	self._objToNode = setmetatable({}, WEAK_K)
	self._nodes = {}
	self._nextId = 1

	rawset(self._nodes, NODE_MARKER, true)

	local vroot = {
		shallow = 0,
		typename = "root",
		id = 0,
		domsize = 0,
		name = "__root__",
		children = {},
		parents = {},
		dominated = {},
		[NODE_MARKER] = true
	}

	self._root = vroot

	self:_traverse(rootName, rootObj, vroot)

	local idom = computeDominators(vroot, self._nodes)

	buildDominatorTree(vroot, idom)
	computeDomSize(vroot, {})

	return self
end

function MemSizeAnalyzer:topByDomSize(n, filterFn)
	local result = {}

	for _, node in ipairs(self._nodes) do
		if not filterFn or filterFn(node) then
			result[#result + 1] = node
		end
	end

	table.sort(result, function(a, b)
		return a.domsize > b.domsize
	end)

	if n > 0 and n < #result then
		local trimmed = {}

		for i = 1, n do
			trimmed[i] = result[i]
		end

		return trimmed
	end

	return result
end

function MemSizeAnalyzer:topByShallowSize(n, filterFn)
	local result = {}

	for _, node in ipairs(self._nodes) do
		if not filterFn or filterFn(node) then
			result[#result + 1] = node
		end
	end

	table.sort(result, function(a, b)
		return a.shallow > b.shallow
	end)

	if n > 0 and n < #result then
		local trimmed = {}

		for i = 1, n do
			trimmed[i] = result[i]
		end

		return trimmed
	end

	return result
end

function MemSizeAnalyzer:nodeOf(obj)
	return self._objToNode[obj]
end

function MemSizeAnalyzer:nodeCount()
	return #self._nodes
end

function MemSizeAnalyzer:totalShallowBytes()
	local total = 0

	for _, n in ipairs(self._nodes) do
		total = total + n.shallow
	end

	return total
end

local function formatBytes(b)
	if b >= 1048576 then
		return string.format("%.2f MB", b / 1048576)
	elseif b >= 1024 then
		return string.format("%.2f KB", b / 1024)
	else
		return string.format("%d B", b)
	end
end

local function nodeLabel(node)
	local label = node.name

	if node.classname then
		label = label .. " [class:" .. node.classname .. "]"
	end

	return label
end

function MemSizeAnalyzer:printDominatorTree(node, maxDepth, minDomSize, _depth, _lines)
	node = node or self._root
	maxDepth = maxDepth or 5
	minDomSize = minDomSize or 1024
	_depth = _depth or 0
	_lines = _lines or {}

	local indent = string.rep("  ", _depth)
	local label = nodeLabel(node)
	local line = string.format("%s[%s] shallow=%s  domsize=%s  (%s)", indent, label, formatBytes(node.shallow), formatBytes(node.domsize), node.typename)

	_lines[#_lines + 1] = line

	if _depth < maxDepth then
		local children = {}

		for _, c in ipairs(node.dominated) do
			children[#children + 1] = c
		end

		table.sort(children, function(a, b)
			return a.domsize > b.domsize
		end)

		for _, c in ipairs(children) do
			if minDomSize <= c.domsize then
				self:printDominatorTree(c, maxDepth, minDomSize, _depth + 1, _lines)
			end
		end
	end

	if _depth == 0 then
		local out = table.concat(_lines, "\n")

		print(out)

		return out
	end

	return _lines
end

function MemSizeAnalyzer:dumpReport(savePath, fileName, topN, minBytes)
	topN = topN or 100
	minBytes = minBytes or 0

	local lines = {}

	lines[#lines + 1] = "========================================================"
	lines[#lines + 1] = "-- Lua Memory Dominator Report"
	lines[#lines + 1] = string.format("-- Total nodes visited : %d", self:nodeCount())
	lines[#lines + 1] = string.format("-- Total shallow bytes : %s", formatBytes(self:totalShallowBytes()))
	lines[#lines + 1] = string.format("-- Root domsize        : %s", formatBytes(self._root and self._root.domsize or 0))
	lines[#lines + 1] = "========================================================"
	lines[#lines + 1] = string.format("-- %-60s  %12s  %12s  %-10s", "Path/Name", "DomSize", "Shallow", "Type")
	lines[#lines + 1] = "--------------------------------------------------------"

	local top = self:topByDomSize(topN, function(n)
		return n.domsize >= minBytes and n.typename ~= "root"
	end)

	for _, node in ipairs(top) do
		lines[#lines + 1] = string.format("  %-60s  %12s  %12s  %-10s", nodeLabel(node), formatBytes(node.domsize), formatBytes(node.shallow), node.typename)
	end

	lines[#lines + 1] = "========================================================"

	local text = table.concat(lines, "\n") .. "\n"
	local affix = string.sub(savePath, -1)

	if affix ~= "/" and affix ~= "\\" then
		savePath = savePath .. "/"
	end

	local fullPath = savePath .. fileName
	local f = assert(io.open(fullPath, "w"))

	f:write(text)
	io.close(f)

	return text
end

function MemSizeAnalyzer.Dump(savePath, fileName, topN)
	collectgarbage("collect")
	collectgarbage("collect")

	local analyzer = MemSizeAnalyzer.new()

	analyzer:analyze("registry", debug.getregistry())
	analyzer:dumpReport(savePath, fileName, topN or 100, 0)

	return analyzer
end

function MemSizeAnalyzer.DumpObject(name, obj, topN)
	if not obj then
		print("[MemSizeAnalyzer] DumpObject: obj is nil")

		return
	end

	local analyzer = MemSizeAnalyzer.new()

	analyzer:analyze(name, obj)
	analyzer:dumpReport(nil, nil, topN or 50, 512)
	print("\n-- Dominator Tree (top 4 levels):")
	analyzer:printDominatorTree(nil, 4, 512)

	return analyzer
end

return MemSizeAnalyzer
