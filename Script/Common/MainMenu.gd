extends Control

@export var testMainMenu:int

# Called when the node enters the scene tree for the first time.
func _ready():
	print("testMainMenu: ")
	print(testMainMenu)
	$TextNode/Button/Start.grab_focus()
	pass # Replace with function body.


func _on_start_pressed():
	Global.SwitchScene("MainGame", self)
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
