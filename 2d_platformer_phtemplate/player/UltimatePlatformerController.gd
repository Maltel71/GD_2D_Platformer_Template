extends CharacterBody2D

class_name PlatformerController2D

@export var README: String = "IMPORTANT: MAKE SURE TO ASSIGN 'left' 'right' 'jump' 'dash' 'up' 'down' in the project settings input map. Usage tips. 1. Hover over each toggle and variable to read what it does and to make sure nothing bugs. 2. Animations are very primitive. To make full use of your custom art, you may want to slightly change the code for the animations"

@export_category("Necesary Child Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D

@export_category("L/R Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
@export var directionalSnap: bool = false
@export var runningModifier: bool = false
@export_subgroup("Air Movement")
@export var useAirSpeed: bool = false
@export_range(50, 1000) var maxAirSpeed: float = 300.0
@export_range(0, 4) var timeToReachMaxAirSpeed: float = 0.15

@export_category("Jumping and Gravity")
@export_range(0, 20) var jumpHeight: float = 2.0
@export_range(0, 20) var jumps: int = 1
@export_range(0, 100) var gravityScale: float = 20.0
@export_range(0, 1000) var terminalVelocity: float = 500.0
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
@export var shortHopAkaVariableJumpHeight: bool = true
@export_range(0, 0.5) var coyoteTime: float = 0.2
@export_range(0, 0.5) var jumpBuffering: float = 0.2

@export_category("Wall Jumping")
@export var wallJump: bool = false
@export_range(0, 0.5) var inputPauseAfterWallJump: float = 0.1
@export_range(0, 90) var wallKickAngle: float = 60.0
@export_range(1, 20) var wallSliding: float = 1.0
@export var wallLatching: bool = false
@export var wallLatchingModifer: bool = false

@export_category("Dashing")
@export_enum("None", "Horizontal", "Vertical", "Four Way", "Eight Way") var dashType: int
@export_range(0, 10) var dashes: int = 1
@export var dashCancel: bool = true
@export_range(1.5, 4) var dashLength: float = 2.5

@export_category("Corner Cutting/Jump Correct")
@export var cornerCutting: bool = false
@export_range(1, 5) var correctionAmount: float = 1.5
@export var leftRaycast: RayCast2D
@export var middleRaycast: RayCast2D
@export var rightRaycast: RayCast2D

@export_category("Down Input")
@export var crouch: bool = false
@export var canRoll: bool
@export_range(1.25, 2) var rollLength: float = 2
@export var groundPound: bool
@export_range(0.05, 0.75) var groundPoundPause: float = 0.25
@export var upToCancel: bool = false

@export_category("Shooting")
@export var can_shoot: bool = true
@export var bullet_scene: PackedScene
@export_range(0.1, 2.0) var shoot_cooldown: float = 0.3

@export_category("Health")
@export var max_health: int = 3

@export_category("Sound Effects")
@export var jump_sound: AudioStream
@export_range(-80, 24) var jump_volume: float = 0.0
@export var damage_sound: AudioStream
@export_range(-80, 24) var damage_volume: float = 0.0
@export var shoot_sound: AudioStream
@export_range(-80, 24) var shoot_volume: float = 0.0
@export var death_sound: AudioStream
@export_range(-80, 24) var death_volume: float = 0.0

@export_category("Animations (Check Box if has animation)")
@export var run: bool
@export var jump: bool
@export var idle: bool
@export var walk: bool
@export var slide: bool
@export var latch: bool
@export var falling: bool
@export var crouch_idle: bool
@export var crouch_walk: bool
@export var roll: bool

var appliedGravity: float
var maxSpeedLock: float
var appliedTerminalVelocity: float

var friction: float
var acceleration: float
var deceleration: float
var airAcceleration: float
var instantAccel: bool = false
var instantStop: bool = false

var jumpMagnitude: float = 500.0
var jumpCount: int
var jumpWasPressed: bool = false
var coyoteActive: bool = false
var dashMagnitude: float
var gravityActive: bool = true
var dashing: bool = false
var dashCount: int
var rolling: bool = false

var twoWayDashHorizontal
var twoWayDashVertical
var eightWayDash

var wasMovingR: bool
var wasPressingR: bool
var movementInputMonitoring: Vector2 = Vector2(true, true)

var gdelta: float = 1

var dset = false

var colliderScaleLockY
var colliderPosLockY

var latched
var wasLatched
var crouching
var groundPounding

var anim
var col
var animScaleLock : Vector2

var can_shoot_now: bool = true
var shoot_tap

var current_health: int

var upHold
var downHold
var leftHold
var leftTap
var leftRelease
var rightHold
var rightTap
var rightRelease
var jumpTap
var jumpRelease
var runHold
var latchHold
var dashTap
var rollTap
var downTap
var twirlTap

func _ready():
	add_to_group("player")
	wasMovingR = true
	anim = PlayerSprite
	col = PlayerCollider
	current_health = max_health
	
	# Add audio player node
	var audio_player = AudioStreamPlayer.new()
	audio_player.name = "AudioPlayer"
	add_child(audio_player)
	
	_updateData()
	
func _updateData():
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	
	if useAirSpeed:
		airAcceleration = maxAirSpeed / timeToReachMaxAirSpeed
	else:
		airAcceleration = acceleration
	
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	
	dashMagnitude = maxSpeed * dashLength
	dashCount = dashes
	
	maxSpeedLock = maxSpeed
	
	animScaleLock = abs(anim.scale)
	colliderScaleLockY = col.scale.y
	colliderPosLockY = col.position.y
	
	if timeToReachMaxSpeed == 0:
		instantAccel = true
		timeToReachMaxSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantAccel = false
	else:
		instantAccel = false
		
	if timeToReachZeroSpeed == 0:
		instantStop = true
		timeToReachZeroSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantStop = false
	else:
		instantStop = false
		
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
	
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	if directionalSnap:
		instantAccel = true
		instantStop = true
	
	twoWayDashHorizontal = false
	twoWayDashVertical = false
	eightWayDash = false
	if dashType == 0:
		pass
	if dashType == 1:
		twoWayDashHorizontal = true
	elif dashType == 2:
		twoWayDashVertical = true
	elif dashType == 3:
		twoWayDashHorizontal = true
		twoWayDashVertical = true
	elif dashType == 4:
		eightWayDash = true

func _process(_delta):
	if is_on_wall() and !is_on_floor() and latch and wallLatching and ((wallLatchingModifer and latchHold) or !wallLatchingModifer):
		latched = true
	else:
		latched = false
		wasLatched = true
		_setLatch(0.2, false)

	if rightHold and !latched:
		anim.scale.x = animScaleLock.x
		$BulletSpawnPoint.position.x = abs($BulletSpawnPoint.position.x)
		$BulletSpawnPoint/WeaponSprite.scale.x = abs($BulletSpawnPoint/WeaponSprite.scale.x)
	if leftHold and !latched:
		anim.scale.x = animScaleLock.x * -1
		$BulletSpawnPoint.position.x = -abs($BulletSpawnPoint.position.x)
		$BulletSpawnPoint/WeaponSprite.scale.x = -abs($BulletSpawnPoint/WeaponSprite.scale.x)
	
	if run and idle and !dashing and !crouching:
		if abs(velocity.x) > 0.1 and is_on_floor() and !is_on_wall():
			anim.speed_scale = abs(velocity.x / 150)
			anim.play("run")
		elif abs(velocity.x) < 0.1 and is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")
	elif run and idle and walk and !dashing and !crouching:
		if abs(velocity.x) > 0.1 and is_on_floor() and !is_on_wall():
			anim.speed_scale = abs(velocity.x / 150)
			if abs(velocity.x) < (maxSpeedLock):
				anim.play("walk")
			else:
				anim.play("run")
		elif abs(velocity.x) < 0.1 and is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")
		
	if velocity.y < 0 and jump and !dashing:
		anim.speed_scale = 1
		anim.play("jump")
		
	if velocity.y > 40 and falling and !dashing and !crouching:
		anim.speed_scale = 1
		anim.play("falling")
		
	if latch and slide:
		if latched and !wasLatched:
			anim.speed_scale = 1
			anim.play("latch")
		if is_on_wall() and velocity.y > 0 and slide and anim.animation != "slide" and wallSliding != 1:
			anim.speed_scale = 1
			anim.play("slide")
			
		if dashing:
			anim.speed_scale = 1
			anim.play("dash")
			
		if crouching and !rolling:
			if abs(velocity.x) > 10:
				anim.speed_scale = 1
				anim.play("crouch_walk")
			else:
				anim.speed_scale = 1
				anim.play("crouch_idle")
		
		if rollTap and canRoll and roll:
			anim.speed_scale = 1
			anim.play("roll")

func _physics_process(delta):
	if !dset:
		gdelta = delta
		dset = true
		
	leftHold = Input.is_action_pressed("left")
	rightHold = Input.is_action_pressed("right")
	upHold = Input.is_action_pressed("up")
	downHold = Input.is_action_pressed("down")
	leftTap = Input.is_action_just_pressed("left")
	rightTap = Input.is_action_just_pressed("right")
	leftRelease = Input.is_action_just_released("left")
	rightRelease = Input.is_action_just_released("right")
	jumpTap = Input.is_action_just_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")
	runHold = Input.is_action_pressed("run")
	latchHold = Input.is_action_pressed("latch")
	dashTap = Input.is_action_just_pressed("dash")
	rollTap = Input.is_action_just_pressed("roll")
	downTap = Input.is_action_just_pressed("down")
	twirlTap = Input.is_action_just_pressed("twirl")
	shoot_tap = Input.is_action_just_pressed("shoot")
	
	if can_shoot and shoot_tap and can_shoot_now and bullet_scene:
		_shoot()
	
	if rightHold and leftHold and movementInputMonitoring:
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = -0.1
	elif rightHold and movementInputMonitoring.x:
		var targetSpeed = maxAirSpeed if (useAirSpeed and !is_on_floor()) else maxSpeed
		var currentAccel = airAcceleration if (useAirSpeed and !is_on_floor()) else acceleration
		
		if velocity.x > targetSpeed or instantAccel:
			velocity.x = targetSpeed
		else:
			velocity.x += currentAccel * delta
		if velocity.x < 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = -0.1
	elif leftHold and movementInputMonitoring.y:
		var targetSpeed = maxAirSpeed if (useAirSpeed and !is_on_floor()) else maxSpeed
		var currentAccel = airAcceleration if (useAirSpeed and !is_on_floor()) else acceleration
		
		if velocity.x < -targetSpeed or instantAccel:
			velocity.x = -targetSpeed
		else:
			velocity.x -= currentAccel * delta
		if velocity.x > 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0.1
				
	if velocity.x > 0:
		wasMovingR = true
	elif velocity.x < 0:
		wasMovingR = false
		
	if rightTap:
		wasPressingR = true
	if leftTap:
		wasPressingR = false
	
	if runningModifier and !runHold:
		maxSpeed = maxSpeedLock / 2
	elif is_on_floor(): 
		maxSpeed = maxSpeedLock
	
	if !(leftHold or rightHold):
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = 0
			
	if crouch:
		if downHold and is_on_floor():
			crouching = true
		elif !downHold and ((runHold and runningModifier) or !runningModifier) and !rolling:
			crouching = false
			
	if !is_on_floor():
		crouching = false
			
	if crouching:
		maxSpeed = maxSpeedLock / 2
		col.scale.y = colliderScaleLockY / 2
		col.position.y = colliderPosLockY + (8 * colliderScaleLockY)
	else:
		maxSpeed = maxSpeedLock
		col.scale.y = colliderScaleLockY
		col.position.y = colliderPosLockY
		
	if canRoll and is_on_floor() and rollTap and crouching:
		_rollingTime(0.75)
		if wasPressingR and !(upHold):
			velocity.y = 0
			velocity.x = maxSpeedLock * rollLength
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(rollLength * 0.0625)
		elif !(upHold):
			velocity.y = 0
			velocity.x = -maxSpeedLock * rollLength
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(rollLength * 0.0625)
		
	if canRoll and rolling:
		pass
			
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
	
	if is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity / wallSliding
		if wallLatching and ((wallLatchingModifer and latchHold) or !wallLatchingModifer):
			appliedGravity = 0
			
			if velocity.y < 0:
				velocity.y += 50
			if velocity.y > 0:
				velocity.y = 0
				
			if wallLatchingModifer and latchHold and movementInputMonitoring == Vector2(true, true):
				velocity.x = 0
			
		elif wallSliding != 1 and velocity.y > 0:
			appliedGravity = appliedGravity / wallSliding
	elif !is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity
	
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
				velocity.y = appliedTerminalVelocity
		
	if shortHopAkaVariableJumpHeight and jumpRelease and velocity.y < 0:
		velocity.y = velocity.y / 2
	
	if jumps == 1:
		if !is_on_floor() and !is_on_wall():
			if coyoteTime > 0:
				coyoteActive = true
				_coyoteTime()
				
		if jumpTap and !is_on_wall():
			if coyoteActive:
				coyoteActive = false
				_jump()
			if jumpBuffering > 0:
				jumpWasPressed = true
				_bufferJump()
			elif jumpBuffering == 0 and coyoteTime == 0 and is_on_floor():
				_jump()	
		elif jumpTap and is_on_wall() and !is_on_floor():
			if wallJump and !latched:
				_wallJump()
			elif wallJump and latched:
				_wallJump()
		elif jumpTap and is_on_floor():
			_jump()
		
		if is_on_floor():
			jumpCount = jumps
			coyoteActive = true
			if jumpWasPressed:
				_jump()

	elif jumps > 1:
		if is_on_floor():
			jumpCount = jumps
		if jumpTap and jumpCount > 0 and !is_on_wall():
			_jump()
			_endGroundPound()
		elif jumpTap and is_on_wall() and wallJump:
			_wallJump()
			
	if is_on_floor():
		dashCount = dashes
	if eightWayDash and dashTap and dashCount > 0 and !rolling:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		var dTime = 0.0625 * dashLength
		_dashingTime(dTime)
		_pauseGravity(dTime)
		velocity = dashMagnitude * input_direction
		dashCount += -1
		movementInputMonitoring = Vector2(false, false)
		_inputPauseReset(dTime)
	
	if twoWayDashVertical and dashTap and dashCount > 0 and !rolling:
		var dTime = 0.0625 * dashLength
		if upHold and downHold:
			_placeHolder()
		elif upHold:
			_dashingTime(dTime)
			_pauseGravity(dTime)
			velocity.x = 0
			velocity.y = -dashMagnitude
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
		elif downHold and dashCount > 0:
			_dashingTime(dTime)
			_pauseGravity(dTime)
			velocity.x = 0
			velocity.y = dashMagnitude
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
	
	if twoWayDashHorizontal and dashTap and dashCount > 0 and !rolling:
		var dTime = 0.0625 * dashLength
		if wasPressingR and !(upHold or downHold):
			velocity.y = 0
			velocity.x = dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
		elif !(upHold or downHold):
			velocity.y = 0
			velocity.x = -dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
			
	if dashing and velocity.x > 0 and leftTap and dashCancel:
		velocity.x = 0
	if dashing and velocity.x < 0 and rightTap and dashCancel:
		velocity.x = 0
	
	if cornerCutting:
		if velocity.y < 0 and leftRaycast.is_colliding() and !rightRaycast.is_colliding() and !middleRaycast.is_colliding():
			position.x += correctionAmount
		if velocity.y < 0 and !leftRaycast.is_colliding() and rightRaycast.is_colliding() and !middleRaycast.is_colliding():
			position.x -= correctionAmount
			
	if groundPound and downTap and !is_on_floor() and !is_on_wall():
		groundPounding = true
		gravityActive = false
		velocity.y = 0
		await get_tree().create_timer(groundPoundPause).timeout
		_groundPound()
	if is_on_floor() and groundPounding:
		_endGroundPound()
	move_and_slide()
	
	if upToCancel and upHold and groundPound:
		_endGroundPound()
	
func _bufferJump():
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false

func _coyoteTime():
	await get_tree().create_timer(coyoteTime).timeout
	coyoteActive = false
	jumpCount += -1
	
func _jump():
	if jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount += -1
		jumpWasPressed = false
		_play_sound(jump_sound, jump_volume)
		
func _wallJump():
	var horizontalWallKick = abs(jumpMagnitude * cos(wallKickAngle * (PI / 180)))
	var verticalWallKick = abs(jumpMagnitude * sin(wallKickAngle * (PI / 180)))
	velocity.y = -verticalWallKick
	var dir = 1
	if wallLatchingModifer and latchHold:
		dir = -1
	if wasMovingR:
		velocity.x = -horizontalWallKick  * dir
	else:
		velocity.x = horizontalWallKick * dir
	if inputPauseAfterWallJump != 0:
		movementInputMonitoring = Vector2(false, false)
		_inputPauseReset(inputPauseAfterWallJump)
	_play_sound(jump_sound, jump_volume)
			
func _setLatch(delay, setBool):
	await get_tree().create_timer(delay).timeout
	wasLatched = setBool
			
func _inputPauseReset(time):
	await get_tree().create_timer(time).timeout
	movementInputMonitoring = Vector2(true, true)

func _decelerate(delta, vertical):
	if !vertical:
		if velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta

func _pauseGravity(time):
	gravityActive = false
	await get_tree().create_timer(time).timeout
	gravityActive = true

func _dashingTime(time):
	dashing = true
	await get_tree().create_timer(time).timeout
	dashing = false

func _rollingTime(time):
	rolling = true
	await get_tree().create_timer(time).timeout
	rolling = false	

func _groundPound():
	appliedTerminalVelocity = terminalVelocity * 10
	velocity.y = jumpMagnitude * 2
	
func _endGroundPound():
	groundPounding = false
	appliedTerminalVelocity = terminalVelocity
	gravityActive = true

func _shoot():
	can_shoot_now = false
	_play_sound(shoot_sound, shoot_volume)
	
	var bullet = bullet_scene.instantiate()
	var spawn_point = $BulletSpawnPoint
	var shoot_direction = 1 if anim.scale.x > 0 else -1
	
	bullet.global_position = spawn_point.global_position
	bullet.set_direction(shoot_direction)
	get_parent().add_child(bullet)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot_now = true

func _placeHolder():
	print("")
	
func take_damage(amount: int) -> void:
	current_health -= amount
	_play_sound(damage_sound, damage_volume)
	
	var knockback_force = 300.0
	var knockback_direction = -1 if anim.scale.x > 0 else 1
	velocity.x = knockback_force * knockback_direction
	velocity.y = -jumpMagnitude * 0.3
	
	if current_health <= 0:
		_die()

func _die():
	_play_sound(death_sound, death_volume)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(4, false)
	
	velocity.y = -jumpMagnitude * 0.8
	gravityActive = true
	
	set_process_input(false)
	
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _play_sound(sound: AudioStream, volume: float = 0.0):
	if sound:
		var player = get_node_or_null("AudioPlayer")
		if player:
			player.stream = sound
			player.volume_db = volume
			player.play()
