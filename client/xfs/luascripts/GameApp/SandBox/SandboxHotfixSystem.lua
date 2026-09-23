-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SandboxHotfixSystem.lua

local SandboxHotfixSystem = {}

SandboxHotfixSystem.hotfixDict = {}

function SandboxHotfixSystem.addHotfix(id, hotfix)
	SandboxHotfixSystem.hotfixDict[id] = hotfix
end

function SandboxHotfixSystem.clear()
	SandboxHotfixSystem.hotfixDict = {}
end

function SandboxHotfixSystem.getHotfix(id)
	return SandboxHotfixSystem.hotfixDict[id]
end

return SandboxHotfixSystem
