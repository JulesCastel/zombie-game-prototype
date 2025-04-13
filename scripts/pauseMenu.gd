extends Control

var isPaused = false: set = setIsPaused

var cursorCrosshair = preload("res://sprites/crosshair.png")

@onready var pauseMusic = $pauseMenuMusic
@onready var gunshot = $gunShotSound
@onready var menuTick = $menuTickSound
@onready var pausedSound = $pausedSound
@onready var unpausedSound = $unpausedSound
@onready var pauseMenu = $background
@onready var settingsMenu = $settingsBackground
@onready var menuSound = $menuSound
@onready var menuHover = $menuHoverSound

func _ready():
	pauseMusic.playing = false
	pauseMenu.visible = true
	settingsMenu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		pauseMusic.playing = !pauseMusic.playing
		self.isPaused = !isPaused
		if isPaused == true:
			Input.set_custom_mouse_cursor(null)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			unpausedSound.playing = false
			pausedSound.play()
		elif isPaused == false:
			pausedSound.playing = false
			unpausedSound.play()
			Input.set_custom_mouse_cursor(cursorCrosshair)
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func setIsPaused(value):
	isPaused = value
	get_tree().paused = isPaused
	visible = isPaused

func _on_resumeButton_mouse_entered():
	if pausedSound.playing == false:
		menuHover.play()

func _on_resumeButton_pressed():
	pauseMusic.playing = false
	menuHover.playing = false
	pausedSound.playing = false
	unpausedSound.play()
	self.isPaused = false
	Input.set_custom_mouse_cursor(cursorCrosshair)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_optionButton_mouse_entered():
	if pausedSound.playing == false:
		menuHover.play()

func _on_optionButton_pressed():
	menuHover.playing = false
	menuSound.play()
	pauseMenu.visible = false
	settingsMenu.visible = true

func _on_quitButton_mouse_entered():
	if pausedSound.playing == false:
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

func _on_backButton_mouse_entered():
	menuHover.play()

func _on_backButton_pressed():
	menuHover.playing = false
	menuSound.play()
	settingsMenu.visible = false
	pauseMenu.visible = true

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

func setBusVolume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < -80)

