extends Node

@export var SCENES: Array[PackedScene] = [
	preload("res://Scenes/MainMenu.tscn"),
	preload("res://Scenes/Game/GameView.tscn"),
]
@export var SCENES_MAP: Dictionary = {
	"MainGame": 1,
	"Menu": 0
}

const SAVE_FILE_PATH = "user://tetris_project.cfg"
var config: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	config = ConfigFile.new()
	print(SCENES)
	print(SCENES_MAP)
	#LoadData()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	
# 預先寫的 function 還沒有藥用
func SaveData():
	config.save(SAVE_FILE_PATH)

func LoadData():
	if config.load(SAVE_FILE_PATH) != OK:
		SaveData()
		return
		
# Scene manager 在 Global.tscn 右側新增需要轉換的場景
func SwitchScene(sceneName: StringName, currentScene: Node):
	var scene = SCENES[SCENES_MAP[sceneName]].instantiate()
	get_tree().root.add_child(scene)
	currentScene.queue_free()

func HideScene(scene):
	scene.hide()

func RemoveScene(scene):
	get_tree().root.remove_child(scene)

func DeleteScene(scene):
	scene.queue_free()

