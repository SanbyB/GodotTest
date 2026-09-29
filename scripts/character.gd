extends CharacterBody2D

var mouseOver:bool = false
var selected: bool = false
enum states {IDLE, SELECTED, RUN, ATTACK, DEFEND}
var state: int = states.IDLE
# position in grid coordinates
var gridPos: Vector2 = Vector2(0, 0)

enum teams {RED, BLACK}

@export var team = teams.BLACK
@export var health: int = 100
@export var movementBudget = 3

var animatedSprite : AnimatedSprite2D
@onready var selectedSprite : AnimatedSprite2D = $select

func _ready() -> void:
	# init a random frame so that all instances aren't in sync
	animatedSprite.frame = randi_range(0, animatedSprite.sprite_frames.get_frame_count("idle") - 1)
	var rect = RectangleShape2D.new()
	# TODO replace 64, 64 with width and height of tiles
	$CollisionEnter.shape.set_size(Vector2(64, 64))
	$CollisionExit.shape.set_size(Vector2(60, 60))
	
	# align the pieces to the squares and set the grid pos
	gridPos = floor(position/64)
	position = gridPos * 64 + Vector2(32, 32)
	
	

func _process(delta: float) -> void:
	animState()
	
	
func animState():
	if state == states.SELECTED:
		selectedSprite.animation = "selected"
		animatedSprite.scale = Vector2(1, 1)
	else:
		selectedSprite.animation = "unselected"
		animatedSprite.scale = Vector2(0.8, 0.8)
		
	if state == states.IDLE:
		animatedSprite.animation = "idle"
	elif state == states.RUN:
		animatedSprite.animation = "run"
	elif state == states.DEFEND:
		animatedSprite.animation = "defend"
	elif state == states.ATTACK:
		animatedSprite.animation = "attack"
		# if on final frame switch back to idle
		if animatedSprite.frame == animatedSprite.sprite_frames.get_frame_count("attack") - 1:
			state = states.IDLE
		
func move():
	var mousePos: Vector2 = get_global_mouse_position()
	var newGridPos: Vector2 = floor(mousePos/64)
	var diff: Vector2 = newGridPos - gridPos
	var dist: int = abs(diff[0]) + abs(diff[1])
	
	if -7 < newGridPos[0] and newGridPos[0] < 6 and\
	   -5 < newGridPos[1] and newGridPos[1] < 4 and\
	   dist <= movementBudget:
		gridPos = newGridPos
		position = gridPos * 64 + Vector2(32, 32)
		select()
		
func select():
	selected = !selected
	if state in [states.IDLE, states.SELECTED]:
		state = states.SELECTED if selected else states.IDLE
	
func attack():
	state = states.ATTACK
	select()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("leftClick"):
		if selected:
			if mouseOver:
				select()
			elif Main.globalMouseOver:
				attack()
			else:
				move()
		elif mouseOver:
			select()
		

func _on_mouse_shape_entered(shape_idx: int) -> void:
	mouseOver = true
	Main.globalMouseOver = true
	print(self, " mouse entered")


func _on_mouse_shape_exited(shape_idx: int) -> void:
	mouseOver = false
	Main.globalMouseOver = false
	print(self, " mouse exited")
