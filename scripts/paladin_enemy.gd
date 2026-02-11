extends CharacterBody2D

## Психоделический Паладин-ЗОЖник
## State Machine: PATROL → CHASE → PANIC

enum State {PATROL, CHASE, PANIC}
var current_state = State.PATROL

@export var patrol_speed: float = 100.0
@export var chase_speed: float = 150.0
@export var panic_speed: float = 200.0
@export var detection_range: float = 300.0

var player: Node2D = null
var patrol_points: Array = []
var current_patrol_index: int = 0
var panic_timer: float = 0.0
var panic_duration: float = 3.0

@onready var animation_player = $AnimationPlayer
@onready var raycast = $RayCast2D

func _ready():
	patrol_points = [
		global_position + Vector2(-100, 0),
		global_position + Vector2(100, 0)
	]
	
func _physics_process(delta):
	match current_state:
		State.PATROL:
			_patrol_behavior(delta)
			_detect_player()
			
		State.CHASE:
			_chase_behavior(delta)
			_check_smoke_collision()
			
		State.PANIC:
			_panic_behavior(delta)
			panic_timer -= delta
			if panic_timer <= 0:
				_exit_panic()
	
	move_and_slide()

func _patrol_behavior(_delta):
	var target = patrol_points[current_patrol_index]
	var direction = (target - global_position).normalized()
	velocity = direction * patrol_speed
	if global_position.distance_to(target) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		velocity = Vector2.ZERO

func _chase_behavior(_delta):
	if not player:
		current_state = State.PATROL
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * chase_speed

func _panic_behavior(_delta):
	if int(panic_timer * 10) % 5 == 0:
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		velocity = random_dir * panic_speed

func _detect_player():
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	var distance = global_position.distance_to(player.global_position)
	if distance < detection_range:
		raycast.target_position = player.global_position - global_position
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			_enter_chase()

func _check_smoke_collision():
	var smoke_areas = get_tree().get_nodes_in_group("smoke")
	for area in smoke_areas:
		if area.overlaps_body(self):
			_enter_panic()
			break

func _enter_chase():
	current_state = State.CHASE
	print("Паладин: ГРЕХ ОБНАРУЖЕН! К ОЧИСТКЕ!")

func _enter_panic():
	current_state = State.PANIC
	panic_timer = panic_duration
	print("Паладин: *кхе-кхе* ЧТО ЭТО?! МОИ ЛЁГКИЕ!")

func _exit_panic():
	current_state = State.CHASE
	print("Паладин: Я... я всё ещё могу бороться со злом!")
