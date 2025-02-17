extends Node3D

@export var torque_magnitude = 100
@export var cam_speed = 10
@export var cam_rot_speed = 5
@export var pitch_range = Vector2(-50,50)
@export var yaw_sensitivity = 0.002
@export var cam_zoom = 3
@export var mass = .1

# rigid body of the players sphere
@onready var rb : RigidBody3D = $"player/Sphere-rigid"

var rb_physics_mat : PhysicsMaterial
var rb_mass = 1
var rb_dir = Vector3.ZERO
#signal positionchange (who_changed_position, whats_the_new_position)
@onready var previous_pos = Vector3.ZERO

# all parts related to the camera
# the camera itself
@onready var cam : Camera3D = $"CameraTarget/SpringArm3D/Camera3D"
# the target the camera points towards
@onready var cam_target : Node3D = $"CameraTarget"
# spring the changes distance to the camera target
@onready var cam_spring : SpringArm3D = $"CameraTarget/SpringArm3D"

# the direction the player wants to move the camera
var camRotDir = Vector3.ZERO
var camTransDir = Vector3.ZERO
var camMaxDistance = 20

var lerpWeight = 0.75

func _ready():
	# camera starts at a distance of -3 meters
	cam_spring.spring_length = 10
	rb_physics_mat = rb.get_physics_material_override()
	# starting mass of rb
	#rb_physics_mat.friction = 0.5
	rb.set_physics_material_override(rb_physics_mat)
	rb.set_mass(mass)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if global_position != previous_pos:
		pass
		#emit_signal("positionchange", name, global_position)
		
	previous_pos = global_position
	# get the new direction the player wants to move in
	readUserInput()
	
	# reposition camera as player moves
	moveCamera(delta)
	
	# apply torquing force to the rigid body in the given direction
	movePlayer(delta)

func readUserInput():
	# clear input from last updated
	rb_dir = Vector3.ZERO
	camRotDir = Vector3.ZERO
	camTransDir = Vector3.ZERO
	
	# alter the zero vector based on player input
	if Input.is_action_pressed("player_forward"):
		#rb_dir.z -= 1
		rb_dir += -basis.x
	if Input.is_action_pressed("player_backward"):
		#rb_dir.z += 1
		rb_dir += basis.x
	if Input.is_action_pressed("player_left"):
		#rb_dir.x -= 1
		rb_dir += basis.z
	if Input.is_action_pressed("player_right"):
		#rb_dir.x += 1
		rb_dir += -basis.z
	
	# if the direction vector has been altered
	if rb_dir != Vector3.ZERO:
		# normalize the vector so all movement has equal speeds
		rb_dir = rb_dir.normalized()
		
	# alter the zero vector based on player input
	if Input.is_action_pressed("camera_up"):
		#cam_dir.x -= 1
		camRotDir += Vector3.UP
	if Input.is_action_pressed("camera_down"):
		camRotDir += Vector3.DOWN
	if Input.is_action_pressed("camera_left"):
		camRotDir += Vector3.LEFT
	if Input.is_action_pressed("camera_right"):
		camRotDir += Vector3.RIGHT
	if Input.is_action_pressed("camera_out"):
		camTransDir += Vector3.BACK
	if Input.is_action_pressed("camera_in"):
		camTransDir += Vector3.FORWARD
	# if the direction vector has been altered
	if camTransDir != Vector3.ZERO:
		# normalize the vector so all movement has equal speeds
		camTransDir = camTransDir.normalized()
	if camRotDir != Vector3.ZERO:
		# normalize the vector so all movement has equal speeds
		camRotDir = camRotDir.normalized()

func moveCamera(delta):
	# set position of camera target equal players rigidbody
	cam_target.position = rb.position
	
	# lets the player change camera distance to camera target
	# this is done by increase the length of the spring arm
	var from = cam_spring.spring_length
	
	if camTransDir == Vector3.FORWARD && from > 0:
		cam_spring.spring_length = lerp(from, from - ( cam_speed*delta ), lerpWeight)
		
	if camTransDir == Vector3.BACK && from < camMaxDistance:
		cam_spring.spring_length = lerp(from, from + ( cam_speed*delta ), lerpWeight)

	if camRotDir.y < 0:
		cam_target.rotate_object_local(-basis.x, camRotDir.y * delta * cam_rot_speed)
	elif camRotDir.y > 0:
		cam_target.rotate_object_local(-basis.x, camRotDir.y * delta * cam_rot_speed)

	if camRotDir.x < 0:
		cam_target.rotate(basis.y, camRotDir.x * delta * cam_rot_speed)
	elif camRotDir.x > 0:
		cam_target.rotate(basis.y, camRotDir.x * delta * cam_rot_speed)
	
func movePlayer(delta):
	var transformed_input = Vector3.ZERO
	
	transformed_input = cam.global_basis.get_rotation_quaternion() * rb_dir
	
	rb.apply_torque( transformed_input * torque_magnitude * delta)
	
