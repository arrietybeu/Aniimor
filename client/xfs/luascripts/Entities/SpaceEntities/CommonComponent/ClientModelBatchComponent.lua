-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientModelBatchComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientModelBatchComponent = Class.Component("ClientModelBatchComponent")

function ClientModelBatchComponent:ctor()
	self.enableRendererBatch = false
	self.disableBatchInfo = {}
end

function ClientModelBatchComponent:setEnableRendererBatch(enable)
	if self.enableRendererBatch ~= enable then
		self.enableRendererBatch = enable

		if self:innerCheckEnableBatchRenderer() and self.eModel and self.eModel.shaderView then
			self.eModel.shaderView:SetEnableRendererBatch(enable)
		end
	end
end

function ClientModelBatchComponent:tempDisableRendererBatch(reason, disable)
	reason = reason or ClientConst.DisableBatchReason.Default

	if disable then
		self.disableBatchInfo[reason] = true
	else
		self.disableBatchInfo[reason] = nil
	end

	self:refreshRendererBatch()
end

function ClientModelBatchComponent:innerCheckEnableBatchRenderer()
	return self.enableRendererBatch and not next(self.disableBatchInfo)
end

function ClientModelBatchComponent:refreshRendererBatch()
	if self.eModel and self.eModel.shaderView then
		if self:innerCheckEnableBatchRenderer() then
			self.eModel.shaderView:SetEnableRendererBatch(true)
		else
			self.eModel.shaderView:SetEnableRendererBatch(false)
		end
	end
end

function ClientModelBatchComponent:flushBatchRenderer()
	if self:innerCheckEnableBatchRenderer() and self.eModel and self.eModel.shaderView then
		self.eModel.shaderView:SetEnableRendererBatch(false)
		self.eModel.shaderView:SetEnableRendererBatch(true)
	end
end

return ClientModelBatchComponent
