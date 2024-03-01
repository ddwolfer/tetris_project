extends Node

#var TETROMINO_WIDTH = 4
#var TETROMINO_HEIGHT = 4

var BLOCK_WIDTH = 64
var BLOCK_HEIGHT = 64

var NORMAL_TETROMINO = [
	# 長條 I 
	{
		spr = "res://Resource/img/Cyan.png",
		cellsVector = [
			[1, 1, 1, 1],
		]
	},
	# J
	{
		spr = "res://Resource/img/Blue.png",
		cellsVector = [
			[1, 0, 0, 0],
			[1, 1, 1, 0]
		]
	},
	# L
	{
		spr = "res://Resource/img/Orange.png",
		cellsVector = [
			[0, 0, 1, 0],
			[1, 1, 1, 0]
		]
	},
	# O
	{
		spr = "res://Resource/img/Yellow.png",
		cellsVector = [
			[0, 1, 1, 0],
			[0, 1, 1, 0]
		]
	},
	# S
	{
		spr = "res://Resource/img/Green.png",
		cellsVector = [
			[0, 1, 1, 0],
			[1, 1, 0, 0]
		]
	},
	# T
	{
		spr = "res://Resource/img/Purple.png",
		cellsVector = [
			[0, 1, 0, 0],
			[1, 1, 1, 0]
		]
	},
	# Z
	{
		spr = "res://Resource/img/Red.png",
		cellsVector = [
			[1, 1, 0, 0],
			[0, 1, 1, 0]
		]
	},
]
