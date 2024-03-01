extends Node

class_name border

# const variables
var BORDER_HEIGHT:int = 20
var BORDER_WIDTH:int  = 10

# variables
var m_playfield = []
var m_tetrominoFactor = preload("Tetromino.gd").new()
var m_startPos = { "x" = 3.5 * TetrominoDefine.BLOCK_WIDTH,  "y" = -(BORDER_HEIGHT - 0.5) * TetrominoDefine.BLOCK_HEIGHT }

# Called when the node enters the scene tree for the first time.
func _ready():
	init_variable()
	m_tetrominoFactor.CreateRandomTetro()
	pass # Replace with function body.

func init_variable():
	# 初始化盤面
	for col in range(BORDER_HEIGHT):
		var colData = []
		for row in range(BORDER_WIDTH):
			colData.append(false)
		m_playfield.append(colData)
	
	# 綁訂節點
	m_tetrominoFactor.setBorderNode(self)
	m_tetrominoFactor.setStartPos(m_startPos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(_event):
	if Input.is_action_just_pressed("confirm"):
		print("按下確認")
	pass
