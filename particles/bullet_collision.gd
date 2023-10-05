extends GPUParticles2D

func _ready():
	finished.connect(func(): queue_free())
