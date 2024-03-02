extends Node

class_name border

# const variables
var BORDER_HEIGHT:int = 20
var BORDER_WIDTH:int  = 10

# variables
@export var m_fallSpeed:float = 1
var m_tetroDefineNow = null
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
	var res = m_tetrominoFactor.CreateRandomTetro()
	m_tetroThisTurn = res["blockAry"]
	m_tetroDefineNow = res["tetroDefine"]
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

# 計算方塊轉向後要在哪邊
func getBlockRotatePos(blockPos:Dictionary, anchorPos:Dictionary)->Dictionary:
	var newCol = 0
	var newRow = 0
	var _col = blockPos["col"] - anchorPos["col"]
	var _row = blockPos["row"] - anchorPos["row"]
	# 不用計算象限的
	if _col == 0 or _row == 0:
		if _row != 0 and _col == 0 :
			newCol = _row * -1
			newRow = 0
		elif _row == 0 and _col != 0:
			newCol = 0
			newRow = _col
		return {"col": newCol + anchorPos["col"], "row": newRow + anchorPos["row"]}
	
	# 對應象限更改
	if _row > 0 and _col > 0:  # 第一象限
		newRow = _col
		newCol = _row * -1
	elif _row > 0 and _col < 0:  # 第二象限
		newRow = _col 
		newCol = _row * -1
	elif _row < 0 and _col < 0 :  # 第三象限
		newRow = _col
		newCol = _row * -1
	elif _row < 0 and _col > 0:  # 第四象限
		newRow = _col 
		newCol = _row * -1
		
	return {"col": newCol + anchorPos["col"], "row": newRow + anchorPos["row"]}

# 轉向
func rotateTetro():
	# 轉的時候撞到牆QQ
	var touchLeft = 0
	var touchRight = 0
	var touchTop = 0
	# 如果開方塊不能轉
	if not m_tetroDefineNow["rotate"]:
		return
	
	var anchorNodePos = getTetroColRowWithNode(m_tetroDefineNow["anchorNode"])
	var tempForPlaceNewBlock = []
	# 記住新轉向後的位置 把現在位置的紀錄刪掉
	for block in m_tetroThisTurn:
		var blockPos = getTetroColRowWithNode(block)
		if block == m_tetroDefineNow["anchorNode"]:
			tempForPlaceNewBlock.append({"nextPos" : blockPos, "block": block})
			m_playfield[blockPos["col"]][blockPos["row"]] = false
			continue
		var nextPos = getBlockRotatePos(blockPos, anchorNodePos)
		tempForPlaceNewBlock.append({"nextPos" : nextPos, "block": block})
		m_playfield[blockPos["col"]][blockPos["row"]] = false
		
		if nextPos["col"] >= BORDER_HEIGHT - 1:
			touchTop = min(BORDER_HEIGHT - 1 - nextPos["col"], touchTop) 
		if nextPos["row"] > BORDER_WIDTH - 1:
			touchRight = -1
		elif nextPos["row"] < 0:
			touchLeft = 1
	
	# 寫入新位置方塊並重新Set position
	for setting in tempForPlaceNewBlock:
		var nextPos = setting["nextPos"]
		m_playfield[nextPos["col"] + touchTop][nextPos["row"] + touchRight + touchLeft] = setting["block"]
		setting["block"].position.x = (nextPos["row"] + touchRight + touchLeft + 0.5) * TetrominoDefine.BLOCK_WIDTH
		setting["block"].position.y = (nextPos["col"] + touchTop + 0.5) * TetrominoDefine.BLOCK_HEIGHT * -1
	

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
