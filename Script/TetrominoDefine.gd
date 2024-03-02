extends Node

#var TETROMINO_WIDTH = 4
#var TETROMINO_HEIGHT = 4

var BLOCK_WIDTH = 64
var BLOCK_HEIGHT = 64

var NORMAL_TETROMINO = [
	# 長條 I 
	{
		spr = "res://Resource/img/Cyan.png",
		rotate = true,
		achorPoint = [0,1],
		cellsVector = [
			[1, 1, 1, 1],
		]
	},
	# J
	{
		spr = "res://Resource/img/Blue.png",
		rotate = true,
		achorPoint = [1,2],
		cellsVector = [
			[1, 0, 0],
			[1, 1, 1]
		]
	},
	# L
	{
		spr = "res://Resource/img/Orange.png",
		rotate = true,
		achorPoint = [1,2],
		cellsVector = [
			[0, 0, 1],
			[1, 1, 1]
		]
	},
	# O
	{
		spr = "res://Resource/img/Yellow.png",
		rotate = false,
		achorPoint = [0,0],
		cellsVector = [
			[1, 1],
			[1, 1]
		]
	},
	# S
	{
		spr = "res://Resource/img/Green.png",
		rotate = true,
		achorPoint = [1,2],
		cellsVector = [
			[0, 1, 1],
			[1, 1, 0]
		]
	},
	# T
	{
		spr = "res://Resource/img/Purple.png",
		rotate = true,
		achorPoint = [1,2],
		cellsVector = [
			[0, 1, 0],
			[1, 1, 1]
		]
	},
	# Z
	{
		spr = "res://Resource/img/Red.png",
		rotate = true,
		achorPoint = [1,2],
		cellsVector = [
			[1, 1, 0],
			[0, 1, 1]
		]
	},
]
