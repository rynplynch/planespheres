extends Node3D

@export var speed = 300
@export var cam_speed = 5
@export var pitch_range = Vector2(-50,50)
@export var yaw_sensitivity = 0.002
@export var cam_offset = Vector3(0,3,-3)

# rigid body of the players sphere
var rb : RigidBody3D
var rb_dir = Vector3.ZERO

# all parts related to the camera
# the camera itself
var cam : Camera3D
# the target the camera points towards
var cam_target : Node3D
# spring the changes distance to the camera target
var cam_spring : SpringArm3D
# the direction the player wants to move the camera
var cam_dir = Vector3.ZERO

func _ready():
	rb = $"sphere/Sphere-rigid"
	
	cam_target = $"CameraTarget"
	cam_spring = $"CameraTarget/SpringArm3D"
	cam = $"CameraTarget/SpringArm3D/Camera3D"
	
	# camera starts at a distance of -3 meters
	cam_spring.spring_length = -3
	# set cameras z equal to this
	cam.position.x = -3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# get the new direction the player wants to move in
	readUserInput()
	
	# reposition camera as player moves
	moveCamera(delta)
	
	# apply torquing force to the rigid body in the given direction
	rb.apply_torque( rb_dir * speed * delta)
	
	
	# allows for smooth movement of player
	# move_and_slide()

func readUserInput():
	# clear input from last updated
	rb_dir = Vector3.ZERO
	cam_dir = Vector3.ZERO
	
	# alter the zero vector based on player input
	if Input.is_action_pressed("player_forward"):
		rb_dir.z -= 1
	if Input.is_action_pressed("player_backward"):
		rb_dir.z += 1
	if Input.is_action_pressed("player_left"):
		rb_dir.x -= 1
	if Input.is_action_pressed("player_right"):
		rb_dir.x += 1
	
	# if the direction vector has been altered
	if rb_dir != Vector3.ZERO:
		# normalize the vector so all movement has equal speeds
		rb_dir = rb_dir.normalized()
		
	# alter the zero vector based on player input
	if Input.is_action_pressed("camera_up"):
		cam_dir.x -= 1
	if Input.is_action_pressed("camera_down"):
		cam_dir.x += 1
	if Input.is_action_pressed("camera_left"):
		cam_dir.y -= 1
	if Input.is_action_pressed("camera_right"):
		cam_dir.y += 1
	if Input.is_action_pressed("camera_out"):
		cam_dir.z -= 1
	if Input.is_action_pressed("camera_in"):
		cam_dir.z += 1
	# if the direction vector has been altered
	if cam_dir != Vector3.ZERO:
		# normalize the vector so all movement has equal speeds
		cam_dir = cam_dir.normalized()

func moveCamera(delta):
	# set position of camera target equal players rigidbody
	cam_target.position = rb.position
	
	# lets the player change camera distance to camera target
	
	# get the new distance value for this frame and save it in the offset
	cam_offset.z = lerp(cam_offset.z, cam_offset.z + 1, delta * cam_speed * cam_dir.z)
	
	# set the new distance for both the spring and the camera itself
	cam_spring.spring_length = cam_offset.z
	cam.position.z = cam_offset.z
	
	var xRot = cam_target.rotation.x
	var yRot = cam_target.rotation.y
	
	cam_target.rotation.x = lerp(xRot, xRot + 1, delta * cam_speed * cam_dir.x)
	cam_target.rotation.y = lerp(yRot, yRot + 1, delta * cam_speed * cam_dir.y)
