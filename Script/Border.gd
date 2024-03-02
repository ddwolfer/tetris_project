extends Node

class_name border

# const variables
var BORDER_HEIGHT:int = 20
var BORDER_WIDTH:int  = 10

# variables
@export var m_fallSpeed:float = 1
var m_playfield = []
var m_tetroThisTurn = []
var m_tetrominoFactor = preload("Tetromino.gd").new()
var m_startPos = { "x" = 3.5 * TetrominoDefine.BLOCK_WIDTH,  "y" = -(BORDER_HEIGHT - 0.5) * TetrominoDefine.BLOCK_HEIGHT }
@onready var m_timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	init_variable()
	getNextTetromino()
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
	
	# 落下時間
	m_timer.wait_time = m_fallSpeed

# 拿下一個方塊
func getNextTetromino():
	m_tetroThisTurn = m_tetrominoFactor.CreateRandomTetro()
	print(m_tetroThisTurn)
	# 開始定時執行
	m_timer.start()
	pass

func fallTetrominoThisTurn():
	var blockNode = null
	for idx in range(m_tetroThisTurn.size()):
		blockNode = m_tetroThisTurn[idx]
		blockNode.position.y = blockNode.position.y + 64
		pass
	

func _on_timer_timeout():
	if m_tetroThisTurn.size() <= 0:
		return
	fallTetrominoThisTurn()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(_event):
	if Input.is_action_just_pressed("confirm"):
		print("按下確認")
	pass
