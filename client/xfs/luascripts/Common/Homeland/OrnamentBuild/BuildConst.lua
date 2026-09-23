-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\OrnamentBuild\\BuildConst.lua

local BuildConst = {}
local bit = bit

BuildConst.OrnamentAttachType = {
	Down = 2,
	Up = 1,
	None = 0,
	Slope = 4,
	Wall = 3
}
BuildConst.AttachPlaneType = {
	Down = 2,
	Up = 1,
	None = 0,
	Left = 4,
	Front = 3,
	Right = 5,
	Slope = 7,
	Back = 6
}
BuildConst.AttachEffectOffsetY = 0.02
BuildConst.DirectionType = {
	Down = 2,
	Back = 4,
	Right = 6,
	Left = 5,
	Front = 3,
	Up = 1
}
BuildConst.DirFitType = {
	RightFit = 8,
	LeftFit = 4,
	BackFit = 2,
	FrontFit = 1,
	Default = 0,
	NoCross = bit.bor(1, 2),
	Cross = bit.bor(4, 8),
	FrontOrLeftFit = bit.bor(1, 4),
	FrontOrRightFit = bit.bor(1, 8),
	BackOrLeftFit = bit.bor(2, 4),
	BackOrRightFit = bit.bor(2, 8),
	ExceptFrontFit = bit.bor(2, 4, 8),
	ExceptBackFit = bit.bor(1, 4, 8),
	ExceptLeftFit = bit.bor(1, 2, 8),
	ExceptRightFit = bit.bor(1, 2, 4)
}
BuildConst.BuildType = {
	TileRidge = 7,
	Tile = 6,
	HandrailFlat = 5,
	HandrailSlope = 4,
	Stair = 3,
	Floor = 1,
	None = 0,
	TileCorner = 8,
	HandrailPillar = 11,
	Brick = 10,
	Pillar = 9,
	Wall = 2
}
BuildConst.LinkSocketPresetType = {
	HandrailSlopeStart = 21,
	HandrailSlopeDown = 20,
	StairCenterDown = 9,
	StairHandRailSocket = 8,
	StairEnd = 7,
	StairStart = 6,
	StairEdge = 5,
	WallBottom = 4,
	WallTop = 3,
	WallEdge = 2,
	FloorEdge = 1,
	BrickDown = 122,
	BrickTop = 121,
	BrickEdge = 120,
	WallSlopRightUp = 111,
	WallSlopLeftUp = 110,
	FloorCenterDown = 102,
	FloorCenterUp = 101,
	FloorCorner = 100,
	HandrailPillarCenter = 93,
	PillarCenter = 92,
	PillarUp = 91,
	PillarDown = 90,
	TileCornerRight = 64,
	TileCornerLeft = 63,
	TileCornerBack = 61,
	TileCornerFront = 60,
	TileRidgeEdge = 51,
	TileRidgeSide = 50,
	TileDown = 43,
	TileEdge = 42,
	TileEnd = 41,
	TileStart = 40,
	HandrailFlatEnd = 32,
	HandrailFlatStart = 31,
	HandrailFlatDown = 30,
	HandrailSlopeEnd = 22
}

local DirType = BuildConst.DirectionType
local PresetType = BuildConst.LinkSocketPresetType
local BuildType = BuildConst.BuildType
local DirFitType = BuildConst.DirFitType

