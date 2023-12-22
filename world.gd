extends Node2D


@onready var visual_polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	visual_polygon_2d.polygon = collision_polygon_2d.polygon
