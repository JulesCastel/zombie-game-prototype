extends Control

@onready var gunshot = $gunShotSound
@onready var menuTick = $menuTickSound
@onready var mainMenu = $mainMenuBackground
@onready var settingsMenu = $settingsBackground2
@onready var menuSound = $menuSound
@onready var menuHover = $menuHoverSound

func _ready():
	Input.set_custom_mouse_cursor(null)
	mainMenu.visible = true
	settingsMenu.visible = false

func _on_startButton_mouse_entered():
	menuHover.play()

func _on_startButton_pressed():
	menuSound.play()
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_optionsButton_mouse_entered():
	menuHover.play()

func _on_optionsButton_pressed():
	menuHover.playing = false
	menuSound.play()
	settingsMenu.visible = true

func _on_masterSlider_value_changed(value):
	menuTick.playing = false
	menuTick.play()
	setBusVolume(0, value)

func _on_SFXSlider_value_changed(value):
	gunshot.playing = true
	setBusVolume(1, value)

func _on_menuSoundsSlider_value_changed(value):
	menuTick.playing = false
	menuTick.play()
	setBusVolume(2, value)

func _on_musicSlider_value_changed(value):
	menuTick.playing = false
	menuTick.play()
	setBusVolume(3, value)

func _on_backButton_mouse_entered():
	menuHover.play()

func _on_backButton_pressed():
	menuHover.playing = false
	menuSound.play()
	settingsMenu.visible = false
	mainMenu.visible = true

func setBusVolume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < -80)

func _on_quitButton_mouse_entered():
	menuHover.play()

func _on_quitButton_pressed():
	menuHover.playing = false
	menuSound.play()
	if menuSound.playing == true:
		var t = Timer.new()
		t.set_wait_time(0.192)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		await t.timeout
	get_tree().quit()



