extends Node2D

@onready var HUD = get_node("/root/world/player/Camera2D/HUD")

@onready var gunShotsound = $gunShotSound
@onready var noAmmoClick = $noAmmoClick
@onready var reloadSound = $reloadSound
@onready var weaponSelect = $weaponSelect
@onready var firerateTimer = $fireRate

var pistolShotSound = preload("res://sounds/weapon sounds/pistol/shot.ogg")
var pistolReloadSound = preload("res://sounds/weapon sounds/pistol/reload.ogg")
var pistolDryfireSound = preload("res://sounds/weapon sounds/pistol/dryfire.ogg")
var pistolSelect = preload("res://sounds/weapon sounds/pistol/select.ogg")

var shotgunShotSound = preload("res://sounds/weapon sounds/shotgun/shot.ogg")
var shotgunReloadSound = preload("res://sounds/weapon sounds/shotgun/singleReload.ogg")
var shotgunDryfireSound = preload("res://sounds/weapon sounds/shotgun/dryfire.ogg")
var shotgunSelect = preload("res://sounds/weapon sounds/shotgun/select.ogg")

var bullet = preload("res://objects/bullet.tscn")
var muzzleFlashTimer = 0
var BULLET_SPEED = 3000

var isReloading = false

var rng = RandomNumberGenerator.new()

var muzzleFlash
@export var firerateSeconds = 1
var bulletPoint
var currentWeapon
var reloadTime
@export var bulletsPerShot = 1
@export var maxAmmo = 1
var currentAmmo
var bulletSpread

func _ready():
	setWeaponPistol()
	currentAmmo = maxAmmo
	HUD.ammoAmount = currentAmmo

func _process(delta):
	bulletPoint.global_rotation = get_global_mouse_position().angle_to_point(position)
	
	if muzzleFlashTimer >= 0:
		muzzleFlashTimer -= delta
		if muzzleFlashTimer <= 0:
			muzzleFlash.visible = false

func _input(event):
	if(event.is_action_pressed("shoot")):
		if $fireRate.is_stopped():
			shootGun()
	if(event.is_action_pressed("reloadGun")):
		if currentWeapon == "shotgun":
			reloadShotgun(reloadTime)
		else:
			reloadGun(reloadTime)
	if(event.is_action_pressed("selectPistol")):
		if currentWeapon != "pistol":
			setWeaponPistol()
	if(event.is_action_pressed("selectShotgun")):
		if currentWeapon != "shotgun":
			setWeaponShotgun()

func setWeaponPistol():
	currentWeapon = "pistol"
	$pistol.visible = true
	$shotgun.visible = false
	bulletPoint = $pistol/bulletPoint
	muzzleFlash = $pistol/muzzleFlash
	firerateSeconds = (pistolShotSound.get_length() / 2)
	firerateTimer.wait_time = firerateSeconds
	bulletSpread = 0.0
	maxAmmo = 10
	HUD.maxAmmo = maxAmmo
	bulletsPerShot = 1
	reloadTime = (pistolReloadSound.get_length() - 0.3)
	$weaponSelect.stream = pistolSelect
	$gunShotSound.stream = pistolShotSound
	$noAmmoClick.stream = pistolDryfireSound
	$reloadSound.stream = pistolReloadSound
	$weaponSelect.play()

func setWeaponShotgun():
	currentWeapon = "shotgun"
	$shotgun.visible = true
	$pistol.visible = false
	bulletPoint = $shotgun/bulletPoint
	muzzleFlash = $shotgun/muzzleFlash
	firerateSeconds = (shotgunShotSound.get_length() - .15)
	firerateTimer.wait_time = firerateSeconds
	bulletSpread = 30.0
	maxAmmo = 8
	HUD.maxAmmo = maxAmmo
	bulletsPerShot = 8
	reloadTime = shotgunReloadSound.get_length()
	$weaponSelect.stream = shotgunSelect
	$gunShotSound.stream = shotgunShotSound
	$noAmmoClick.stream = shotgunDryfireSound
	$reloadSound.stream = shotgunReloadSound
	$weaponSelect.play()

func shootGun():
	#this if condition prevents shooting with no ammo and while reloading
	if HUD.mouseOverNextWave == false and currentAmmo > 0 and $reloadSound.playing == false:
		currentAmmo -= 1
		
		HUD.ammoAmount = currentAmmo
		
		muzzleFlash.visible = true
		muzzleFlashTimer = 0.1
		
		$gunShotSound.play()
		
		$fireRate.start()
		
		#this spawns bullets from the bulletPoint node on player.tscn
		if bulletsPerShot > 1:
			var bulletInstance = bullet.instantiate()
			bulletInstance.position = bulletPoint.get_global_position()
			bulletInstance.rotation_degrees = bulletPoint.get_global_rotation_degrees()
			bulletInstance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(global_rotation), Vector2())
			get_tree().get_root().add_child(bulletInstance)
