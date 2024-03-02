extends Node

class_name Tetromino

var BLOCK_FILE =  "res://Scenes/Game/Block.tscn"

var m_anchorNode = null
var m_borderNode = null
var m_startPos = {"x":0, "y":0}

var COLOR_LIST = [
	"res://Resource/img/Blue.png",
	"res://Resource/img/Cyan.png",
	"res://Resource/img/Green.png",
	"res://Resource/img/Orange.png",
	"res://Resource/img/Purple.png",
	"res://Resource/img/Red.png",
	"res://Resource/img/Yellow.png"
]

var BLOCK_PATH = "res://Scenes/Game/Block.tscn"
@onready var UI_ROOT = $Node

# Called when the node enters the scene tree for the first time.
func _ready():
	print("@@ddw ready")

func setBorderNode(BorderNode):
	m_borderNode = BorderNode

func setStartPos(startPos:Dictionary):
	m_startPos.x = startPos.x
	m_startPos.y = startPos.y

func CreateRandomTetro()->Dictionary:
	if not m_borderNode:
		return {}
	
	var ranblockDefine = TetrominoDefine.NORMAL_TETROMINO[ randi() % TetrominoDefine.NORMAL_TETROMINO.size() ]
	var tetroAry = CreateTetromino(ranblockDefine)
	ranblockDefine["anchorNode"] = m_anchorNode
	return {"blockAry": tetroAry, "tetroDefine": ranblockDefine}
	

func CreateTetromino(tetrominoSetting:Dictionary)->Array:
	var blockList = []
	var blockPos = tetrominoSetting.cellsVector
	var color = 0
	for col in range(blockPos.size()):
		for row in range(blockPos[col].size()):
			if blockPos[col][row] == 1:
				var newBlock = load(BLOCK_PATH).instantiate()
				newBlock.get_node("./Sprite2D").texture = load(tetrominoSetting["spr"])
				color = color + 1
				newBlock.position.x = row * TetrominoDefine.BLOCK_WIDTH + m_startPos.x
				newBlock.position.y = col * TetrominoDefine.BLOCK_HEIGHT + m_startPos.y
				blockList.append(newBlock)
				m_borderNode.add_child(newBlock)
				print(newBlock)
				if col == tetrominoSetting["achorPoint"][0] and row == tetrominoSetting["achorPoint"][1]:
					m_anchorNode = newBlock

	return blockList

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
