extends CanvasLayer

var cursorCrosshair = preload("res://sprites/crosshair.png")

@onready var sprintIcon = $sprinting
@onready var controlsHUD = $controls

@onready var reloadingText = $reloading

@onready var reloadingAnimation = $reloading/reloadingAnimation

@onready var healthText = $status/healthText
var healthAmount = null

@onready var ammoText = $status/ammoText
var maxAmmo = null
var ammoAmount = null

@onready var zombieCountText = $zombieCount

@onready var killCountText = $zombieCount/killCount
var killCount = 0

@onready var waveText = $wave
var waveCount = 1

@onready var nextWaveButton = $nextWaveButton

@onready var reloadPrompt = $rToReload
@onready var reloadFade = $rToReload/fadeOut

var zombiesInWave = 1
var zombiesLeftInWave = 0

func nextWave(wave):
	zombiesInWave = wave * 5

func _ready():
	$nextWaveSound.play()

func _process(delta):
	#fades out the controls section at a rate of TimeFromLastFrame^1.4
	if controlsHUD.modulate.a > 0:
		controlsHUD.modulate.a -= pow(delta, 1.4) #pow is GDScript's exponent math function
	
	healthText.set_text("Health: " + str(healthAmount) + "/100")
	ammoText.set_text("Ammo: " + str(ammoAmount) + "/" + str(maxAmmo))
	zombieCountText.set_text("Zombies left: " + str(zombiesLeftInWave))
	killCountText.set_text("Zombies killed: " +str(killCount))
	waveText.set_text("Wave: " + str(waveCount))
	

var mouseOverNextWave = false

func _on_nextWaveButton_pressed():
	$nextWaveSound.play()
	nextWaveButton.visible = false
	Input.set_custom_mouse_cursor(cursorCrosshair)
	mouseOverNextWave = false
	waveCount += 1
	nextWave(waveCount)
	zombiesLeftInWave = zombiesInWave

func _on_nextWaveButton_mouse_entered():
	Input.set_custom_mouse_cursor(null)
	mouseOverNextWave = true

func _on_nextWaveButton_mouse_exited():
	Input.set_custom_mouse_cursor(cursorCrosshair)
	mouseOverNextWave = false


func _on_nextWaveButton_visibility_changed():
	if $nextWaveButton.visible == true:
		$waveCompleteSound.play()
