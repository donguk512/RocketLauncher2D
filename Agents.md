# 🚀 Spaceflight Simulator (SFS) Homage 개발 관리 문서

> 본 문서는 데스크탑/노트북 크로스 플랫폼 개발 및 AI-개발자 간 컨텍스트 동기화를 위해 매 작업마다 자동으로 업데이트됩니다.

---

## 📌 1. 프로젝트 개요 및 환경
- **엔진**: Godot 4.x (Standard GDScript 버전)
- **렌더러**: Compatibility (OpenGL 3 / WebGL 2 기반, 구형 기기 및 내장 그래픽 최적화)
- **목표 사양**: 15년 전 구형 듀얼코어 노트북에서도 60fps 안정적 구동
- **핵심 아키텍처**:
  - `RigidBody2D` 단일체 및 `_integrate_forces` 직접 물리 적분
  - 가벼운 `CPUParticles2D` 기반 화염 이펙트 (GPU 파티클 배제)
  - `RayCast2D` 기반 지형 거리 측정 및 착륙/충돌 감지
  - 신호(`Signal`) 기반 비동기 UI(`CanvasLayer`) 데이터 브로드캐스팅

---

## 🌲 2. 현재 씬(Scene) 및 노드(Node) 계층 구조

### 🚀 `res://scenes/rocket.tscn` (Rocket 단일체)
```text
Rocket (RigidBody2D) [@scripts/rocket.gd]
├── Sprite2D (임시 로켓 기체 텍스처/플레이스홀더)
├── CollisionShape2D (CapsuleShape2D / 기체 충돌체)
├── ThrustParticles (CPUParticles2D / 메인 엔진 분사 화염)
├── RCSLeftParticles (CPUParticles2D / 좌측 RCS 자세제어 화염)
├── RCSRightParticles (CPUParticles2D / 우측 RCS 자세제어 화염)
└── LandingGearRay (RayCast2D / 착륙 지면 감지용 레이캐스트)
```

---

## ⚙️ 3. 구현된 핵심 로직

### ✅ 1) 로켓 물리 및 역학 시스템 (`rocket.gd`)
- **물리 적분 제어 (`_integrate_forces`)**:
  - 엔진 추력: 로켓의 로컬 상단 벡터(`-global_transform.y`) 방향으로 `apply_central_force()` 가속.
  - 자세 제어 토크: A/D 입력을 받아 `apply_torque()`로 각운동량 제어.
- **가변 질량 시스템 ($F = ma$)**:
  - 건조 질량(`dry_mass`) + 현재 연료량(`current_fuel_mass`)을 합산하여 매 틱마다 `mass` 동적 갱신.
  - 연료 소모에 따라 질량이 줄어들어 동일 추력 대비 가속도가 점진적으로 증가.
- **이펙트 연동**:
  - 추력 활성화 시 `CPUParticles2D` 활성화 및 엔진 점화.
- **UI 연동 시그널**:
  - `fuel_changed(current, max)`: 잔여 연료 비율 전송.
  - `thrust_state_changed(is_thrusting)`: 추력 ON/OFF 상태 전송.

---

## 🚧 4. 미해결 이슈 및 최적화 체크리스트
- [ ] 조작 키맵(`InputMap`) 프로젝트 설정 등록 (기본 `ui_accept`, `ui_left`, `ui_right` 외에 `throttle_up`, `throttle_down` 등 확장 필요)
- [ ] 지상 런치패드 및 중력장 행성 씬 구성 (`world.tscn`)
- [ ] CanvasLayer 기반 HUD 계기판 (고도, 속도계, 연료 게이지, TWR 표시기) 제작
- [ ] 착륙 판정 로직 (속도/각도 임계값 기반 착륙 성공 vs 폭발 판정)

---

## 🎯 5. 다음 작업할 목표
1. 메인 월드 씬(`res://scenes/world.tscn`) 및 행성/런치패드 지형 생성 (2D 정적 지형 `StaticBody2D`).
2. 로켓 추종 2D 카메라(`Camera2D`)의 줌/스무딩 세팅.
3. CanvasLayer HUD UI 연결 (연료 게이지 및 고도/속도 실시간 표시).
