extends KinematicBody2D

# global var
const UP = Vector2(0.0, -1.0)
const JUMP_DUMMY = 20
export var speed := 200.0
export var patrol_speed := 100.0
export var gravity := 20.0
var direction = Vector2(0,0)
var knockback = Vector2(0,0)
enum StateEnum {IDLE, ATTACK, HIT, CHASE, DEATH, PATROL = -1}

export(StateEnum) var state = StateEnum.IDLE
var is_patrol = false
var is_alive = true
var is_change_dir = false
var dir: int

onready var _sprite = $AnimatedSprite
onready var _animation = _sprite.get_child(0)
onready var _tree = $AnimationTree
onready var state_machine = _tree.get("parameters/playback")
onready var _playerDetection = $DetectionZone
onready var _enemyHitboxVector = $Position2DHitBox/Hitbox
onready var _stats = $Stats
onready var _playerHealth = get_node("/root/World/Player/Stats")

func _ready():
	_tree.active = true
	_enemyHitboxVector.knockback_vector = direction
	_playerHealth.connect("no_health", self, "_on_character_death")
func _process(delta):
	pass
	if is_on_floor():
		direction.y = JUMP_DUMMY
	else:
		direction.y += gravity
func _physics_process(delta):
	
	knockback = knockback.move_toward(Vector2(0,0), speed)
	knockback = move_and_slide(knockback, UP)
	match state:
		StateEnum.IDLE:
			idle_state()
		StateEnum.ATTACK:
			attack_state()
		StateEnum.HIT:
			hit_state()
		StateEnum.CHASE:
			chase_state()
		StateEnum.DEATH:
			death_state()
		StateEnum.PATROL:
			patrol_state()

func _on_character_death():
	is_alive = false
	state = StateEnum.IDLE
func move_char():
	direction = move_and_slide(direction, UP)
func seek_player():
	if _playerDetection.can_see_player():
		state = StateEnum.CHASE

func chase_state():
	var player = _playerDetection.player
	if player != null and is_alive:
		var relative_dist = (player.global_position - global_position)
		var player_dir = relative_dist.normalized()
		print(direction)
		direction.x = direction.move_toward(player_dir, speed).x * speed
		print(direction.x)
		_enemyHitboxVector.knockback_vector = direction
		if abs(relative_dist.x) < 50:
			direction.x = direction.move_toward(player_dir, speed).x
			state = StateEnum.ATTACK
		change_dir(direction.x)
		state_machine.travel("walk")
		move_char()
	else:
		if not is_patrol:
			state = StateEnum.IDLE
		else:
			state = StateEnum.PATROL
	
	
func hit_state():
	$Position2D/Hurtbox/CollisionShape2D.disabled = true
	$Position2DHitBox/Hitbox/CollisionShape2D.disabled = true
	state_machine.travel("hit")

func death_state():
	$CollisionShape2D.disabled = true
	state_machine.travel("death")

func idle_state():
	
	state_machine.travel("idle")
	seek_player()

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 10
	_stats.health -= area.attack_damage
	state = StateEnum.HIT
	if _stats.health <= 0:
		state = StateEnum.DEATH

func patrol_state():
	is_patrol = true
	direction.x = -patrol_speed if is_change_dir else patrol_speed
	print(direction.y)
	state_machine.travel("walk")
	var object_collided_with = $RayCastX.get_collider()
	if not $RayCastY.is_colliding() and is_on_floor():
		is_change_dir = true
		change_dir(direction.x)
	if $RayCastX.is_colliding() and is_on_floor():
		is_change_dir = false
		change_dir(direction.x)
	move_char()
	seek_player()
	
func change_dir(sprite_dir):
	var s_dir: float
	if sprite_dir < 0:
		dir = -1
		s_dir = -1.5
	else:
		dir = 1
		s_dir = 1.5
	$Position2DHitBox/Hitbox.scale.x = dir
	$Position2D/Hurtbox.scale.x = dir
	$RayCastY.scale.x = dir
	$RayCastX.scale.y = dir
	$CollisionShape2D.position.x = dir
	$DetectionZone/CollisionShape2D.position.x = dir
	_sprite.scale.x = s_dir
	
func hit_animation_finished():
	$Position2D/Hurtbox/CollisionShape2D.disabled = false
	#$Position2DHitBox/Hitbox/CollisionShape2D.disabled = false
	state = StateEnum.IDLE

func attack_state():
	var attack_damage = randi() % (15 - 10) + 10
	$Position2DHitBox/Hitbox.attack_damage = attack_damage
	state_machine.travel("attack")
		
func attack_animation_finished():
	state_machine.travel("walk")
	state = StateEnum.CHASE
