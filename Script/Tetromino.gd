extends Node

class_name Tetromino

var BLOCK_FILE =  "res://Scenes/Game/Block.tscn"

var m_borderNode = null
var m_startPos = {"x":0, "y":0}
var m_blockPool = []


@onready var BLOCK =  preload("res://Scenes/Game/Block.tscn")
@onready var RED_SPR = preload("res://Resource/img/Red.png")
@onready var UI_ROOT = $Node

# Called when the node enters the scene tree for the first time.
func _ready():
	print("@@ddw ready")

func setBorderNode(BorderNode):
	m_borderNode = BorderNode

func setStartPos(startPos:Dictionary):
	m_startPos.x = startPos.x
	m_startPos.y = startPos.y

func CreateRandomTetro()->bool:
	if not m_borderNode:
		return false
	
	var ranblockDefine = TetrominoDefine.NORMAL_TETROMINO[ randi() % 7 ]
	CreateTetromino(ranblockDefine)
	return true
	

func CreateTetromino(tetrominoSetting:Dictionary):
	var blockPos = tetrominoSetting.cellsVector
	for col in range(blockPos.size()):
		for row in range(blockPos[col].size()):
			if blockPos[col][row] == 1:
				print("found at col: %d row: %d" % [col, row])
				print("position should be y x : %d %d" % [col * TetrominoDefine.BLOCK_HEIGHT, row  * TetrominoDefine.BLOCK_WIDTH])
				var testSpr = Sprite2D.new()
				testSpr.texture = load(tetrominoSetting["spr"])
				testSpr.position.x = row * TetrominoDefine.BLOCK_WIDTH + m_startPos.x
				testSpr.position.y = col * TetrominoDefine.BLOCK_HEIGHT + m_startPos.y
				m_borderNode.add_child(testSpr)

func ClearAllPiece():
	for blockData in m_blockPool:
		blockData["collision"].disabled = true
		blockData["node"].visible = false
	pass

func CreateNewBlock():
	var blockData = {}
	blockData["node"] = load(BLOCK_FILE).instantiate()
	blockData["spr"] = blockData.node.get_node("Sprite2D")
	blockData["collision"] = blockData.node.get_node("CollisionShape2D")
	
	return blockData

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
