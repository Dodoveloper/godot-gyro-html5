# Example class to show how to get gyroscope data from mobile devices running
# HTML5 apps. We leverage the Godot-Javascript bridge to make JavaScript calls
# and get data from the sensors.
# This is needed because the Godot API for the gyroscope only works on **native**
# mobile platforms.
# Note: apparently, when using JavaScript.create_callback, we need to do that
# at the top of the script, otherwise it will not work.
class_name SensorComponent
extends Node


signal ios_permission_requested(value)
signal gyroscope_triggered(coords)

var window = JavaScript.get_interface("window")
var console = JavaScript.get_interface("console")
var handleOrientation = JavaScript.create_callback(self, "_handle_orientation")
var iosHandleOrientation = JavaScript.create_callback(self, "_ios_handle_orientation")
# iOS only: should be set from a different script
var is_permission_asked := false setget _set_is_permission_asked
var os_string: String


func _ready() -> void:
	if OS.has_feature("JavaScript"):
		# try to get OS, getOS() is defined in the head_include property!
		os_string = window.getOS()
		# works on Android
		if os_string == "Android":
			window.addEventListener("deviceorientation", handleOrientation)


# Event listener: handles orientation by getting the event data.
func _handle_orientation(args: Array) -> void:
	var event = args[0]
	if event != null:
		var coords := Vector3(event.beta, event.gamma, event.alpha)
		emit_signal("gyroscope_triggered", coords)
	else:
		print("Couldn't get event data!")


# iOS only. This gets triggered when the user interacted with a UI element
# to explicitly ask for permission to use a sensor.
# This function actually triggers the code to request permission to the user
# and subsequently invoke the JavaScript callback to get sensor data.
func _set_is_permission_asked(value: bool) -> void:
	is_permission_asked = value
	if value:
		var devicemotionevent = JavaScript.get_interface("DeviceMotionEvent")
		devicemotionevent.requestPermission().then(iosHandleOrientation).\
				catch(console.error)


# iOS only: checks if permission to use the gyroscope was granted.
# User interaction is mandatory for iPhones, plus note that it only works
# under an HTTPS website.
func _ios_handle_orientation(args: Array) -> void:
	var state = args[0]
	if state == "granted":
		window.addEventListener("deviceorientation", handleOrientation)
	else:
		print("Request to access the orientation was rejected")
	emit_signal("ios_permission_requested", state == "granted")
