extends Node3D

@onready var camera = null

func _ready():
    # Get the viewport's 3D camera
    if camera == null:
        camera = get_viewport().get_camera_3d()