extends Node

class_name border

# const variables
var BORDER_HEIGHT:int = 20
var BORDER_WIDTH:int  = 10
var MAX_FALL_SPEED:float  = 0.1
var MIN_FALL_SPEED:float  = 2

# variables
var m_fallSpeed:float = MIN_FALL_SPEED
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
	for row in range(BORDER_HEIGHT):
		var colData = []
		for col in range(BORDER_WIDTH):
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
		var tetroPos = getTetroRowColWithNode(block)
		m_playfield[tetroPos["row"]][tetroPos["col"]] = block

# 回傳 目前方塊在哪行哪列 (start with 0)
func getTetroRowColWithNode(tetroNode:Node2D)->Dictionary:
	var row:int = 0
	var col:int = 0
	
	row = int(float(tetroNode.position.y - (TetrominoDefine.BLOCK_HEIGHT / 2.0)) / float(TetrominoDefine.BLOCK_HEIGHT) ) * -1 - 1
	col = int(float(tetroNode.position.x - (TetrominoDefine.BLOCK_WIDTH / 2.0)) / float(TetrominoDefine.BLOCK_WIDTH))
	
	return {"row":row, "col":col}

# 落下本輪的方塊
func fallTetrominoThisTurn():
	for row in range(m_playfield.size()):
		for col in range(m_playfield[row].size()):
			var blockNode = m_playfield[row][col]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法下降 (事前應該會先判斷)
			if m_playfield[row-1][col]:
				return
			blockNode.position.y = blockNode.position.y + TetrominoDefine.BLOCK_HEIGHT
			m_playfield[row-1][col] = blockNode
			m_playfield[row][col] = false
# 往左跑
func moveTetroLeft():
	for col in range(m_playfield[0].size()):
		for row in range(m_playfield.size()):
			var blockNode = m_playfield[row][col]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法往左
			if col <= 0:
				return
			if m_playfield[row][col - 1]:
				return
			blockNode.position.x = blockNode.position.x - TetrominoDefine.BLOCK_WIDTH
			m_playfield[row][col - 1] = blockNode
			m_playfield[row][col] = false
# 往右跑
func moveTetroRight():
	for _row in range(m_playfield[0].size()):
		for row in range(m_playfield.size()):
			var col = m_playfield[0].size() - _row - 1
			var blockNode = m_playfield[row][col]
			if not blockNode:
				continue
			# 如果不是本輪的
			if not blockNode in m_tetroThisTurn:
				continue
			# 如果無法往右
			if col >= (m_playfield[0].size() - 1):
				return
			if m_playfield[row][col + 1]:
				return
			blockNode.position.x = blockNode.position.x + TetrominoDefine.BLOCK_WIDTH
			m_playfield[row][col + 1] = blockNode
			m_playfield[row][col] = false

func setFallSpeed(speed): 
	m_fallSpeed = speed
	m_timer.wait_time = m_fallSpeed
	m_timer.start()

# 計算方塊轉向後要在哪邊
func getBlockRotatePos(blockPos:Dictionary, anchorPos:Dictionary)->Dictionary:
	var newRow = 0
	var newCol = 0
	var _col = blockPos["row"] - anchorPos["row"]
	var _row = blockPos["col"] - anchorPos["col"]
	# 不用計算象限的
	if _col == 0 or _row == 0:
		if _row != 0 and _col == 0 :
			newRow = _row * -1
			newCol = 0
		elif _row == 0 and _col != 0:
			newRow = 0
			newCol = _col
		return {"row": newRow + anchorPos["row"], "col": newCol + anchorPos["col"]}
	
	# 對應象限更改
	if _row > 0 and _col > 0:  # 第一象限
		newCol = _col
		newRow = _row * -1
	elif _row > 0 and _col < 0:  # 第二象限
		newCol = _col 
		newRow = _row * -1
	elif _row < 0 and _col < 0 :  # 第三象限
		newCol = _col
		newRow = _row * -1
	elif _row < 0 and _col > 0:  # 第四象限
		newCol = _col 
		newRow = _row * -1
		
	return {"row": newRow + anchorPos["row"], "col": newCol + anchorPos["col"]}

