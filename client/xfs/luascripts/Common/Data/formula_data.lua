-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\formula_data.lua

local data = {
	[100] = {
		formula = function(level)
			local exp = 0

			exp = 30 * math.pow(level, 0.6)

			return exp
		end
	},
	[101] = {
		formula = function(level)
			local exp = 0

			exp = 90 * math.pow(level, 0.6)

			return exp
		end
	},
	[102] = {
		formula = function(level)
			local exp = 0

			exp = 30 * math.pow(level, 0.6)

			return exp
		end
	},
	[103] = {
		formula = function(level)
			local exp = 0

			exp = 90 * math.pow(level, 0.6)

			return exp
		end
	},
	[104] = {
		formula = function()
			local ratio = 0

			ratio = string.format("%.2f", -math.random() * 0.1)

			return ratio, {
				0,
				0.1
			}
		end
	},
	[105] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 0.7

			x = math.random(0, 3)
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507)) * 0.1
			ratio = ratio % 0.01

			return ratio, {
				0,
				0.1
			}
		end
	},
	[106] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 0.9

			x = math.random(0, 3)
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507)) * 0.1
			ratio = ratio % 0.01

			return ratio, {
				0,
				0.1
			}
		end
	},
	[107] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 1.1

			x = math.random(0, 3)
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507)) * 0.1
			ratio = ratio % 0.01

			return ratio, {
				0,
				0.1
			}
		end
	},
	[108] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 1.3

			x = math.random(0, 3)
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507)) * 0.1
			ratio = ratio % 0.01

			return ratio, {
				0,
				0.1
			}
		end
	},
	[109] = {
		formula = function(canCatchValue, catchProbRadio)
			local ratio = 0

			ratio = math.min(catchProbRadio, (500 - canCatchValue) / 500)

			return ratio
		end
	},
	[110] = {
		formula = function(level)
			local exp = 0

			exp = 90 * math.pow(level, 0.6)

			return exp
		end
	},
	[111] = {
		formula = function(level, isShiny, isBoss)
			local reward = 0

			reward = 5 * math.pow(level, 2)

			if isShiny then
				reward = reward + 500
			end

			if isBoss then
				reward = reward + 100
			end

			return reward
		end
	}
}

return data
