TODO:
	Create low poly map in blender.
	Create zombies AI
	Create turrets system

📝 1. Sistema de vida / energía

Auto: tiene una variable battery_charge (0–100) y una variable health (vida física).

battery_charge sube con el tiempo → objetivo de victoria.

health baja cuando los zombies lo golpean → derrota si llega a 0.

Jugador y zombies: cada uno con health, para poder recibir daño de balas.

📝 2. Sistema de daño

Cuando una bala toca un zombie → reduce zombie.health.

Cuando un zombie ataca el auto → reduce auto.health.

Cuando una bala enemiga (si decides que existan) toca al jugador → reduce player.health.
👉 Esto se puede centralizar en un Damageable.gd con función:

func apply_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()

📝 3. Oleadas de zombies (Spawner)

Un nodo ZombieSpawner.gd que:

Cada X segundos instancia zombies en puntos de spawn.

Incrementa la dificultad (más cantidad, más rápidos, tipos diferentes).

Ejemplo:

@export var spawn_points: Array[Marker3D]
@export var zombie_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var zombies_per_wave: int = 3

var _time := 0.0

func _physics_process(delta):
	_time += delta
	if _time >= spawn_interval:
		_time = 0
		for i in zombies_per_wave:
			var spawn = spawn_points.pick_random()
			var zombie = zombie_scene.instantiate()
			zombie.global_position = spawn.global_position
			get_parent().add_child(zombie)

📝 4. HUD (Interfaz de usuario)

Mostrar:

Vida del auto.

Progreso de carga de batería.

Vida del jugador.

Munición si la armas la necesitan.

Esto ayuda mucho a testear.

📝 5. Condiciones de victoria / derrota

Victoria: cuando battery_charge >= 100.

Derrota: cuando auto.health <= 0 o player.health <= 0.

Mostrar pantalla de resultado (You Win / You Lose) y opción de reinicio.

🚀 Orden recomendado

Sistema de vida/energía.

Sistema de daño (balas → zombies, zombies → auto).

HUD para ver valores en pantalla.

Spawner de zombies con oleadas.

Condiciones de victoria/derrota.

👉 Con eso ya vas a tener un primer prototipo jugable completo 🎉:

Entras al mapa.

El auto se empieza a cargar.

Zombies aparecen en oleadas y atacan.

El jugador los elimina con armas y torretas.

Ganás o perdés según el estado del auto.