# 轉向  大致流程為  1.算出新位置 2.確認新位置會不會壞掉 3.砍掉原有位置紀錄點 4.將方塊轉移到新位置並記錄在m_playfield上面
func rotateTetro():
	# 轉的時候撞到牆QQ
	var touchLeft = 0
	var touchRight = 0
	var touchTop = 0
	# 如果開方塊不能轉
	if not m_tetroDefineNow["rotate"]:
		return
	
	var anchorNodePos = getTetroRowColWithNode(m_tetroDefineNow["anchorNode"])
	var tempForPlaceNewBlock = []
	# 記住新轉向後的位置 把現在位置的紀錄刪掉
	for block in m_tetroThisTurn:
		var blockPos = getTetroRowColWithNode(block)
		# 中心點方塊不轉
		if block == m_tetroDefineNow["anchorNode"]:
			tempForPlaceNewBlock.append({"nextPos" : blockPos, "block": block})
			continue
		var nextPos = getBlockRotatePos(blockPos, anchorNodePos)
		tempForPlaceNewBlock.append({"nextPos" : nextPos, "block": block})
		# 避免撞牆
		if nextPos["row"] >= BORDER_HEIGHT - 1:
			touchTop = min(BORDER_HEIGHT - 1 - nextPos["row"], touchTop) 
		if nextPos["col"] > BORDER_WIDTH - 1:
			touchRight = min(BORDER_WIDTH - 1 - nextPos["col"], touchRight)
		elif nextPos["col"] < 0:
			touchLeft = max(-nextPos["col"], touchLeft)
	
	# 微調位置
	for blockInfo in tempForPlaceNewBlock:
		blockInfo["nextPos"]["col"] = blockInfo["nextPos"]["col"] + touchRight + touchLeft
		blockInfo["nextPos"]["row"] = blockInfo["nextPos"]["row"] + touchTop
	
	# 確認是否可轉
	if not checkRotateValidity(tempForPlaceNewBlock):
		return
	
	# 統一刪除
	for block in m_tetroThisTurn:
		var blockPos = getTetroRowColWithNode(block)
		m_playfield[blockPos["row"]][blockPos["col"]] = false
		
	# 寫入新位置方塊並重新Set position
	for setting in tempForPlaceNewBlock:
		var nextPos = setting["nextPos"]
		m_playfield[nextPos["row"]][nextPos["col"]] = setting["block"]
		setting["block"].position.x = (nextPos["col"] + 0.5) * TetrominoDefine.BLOCK_WIDTH
		setting["block"].position.y = (nextPos["row"] + 0.5) * TetrominoDefine.BLOCK_HEIGHT * -1
	
# 確認可轉不會壞
func checkRotateValidity(newBlockList:Array)->bool:
	for blockInfo in newBlockList:
		var _col = blockInfo["nextPos"]["col"]
		var _row = blockInfo["nextPos"]["row"]
		# 如果該格有方塊
		if m_playfield[_row][_col]:
			# 如果該格方塊不是目前這輪的(也就是撞到現有方塊)
			if not m_playfield[_row][_col] in m_tetroThisTurn:
				return false
	return true	

# 可以再往下
func checkCanFall()->bool:
	for block in m_tetroThisTurn:
		var pos = getTetroRowColWithNode(block)
		# 下面就是底
		if pos["row"] <= 0 :
			return false
		# 下面有其他方塊
		if m_playfield[pos["row"] - 1][pos["col"]] and not (m_playfield[pos["row"] - 1][pos["col"]] in m_tetroThisTurn):
			return false
				
	return true

# 遊戲是否結束
func checkIsEndGame()->bool:
	# 偵測最高那一排 index 3~7 有沒有方塊
	var maxCheck = 7
	var minCheck = 3
	for idx in range(minCheck, maxCheck):
		print(idx)
		if m_playfield[BORDER_HEIGHT-1][idx]:
			return true
	return false

# 確定有沒有要刪除的
func checkLineEliminate():
	for row in range(m_playfield.size()):
		var haveEmpty = false
		for block in m_playfield[row]:
			if not block:
				haveEmpty = true
		if not haveEmpty:
			eliminateLine(row)
			checkLineEliminate()
			return

# 刪除一列		
func eliminateLine(line:int):
	# 整列的方塊消失
	for col in range(m_playfield[line].size()):
		var block = m_playfield[line][col]
		self.remove_child(block)
		m_playfield[line][col] = false
	
	# 把上面的方塊通通下移
	for row in range(line, BORDER_HEIGHT):
		for col in range(BORDER_WIDTH):
			if not m_playfield[row][col]:
				continue
			var block = m_playfield[row][col]
			block.position.y = block.position.y + TetrominoDefine.BLOCK_HEIGHT
			m_playfield[row - 1][col] = m_playfield[row][col]
			m_playfield[row][col] = false

# 拿來落下用的
func _on_timer_timeout():
	if m_tetroThisTurn.size() <= 0:
		return
	if checkCanFall():
		fallTetrominoThisTurn()
	else:
		checkLineEliminate()
		m_timer.stop()
		m_tetroThisTurn.clear()
		if not checkIsEndGame():
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
	if Input.is_action_just_pressed("down"):
		setFallSpeed(MAX_FALL_SPEED)
	if Input.is_action_just_released("down"):
		setFallSpeed(MIN_FALL_SPEED)
