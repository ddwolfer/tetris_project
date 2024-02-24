extends Node

const SaveFilePath = "user://tetris_project.cfg"
var config: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	print("@@ddw is ready")
	# 存檔/設定 資料讀取
	config = ConfigFile.new()
	
	load_data()

func save_data():
	config.save(SaveFilePath)

func load_data():
	if config.load(SaveFilePath) != OK:
		save_data()
		return
