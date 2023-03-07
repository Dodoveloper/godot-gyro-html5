# Example class to show how to get gyroscope data from mobile devices running
# HTML5 apps. We leverage the Godot-Javascript bridge to make JavaScript calls
# and get data from the sensors.
# This is needed because the Godot API for the gyroscope only works on **native**
# mobile platforms.
extends Node


var window = JavaScript.get_interface("window")
var console = JavaScript.get_interface("console")
# Need to create the callback here or it doesn't work
var handleOrientation = JavaScript.create_callback(self, "handle_orientation")
var iosHandleOrientation = JavaScript.create_callback(self, "ios_handle_orientation")

onready var os_label := $Control/OS as Label
onready var gyro_label := $Control/Gyroscope as Label
# iOS only
onready var enable_gyro_btn := $Control/EnableGyro as CheckButton


func _ready() -> void:
	enable_gyro_btn.hide()
	if OS.has_feature("JavaScript"):
		# try to get OS, getOS() is defined in the head_include property!
		var os_string = window.getOS()
		os_label.text = "OS: %s" % os_string
		# works on Android
		if os_string == "Android":
			window.addEventListener("deviceorientation", handleOrientation)
		elif os_string == "iOS":
			enable_gyro_btn.show()
#		window.addEventListener("deviceorientation",
#			(event) => window.result = event.alpha + "|" + event.beta + "|" + event.gamma
#		);


# Event listener: handles orientation by getting the event data
func handle_orientation(args: Array) -> void:
	var event = args[0]
	if event != null:
		var coords := "(%.2f, %.2f, %.2f)" % [event.alpha, event.beta, event.gamma]
		gyro_label.text = "Gyroscope: %s" % coords
	else:
		print("Couldn't get event data!")


# iOS only: checks if permission to use the gyroscope was granted.
# User interaction is mandatory for iPhones, plus note that it only works
# under an HTTPS website.
func ios_handle_orientation(args: Array) -> void:
	var state = args[0]
	enable_gyro_btn.pressed = args[0] == "granted"
	if state == "granted":
		window.addEventListener("deviceorientation", handleOrientation)
	else:
		print("Request to access the orientation was rejected")


func _on_CheckButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		var devicemotionevent = JavaScript.get_interface("DeviceMotionEvent")
		devicemotionevent.requestPermission().then(iosHandleOrientation).\
				catch(console.error)
