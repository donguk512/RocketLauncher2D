class_name Rocket
extends RigidBody2D

## [Roblox vs Godot 비유 가이드]
## - class_name Rocket: Luau의 모듈 클래스 정의와 동일. 다른 스크립트에서 타입 힌트로 사용 가능.
## - RigidBody2D: Roblox의 BasePart에 Mass/AssemblyLinearVelocity 등이 내장된 물리 인스턴스.
## - Signal: Roblox의 BindableEvent와 동일. 이벤트 발행(emit) 시 연결된 리스너가 호출됨.
## - @onready: Roblox의 WaitForChild()를 스크립트 시작 시점에 한 번에 수행하는 키워드.

# ----------------------------------------------------
# 📡 시그널 (Roblox: BindableEvent)
# ----------------------------------------------------
signal fuel_changed(current_fuel: float, max_fuel: float)
signal thrust_changed(is_thrusting: bool, throttle_ratio: float)
signal rocket_destroyed()

# ----------------------------------------------------
# ⚙️ 로켓 파라미터 (인스펙터 노출 변수 / Roblox: Attributes)
# ----------------------------------------------------
@export_group("Mass & Fuel")
@export var dry_mass: float = 1000.0          ## 건조 중량 (연료 제외 기체 무게, kg)
@export var max_fuel_mass: float = 1000.0     ## 최대 탑재 가능 연료량 (kg)
@export var fuel_burn_rate: float = 50.0      ## 풀 스로틀 시 초당 연료 소모량 (kg/s)

@export_group("Engine & Control")
@export var max_thrust: float = 3500000.0       ## 최대 엔진 추력 (N - 뉴턴 단위)
@export var torque_strength: float = 8000000.0 ## 회전 토크 강도 (N*m)

# ----------------------------------------------------
# 🔍 노드 참조 (Roblox: local Part = Model:WaitForChild("Part"))
# ----------------------------------------------------
@onready var thrust_particles: CPUParticles2D = $ThrustParticles
@onready var rcs_left_particles: CPUParticles2D = $RCSLeftParticles
@onready var rcs_right_particles: CPUParticles2D = $RCSRightParticles
@onready var landing_ray: RayCast2D = $LandingGearRay

# ----------------------------------------------------
# 📊 런타임 상태 변수
# ----------------------------------------------------
var current_fuel: float = 0.0
var throttle: float = 1.0          ## 0.0 ~ 1.0 (스로틀 비율)
var is_thrusting: bool = false
var turn_input: float = 0.0        ## -1.0 (좌), 1.0 (우), 0.0 (중립)


func _ready() -> void:
	# 초기 연료 완충 및 질량 세팅
	current_fuel = max_fuel_mass
	_update_mass()
	
	# 파티클 기본 비활성화
	if thrust_particles:
		thrust_particles.emitting = false
	if rcs_left_particles:
		rcs_left_particles.emitting = false
	if rcs_right_particles:
		rcs_right_particles.emitting = false


func _process(_delta: float) -> void:
	# [입력 처리] - Roblox의 UserInputService / ContextActionService 역할
	# 기본 UI 액션 매핑(Space = ui_accept, A/Left = ui_left, D/Right = ui_right) 활용
	is_thrusting = Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)
	
	var left: bool = Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)
	var right: bool = Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)
	
	turn_input = 0.0
	if left:
		turn_input -= 1.0
	if right:
		turn_input += 1.0
	
	# RCS 파티클 시각 효과 제어
	if rcs_left_particles:
		rcs_left_particles.emitting = (turn_input > 0.0) # 우회전 시 좌측 노즐 분사
	if rcs_right_particles:
		rcs_right_particles.emitting = (turn_input < 0.0) # 좌회전 시 우측 노즐 분사


## [핵심 물리 적분 함수]
## Roblox의 RunService.Stepped + VectorForce 조작에 해당합니다.
## RigidBody2D의 모든 물리 연산(힘, 토크, 질량 반영)은 반드시 이 함수 내에서 직접 처리해야
## 물리 엔진 틱과 100% 동기화되어 흔들림이나 떨림 현상이 발생하지 않습니다.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dt: float = state.step
	
	# 1. 추력(Thrust) 및 연료 소모 처리
	if is_thrusting and current_fuel > 0.0:
		var fuel_spent: float = fuel_burn_rate * throttle * dt
		current_fuel = maxf(0.0, current_fuel - fuel_spent)
		_update_mass()
		
		# 로켓의 로컬 상단 방향 벡터 (-transform.y)
		# Godot 2D 좌표계는 아래가 +Y이므로, 위쪽은 -Y 벡터입니다.
		var forward_dir: Vector2 = -global_transform.y
		var thrust_force: Vector2 = forward_dir * (max_thrust * throttle)
		
		# 물리 상태에 중심력 적용 (Roblox: VectorForce:Apply())
		state.apply_central_force(thrust_force)
		
		if thrust_particles and not thrust_particles.emitting:
			thrust_particles.emitting = true
			thrust_changed.emit(true, throttle)
	else:
		if thrust_particles and thrust_particles.emitting:
			thrust_particles.emitting = false
			thrust_changed.emit(false, 0.0)
	
	# 2. 자세 제어 토크(Torque) 처리 (A / D 키)
	if turn_input != 0.0:
		var applied_torque: float = turn_input * torque_strength
		state.apply_torque(applied_torque)
	
	# 3. 연료 잔량 시그널 통보 (Roblox: RemoteEvent / BindableEvent:Fire())
	fuel_changed.emit(current_fuel, max_fuel_mass)


## 연료 감소에 따른 기체 질량(F=ma) 동적 갱신
func _update_mass() -> void:
	mass = dry_mass + current_fuel
