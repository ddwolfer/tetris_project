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

# 拿下一輪方塊
func getNextTetromino():
	m_tetroThisTurn = m_tetrominoFactor.CreateRandomTetro()
	# 開始定時執行
	m_timer.start()
	# 放入對應位置的 playfield 方便取用
	for block in m_tetroThisTurn:
		var tetroPos = getTetroColRowWithNode(block)
		m_playfield[tetroPos["col"]][tetroPos["row"]] = block

# 回傳 目前方塊在哪行哪列 (start with 0)
func getTetroColRowWithNode(tetroNode:Node2D)->Dictionary:
	var col:int = 0
	var row:int = 0
	
	col = int(float(tetroNode.position.y - (TetrominoDefine.BLOCK_HEIGHT / 2.0)) / float(TetrominoDefine.BLOCK_HEIGHT) ) * -1 - 1
	row = int(float(tetroNode.position.x - (TetrominoDefine.BLOCK_WIDTH / 2.0)) / float(TetrominoDefine.BLOCK_WIDTH))
	
	return {"col":col, "row":row}

# 落下本輪的方塊
func fallTetrominoThisTurn():
	for col in range(m_playfield.size()):
		for row in range(m_playfield[col].size()):
			var blockNode = m_playfield[col][row]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法下降 (事前應該會先判斷)
			if m_playfield[col-1][row]:
				return
			blockNode.position.y = blockNode.position.y + TetrominoDefine.BLOCK_HEIGHT
			m_playfield[col-1][row] = blockNode
			m_playfield[col][row] = false
# 往左跑
func moveTetroLeft():
	for row in range(m_playfield[0].size()):
		for col in range(m_playfield.size()):
			var blockNode = m_playfield[col][row]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法往左
			if row <= 0:
				return
			if m_playfield[col][row - 1]:
				return
			blockNode.position.x = blockNode.position.x - TetrominoDefine.BLOCK_WIDTH
			m_playfield[col][row - 1] = blockNode
			m_playfield[col][row] = false
# 往右跑
func moveTetroRight():
	for _row in range(m_playfield[0].size()):
		for col in range(m_playfield.size()):
			var row = m_playfield[0].size() - _row - 1
			var blockNode = m_playfield[col][row]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法往右
			if row >= (m_playfield[0].size() - 1):
				return
			if m_playfield[col][row + 1]:
				return
			blockNode.position.x = blockNode.position.x + TetrominoDefine.BLOCK_WIDTH
			m_playfield[col][row + 1] = blockNode
			m_playfield[col][row] = false

# 轉向
func rotateTetro():
	pass

func checkCanFall()->bool:
	var findBottomBlock = false
	for col in range(m_playfield.size()):
		if findBottomBlock:
			break
		for row in range(m_playfield[col].size()):
			var blockNode = m_playfield[col][row]
			if not blockNode in m_tetroThisTurn:
				continue
			# 找到該輪最下面一塊方塊了
			findBottomBlock = true
			var tetroPos = getTetroColRowWithNode(blockNode)
			# 是否到最底部(col)
			if tetroPos["col"] <= 0 :
				return false
			# 下面是否有別的方塊
			if m_playfield[tetroPos["col"] - 1][tetroPos["row"]]:
				return false
				
	return true

# 遊戲是否結束
func checkIsEndGame()->bool:
	
	return false

# 拿來落下用的
func _on_timer_timeout():
	if m_tetroThisTurn.size() <= 0:
		return
	if checkCanFall():
		fallTetrominoThisTurn()
	else:
		checkIsEndGame()
		m_timer.stop()
		m_tetroThisTurn.clear()
		getNextTetromino()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(_event):
	if Input.is_action_just_pressed("confirm"):
		print("按下確認")
	if Input.is_action_just_pressed("right"):
		moveTetroRight()
	if Input.is_action_just_pressed("left"):
		moveTetroLeft()
	if Input.is_action_just_pressed("up"):
		rotateTetro()
	pass
