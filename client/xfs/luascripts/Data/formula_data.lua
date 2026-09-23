-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\formula_data.lua

local data = {
	{
		formula = function()
			return 1
		end
	},
	{
		formula = function()
			return 0
		end
	},
	{
		formula = function(lv, X)
			return X
		end
	},
	[104] = {
		formula = function()
			local ratio = 0

			ratio = string.format("%.2f", -math.random())

			return ratio
		end,
		range = {
			0,
			1
		}
	},
	[105] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 0.7

			x = math.random() * 3
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507))
			ratio = math.round(ratio / 0.01) * 0.01

			return ratio
		end,
		range = {
			0,
			1
		}
	},
	[106] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 0.9

			x = math.random() * 3
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507))
			ratio = math.round(ratio / 0.01) * 0.01

			return ratio
		end,
		range = {
			0,
			1
		}
	},
	[107] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 1.1

			x = math.random() * 3
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507))
			ratio = math.round(ratio / 0.01) * 0.01

			return ratio
		end,
		range = {
			0,
			1
		}
	},
	[108] = {
		formula = function()
			local ratio = 0
			local x = 0
			local u = 0
			local a = 1.3

			x = math.random() * 3
			ratio = math.exp(-1 * math.pow(x - u, 2) / (2 * math.pow(a, 2))) / (a * 2.507) / (math.exp(-math.pow(-1 * u, 2) / (2 * math.pow(a, 2))) / (a * 2.507)) * 0.1
			ratio = math.round(ratio / 0.01) * 0.01

			return ratio
		end,
		range = {
			0,
			1
		}
	},
	[109] = {
		formula = function(canCatchValue, catchProbRadio)
			local ratio = 0

			ratio = math.min(catchProbRadio, (500 - canCatchValue) / 500)

			return ratio
		end
	},
	[110] = {
		formula = function(petLevel)
			return 200
		end
	},
	[111] = {
		formula = function(dif)
			local level, isShiny, isBoss = dif:getCatchPetLevel(), dif:isCatchPetShiny(), dif:isCatchPetBoss()
			local reward = 0

			reward = 10 * math.pow(level, 1)

			if isShiny then
				reward = reward + 2000
			end

			if isBoss then
				reward = reward + 1000
			end

			return reward
		end
	},
	[116] = {
		formula = function(dif)
			local level, isShiny, isBoss = dif:getCatchPetLevel(), dif:isCatchPetShiny(), dif:isCatchPetBoss()
			local exp = 0

			exp = 40 * math.pow(level, 0.2)

			if isShiny then
				exp = exp + 100
			end

			if isBoss then
				exp = exp + 100
			end

			exp = math.round(exp)

			return exp
		end
	},
	[1001] = {
		formula = function(dif)
			local exp = 0

			exp = 50 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1002] = {
		formula = function(dif)
			local exp = 0

			exp = 350 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1003] = {
		formula = function(dif)
			local exp = 0

			exp = 350 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1101] = {
		formula = function(dif)
			local exp = 0

			exp = 50 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1102] = {
		formula = function(dif)
			local exp = 0

			exp = 350 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1103] = {
		formula = function(dif)
			local exp = 0

			exp = 350 * math.pow(dif.getKillOrCapturePuppetLevel(), 0.6) * 2
			exp = math.round(exp)

			return exp
		end
	},
	[1104] = {
		formula = function()
			return -1
		end
	},
	[1105] = {
		formula = function(num)
			if num >= 80 then
				return 0
			elseif num >= 70 then
				return 0
			elseif num >= 51 then
				return 0
			elseif num >= 31 then
				return 0
			elseif num >= 11 then
				return 0
			else
				return 0
			end
		end
	},
	[1106] = {
		formula = function(quality)
			if quality == 2 then
				return 1
			elseif quality == 3 then
				return 1
			elseif quality == 4 then
				return 1
			elseif quality == 5 then
				return 1
			else
				return 1
			end
		end
	},
	[1107] = {
		formula = function(quality)
			if quality == 2 then
				return 1
			elseif quality == 3 then
				return 1
			elseif quality == 4 then
				return 1
			elseif quality == 5 then
				return 1
			else
				return 1
			end
		end
	},
	[1108] = {
		formula = function(quality)
			if quality == 2 then
				return 1
			elseif quality == 3 then
				return 1
			elseif quality == 4 then
				return 1
			elseif quality == 5 then
				return 1
			else
				return 1
			end
		end
	},
	[1109] = {
		formula = function(quality)
			if quality == 2 then
				return 1
			elseif quality == 3 then
				return 1
			elseif quality == 4 then
				return 1
			elseif quality == 5 then
				return 1
			else
				return 1
			end
		end
	},
	[1110] = {
		formula = function(quality)
			if quality == 2 then
				return 6
			elseif quality == 3 then
				return 6.5
			elseif quality == 4 then
				return 5
			elseif quality == 5 then
				return 3
			else
				return 10
			end
		end
	},
	[1111] = {
		formula = function(quality)
			if quality == 2 then
				return 4
			elseif quality == 3 then
				return 3
			elseif quality == 4 then
				return 3
			elseif quality == 5 then
				return 3.5
			else
				return 4
			end
		end
	},
	[1112] = {
		formula = function(quality)
			if quality == 2 then
				return 0
			elseif quality == 3 then
				return 0.5
			elseif quality == 4 then
				return 2
			elseif quality == 5 then
				return 3.5
			else
				return 0
			end
		end
	},
	[1113] = {
		formula = function(num, energyGet)
			if num >= 10500 then
				return 1
			elseif num >= 6001 then
				return 0.03
			elseif num >= 3001 then
				return 0.03
			elseif num >= 1501 then
				return 0.03
			elseif num >= 501 then
				return 0.03
			else
				return 0.03
			end
		end
	},
	[1114] = {
		formula = function(num)
			if num >= 10500 then
				return 1
			else
				return 0.006
			end
		end
	},
	[1115] = {
		formula = function(num, order)
			if order == 1 then
				return 0
			elseif order == 2 then
				return 0
			elseif order == 3 then
				return 0
			else
				return 0
			end
		end
	},
	[1116] = {
		formula = function(num, order)
			if order == 1 then
				return 24
			elseif order == 2 then
				return 24
			elseif order == 3 then
				return 24
			else
				return 24
			end
		end
	},
	[1117] = {
		formula = function(num, order)
			if order == 1 then
				return 24
			elseif order == 2 then
				return 24
			elseif order == 3 then
				return 24
			else
				return 24
			end
		end
	},
	[1118] = {
		formula = function(quality)
			if quality == 2 then
				return 1
			elseif quality == 3 then
				return 2
			elseif quality == 4 then
				return 4
			elseif quality == 5 then
				return 6
			else
				return 1
			end
		end
	},
	[1119] = {
		formula = function(quality)
			if quality == 2 then
				return 2
			elseif quality == 3 then
				return 3
			elseif quality == 4 then
				return 4
			elseif quality == 5 then
				return 2
			else
				return 2
			end
		end
	},
	[1120] = {
		formula = function(quality)
			if quality == 2 then
				return 7
			elseif quality == 3 then
				return 5
			elseif quality == 4 then
				return 2
			elseif quality == 5 then
				return 2
			else
				return 7
			end
		end
	},
	[1121] = {
		formula = function(init_val, cur_max_dur, init_max_dur, cur_dur)
			init_max_dur = math.max(init_max_dur, 1)

			local base_value = init_val * (cur_max_dur / init_max_dur)
			local depreciation = 0.1 * init_val * (1 - cur_dur / init_max_dur)

			return math.max(0.1 * init_val, base_value - depreciation)
		end
	},
	[1122] = {
		formula = function(init_val, cur_dur, max_dur)
			local dur_ratio = math.max(0, cur_dur / math.max(max_dur, 1))
			local k = 2
			local actual_value = init_val * math.pow(dur_ratio, k)

			return actual_value
		end
	},
	[1123] = {
		formula = function(value)
			local x = 5
			local result = 1

			result = value >= 22500 and value <= 29999 and 2 or value >= 30000 and value <= 44999 and 2 or value >= 45000 and value <= 89999 and 3 or value >= 90000 and value <= 224999 and 4 or value >= 225000 and value <= 99999999 and 5 or 1

			if result < 5 and math.random() < x / 100 then
				result = result + 1
			end

			return result
		end
	},
	[1124] = {
		formula = function()
			local x = 0

			x = math.random()

			if x >= 0.95 then
				return 4, 500
			elseif x >= 0.9 then
				return 3, 350
			elseif x >= 0.4 then
				return 2, 300
			else
				return 1, 275
			end
		end
	},
	[1125] = {
		formula = function()
			return 4, 1500
		end
	},
	[1126] = {
		formula = function(num, weeknum)
			num = num or 0
			weeknum = weeknum or 0

			if weeknum < 10 then
				if num >= 200 then
					return 1
				elseif num >= 1 then
					return 0.01
				else
					return 0
				end
			elseif num >= 400 then
				return 1
			elseif num >= 1 then
				return 0.005
			else
				return 0
			end
		end
	},
	[1127] = {
		formula = function(num, weeknum)
			num = num or 0
			weeknum = weeknum or 0

			if weeknum == 0 then
				if num >= 1000 then
					return 1
				elseif num >= 1 then
					return 0.002
				else
					return 0
				end
			elseif weeknum == 1 then
				if num >= 2000 then
					return 1
				elseif num >= 1 then
					return 0.001
				else
					return 0
				end
			elseif num >= 3000 then
				return 1
			elseif num >= 1 then
				return 0.0005
			else
				return 0
			end
		end
	},
	[1129] = {
		formula = function(result, difficulty, enemy, boss)
			local stage

			if difficulty == 3 then
				stage = 1 * enemy + 2 * boss
			elseif difficulty == 4 then
				stage = 2 * enemy + 5 * boss
			elseif difficulty == 5 then
				stage = 5 * enemy + 10 * boss
			elseif difficulty == 6 then
				stage = 10 * enemy + 20 * boss
			else
				stage = 0
			end

			return stage
		end
	},
	[1130] = {
		formula = function(result, kills, assists)
			local kill_weight = 10
			local assist_weight = 3

			return kills * kill_weight + assists * assist_weight
		end
	},
	[1131] = {
		formula = function(result, difficulty, self_q, team_q)
			local self_q4 = self_q[4] or 0
			local self_q5 = self_q[5] or 0
			local self_q6 = self_q[6] or 0
			local team_q4 = team_q[4] or 0
			local team_q5 = team_q[5] or 0
			local team_q6 = team_q[6] or 0
			local weight_self_q4 = 10
			local weight_self_q5 = 25
			local weight_self_q6 = 60
			local weight_team_q4 = 5
			local weight_team_q5 = 10
			local weight_team_q6 = 30
			local base_score = self_q4 * weight_self_q4 + self_q5 * weight_self_q5 + self_q6 * weight_self_q6 + team_q4 * weight_team_q4 + team_q5 * weight_team_q5 + team_q6 * weight_team_q6

			return base_score
		end
	},
	[1132] = {
		formula = function(result, loot_value, rank_level, difficulty)
			local diff_multiplier = {
				nil,
				nil,
				0.18,
				0.18,
				0.18,
				0.17,
				[99] = 0.18
			}
			local base_score = math.ceil(math.sqrt(loot_value) * diff_multiplier[difficulty])

			return base_score
		end
	},
	[1133] = {
		formula = function(result, score1, score3, score4)
			return math.floor(score1 + score3 + score4)
		end
	},
	[1134] = {
		formula = function(result, score2)
			return math.floor(score2)
		end
	},
	[1135] = {
		formula = function(result, rank, stage)
			local rand_stage_bonus_table = {
				{
					5,
					8,
					12,
					15
				},
				{
					10,
					16,
					24,
					30
				},
				{
					12,
					20,
					30,
					38
				},
				{
					15,
					24,
					36,
					45
				},
				{
					17,
					28,
					42,
					52
				},
				{
					20,
					35,
					48,
					60
				},
				{
					25,
					38,
					55,
					70
				}
			}

			return math.ceil(rand_stage_bonus_table[rank][stage])
		end
	},
	[1136] = {
		formula = function(result, rank, stage)
			local rand_stage_bonus_table = {
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				},
				{
					25,
					50,
					75,
					100
				}
			}

			return math.ceil(rand_stage_bonus_table[rank][stage])
		end
	},
	[1137] = {
		formula = function(result, rank, stage)
			local rand_stage_bonus_table = {
				{
					8,
					15,
					20,
					30
				},
				{
					10,
					20,
					30,
					40
				},
				{
					12,
					25,
					35,
					50
				},
				{
					15,
					30,
					45,
					60
				},
				{
					18,
					35,
					50,
					70
				},
				{
					18,
					35,
					50,
					70
				},
				{
					18,
					35,
					50,
					70
				}
			}

			return math.ceil(rand_stage_bonus_table[rank][stage])
		end
	},
	[1138] = {
		formula = function(result, loot_value, rank_level, difficulty)
			local diff_multiplier = {
				nil,
				nil,
				0.18,
				0.18,
				0.18,
				0.17,
				[99] = 0.18
			}
			local base_score = math.ceil(math.sqrt(loot_value) * diff_multiplier[difficulty])

			return base_score
		end
	},
	[1139] = {
		formula = function(result, score1, score3, score4)
			return 0
		end
	},
	[1140] = {
		formula = function(result, score2)
			return 0
		end
	},
	[1141] = {
		formula = function(result, behavior_score, evac_multiplier, evac_score, rank_level, difficulty)
			local RECOMMENDED_RANK = {
				nil,
				nil,
				1,
				2,
				3,
				7,
				[99] = 7
			}
			local MAX_SCORE_RANK = {
				nil,
				nil,
				3,
				4,
				5,
				7,
				[99] = 7
			}
			local rec_rank = RECOMMENDED_RANK[difficulty]
			local max_rank = MAX_SCORE_RANK[difficulty]

			if not rec_rank then
				return 0
			end

			if max_rank < rank_level then
				if result == 0 then
					return 0
				else
					behavior_score = 0
				end
			end

			local base_score = behavior_score * evac_multiplier + evac_score

			if (max_rank < rank_level or result ~= 0) and base_score > 0 then
				return 0
			end

			if base_score <= 0 then
				return math.floor(base_score)
			end

			local decay_factor = 1

			if rec_rank < rank_level then
				local rank_diff = rank_level - rec_rank

				decay_factor = math.max(0.5, 1 - rank_diff * 0)
			end

			return math.ceil(base_score * decay_factor)
		end
	},
	[1142] = {
		formula = function(luckyResult, rainbowEnergyLevel, itemCountMap)
			local qualityLeapDistribution = {
				0.7,
				0.25,
				0.05
			}
			local configs = {
				{
					{
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								700034,
								2
							},
							sideQualityRules = {
								[700034] = {
									{
										maximum = 5,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 10,
										minimum = 6,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 15,
										minimum = 11,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 16,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								},
								[2] = {
									{
										maximum = 15999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 16000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 79999,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 80000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 1,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 700034,
									qualityLeapChance = false
								}
							}
						},
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								2
							},
							sideQualityRules = {
								[2] = {
									{
										maximum = 7999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 19999,
										minimum = 8000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 20000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						}
					},
					{
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								700034,
								2
							},
							sideQualityRules = {
								[700034] = {
									{
										maximum = 5,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 10,
										minimum = 6,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 15,
										minimum = 11,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 16,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								},
								[2] = {
									{
										maximum = 15999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 16000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 79999,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 80000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 700034,
									qualityLeapChance = false
								}
							}
						},
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								2
							},
							sideQualityRules = {
								[2] = {
									{
										maximum = 7999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 19999,
										minimum = 8000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 20000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						}
					},
					{
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								700034,
								2
							},
							sideQualityRules = {
								[700034] = {
									{
										maximum = 5,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 10,
										minimum = 6,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 15,
										minimum = 11,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 16,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								},
								[2] = {
									{
										maximum = 15999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 16000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 79999,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 80000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 4,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 3,
									itemId = 700034,
									qualityLeapChance = 0.7
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						},
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								2
							},
							sideQualityRules = {
								[2] = {
									{
										maximum = 7999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 19999,
										minimum = 8000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 20000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						}
					},
					{
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								700034,
								2
							},
							sideQualityRules = {
								[700034] = {
									{
										maximum = 5,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 10,
										minimum = 6,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 15,
										minimum = 11,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 16,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								},
								[2] = {
									{
										maximum = 15999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 16000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 79999,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 80000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 10,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 20,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 15,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 10,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 25,
									itemId = 700034,
									qualityLeapChance = false
								}
							}
						},
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.4,
							waveJitter = 0.2,
							rewardOrder = {
								2
							},
							sideQualityRules = {
								[2] = {
									{
										maximum = 7999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 19999,
										minimum = 8000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 20000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2.5,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 2,
									weight = 2.5,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						}
					}
				},
				{
					[4] = {
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.7,
							waveJitter = 0.2,
							rewardOrder = {
								700034,
								110908,
								2
							},
							sideQualityRules = {
								[700034] = {
									{
										maximum = 17,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 34,
										minimum = 18,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 51,
										minimum = 35,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 52,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								},
								[110908] = {
									{
										maximum = false,
										minimum = 1,
										probabilities = {
											0,
											0,
											0,
											0,
											0,
											1
										}
									}
								},
								[2] = {
									{
										maximum = 39999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 79999,
										minimum = 40000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 119999,
										minimum = 80000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 120000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 6,
									weight = 1,
									itemId = 110908,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1,
									itemId = 700034,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 6,
									weight = 1,
									itemId = 110908,
									qualityLeapChance = false
								}
							}
						},
						{
							defaultPointMax = 5,
							defaultPointMin = 2,
							qualityLeapChance = 0.7,
							waveJitter = 0.2,
							rewardOrder = {
								2
							},
							sideQualityRules = {
								[2] = {
									{
										maximum = 7999,
										minimum = 1,
										probabilities = {
											0,
											1,
											0,
											0,
											0,
											0
										}
									},
									{
										maximum = 19999,
										minimum = 8000,
										probabilities = {
											0,
											0,
											1,
											0,
											0,
											0
										}
									},
									{
										maximum = 39999,
										minimum = 20000,
										probabilities = {
											0,
											0,
											0,
											1,
											0,
											0
										}
									},
									{
										maximum = false,
										minimum = 40000,
										probabilities = {
											0,
											0,
											0,
											0,
											1,
											0
										}
									}
								}
							},
							waves = {
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1.5,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1.5,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 1.5,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 2,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 2.5,
									itemId = 2,
									qualityLeapChance = false
								},
								{
									splitJitter = 0.2,
									pointMax = false,
									pointMin = false,
									baseQuality = 3,
									weight = 2.5,
									itemId = 2,
									qualityLeapChance = false
								}
							}
						}
					}
				}
			}
			local luckyConfigs = configs[luckyResult]
			local candidates = luckyConfigs and luckyConfigs[rainbowEnergyLevel]

			if not candidates or type(itemCountMap) ~= "table" then
				return {}
			end

			local function randomInt(minimum, maximum)
				return minimum + math.floor(math.random() * (maximum - minimum + 1))
			end

			local function qualityWithLeap(baseQuality, leapChance, maximumQuality)
				baseQuality = math.min(baseQuality, maximumQuality)

				if maximumQuality <= baseQuality or leapChance <= 0 then
					return baseQuality
				end

				if leapChance <= math.random() then
					return baseQuality
				end

				local stepRoll, cumulative = math.random(), 0

				for step = 1, 3 do
					cumulative = cumulative + qualityLeapDistribution[step]

					if stepRoll < cumulative then
						return math.min(maximumQuality, baseQuality + step)
					end
				end

				return math.min(maximumQuality, baseQuality + 3)
			end

			local function sideQualityFor(rule, quantity, roll)
				if not rule then
					return nil
				end

				for bandIndex = 1, #rule do
					local band = rule[bandIndex]

					if quantity >= band.minimum and (not band.maximum or quantity <= band.maximum) then
						local cumulative = 0

						for quality = 1, 6 do
							cumulative = cumulative + band.probabilities[quality]

							if roll < cumulative or quality == 6 then
								return quality
							end
						end
					end
				end

				return nil
			end

			local function splitWeighted(total, entries, jitter)
				local reserved = 0

				for index = 1, #entries do
					reserved = reserved + entries[index].minimum
				end

				if total < reserved then
					return nil
				end

				local remaining = total - reserved
				local weights, weightTotal = {}, 0

				for index = 1, #entries do
					local factor = 1 + (math.random() * 2 - 1) * jitter
					local weight = math.max(1e-06, entries[index].weight * factor)

					weights[index], weightTotal = weight, weightTotal + weight
				end

				local amounts, distributed = {}, 0

				for index = 1, #entries do
					local extra = math.floor(remaining * weights[index] / weightTotal)

					amounts[index] = entries[index].minimum + extra
					distributed = distributed + extra
				end

				local remainder = remaining - distributed
				local cursor = randomInt(1, #entries)

				while remainder > 0 do
					amounts[cursor] = amounts[cursor] + 1
					cursor = cursor % #entries + 1
					remainder = remainder - 1
				end

				return amounts
			end

			local totals, inputCount = {}, 0

			for itemId, itemNum in pairs(itemCountMap) do
				if type(itemId) ~= "number" or itemId <= 0 or itemId % 1 ~= 0 or type(itemNum) ~= "number" or itemNum <= 0 or itemNum % 1 ~= 0 then
					return {}
				end

				totals[itemId], inputCount = itemNum, inputCount + 1
			end

			local config

			for candidateIndex = 1, #candidates do
				local candidate, matches = candidates[candidateIndex], inputCount == #candidates[candidateIndex].rewardOrder

				if matches then
					for index = 1, #candidate.rewardOrder do
						if not totals[candidate.rewardOrder[index]] then
							matches = false

							break
						end
					end
				end

				if matches then
					config = candidate

					break
				end
			end

			if not config then
				return {}
			end

			local waveTotals = {}

			for rewardIndex = 1, #config.rewardOrder do
				local itemId, entries = config.rewardOrder[rewardIndex], {}

				for waveIndex = 1, #config.waves do
					local wave = config.waves[waveIndex]

					if wave.itemId == itemId then
						entries[#entries + 1] = {
							waveIndex = waveIndex,
							minimum = wave.pointMin or config.defaultPointMin,
							weight = wave.weight
						}
					end
				end

				local allocations = splitWeighted(totals[itemId], entries, config.waveJitter)

				if not allocations then
					return {}
				end

				for index = 1, #entries do
					waveTotals[entries[index].waveIndex] = allocations[index]
				end
			end

			local sideQualityRolls = {}

			for rewardIndex = 1, #config.rewardOrder do
				sideQualityRolls[config.rewardOrder[rewardIndex]] = math.random()
			end

			local result = {}

			for waveIndex = 1, #config.waves do
				local wave, sideQuantity = config.waves[waveIndex], waveTotals[waveIndex]
				local sideQuality = sideQualityFor(config.sideQualityRules[wave.itemId], sideQuantity, sideQualityRolls[wave.itemId])

				if not sideQuality then
					return {}
				end

				local pointMin = wave.pointMin or config.defaultPointMin
				local pointMax = math.min(wave.pointMax or config.defaultPointMax, sideQuantity)

				if pointMax < pointMin then
					return {}
				end

				local pointCount = randomInt(pointMin, pointMax)
				local pointEntries, baseQuality = {}, math.min(wave.baseQuality, sideQuality)
				local leapChance = wave.qualityLeapChance or config.qualityLeapChance

				for pointIndex = 1, pointCount do
					pointEntries[pointIndex] = {
						weight = 1,
						minimum = 1
					}
				end

				local pointAmounts = splitWeighted(sideQuantity, pointEntries, wave.splitJitter)
				local pointQualities, anchorPointIndex = {}, 1

				for pointIndex = 2, #pointAmounts do
					if pointAmounts[pointIndex] > pointAmounts[anchorPointIndex] then
						anchorPointIndex = pointIndex
					end
				end

				for pointIndex = 1, #pointAmounts do
					pointQualities[pointIndex] = pointIndex == anchorPointIndex and sideQuality or qualityWithLeap(baseQuality, leapChance, sideQuality)
				end

				result[#result + 1] = {
					sideQuality,
					wave.itemId,
					sideQuantity,
					pointQualities
				}
			end

			return result
		end
	},
	[2001] = {
		formula = function(dif)
			local exp = 0

			exp = 20 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2002] = {
		formula = function(dif)
			local exp = 0

			exp = 20 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2003] = {
		formula = function(dif)
			local exp = 0

			exp = 30 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2101] = {
		formula = function(dif)
			local exp = 0

			exp = 20 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2102] = {
		formula = function(dif)
			local exp = 0

			exp = 30 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2103] = {
		formula = function(dif)
			local exp = 0

			exp = 30 * math.pow(dif:getPlayerLevel(), 0.2)
			exp = math.round(exp)

			return exp
		end
	},
	[2200] = {
		formula = function(level, evoStage, starRating)
			local maxTotalEV = 120
			local poolLevel = 58
			local starEVTable = {
				0,
				0,
				0,
				0,
				5,
				13,
				23
			}
			local evoEVTable = {
				5,
				5,
				5,
				5
			}
			local starEV = starEVTable[starRating] or 0
			local evoEV = evoEVTable[evoStage] or 0
			local levelMilestones = {
				{
					level = 45,
					points = 5
				},
				{
					level = 55,
					points = 10
				},
				{
					level = 60,
					points = 10
				},
				{
					level = 65,
					points = 10
				},
				{
					level = 70,
					points = 15
				}
			}
			local levelEV = 0

			for i = 1, #levelMilestones do
				if level >= levelMilestones[i].level then
					levelEV = levelEV + levelMilestones[i].points
				else
					break
				end
			end

			local result = math.floor(starEV + evoEV + levelEV)

			return math.min(result, maxTotalEV)
		end
	},
	[3001] = {
		formula = function(atk, def, bpAtk, casterLevel, instantDamageV, instantDmgRate, power, additionDamageV, epDamageRate, elementDamageFactor, criticalDamageRatio, elementDamageAddRatio, sameElementDamageRatio, abilityAdvantageRatio, instantDamageFix, takenDmgIncRateV, takenDmgDecRateV, takenDmgDecFix, dmgBreakAddRatio, finalTakenDmgIncRateV, finalTakenDmgDecRateV, skillDamageRatio, pvpDmg, playTakenDmgIncRateV, playTakenDmgDecRateV, allTakenDmgIncRateV, allTakenDmgDecRateV, oneTakenDmgIncRateV, oneTakenDmgDecRateV, lvModifyDmgIncFixRate, lvModifyDmgIncDecRate, robEggDmg, isPvp)
			local pvpFactor = 1

			if isPvp == 1 then
				pvpFactor = 0.15
			end

			local finalAtk = math.max(atk, 0.825 * bpAtk)

			return math.max((math.max(finalAtk - def, 0.1 * finalAtk) * (instantDamageV + instantDmgRate * power / 10) + additionDamageV) * elementDamageFactor * sameElementDamageRatio * abilityAdvantageRatio * epDamageRate * elementDamageAddRatio * skillDamageRatio * math.min(3, criticalDamageRatio) * math.max(0.2, 1 + takenDmgIncRateV - takenDmgDecRateV) * dmgBreakAddRatio * math.max(0.2, pvpDmg) * math.max(0.2, 1 + finalTakenDmgIncRateV - finalTakenDmgDecRateV) * math.max(0.2, 1 + allTakenDmgIncRateV) * math.max(0.2, 1 - allTakenDmgDecRateV) * math.max(0.2, 1 + oneTakenDmgIncRateV) * math.max(0.2, 1 - oneTakenDmgDecRateV) + (instantDamageFix - takenDmgDecFix), 0) * pvpFactor * math.max(0.2, 1 + playTakenDmgIncRateV) * math.max(0.2, 1 - playTakenDmgDecRateV) * (1 + lvModifyDmgIncFixRate) * math.max(0.2, 1 - lvModifyDmgIncDecRate) * robEggDmg
		end
	},
	[3002] = {
		isExportClient = 1,
		formula = function(speciesPoint, individualPoint, mathFloorFun)
			return speciesPoint + individualPoint
		end
	},
	[3003] = {
		isExportClient = 1,
		formula = function(speciesPoint, individualPoint, objLevel, mathFloorFun)
			local base = (speciesPoint + 20) * (1 + individualPoint * 0.008)

			if type(mathFloorFun) ~= "function" then
				return base
			end

			return mathFloorFun(base / 120 * (objLevel * objLevel * 0 + objLevel * 6 + 35) * 20)
		end
	},
	[3004] = {
		isExportClient = 1,
		formula = function(speciesPoint, individualPoint, objLevel, mathFloorFun)
			local base = speciesPoint * (1 + individualPoint * 0.008)

			if type(mathFloorFun) ~= "function" then
				return base
			end

			return mathFloorFun(base / 120 * (objLevel * objLevel * 0 + objLevel * 6 + 35) * 1)
		end
	},
	[3005] = {
		isExportClient = 1,
		formula = function(rawTotal, attributeSatisfy, attributeUp, mathFloorFun)
			return 0
		end
	},
	[3006] = {
		formula = function(casterBpAtkCur, casterLevel, targetLevel, isPlayer)
			if isPlayer then
				return 1
			else
				return 1
			end
		end
	},
	[3007] = {
		formula = function(speciesPoint, individualPoint, objLevel, mathFloorFun)
			local base = speciesPoint * (1 + individualPoint * 0.008)

			if type(mathFloorFun) ~= "function" then
				return base
			end

			return mathFloorFun(base / 80 * (objLevel * objLevel * 0 + objLevel * 6 + 35) * 0.5)
		end
	},
	[3008] = {
		formula = function(speciesPoint, individualPoint, objLevel, mathFloorFun)
			local base = speciesPoint * (1 + individualPoint * 0.008)

			if type(mathFloorFun) ~= "function" then
				return base
			end

			return mathFloorFun(base / 90 * (objLevel * objLevel * 0 + objLevel * 6 + 35) * 0.5)
		end
	},
	[3009] = {
		formula = function(casterEpRegenForceCur, casterLevel, isPlayer)
			if isPlayer then
				return 1
			else
				return math.min(0.9 + 0.45 * casterEpRegenForceCur / (casterLevel * casterLevel * 0 + casterLevel * 6 + 35) / 0.5, 5)
			end
		end
	},
	[3010] = {
		formula = function(elementAtk, elementDef, power, srcElementLv)
			return math.max(0, (elementAtk - elementDef) * power * 0.1)
		end
	},
	[3011] = {
		formula = function(cp, lv, spec)
			local result = {
				0,
				0,
				0,
				0,
				0
			}
			local weight = {
				0.5,
				0.3,
				0.2,
				0.2,
				0
			}
			local specWeight = {
				61.81,
				83.81,
				81.69,
				88.39,
				88.39,
				86.73
			}
			local weightCp = 0
			local factor = 0
			local maxFactor = 3
			local targetLv = lv[1]
			local flv = 0 * targetLv * targetLv + 6 * targetLv + 35
			local baseCp = 8 * flv

			for i, v in ipairs(cp) do
				weightCp = weightCp + weight[i] * v
			end

			if weightCp < baseCp then
				factor = (0.5 * baseCp + weightCp * 0.5) / baseCp
			else
				factor = math.min(maxFactor, math.pow(weightCp / baseCp, 0.5))
			end

			spec[1] = spec[1] + 20

			for i, v in ipairs(spec) do
				result[i] = math.max(0, factor * specWeight[i])
			end

			return result
		end
	},
	[3012] = {
		isExportClient = 1,
		formula = function(props, lv)
			local result = {
				0,
				0,
				0,
				0,
				0,
				0
			}
			local spec = {
				0,
				0,
				0,
				0,
				0,
				0
			}
			local specFactor = {
				120,
				120,
				50,
				80,
				80,
				50
			}
			local flvFactor = {
				20,
				1.25,
				1,
				0.5,
				0.5,
				0.5
			}
			local maxSpec = 200
			local flv = 0 * lv * lv + 6 * lv + 35

			for i, v in ipairs(props) do
				spec[i] = v / flv / flvFactor[i] * specFactor[i]

				if i == 1 then
					spec[i] = spec[i] - 20
				end

				result[i] = math.min(1, math.max(0, spec[i] / maxSpec))
			end

			return result
		end
	},
	[3013] = {
		isExportClient = 1,
		formula = function(atk, def, needAbilityLv, petAbilityLv, isPersonalityMatch)
			local result

			result = (atk[petAbilityLv] - def[needAbilityLv]) * (1 + isPersonalityMatch * 0.2)

			return result
		end
	},
	[3014] = {
		isExportClient = 1,
		formula = function(level, propTotalValues)
			local ret = 0
			local propFactors = {
				0.045455,
				1,
				1,
				1,
				1,
				1
			}

			for i, factor in ipairs(propFactors) do
				ret = ret + (propTotalValues[i] or 0) * factor
			end

			return math.round(ret)
		end
	},
	[3015] = {
		formula = function(lv, p1, p2, p3)
			return p1 * lv * lv + p2 * lv + p3
		end
	},
	[3016] = {
		formula = function(lv, p1, p2, p3)
			local result

			if lv <= 25 then
				result = (p2 - p1) / 10 * (lv - 15) + p1
			else
				result = (p3 - p2) / 25 * (lv - 25) + p2
			end

			return math.max(p1, math.min(p3, result))
		end
	},
	[3017] = {
		formula = function(lv, p1, p2)
			local result

			result = (p2 - p1) / 20 * (lv - 30) + p1

			return math.max(p1, math.min(p2, result))
		end
	},
	[3018] = {
		formula = function(speciesPoint, individualPoint, objLevel, mathFloorFun)
			local base = speciesPoint * (1 + individualPoint * 0.008)

			if type(mathFloorFun) ~= "function" then
				return base
			end

			return mathFloorFun(base / 100 * (objLevel * objLevel * 0 + objLevel * 6 + 35) * 1)
		end
	},
	[3019] = {
		formula = function(elementAtk, elementDef, power, srcElementLv)
			return 2 * power
		end
	},
	[3020] = {
		formula = function(strengthenPoint, mathFloorFun)
			return mathFloorFun((strengthenPoint - 1) / 5) + 1
		end
	},
	[3021] = {
		formula = function(lv, stage, quality)
			return 30
		end
	},
	[3022] = {
		formula = function(totalPoint, commWeight)
			local value = {
				0,
				0,
				0,
				0,
				0,
				0
			}
			local mainPoint = math.min(math.floor(totalPoint / (commWeight + 1)), 20)

			if totalPoint == commWeight then
				mainPoint = mainPoint + 1
			end

			local otherPoint = totalPoint - mainPoint * commWeight

			if math.random() > 0.5 then
				value[1] = math.floor(mainPoint / 2)
			else
				value[1] = math.ceil(mainPoint / 2)
			end

			value[2] = mainPoint - value[1]

			if otherPoint > 0 and mainPoint > 1 then
				local lowerLimit = math.max(math.min((otherPoint / math.floor(mainPoint / 2) - 1) / 3, 1), 0)
				local weight = {}
				local weightTotal = 0
				local remainPoint = otherPoint
				local otherValue = {
					0,
					0,
					0,
					0
				}
				local sortValue = {}

				for i = 1, 4 do
					weight[i] = lowerLimit + (1 - lowerLimit) * math.random()
					weightTotal = weightTotal + weight[i]
				end

				for i, v in ipairs(weight) do
					otherValue[i] = math.floor(v / math.max(weightTotal, 0.001) * otherPoint)
					remainPoint = remainPoint - otherValue[i]
				end

				remainPoint = math.min(remainPoint, 4)

				if remainPoint > 0 then
					for i, v in ipairs(otherValue) do
						sortValue[i] = v
					end

					table.sort(sortValue)

					local threshold = sortValue[remainPoint]
					local count = 0

					for i, v in ipairs(otherValue) do
						if v <= threshold and count < remainPoint then
							otherValue[i] = v + 1
							count = count + 1
						end
					end
				end

				for i, v in ipairs(otherValue) do
					value[i + 2] = v
				end
			end

			return value
		end
	},
	[3023] = {
		formula = function(dmgPercent, bpAtkCur, bpDefCur, bpDamFixRate, bpRate, bpAtkRatio, bpReduceRate, bpAddRatio, instantDamageV, instantDmgRate, power, bpPower, additionDamageV, epDamageRate, elementDamageFactor, criticalDamageRatio, elementDamageAddRatio, sameElementDamageRatio, abilityAdvantageRatio, instantDamageFix, takenDmgIncRateV, takenDmgDecRateV, takenDmgDecFix, dmgBreakAddRatio, finalTakenDmgIncRateV, finalTakenDmgDecRateV, skillDamageRatio, pvpDmg, playTakenDmgIncRateV, playTakenDmgDecRateV, allTakenDmgIncRateV, allTakenDmgDecRateV, oneTakenDmgIncRateV, oneTakenDmgDecRateV, lvModifyDmgIncFixRate, lvModifyDmgIncDecRate, robEggDmg, isPvp)
			local result

			result = math.max((bpAtkCur - bpDefCur) * (instantDamageV + instantDmgRate * power / 10) * bpRate * bpDamFixRate * bpAtkRatio * math.max(0.2, bpAddRatio + bpReduceRate - 1) * math.max(1, elementDamageFactor) * abilityAdvantageRatio * math.min(3, criticalDamageRatio) * elementDamageAddRatio * epDamageRate, 0) * math.pow(robEggDmg, 0.5) * math.pow((1 + lvModifyDmgIncFixRate) * math.max(0.2, 1 - lvModifyDmgIncDecRate), 0.5)

			return result
		end
	},
	[3024] = {
		formula = function(lv, propBossGrade, speciesPoint, p1, p2, p3)
			local result
			local flv = lv * lv * 0 + lv * 6 + 35

			result = (p1 * propBossGrade + p2) * flv * speciesPoint + p3

			return result
		end
	},
	[3025] = {
		formula = function(hp_max_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 3.75e-05 * hp_max_cur) or 0) * calcValueByFormula
		end
	},
	[3026] = {
		formula = function(atk_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 0.00075 * atk_cur) or 0) * calcValueByFormula
		end
	},
	[3027] = {
		formula = function(def_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 0.0015 * def_cur) or 0) * calcValueByFormula
		end
	},
	[3028] = {
		formula = function(def_mag_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 0.0015 * def_mag_cur) or 0) * calcValueByFormula
		end
	},
	[3029] = {
		formula = function(ep_regen_force_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 0.0012 * ep_regen_force_cur) or 0) * calcValueByFormula
		end
	},
	[3030] = {
		formula = function(bp_atk_cur, calcValueByFormula)
			return (math.min(1.4, 0.8 + 0.001 * bp_atk_cur) or 0) * calcValueByFormula
		end
	},
	[3031] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (0.003978 * math.pow(calcLv, 2) - 0.03911 * calcLv + 1.178) * ttk / 10 * elementFactor / 1.6

			return math.max(result, 0.01)
		end
	},
	[3032] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return math.max(result, 0)
		end
	},
	[3033] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return result
		end
	},
	[3034] = {
		formula = function(lv, ttk, needBeCountered)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needBeCountered == 1 then
				elementFactor = 0.625
			end

			result = (-4.254e-06 * math.pow(calcLv, 3) + 0.000736 * math.pow(calcLv, 2) - 0.03927 * calcLv - 0.0091 + 1) * 60 / ttk * elementFactor - 1

			return math.max(result, -0.99)
		end
	},
	[3035] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-3.48e-05 * math.pow(calcLv, 3) + 0.003038 * math.pow(calcLv, 2) - 0.02229 * calcLv + 0.8234) * ttk / 5 * elementFactor / 1.6 * baseBp

			return math.max(result, 0)
		end
	},
	[3036] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (0.005634 * math.pow(calcLv, 2) - 0.05541 * calcLv + 1.664) * ttk / 15 * elementFactor / 1.6

			return math.max(result, 0.01)
		end
	},
	[3037] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return math.max(result, 0)
		end
	},
	[3038] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return result
		end
	},
	[3039] = {
		formula = function(lv, ttk, needBeCountered)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needBeCountered == 1 then
				elementFactor = 0.625
			end

			result = (-3.335e-06 * math.pow(calcLv, 3) + 0.000679 * math.pow(calcLv, 2) - 0.03974 * calcLv + 0.165 + 1) * 40 / ttk * elementFactor - 1

			return math.max(result, -0.99)
		end
	},
	[3040] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-3.48e-05 * math.pow(calcLv, 3) + 0.003038 * math.pow(calcLv, 2) - 0.02229 * calcLv + 0.8234) * ttk / 5 * elementFactor / 1.6 * baseBp

			return math.max(result, 0)
		end
	},
	[3041] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (0.005634 * math.pow(calcLv, 2) - 0.05541 * calcLv + 1.664) * ttk / 25 * elementFactor / 1.6

			return math.max(result, 0.01)
		end
	},
	[3042] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return math.max(result, 0)
		end
	},
	[3043] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return result
		end
	},
	[3044] = {
		formula = function(lv, ttk, needBeCountered)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needBeCountered == 1 then
				elementFactor = 0.625
			end

			result = (-5.998e-06 * math.pow(calcLv, 3) + 0.001076 * math.pow(calcLv, 2) - 0.05853 * calcLv + 0.529 + 1) * 30 / ttk * elementFactor - 1

			return math.max(result, -0.99)
		end
	},
	[3045] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-3.48e-05 * math.pow(calcLv, 3) + 0.003038 * math.pow(calcLv, 2) - 0.02229 * calcLv + 0.8234) * ttk / 5 * elementFactor / 1.6 * baseBp

			return math.max(result, 0)
		end
	},
	[3046] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-6.776e-06 * math.pow(calcLv, 4) + 0.0008627 * math.pow(calcLv, 3) + 0.00089 * math.pow(calcLv, 2) - 0.08677 * calcLv + 4.556) * ttk / 90 * elementFactor / 1.6

			return math.max(result, 0.01)
		end
	},
	[3047] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return math.max(result, 0)
		end
	},
	[3048] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (-4.663e-06 * math.pow(calcLv, 3) + 0.0006604 * math.pow(calcLv, 2) + 0.008379 * calcLv + 0.9607) * rate

			return math.max(result, 0)
		end
	},
	[3049] = {
		formula = function(lv, ttk, needBeCountered)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1

			if needBeCountered == 1 then
				elementFactor = 0.625
			end

			result = (0 * math.pow(calcLv, 3) + 0.0001541 * math.pow(calcLv, 2) - 0.005637 * calcLv + 0.435) * 30 / ttk * elementFactor - 1

			return math.max(result, -0.99)
		end
	},
	[3050] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-2.484e-05 * math.pow(calcLv, 4) + 0.002265 * math.pow(calcLv, 3) - 0.04807 * math.pow(calcLv, 2) + 0.5134 * calcLv + 4.114) * ttk / 60 * elementFactor / 1.6 * baseBp

			return math.max(result, 0)
		end
	},
	[3051] = {
		formula = function(lv, ttk, needCounter)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			if needCounter == 1 then
				elementFactor = 1.6
			end

			result = (-3.926e-05 * math.pow(calcLv, 3) + 0.005005 * math.pow(calcLv, 2) - 0.04969 * calcLv + 1.234) * ttk / 15 * elementFactor / 1.6 * baseBp

			return math.max(result, 0)
		end
	},
	[3052] = {
		formula = function(lv, setLv, hpRate, bpRate)
			local result
			local calcLv = math.min(60, math.max(1, setLv))
			local elementFactor = 1
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBp = 10 * flv

			result = (7.885e-06 * math.pow(calcLv, 3) - 0.0007003 * math.pow(calcLv, 2) - 0.003136 * calcLv + 1.486) * hpRate * bpRate * baseBp

			return math.max(result, 0)
		end
	},
	[3053] = {
		formula = function(lv, changeLv)
			local result
			local calcLv = math.min(60, math.max(1, lv))
			local flv = lv * lv * 0 + lv * 4 + 35
			local baseBpDef = 0.8 * flv

			result = (1.674e-05 * math.pow(calcLv, 3) - 0.001479 * math.pow(calcLv, 2) - 0.001179 * calcLv - 0.8645) * baseBpDef * math.max(0, math.min(1, (changeLv + 20 - lv) * 0.05))

			return result
		end
	},
	[3054] = {
		isExportClient = 1,
		formula = function(atk, def, needAbilityLv, petAbilityLv, isPersonalityMatch)
			local result

			if needAbilityLv < petAbilityLv then
				result = 2 + petAbilityLv - needAbilityLv
			else
				result = 1 + 0.25 * (petAbilityLv - needAbilityLv)
			end

			result = 60 * result * (1 + isPersonalityMatch * 0.2)

			return result
		end
	},
	[3066] = {
		formula = function(FinalProb)
			local p = math.min(1, math.max(0, FinalProb))^0.5
			local w1 = p * (1 - p)
			local w2 = p * p

			return w1, w2
		end
	},
	[3067] = {
		formula = function(atk, def, bpAtk, casterLevel, instantDamageV, instantDmgRate, power, additionDamageV, epDamageRate, elementDamageFactor, criticalDamageRatio, elementDamageAddRatio, sameElementDamageRatio, abilityAdvantageRatio, instantDamageFix, takenDmgIncRateV, takenDmgDecRateV, takenDmgDecFix, dmgBreakAddRatio, finalTakenDmgIncRateV, finalTakenDmgDecRateV, skillDamageRatio, pvpDmg, playTakenDmgIncRateV, playTakenDmgDecRateV, allTakenDmgIncRateV, allTakenDmgDecRateV, oneTakenDmgIncRateV, oneTakenDmgDecRateV, lvModifyDmgIncFixRate, lvModifyDmgIncDecRate, eggUse, isPvp)
			local pvpFactor = 1

			if isPvp == 1 then
				pvpFactor = 0.3
			end

			local finalAtk = math.max(atk, 0.9 * bpAtk)

			return math.max((math.max(finalAtk - def, 0.1 * finalAtk) * (instantDamageV + instantDmgRate * power / 10) + additionDamageV) * elementDamageFactor * sameElementDamageRatio * abilityAdvantageRatio * epDamageRate * elementDamageAddRatio * skillDamageRatio * math.min(3, criticalDamageRatio) * math.max(0.2, 1 + takenDmgIncRateV - takenDmgDecRateV) * dmgBreakAddRatio * math.max(0.2, pvpDmg) * (1 + finalTakenDmgIncRateV) * (1 - finalTakenDmgDecRateV) * math.max(0.2, 1 + allTakenDmgIncRateV) * math.max(0.2, 1 - allTakenDmgDecRateV) * math.max(0.2, 1 + oneTakenDmgIncRateV) * math.max(0.2, 1 - oneTakenDmgDecRateV) * eggUse + (instantDamageFix - takenDmgDecFix), 0.05) * pvpFactor * math.max(0.2, 1 + playTakenDmgIncRateV) * math.max(0.2, 1 - playTakenDmgDecRateV) * (1 + lvModifyDmgIncFixRate) * math.max(0.2, 1 - lvModifyDmgIncDecRate)
		end
	},
	[3068] = {
		formula = function(TrapDmg, Level, pvpDmg, robEggDmg)
			return math.max(TrapDmg * (1 - (1 - pvpDmg) * 0.5), 0.3)
		end
	},
	[3069] = {
		formula = function(elementAtk, elementDef, power, srcElementLv, epCost, calcValue, ecsChange)
			return math.max(0, (elementAtk - elementDef) * math.max(epCost, 20) * calcValue * (1 + ecsChange) * 0.3)
		end
	},
	[3070] = {
		formula = function(lv, type)
			return 10
		end
	},
	[3071] = {
		formula = function(healVal, casterHealAddRatio, sceneHealRatio, healAddRatio)
			local val = healVal * sceneHealRatio * (1 + healAddRatio) * (1 + casterHealAddRatio)

			return val
		end
	},
	[3072] = {
		formula = function(shieldVal, sceneHealRatio, shieldAddRatio)
			local val = shieldVal * sceneHealRatio * (1 + shieldAddRatio)

			return val
		end
	},
	[3073] = {
		formula = function(damage, reduceShieldFactor, shieldTakenDmgIncRateV, shieldDmgIncRateV)
			local shieldDamageFactor = (1 + reduceShieldFactor or 1) + shieldTakenDmgIncRateV + shieldDmgIncRateV

			if shieldDamageFactor <= 0 then
				shieldDamageFactor = 0.01
			end

			local finalDamage = damage * shieldDamageFactor

			return finalDamage, shieldDamageFactor
		end
	},
	[3100] = {
		formula = function(lv, enhancedSkill, collect, speciesHp, speciesAtk, speciesDef, speciesDefmag, speciesEp, speciesBp, carryCp, potentialCp, resonanceCp, rainbow)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local carryCp = carryCp or 0
			local potentialCp = potentialCp or 0
			local resonanceCp = resonanceCp or 0

			result = math.round((calcLv * 6 + 35) * (speciesHp + speciesAtk * 2 + speciesDef + speciesDefmag + speciesEp + speciesBp) * (1 + enhancedSkill * 0.05) * (1 + potentialCp * 0.00055) * 0.005) + enhancedSkill * 20 + carryCp + potentialCp * 0.3 + resonanceCp + (collect - 1 + rainbow) * 5

			return math.max(result, 1)
		end
	},
	[3101] = {
		formula = function(lv, ttk, speciesRate, allin, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 2.03e-06 * math.pow(calcLv, 3) - 2.78e-06 * math.pow(calcLv, 2) - 0.00025339 * calcLv + 0.07617853
			else
				regressionFactor = 5.03e-09 * math.pow(calcLv, 5) - 1.4262e-06 * math.pow(calcLv, 4) + 0.0001494542 * math.pow(calcLv, 3) - 0.0071018605 * math.pow(calcLv, 2) + 0.1568861725 * calcLv - 1.2146712941
			end

			result = regressionFactor * ttk * allin * speciesRate * elementFactor

			return math.max(result, 0.01)
		end
	},
	[3102] = {
		formula = function(lv, rate, speciesRate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 5.9e-07 * math.pow(calcLv, 3) - 1.305e-05 * math.pow(calcLv, 2) + 7.82e-05 * calcLv + 0.52313229
			else
				regressionFactor = 5.955e-08 * math.pow(calcLv, 4) - 1.52295e-05 * math.pow(calcLv, 3) + 0.0013851149 * math.pow(calcLv, 2) - 0.0466001244 * calcLv + 1.0331406995
			end

			result = regressionFactor * rate * speciesRate

			return math.max(result, 0.01)
		end
	},
	[3103] = {
		formula = function(lv, rate, speciesRate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 4.84e-06 * math.pow(calcLv, 3) - 0.00010746 * math.pow(calcLv, 2) + 0.00064381 * calcLv + 2.1869532
			else
				regressionFactor = 4.8233e-07 * math.pow(calcLv, 4) - 0.0001172195 * math.pow(calcLv, 3) + 0.0098905803 * math.pow(calcLv, 2) - 0.3144172571 * calcLv + 5.489767944
			end

			result = regressionFactor * rate * speciesRate

			return math.max(result, -9999)
		end
	},
	[3104] = {
		formula = function(lv, rate)
			local result

			result = 1 - 0.5 / (1 - math.max(rate, -1))

			return result
		end
	},
	[3105] = {
		formula = function(lv, rate, ttk, bloodlust, needCounter)
			local result
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.2
			end

			result = 76.53061224 / rate / ttk / bloodlust * elementFactor - 1

			return math.max(result, -0.9)
		end
	},
	[3106] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.0005704 * math.pow(calcLv, 3) - 0.03484944 * math.pow(calcLv, 2) + 7.24411034 * calcLv - 198.28153997
			else
				regressionFactor = 0.0001482986 * math.pow(calcLv, 4) - 0.0291289103 * math.pow(calcLv, 3) + 2.0358488693 * math.pow(calcLv, 2) - 60.6870203674 * calcLv + 572.0670386832
			end

			result = regressionFactor

			return math.max(result, -9999)
		end
	},
	[3107] = {
		formula = function(lv, ttk, noBig, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.01797194 * math.pow(calcLv, 3) + 0.1151636 * math.pow(calcLv, 2) - 5.30639708 * calcLv + 967.15856906
			else
				regressionFactor = -0.00046079489 * math.pow(calcLv, 4) + 0.0642319554 * math.pow(calcLv, 3) - 2.1403799549 * math.pow(calcLv, 2) + 54.5775468722 * calcLv + 329.8704943955
			end

			result = regressionFactor * ttk * noBig * elementFactor

			return math.max(result, -9999)
		end
	},
	[3108] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = -0.00176794 * math.pow(calcLv, 3) + 0.15809145 * math.pow(calcLv, 2) - 4.07411446 * calcLv - 29.91730345
			else
				regressionFactor = 1.686352e-05 * math.pow(calcLv, 4) - 0.0019631376 * math.pow(calcLv, 3) + 0.0400292276 * math.pow(calcLv, 2) + 2.5599171185 * calcLv - 123.2989586011
			end

			result = regressionFactor

			return math.max(result, -9999)
		end
	},
	[3109] = {
		formula = function(lv, ttk, noBig, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.03248729 * math.pow(calcLv, 3) - 0.84002093 * math.pow(calcLv, 2) + 42.04376314 * calcLv + 281.42637984
			else
				regressionFactor = 0.0001463926 * math.pow(calcLv, 4) - 0.0611009251 * math.pow(calcLv, 3) + 7.0542305125 * math.pow(calcLv, 2) - 236.9426417667 * calcLv + 3540.3670946658
			end

			result = regressionFactor * ttk * noBig * elementFactor * (1 - 0.08 * math.max(math.min(calcLv - 29, 1), 0) - 0.08 * math.max(math.min(calcLv - 39, 1), 0) - 0.08 * math.max(math.min(calcLv - 49, 1), 0))

			return math.max(result, 0.01)
		end
	},
	[3110] = {
		formula = function(lv, ttk, noBig, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.4
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.00033478 * math.pow(calcLv, 3) - 0.00638831 * math.pow(calcLv, 2) + 9.16772211 * calcLv + 53.25878512
			else
				regressionFactor = 1.79869e-05 * math.pow(calcLv, 4) - 0.0116044223 * math.pow(calcLv, 3) + 1.4768265884 * math.pow(calcLv, 2) - 43.5365263699 * calcLv + 619.0788382776
			end

			result = regressionFactor * ttk * noBig * elementFactor

			return math.max(result, 0.01)
		end
	},
	[3111] = {
		formula = function(lv, rate, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.25
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 1.16e-06 * math.pow(calcLv, 3) - 2.585e-05 * math.pow(calcLv, 2) + 0.00015488 * calcLv + 1.03610667
			else
				regressionFactor = 1.4383e-07 * math.pow(calcLv, 4) - 3.4322e-05 * math.pow(calcLv, 3) + 0.0029873201 * math.pow(calcLv, 2) - 0.0993568616 * calcLv + 2.1258581377
			end

			result = regressionFactor * rate * elementFactor

			return math.max(result, 0.01)
		end
	},
	[3112] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 2.42e-06 * math.pow(calcLv, 3) - 5.373e-05 * math.pow(calcLv, 2) + 0.0003219 * calcLv + 1.0934766
			else
				regressionFactor = 2.4116e-07 * math.pow(calcLv, 4) - 5.86097e-05 * math.pow(calcLv, 3) + 0.0049452901 * math.pow(calcLv, 2) - 0.1572086286 * calcLv + 2.744883972
			end

			result = regressionFactor * rate

			return math.max(result, 0.01)
		end
	},
	[3113] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 1.18e-06 * math.pow(calcLv, 3) - 2.61e-05 * math.pow(calcLv, 2) + 0.0001564 * calcLv + 1.04626458
			else
				regressionFactor = 1.191e-07 * math.pow(calcLv, 4) - 3.0459e-05 * math.pow(calcLv, 3) + 0.0027702299 * math.pow(calcLv, 2) - 0.0932002489 * calcLv + 2.066281399
			end

			result = regressionFactor * rate

			return math.max(result, -0.99)
		end
	},
	[3114] = {
		formula = function(lv, ttk, rate, needCounter)
			local result
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.25
			end

			result = 20 / ttk * (0.5 / (rate - 0.5)) * elementFactor - 1

			return result
		end
	},
	[3115] = {
		formula = function(lv, ttk, rate)
			local result

			result = 1 - 20 / ttk * (1 / (2 - rate))

			return result
		end
	},
	[3116] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.00038606 * math.pow(calcLv, 3) - 0.00875368 * math.pow(calcLv, 2) + 0.61719818 * calcLv + 3.21156552
			else
				regressionFactor = 1.258925e-05 * math.pow(calcLv, 4) - 0.007750456 * math.pow(calcLv, 3) + 1.0336739404 * math.pow(calcLv, 2) - 40.4222008742 * calcLv + 493.9382246174
			end

			result = regressionFactor * rate

			return math.max(result, 0)
		end
	},
	[3117] = {
		formula = function(lv, rate, needCounter)
			local result
			local calcLv = math.min(70, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.25
			end

			result = (0.0004361929 * math.pow(calcLv, 4) - 0.0569614159 * math.pow(calcLv, 3) + 2.5344138653 * math.pow(calcLv, 2) + 53.1743832189 * calcLv + 660.9493895678) * rate * elementFactor

			return math.max(result, 500)
		end
	},
	[3118] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(70, math.max(1, lv))

			result = (1.09874e-05 * math.pow(calcLv, 4) - 0.0014363959 * math.pow(calcLv, 3) + 0.063966487 * math.pow(calcLv, 2) + 1.3420413566 * calcLv + 16.6882595437) * rate

			return math.max(result, 10)
		end
	},
	[3119] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(70, math.max(1, lv))

			result = (2.479396e-05 * math.pow(calcLv, 4) - 0.0032385972 * math.pow(calcLv, 3) + 0.1479323695 * math.pow(calcLv, 2) + 2.749251507 * calcLv + 36.3900056035) * rate

			return math.max(result, -9999)
		end
	},
	[3122] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.00019303 * math.pow(calcLv, 3) - 0.00437684 * math.pow(calcLv, 2) + 0.30859909 * calcLv + 1.60578276
			else
				regressionFactor = -5.61046e-06 * math.pow(calcLv, 4) - 0.0004004034 * math.pow(calcLv, 3) + 0.1877530854 * math.pow(calcLv, 2) - 8.9194092882 * calcLv + 121.9269649033
			end

			result = regressionFactor * rate

			return math.max(result, 0)
		end
	},
	[3123] = {
		formula = function(lv, rate, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.25
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 1.06e-06 * math.pow(calcLv, 3) - 2.35e-05 * math.pow(calcLv, 2) + 0.0001408 * calcLv + 1.03464242
			else
				regressionFactor = 2.0213e-07 * math.pow(calcLv, 4) - 5.60311e-05 * math.pow(calcLv, 3) + 0.005153242 * math.pow(calcLv, 2) - 0.1737310687 * calcLv + 2.9376494859
			end

			result = regressionFactor * rate * elementFactor

			return math.max(result, 0.01)
		end
	},
	[3124] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 2.2e-06 * math.pow(calcLv, 3) - 4.885e-05 * math.pow(calcLv, 2) + 0.00029264 * calcLv + 1.09043327
			else
				regressionFactor = 4.8935e-07 * math.pow(calcLv, 4) - 0.0001100692 * math.pow(calcLv, 3) + 0.0085431186 * math.pow(calcLv, 2) - 0.2546349079 * calcLv + 3.6385754019
			end

			result = regressionFactor * rate

			return math.max(result, 0.01)
		end
	},
	[3125] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 1.07e-06 * math.pow(calcLv, 3) - 2.373e-05 * math.pow(calcLv, 2) + 0.00014218 * calcLv + 1.04478598
			else
				regressionFactor = 2.1599e-07 * math.pow(calcLv, 4) - 5.85535e-05 * math.pow(calcLv, 3) + 0.005269863 * math.pow(calcLv, 2) - 0.1730204617 * calcLv + 2.8940384832
			end

			result = regressionFactor * rate

			return math.max(result, -0.99)
		end
	},
	[3128] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.00038606 * math.pow(calcLv, 3) - 0.00875368 * math.pow(calcLv, 2) + 0.65319818 * calcLv + 3.42156552
			else
				regressionFactor = 0.00019396958 * math.pow(calcLv, 4) - 0.0461518095 * math.pow(calcLv, 3) + 3.8446130197 * math.pow(calcLv, 2) - 122.3383956332 * calcLv + 1310.0515485555
			end

			result = regressionFactor * rate

			return math.max(result, 0)
		end
	},
	[3129] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = -0.00010708 * math.pow(calcLv, 3) + 0.00011394 * math.pow(calcLv, 2) + 0.0137363 * calcLv + 4.43834756
			else
				regressionFactor = 2.71e-08 * math.pow(calcLv, 4) + 2.00013e-05 * math.pow(calcLv, 3) - 0.0025611505 * math.pow(calcLv, 2) + 0.0254198921 * calcLv + 4.3731473793
			end

			result = regressionFactor - 1

			return math.max(result, -9)
		end
	},
	[3130] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = -0.00010708 * math.pow(calcLv, 3) + 0.00011394 * math.pow(calcLv, 2) + 0.0137363 * calcLv + 4.43834756
			else
				regressionFactor = 2.71e-08 * math.pow(calcLv, 4) + 2.00013e-05 * math.pow(calcLv, 3) - 0.0025611505 * math.pow(calcLv, 2) + 0.0254198921 * calcLv + 4.3731473793
			end

			result = 1 - regressionFactor

			return math.max(result, -9)
		end
	},
	[3131] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = -2.407e-05 * math.pow(calcLv, 3) + 0.00013224 * math.pow(calcLv, 2) + 0.00176923 * calcLv + 3.80233046
			else
				regressionFactor = 3.1224e-07 * math.pow(calcLv, 4) - 6.51021e-05 * math.pow(calcLv, 3) + 0.0057853766 * math.pow(calcLv, 2) - 0.2870341189 * calcLv + 7.832778878
			end

			result = regressionFactor - 1

			return math.max(result, -9)
		end
	},
	[3132] = {
		formula = function(lv)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = -2.407e-05 * math.pow(calcLv, 3) + 0.00013224 * math.pow(calcLv, 2) + 0.00176923 * calcLv + 3.80233046
			else
				regressionFactor = 3.1224e-07 * math.pow(calcLv, 4) - 6.51021e-05 * math.pow(calcLv, 3) + 0.0057853766 * math.pow(calcLv, 2) - 0.2870341189 * calcLv + 7.832778878
			end

			result = 1 - regressionFactor

			return math.max(result, -9)
		end
	},
	[3133] = {
		formula = function(lv, ttk, speciesRate, allin, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.6
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 5.5e-07 * math.pow(calcLv, 3) - 3.46e-06 * math.pow(calcLv, 2) - 3.547e-05 * calcLv + 0.08198255
			else
				regressionFactor = 7.49e-09 * math.pow(calcLv, 5) - 1.9723e-06 * math.pow(calcLv, 4) + 0.0001942808 * math.pow(calcLv, 3) - 0.0088101791 * math.pow(calcLv, 2) + 0.1884256915 * calcLv - 1.4456301243
			end

			result = regressionFactor * ttk * allin * speciesRate * elementFactor

			return math.max(result, 0.01)
		end
	},
	[3134] = {
		formula = function(lv, rate, speciesRate)
			local result
			local calcLv = math.min(70, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 4.9e-07 * math.pow(calcLv, 3) - 1.079e-05 * math.pow(calcLv, 2) + 6.463e-05 * calcLv + 0.47490272
			else
				regressionFactor = 9.818e-08 * math.pow(calcLv, 4) - 2.66152e-05 * math.pow(calcLv, 3) + 0.0023953923 * math.pow(calcLv, 2) - 0.0786456644 * calcLv + 1.3154720378
			end

			result = regressionFactor * rate * speciesRate

			return math.max(result, 0.01)
		end
	},
	[3135] = {
		formula = function(lv, rate, speciesRate)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 4.84e-06 * math.pow(calcLv, 3) - 0.00010746 * math.pow(calcLv, 2) + 0.00064381 * calcLv + 2.3989532
			else
				regressionFactor = 1.07656e-06 * math.pow(calcLv, 4) - 0.0002421522 * math.pow(calcLv, 3) + 0.0187948609 * math.pow(calcLv, 2) - 0.5601967975 * calcLv + 8.0048658842
			end

			result = regressionFactor * rate * speciesRate

			return math.max(result, -9999)
		end
	},
	[3151] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(70, math.max(1, lv))

			result = rate + 0.008 * (calcLv - 20)

			return math.max(result, -0.9)
		end
	},
	[3152] = {
		formula = function(lv, base, levelget, minlevel)
			local result
			local calcLv = math.min(70, math.max(1, lv))

			result = base + levelget * (calcLv - minlevel)

			return math.max(result, 0)
		end
	},
	[3153] = {
		formula = function(lv, base, levelget, minlevel)
			local result
			local calcLv = math.min(70, math.max(30, lv))

			result = base * math.min(calcLv - minlevel, 1) + levelget * (calcLv - minlevel)

			return math.min(result, 0)
		end
	},
	[3161] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result
			local calcplayerLv = math.min(70, math.max(1, playerLv))
			local calcplayerBotLv = math.min(70, math.max(1, playerBotLv))

			result = calcplayerLv - calcplayerBotLv

			return 10
		end
	},
	[3162] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 40 then
					result = math.max(0, calcPetLv - 4 - defaultBotLv)
				elseif defaultBotLv > 30 then
					result = math.max(0, calcPetLv - 5 - defaultBotLv)
				else
					result = math.max(0, calcPetLv - 6 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3163] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 40 then
					result = math.max(0, calcPetLv - 2 - defaultBotLv)
				elseif defaultBotLv > 30 then
					result = math.max(0, calcPetLv - 3 - defaultBotLv)
				else
					result = math.max(0, calcPetLv - 4 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3164] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 40 then
					result = math.max(0, calcPetLv - 1 - defaultBotLv)
				elseif defaultBotLv > 30 then
					result = math.max(0, calcPetLv - 2 - defaultBotLv)
				else
					result = math.max(0, calcPetLv - 3 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3165] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 50 then
					result = math.max(0, calcPetLv + 2 - defaultBotLv)
				else
					result = math.max(0, calcPetLv + 1 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3166] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 50 then
					result = math.max(0, calcPetLv + 3 - defaultBotLv)
				else
					result = math.max(0, calcPetLv + 2 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3167] = {
		formula = function(titleLv, playerLv, playerBotLv)
			local result = 0

			if titleLv >= 3 then
				local calcPetLv = math.max(1, titleLv * 5 + 20)
				local defaultBotLv = math.max(1, math.max(1, playerBotLv or 0))

				if defaultBotLv > 50 then
					result = math.max(0, calcPetLv + 4 - defaultBotLv)
				else
					result = math.max(0, calcPetLv + 3 - defaultBotLv)
				end
			end

			return result
		end
	},
	[3198] = {
		formula = function(bpDamFixRate, bpAtkRatio, bpReduceRate, bpAddRatio, elementDamageFactor, elementDamageAddRatio, skillDamageRatio, pvpDmg, robEggDmg, buffBreak)
			local result

			result = math.max(buffBreak * bpDamFixRate * bpAtkRatio * bpAddRatio * bpReduceRate * math.max(1, elementDamageFactor) * elementDamageAddRatio * robEggDmg, 0)

			return result
		end
	},
	[3199] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(70, math.max(1, lv))
			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.02573758 * math.pow(calcLv, 3) - 0.5835786 * math.pow(calcLv, 2) + 441.14654558 * calcLv + 2547.43770118
			else
				regressionFactor = 0.00404556968 * math.pow(calcLv, 4) - 1.1860574492 * math.pow(calcLv, 3) + 117.9291025139 * math.pow(calcLv, 2) - 3745.5066661239 * calcLv + 49981.2914841176
			end

			result = regressionFactor * rate

			return math.max(result, 100)
		end
	},
	[3401] = {
		formula = function(def_cur, calcValueByFormula)
			return math.floor((math.min(1.2, 0.002 * def_cur) or 0) * calcValueByFormula)
		end
	},
	[3501] = {
		formula = function(level, a1, b1, floorValue, warningRate)
			local calcLevel = math.max(1, level)
			local value = a1 * calcLevel + b1

			return math.max(value, floorValue) * (warningRate or 1)
		end
	},
	[3502] = {
		formula = function(level, splitLevel, a1, b1, a2, b2, warningRate)
			local calcLevel = math.max(1, level)
			local value

			if calcLevel <= splitLevel then
				value = a1 * calcLevel + b1
			else
				value = a2 * calcLevel + b2
			end

			return math.max(0, value * (warningRate or 1))
		end
	},
	[3511] = {
		formula = function(level, arg1, arg2)
			return (level * level * 0 + level * 40 + 200) * arg1 / 3000 + 1000
		end
	},
	[3601] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (0.0885694 * math.pow(calcLv, 2) - 0.853354 * calcLv + 1.2535817) * rate

			return math.max(result, 0)
		end
	},
	[3602] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = (0.0093981 * math.pow(calcLv, 2) + 0.612407 * calcLv - 4.791711) * rate

			return math.max(result, 0)
		end
	},
	[3603] = {
		formula = function(lv, rate)
			local result
			local calcLv = math.min(60, math.max(1, lv))

			result = 33 * calcLv * rate

			return math.max(result, 0)
		end
	},
	[4001] = {
		formula = function(height, mathFloorFun)
			return math.min(1, (math.max(0, height - 15) / 85)^2)
		end
	},
	[4002] = {
		formula = function(mLv)
			return math.max(1, mLv - 5)
		end
	},
	[4003] = {
		formula = function(curHP, maxHp)
			local hpPercent = curHP / maxHp

			if hpPercent < 0.1 then
				return 2 - 7 * hpPercent
			elseif hpPercent < 0.8 then
				return 1.3 - 0.4 * hpPercent
			else
				return math.max(0.8, 1.8 - hpPercent)
			end
		end
	},
	[4004] = {
		formula = function(targetLv, playerLv, masterLevel, catchLevel)
			local dif = targetLv - playerLv
			local result = 1

			if dif >= 15 then
				result = 0.1
			elseif dif > 10 then
				result = 1 - 0.2 * (dif - 10)
			end

			return result
		end
	},
	[5000] = {
		formula = function(ratio, breedTotalCount, noMutationTalentAcc)
			local notYetMutationed = breedTotalCount == noMutationTalentAcc

			if notYetMutationed and breedTotalCount + 1 >= math.random(1, 3) then
				return 1
			end

			return ratio
		end
	},
	[5001] = {
		formula = function(ratio, breedTotalCount, noMutationFlashAcc, rareTalentCount)
			local notYetMutationed = breedTotalCount == noMutationFlashAcc

			if notYetMutationed and rareTalentCount > 0 then
				return 1
			end

			return ratio
		end
	},
	[5002] = {
		formula = function(ballLv, ballLvDownRange, ballLvUpRange, targetLv, ballProbBase, catchLvUp, createPlentyProb, playerLevel)
			local result = ballProbBase

			if createPlentyProb ~= 1 then
				result = result * createPlentyProb
			end

			return result
		end
	},
	[5999] = {
		formula = function(ownerLv, minLevel, maxLevel)
			local randomLevel = math.random(minLevel or 0, maxLevel or 0)
			local result = (ownerLv or 1) + randomLevel

			return result
		end
	},
	[6000] = {
		formula = function(starLevel, minLevel, maxLevel, lv)
			local resultMinLevel = (lv or 0) + minLevel
			local resultMaxLevel = (lv or 0) + maxLevel
			local baseLevel = math.max(10, starLevel * 10 - 5 - math.max(0, starLevel - 4) * 5)

			if resultMinLevel < baseLevel then
				resultMinLevel = baseLevel - 10 + math.round(resultMinLevel / baseLevel * 10)
			end

			if resultMaxLevel < baseLevel then
				resultMaxLevel = baseLevel - 10 + math.round(resultMaxLevel / baseLevel * 10)
			end

			resultMinLevel = math.max(1, resultMinLevel)
			resultMaxLevel = math.max(1, resultMaxLevel)

			return resultMinLevel, resultMaxLevel
		end
	},
	[6001] = {
		formula = function(starLevel, lv, isGroupDead)
			local resultMinLevel = 1
			local resultMaxLevel = 1

			if isGroupDead then
				resultMinLevel = math.max(lv or 1, starLevel * 10 - 5 - math.max(0, starLevel - 4) * 5)
				resultMaxLevel = math.max(lv or 1, starLevel * 10 - 5 - math.max(0, starLevel - 4) * 5)
			else
				resultMinLevel = lv or 1
				resultMaxLevel = lv or 1
			end

			return resultMinLevel, resultMaxLevel
		end
	},
	[6002] = {
		formula = function(chooseType, type, difficulty, progress)
			local resultWeight = 0

			if chooseType == type then
				resultWeight = 3 * (1 - progress) / difficulty
			else
				resultWeight = 1 * (1 - progress) / difficulty
			end

			return resultWeight
		end
	},
	[6003] = {
		formula = function(rejectmeetnum, inscene, inteam, battlestate, challengebossnum, passedbossnum, passedresearchtraitnum, itemgetnum)
			local resultWeight
			local rejectFactor = math.max(0, 1 - rejectmeetnum / 3)
			local bossFactor
			local researchFactor = math.min(1, passedresearchtraitnum / 100)
			local itemFactor = math.min(1, itemgetnum / 100)

			bossFactor = challengebossnum == 0 and 0.1 or math.min(1, passedbossnum * 0.1 + 0.5 * passedbossnum / challengebossnum)
			resultWeight = (not inscene or inteam or battlestate) and 0 or rejectFactor * (bossFactor + 0.25 * researchFactor + 0.25 * itemFactor)

			return resultWeight
		end
	},
	[6004] = {
		formula = function(lv, targetLv, gender, targetGender, targetValue)
			local resultWeight = 0
			local lvFactor = math.max(0, math.min(1, 0.5 + 0.1 * (targetLv - lv)))
			local genderFactor = 1

			if gender ~= targetGender then
				genderFactor = 1.5
			end

			resultWeight = lvFactor * genderFactor * targetValue

			return resultWeight
		end
	},
	[6005] = {
		formula = function(rejectmeetnum, inteam, battlestate, rejectteamnum)
			local resultWeight
			local rejectFactor = math.max(0, 1 - rejectmeetnum / 3) * math.max(0, 1 - rejectteamnum / 3)

			resultWeight = (inteam or battlestate) and 0 or rejectFactor

			return resultWeight
		end
	},
	[6006] = {
		formula = function(lv, targetLv, melodygender, targetGender, targetValue)
			local resultWeight = 0
			local lvFactor = math.max(0, math.min(1, 0.5 + 0.1 * math.abs(targetLv - lv)))
			local genderFactor = 1

			if melodygender ~= 0 and melodygender ~= targetGender then
				genderFactor = 0
			end

			resultWeight = lvFactor * genderFactor * targetValue

			return resultWeight
		end
	},
	[6007] = {
		formula = function(temperature, light, rt, rl)
			if rt ~= 0 and rl ~= 0 then
				if temperature == rt and light == rl then
					return 0.5
				end

				return 0
			end

			if rt ~= 0 or rl ~= 0 then
				if temperature ~= 0 and temperature == rt or light ~= 0 and light == rl then
					return 0.5
				end

				return 0
			end

			return 0
		end
	},
	[6008] = {
		formula = function(gender, recentteamupnum, recentinsamehomepark, targetGender, targetRecentinsamehomepark)
			local score = 0
			local recentteamupnumScore = 10 * recentteamupnum
			local genderFactor = 0
			local recentinsamehomeparkFactor = 0

			if recentinsamehomepark == targetRecentinsamehomepark then
				recentinsamehomeparkFactor = 1
			end

			if gender ~= targetGender then
				genderFactor = 1
			end

			score = genderFactor * 100 + recentinsamehomeparkFactor * 100 + recentteamupnumScore

			return score
		end
	},
	[6009] = {
		formula = function(expectValue, actualValue, lastActualValue, lastFixedValue, dayEndTm, nowTm, t0, localHour)
			local function toNonNegativeInteger(value)
				value = tonumber(value) or 0

				if value ~= value then
					return 0
				end

				return math.floor(math.max(0, value))
			end

			expectValue = toNonNegativeInteger(expectValue)
			actualValue = toNonNegativeInteger(actualValue)
			lastActualValue = toNonNegativeInteger(lastActualValue)
			lastFixedValue = toNonNegativeInteger(lastFixedValue)
			dayEndTm = tonumber(dayEndTm)
			nowTm = tonumber(nowTm)
			t0 = tonumber(t0)
			localHour = tonumber(localHour)

			local actualGrowth = math.max(0, actualValue - lastActualValue)
			local algorithmGrowth = 0

			if actualValue < expectValue and dayEndTm and nowTm and t0 and t0 > 0 and nowTm < dayEndTm then
				local remainingPeriods = math.max(1, (dayEndTm - nowTm) / t0)
				local alpha = 0.3
				local randomRate = 1 - alpha + math.random() * (2 * alpha)
				local beta = 1

				if localHour and localHour >= 0 and localHour < 8 then
					beta = 0.1
				end

				local gap = math.max(0, expectValue - lastFixedValue)

				algorithmGrowth = math.floor(gap / remainingPeriods * randomRate * beta)
			end

			return math.floor(math.max(0, lastFixedValue + math.max(actualGrowth, algorithmGrowth)))
		end
	},
	[6010] = {
		formula = function(baseValue, label, formQuality, rating)
			local result
			local factor = 1

			if label % 2 == 1 then
				factor = factor + 0.5
			end

			if formQuality == 6 then
				factor = factor + 0.5
			end

			result = baseValue * factor

			return result
		end
	},
	[9001] = {
		formula = function(duration, deltaTime)
			if duration == -1 then
				duration = 10
			end

			if deltaTime <= 1 then
				duration = duration * 0.1
				duration = math.max(duration, 1)
			elseif deltaTime <= 3 then
				duration = duration * 0.5
				duration = math.max(duration, 3)
			elseif deltaTime <= 5 then
				duration = duration * 0.9
				duration = math.max(duration, 3)
			end

			return duration
		end
	},
	[13025] = {
		formula = function(hp_max_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 2.5e-05 * hp_max_cur) or 0) * calcValueByFormula
		end
	},
	[13026] = {
		formula = function(atk_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 0.0005 * atk_cur) or 0) * calcValueByFormula
		end
	},
	[13027] = {
		formula = function(def_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 0.001 * def_cur) or 0) * calcValueByFormula
		end
	},
	[13028] = {
		formula = function(def_mag_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 0.001 * def_mag_cur) or 0) * calcValueByFormula
		end
	},
	[13029] = {
		formula = function(ep_regen_force_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 0.0008 * ep_regen_force_cur) or 0) * calcValueByFormula
		end
	},
	[13030] = {
		formula = function(bp_atk_cur, calcValueByFormula)
			return (math.min(1.2, 0.8 + 0.0006666666666666668 * bp_atk_cur) or 0) * calcValueByFormula
		end
	},
	[23025] = {
		formula = function(hp_max_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 1.25e-05 * hp_max_cur) or 0) * calcValueByFormula
		end
	},
	[23026] = {
		formula = function(atk_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 0.00025 * atk_cur) or 0) * calcValueByFormula
		end
	},
	[23027] = {
		formula = function(def_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 0.0005 * def_cur) or 0) * calcValueByFormula
		end
	},
	[23028] = {
		formula = function(def_mag_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 0.0005 * def_mag_cur) or 0) * calcValueByFormula
		end
	},
	[23029] = {
		formula = function(ep_regen_force_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 0.0004 * ep_regen_force_cur) or 0) * calcValueByFormula
		end
	},
	[23030] = {
		formula = function(bp_atk_cur, calcValueByFormula)
			return (math.min(1.2, 1 + 0.0003333333333333334 * bp_atk_cur) or 0) * calcValueByFormula
		end
	},
	[31051] = {
		formula = function(lv, rate, ttk, bloodlust, needCounter)
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.2
			end

			local levelFactor = 1

			if lv >= 45 and lv <= 54 then
				levelFactor = 0.9
			elseif lv > 54 then
				levelFactor = 0.85
			end

			local result = 76.53061224 / rate / ttk / bloodlust * elementFactor * levelFactor - 1

			return math.max(result, -0.9)
		end
	},
	[31101] = {
		formula = function(lv, ttk, noBig, needCounter)
			local result
			local calcLv = math.min(80, math.max(1, lv))
			local elementFactor = 1

			if needCounter == 1 then
				elementFactor = 1.4
			end

			local levelFactor = 1

			if calcLv >= 20 and calcLv < 30 then
				levelFactor = 0.85
			elseif calcLv >= 30 and calcLv < 38 then
				levelFactor = 0.75
			end

			local regressionFactor

			if calcLv <= 20 then
				regressionFactor = 0.00033478 * math.pow(calcLv, 3) - 0.00638831 * math.pow(calcLv, 2) + 9.16772211 * calcLv + 53.25878512
			else
				regressionFactor = 1.79869e-05 * math.pow(calcLv, 4) - 0.0116044223 * math.pow(calcLv, 3) + 1.4768265884 * math.pow(calcLv, 2) - 43.5365263699 * calcLv + 619.0788382776
			end

			result = regressionFactor * ttk * noBig * elementFactor * levelFactor

			return math.max(result, 0.01)
		end
	}
}

return data