BuildConst.SocketDirMatchInfo = {
	[DirType.Front] = DirType.Back,
	[DirType.Back] = DirType.Front,
	[DirType.Left] = DirType.Right,
	[DirType.Right] = DirType.Left,
	[DirType.Up] = DirType.Down,
	[DirType.Down] = DirType.Up
}
BuildConst.DirVectorInfo = {
	[DirType.Up] = {
		0,
		1,
		0
	},
	[DirType.Down] = {
		0,
		-1,
		0
	},
	[DirType.Front] = {
		0,
		0,
		1
	},
	[DirType.Back] = {
		0,
		0,
		-1
	},
	[DirType.Left] = {
		-1,
		0,
		0
	},
	[DirType.Right] = {
		1,
		0,
		0
	}
}
BuildConst.DirConvertInfo = {
	[DirType.Front] = {
		[DirType.Front] = DirType.Front,
		[DirType.Left] = DirType.Left,
		[DirType.Right] = DirType.Right,
		[DirType.Back] = DirType.Back,
		[DirType.Up] = DirType.Up,
		[DirType.Down] = DirType.Down
	},
	[DirType.Right] = {
		[DirType.Front] = DirType.Right,
		[DirType.Right] = DirType.Back,
		[DirType.Back] = DirType.Left,
		[DirType.Left] = DirType.Front,
		[DirType.Up] = DirType.Up,
		[DirType.Down] = DirType.Down
	},
	[DirType.Back] = {
		[DirType.Front] = DirType.Back,
		[DirType.Right] = DirType.Left,
		[DirType.Back] = DirType.Front,
		[DirType.Left] = DirType.Right,
		[DirType.Up] = DirType.Up,
		[DirType.Down] = DirType.Down
	},
	[DirType.Left] = {
		[DirType.Front] = DirType.Left,
		[DirType.Right] = DirType.Front,
		[DirType.Back] = DirType.Right,
		[DirType.Left] = DirType.Back,
		[DirType.Up] = DirType.Up,
		[DirType.Down] = DirType.Down
	}
}
BuildConst.LinkPresetData = {
	[PresetType.FloorEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Stair] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.StairStart] = {},
							[PresetType.StairEnd] = {}
						}
					}
				}
			},
			[DirType.Up] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					}
				},
				checkDirType = DirType.Front
			},
			[DirType.Down] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					}
				},
				checkDirType = DirType.Front
			}
		},
		mainDirTypes = {
			DirType.Front,
			DirType.Up
		}
	},
	[PresetType.FloorCorner] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			},
			[DirType.Down] = {
				socketData = {
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			}
		},
		mainDirTypes = {
			DirType.Up,
			DirType.Down
		}
	},
	[PresetType.FloorCenterUp] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.FloorCenterDown] = {}
						}
					}
				},
				srcBuildTypeStrict = {
					[BuildType.Stair] = {},
					[BuildType.Floor] = {}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.FloorCenterDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.FloorCenterUp] = {}
						}
					}
				}
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.WallEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.PillarCenter] = {}
						}
					}
				}
			},
			[DirType.Left] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.PillarCenter] = {}
						}
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.PillarCenter] = {}
						}
					}
				}
			}
		}
	},
	[PresetType.WallTop] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Tile] = {
						dirFitType = DirFitType.NoCross,
						targetSocketPresetStrict = {
							[PresetType.TileDown] = {}
						}
					}
				},
				checkDirType = DirType.Front
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.WallSlopLeftUp] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.LeftFit,
						targetSocketPresetStrict = {
							[PresetType.TileDown] = {}
						}
					}
				},
				checkDirType = DirType.Front,
				srcBuildTypeStrict = {
					[BuildType.Tile] = {}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.WallSlopRightUp] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.RightFit,
						targetSocketPresetStrict = {
							[PresetType.TileDown] = {}
						}
					}
				},
				checkDirType = DirType.Front,
				srcBuildTypeStrict = {
					[BuildType.Tile] = {}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.WallBottom] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Wall] = {
						dirFitType = DirFitType.NoCross
					}
				},
				checkDirType = DirType.Front
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.StairEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Stair] = {
						dirFitType = DirFitType.FrontFit
					}
				},
				checkDirTypeEnt = DirType.Front
			},
			[DirType.Up] = {
				socketData = {},
				srcBuildTypeStrict = {
					[BuildType.HandrailSlope] = {}
				}
			}
		},
		mainDirTypes = {
			DirType.Front,
			DirType.Up
		}
	},
	[PresetType.StairStart] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Stair] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		}
	},
	[PresetType.StairEnd] = {
		dirData = {
			[DirType.Back] = {
				socketData = {
					[BuildType.Stair] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Back
	},
	[PresetType.StairHandRailSocket] = {
		dirData = {
			[DirType.Up] = {
				socketData = {},
				srcBuildTypeStrict = {
					[BuildType.HandrailSlope] = {}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.StairCenterDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.FloorCenterUp] = {}
						}
					}
				}
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.HandrailSlopeDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Stair] = {
						dirFitType = DirFitType.FrontFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.HandrailSlopeStart] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Left] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				},
				checkDirTypeEnt = DirType.Front
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		}
	},
	[PresetType.HandrailSlopeEnd] = {
		dirData = {
			[DirType.Back] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Left] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			}
		},
		mainDirType = DirType.Back
	},
	[PresetType.HandrailFlatDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Floor] = {
						dirFitType = DirFitType.Default
					}
				}
			}
		}
	},
	[PresetType.HandrailFlatStart] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Left] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			}
		}
	},
	[PresetType.HandrailFlatEnd] = {
		dirData = {
			[DirType.Back] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.FrontFit
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Left] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default
					},
					[BuildType.HandrailPillar] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailPillarCenter] = {}
						}
					}
				}
			}
		},
		mainDirType = DirType.Back
	},
	[PresetType.TileStart] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.Cross
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.FrontOrLeftFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		}
	},
	[PresetType.TileEnd] = {
		dirData = {
			[DirType.Back] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.Cross
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.BackOrLeftFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Back
	},
	[PresetType.TileEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.FrontFit
					},
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.Cross
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.FrontOrLeftFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		}
	},
	[PresetType.TileDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.WallSlopLeftUp] = {
								dirFitType = DirFitType.RightFit
							},
							[PresetType.WallSlopRightUp] = {
								dirFitType = DirFitType.LeftFit
							},
							[PresetType.WallTop] = {
								dirFitType = DirFitType.NoCross
							}
						}
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.TileRidgeEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.NoCross
					}
				},
				checkDirTypeEnt = DirType.Front,
				srcBuildTypeStrict = {
					[BuildType.TileRidge] = {}
				}
			}
		}
	},
	[PresetType.TileRidgeSide] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.NoCross
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.TileCornerBack] = {},
							[PresetType.TileCornerLeft] = {}
						}
					}
				},
				checkDirType = DirType.Front
			}
		}
	},
	[PresetType.TileCornerFront] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.RightFit
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.RightFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Front
	},
	[PresetType.TileCornerBack] = {
		dirData = {
			[DirType.Back] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.FrontFit
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.BackOrRightFit
					},
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.Cross
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Back
	},
	[PresetType.TileCornerLeft] = {
		dirData = {
			[DirType.Left] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.RightFit
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.BackOrLeftFit
					},
					[BuildType.TileRidge] = {
						dirFitType = DirFitType.NoCross
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Left
	},
	[PresetType.TileCornerRight] = {
		dirData = {
			[DirType.Right] = {
				socketData = {
					[BuildType.Tile] = {
						dirFitType = DirFitType.FrontFit
					},
					[BuildType.TileCorner] = {
						dirFitType = DirFitType.LeftFit
					}
				},
				checkDirTypeEnt = DirType.Front
			}
		},
		mainDirType = DirType.Right
	},
	[PresetType.PillarDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					}
				}
			}
		},
		mainDirType = DirType.Down
	},
	[PresetType.PillarUp] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Pillar] = {
						dirFitType = DirFitType.Default
					}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.PillarCenter] = {
		dirData = {
			[DirType.Left] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			},
			[DirType.Front] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			},
			[DirType.Back] = {
				socketData = {
					[BuildType.Wall] = {
						dirFitType = DirFitType.Default
					}
				}
			}
		}
	},
	[PresetType.HandrailPillarCenter] = {
		dirData = {
			[DirType.Left] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailSlopeStart] = {},
							[PresetType.HandrailSlopeEnd] = {}
						}
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailFlatStart] = {},
							[PresetType.HandrailFlatEnd] = {}
						}
					}
				}
			},
			[DirType.Right] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailSlopeStart] = {},
							[PresetType.HandrailSlopeEnd] = {}
						}
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailFlatStart] = {},
							[PresetType.HandrailFlatEnd] = {}
						}
					}
				}
			},
			[DirType.Front] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailSlopeStart] = {},
							[PresetType.HandrailSlopeEnd] = {}
						}
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailFlatStart] = {},
							[PresetType.HandrailFlatEnd] = {}
						}
					}
				}
			},
			[DirType.Back] = {
				socketData = {
					[BuildType.HandrailSlope] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailSlopeStart] = {},
							[PresetType.HandrailSlopeEnd] = {}
						}
					},
					[BuildType.HandrailFlat] = {
						dirFitType = DirFitType.Default,
						targetSocketPresetStrict = {
							[PresetType.HandrailFlatStart] = {},
							[PresetType.HandrailFlatEnd] = {}
						}
					}
				}
			}
		},
		mainDirTypes = {
			DirType.Left,
			DirType.Right,
			DirType.Front,
			DirType.Back
		}
	},
	[PresetType.BrickEdge] = {
		dirData = {
			[DirType.Front] = {
				socketData = {
					[BuildType.Brick] = {
						dirFitType = DirFitType.Default
					}
				},
				srcBuildTypeStrict = {
					[BuildType.Brick] = {}
				}
			}
		}
	},
	[PresetType.BrickTop] = {
		dirData = {
			[DirType.Up] = {
				socketData = {
					[BuildType.Brick] = {
						dirFitType = DirFitType.Default
					}
				},
				srcBuildTypeStrict = {
					[BuildType.Brick] = {}
				}
			}
		},
		mainDirType = DirType.Up
	},
	[PresetType.BrickDown] = {
		dirData = {
			[DirType.Down] = {
				socketData = {
					[BuildType.Brick] = {
						dirFitType = DirFitType.Default
					}
				},
				srcBuildTypeStrict = {
					[BuildType.Brick] = {}
				}
			}
		},
		mainDirType = DirType.Down
	}
}

