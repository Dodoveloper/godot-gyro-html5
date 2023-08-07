extends Node2D


const TILT_TRESHOLD := 5.0
const CAMERA_STEP := 3  # pixels
const CAMERA_SPEED := 200.0

onready var camera := $Camera2D as Camera2D
onready var sensor_component := $SensorComponent as SensorComponent
onready var background := $ParallaxBackground/ParallaxLayer1/Background as Sprite
onready var os_label := $"%OSLabel" as Label
onready var gyro_label := $"%GyroscopeLabel" as Label
# iOS only
onready var enable_gyro_btn := $"%EnableGyroBtn" as CheckButton
onready var farthest_layer := $ParallaxBackground/ParallaxLayer1 as ParallaxLayer
onready var default_camera_pos := camera.position.x


func _ready() -> void:
	# dynamically set camera limits based on the farthest parallax layer
	var screen_size_x: int = ProjectSettings.get("display/window/size/width")
	var background_extents := background.texture.get_size()
	# get the distance between one edge of the background and one of the screen size,
	# then scale it based on the background's parallax layer
	var scaled_delta_x := round(abs(background_extents.x - screen_size_x) / 2\
			/ farthest_layer.motion_scale.x)
	camera.limit_left = int(-scaled_delta_x)
	camera.limit_right = int(scaled_delta_x - screen_size_x)
	# update UI
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % sensor_component.os_string
	# plug-in logic
	if sensor_component.os_string == "iOS":
		enable_gyro_btn.show()


func _physics_process(delta: float) -> void:
	var dir := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	camera.position.x = lerp(camera.position.x, camera.position.x + CAMERA_STEP * dir,
			CAMERA_SPEED * delta)


# Used to trigger the iOS permission logic
func _on_EnableGyro_toggled(button_pressed: bool) -> void:
	sensor_component.is_permission_asked = button_pressed


# Here is where the sensor data is received, in case of success
func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void:
	# display text on the UI
	var text := "(%.2f, %.2f, %.2f)" % [coords.x, coords.y, coords.z]
	gyro_label.text = "Gyroscope: %s" % text
	# camera-moving logic
	var relative_scroll: float = coords.y if abs(coords.y) > TILT_TRESHOLD else 0.0
	camera.position.x += CAMERA_STEP * (relative_scroll / 2.5)
#	camera_pos.x = lerp(camera_pos.x, camera_pos.x + relative_scroll, 0.5)


# Updates the checkbox button based on the outcome of the request
func _on_SensorComponent_ios_permission_requested(value: bool) -> void:
	enable_gyro_btn.pressed = value
	enable_gyro_btn.disabled = true
