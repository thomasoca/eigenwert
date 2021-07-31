extends KinematicBody2D
class_name Player

# const and global variable
const UP = Vector2(0.0, -1.0)
export var speed := 200.0
export var roll_speed := 250.0
export var gravity := 20.0
export var jump_force := -400.0
var direction = Vector2(0,0)
var knockback = Vector2(0,0)
var orientation
var attack_counter := 0
enum {MOVE, ATTACK_1, ATTACK_2, ROLL, JUMP, HIT, DEATH}
var state = MOVE
# call animated sprite
onready var _sprite = $AnimatedSprite
onready var _animation = _sprite.get_child(0)
onready var _tree = $AnimationTree
onready var state_machine = _tree.get("parameters/playback")
onready var _swordHitboxVector = $Position2D/Hitbox
onready var _stats = $Stats

func _ready():
	_tree.active = true
	_swordHitboxVector.knockback_vector = direction
func _process(delta):
	direction.y += gravity
func _physics_process(delta):
	
	if _stats.stamina < _stats.max_stamina: 
		_stats.stamina += 1
	knockback = knockback.move_toward(Vector2(0,0), speed)
	knockback = move_and_slide(knockback, UP)
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK_1:
			attack_state(delta, "attack_1")
		ATTACK_2:
			attack_state(delta, "attack_2")
		HIT:
			hit_state()
		DEATH:
			death_state()
func move_char():
	direction = move_and_slide(direction, UP)
func death_state():
	state_machine.travel("death")
	move_char()
func move_state(delta) -> void:
	if Input.is_action_pressed("ui_right"):
		attack_counter = 0
		direction.x = speed
		state_machine.travel("run")
		orientation = 1
		change_dir(orientation)
		
	elif Input.is_action_pressed("ui_left"):
		attack_counter = 0
		direction.x = -speed
		orientation = -1
		state_machine.travel("run")
		change_dir(orientation)
	else:
		direction.x = 0
		state_machine.travel("idle")
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			attack_counter = 0
			direction.y = jump_force
	else:
		state_machine.travel("jump")
	
	# Apply movement
	_swordHitboxVector.knockback_vector = direction
	move_char()
	if is_on_floor():
		if Input.is_action_just_pressed("attack_1"):
			attack_counter += 1
			if attack_counter % 2 != 0:
				state = ATTACK_1
			else:
				state = ATTACK_2
				attack_counter = 0
		elif Input.is_action_just_pressed("roll") and direction.x != 0:
			attack_counter = 0
			state = ROLL

func attack_state(delta, type: String):
	if type == "attack_1":
		
		state_machine.travel("attack_1")
	else:

		state_machine.travel("attack_2")

func change_dir(dir):
	$Position2D/Hitbox.scale.x = dir
	$CollisionShape2D.position.x = dir
	_sprite.scale.x = dir
		
func attack_animation_finished():
	_stats.stamina -= 20
	state = MOVE

func roll_state(delta):
	$Position2DHurtBox/Hurtbox/CollisionShape2D.disabled = true
	direction.x = orientation * roll_speed
	state_machine.travel("roll")
	move_char()
		
func roll_animation_finished():
	_stats.stamina -= 25
	$Position2DHurtBox/Hurtbox/CollisionShape2D.disabled = false
	state = MOVE

func hit_state():
	$Position2DHurtBox/Hurtbox/CollisionShape2D.disabled = true
	$Position2D/Hitbox/CollisionShape2D.disabled = true
	state_machine.travel("hit")
	move_char()

func hit_animation_finished():
	$Position2DHurtBox/Hurtbox/CollisionShape2D.disabled = false
	state = MOVE

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 7
	print(area.attack_damage)
	_stats.health -= area.attack_damage
	state = HIT
	if _stats.health <= 0:
		state = DEATH
		
func set_active(active: bool):
	set_physics_process(active)
	set_process(active)
	set_process_input(active)