function BuildConst.buildEnumOptionList(enumTable)
	local options = {
		{
			label = "无"
		}
	}
	local sorted = {}

	for name, value in pairs(enumTable) do
		sorted[#sorted + 1] = {
			name = name,
			value = value
		}
	end

	table.sort(sorted, function(a, b)
		return a.value < b.value
	end)

	for _, item in ipairs(sorted) do
		options[#options + 1] = {
			label = item.name,
			value = item.value
		}
	end

	return options
end

function BuildConst.getLinkSocketPresetOptionList()
	return BuildConst.buildEnumOptionList(BuildConst.LinkSocketPresetType)
end

function BuildConst.getLinkSocketDirOptionList()
	return BuildConst.buildEnumOptionList(BuildConst.DirectionType)
end

BuildConst.LINK_DEBUG_LINE_LEN = 0.6
BuildConst.LINK_DEBUG_CANDIDATE_MAIN_COLOR = {
	0,
	1,
	0
}
BuildConst.LINK_DEBUG_CANDIDATE_OTHER_COLOR = {
	1,
	1,
	1
}
BuildConst.LINK_DEBUG_SRC_COLOR = {
	0.4,
	0.7,
	1
}
BuildConst.LINK_DEBUG_SRC_SNAP_COLOR = {
	1,
	0.4,
	0.7
}
BuildConst.LINK_DEBUG_SRC_FILTERED_COLOR = {
	0,
	0,
	0
}
BuildConst.LINK_DEBUG_SRC_PRESET_STRICT_COLOR = {
	1,
	0.5,
	0
}

return BuildConst