#all bulletsPerShot but one have randomized cone of fire, so that at least one bullet goes where the player is pointing at
			for i in (bulletsPerShot - 1):
				bulletInstance = bullet.instantiate()
				bulletInstance.name = "bullet"
				bulletInstance.position = bulletPoint.get_global_position()
				bulletInstance.rotation_degrees = global_rotation_degrees
				if bulletSpread > 0:
					#this generates a random integer from negative bulletSpread to positive bulletSpread in degrees
					rng.randomize()
					var spread = rng.randi_range((-1 * bulletSpread), bulletSpread)
					spread = deg_to_rad(spread)
					bulletInstance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(global_rotation + spread), Vector2())
				else:
					bulletInstance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(global_rotation), Vector2())
				get_tree().get_root().add_child(bulletInstance)
		else:
			var bulletInstance = bullet.instantiate()
			bulletInstance.position = bulletPoint.get_global_position()
			bulletInstance.rotation_degrees = global_rotation_degrees
			if bulletSpread > 0:
				#this generates a random integer from -bulletSpread to +bulletSpread 
				rng.randomize()
				var spread = rng.randi_range((-1 * bulletSpread), bulletSpread)
				spread = deg_to_rad(spread)
				bulletInstance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(global_rotation + spread), Vector2())
			else:
				bulletInstance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(global_rotation), Vector2())
			get_tree().get_root().add_child(bulletInstance)
	elif currentAmmo == 0 and $reloadSound.playing == false and $noAmmoClick.playing == false and HUD.mouseOverNextWave == false: 
		dryFire()
	else:
		return

func dryFire():
	$noAmmoClick.play()
	HUD.reloadPrompt.visible = true
	HUD.reloadFade.play("fadeOut")

func reloadGun(reloadTimeSeconds):
	if $reloadSound.playing == false and currentAmmo != maxAmmo:
		
		isReloading = true
		
		HUD.reloadPrompt.visible = false
		HUD.reloadingText.visible = true
		HUD.sprintIcon.visible = false
		HUD.reloadingAnimation.frame = 0
		#             the reload animation is 62 frames long
		HUD.reloadingAnimation.speed_scale = (62 / reloadTimeSeconds)
		HUD.reloadingAnimation.play()
		
		$reloadSound.playing = true
		if $reloadSound.playing == true:
			#actions while reloading is happening, tied to the length of time of reload sound
			if HUD.sprintIcon.visible == true:
				HUD.sprintIcon.visible = false
			var reloadTimer = Timer.new()
			reloadTimer.set_wait_time(reloadTimeSeconds)
			reloadTimer.set_one_shot(true)
			self.add_child(reloadTimer)
			reloadTimer.start()
			await reloadTimer.timeout
			#waits for the duration of the reload sound before doing these below
			currentAmmo = maxAmmo
			HUD.reloadingText.visible = false
			HUD.ammoAmount = currentAmmo
			isReloading = false
	else:
		return

func reloadShotgun(reloadTimeSeconds):
	if $reloadSound.playing == false and currentAmmo != maxAmmo:
		isReloading = true
		HUD.reloadPrompt.visible = false
		HUD.reloadingText.visible = true
		HUD.sprintIcon.visible = false
		HUD.reloadingAnimation.frame = 0
		#             the reload animation is 62 frames long
		HUD.reloadingAnimation.speed_scale = (62 / reloadTimeSeconds)
		HUD.reloadingAnimation.play()
		$reloadSound.playing = true
		if $reloadSound.playing == true:
			#actions while reloading is happening, tied to the length of time of reload sound
			if HUD.sprintIcon.visible == true:
				HUD.sprintIcon.visible = false
			var reloadTimer = Timer.new()
			reloadTimer.set_wait_time(reloadTimeSeconds)
			reloadTimer.set_one_shot(true)
			self.add_child(reloadTimer)
			reloadTimer.start()
			await reloadTimer.timeout
			#waits for the duration of the reload sound before doing these below
			currentAmmo += 1
			HUD.reloadingText.visible = false
			HUD.ammoAmount = currentAmmo
			isReloading = false
	else:
		return
