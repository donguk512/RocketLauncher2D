# 🚀 Spaceflight Simulator (SFS) Homage 개발 관리 문서

> 본 문서는 데스크탑/노트북 크로스 플랫폼 개발 및 AI-개발자 간 컨텍스트 동기화를 위해 매 작업마다 자동으로 업데이트됩니다.

---

## 🤝 0. 멘토링 & 협업 원칙 (중요!)
- **학습 중심 멘토링**: AI는 임의로 씬 파일(`.tscn`)이나 스크립트(`.gd`)를 먼저 생성하지 않습니다.
- **사전 요청 원칙**: 사용자가 명시적으로 "코드를 작성해줘", "씬을 생성해줘"라고 요청할 때만 파일 생성 및 수정을 수행합니다.
- **설명 및 비유 우선**: Godot의 구조, 노드의 기능, 작동 원리를 **Roblox의 대응 개념에 빗대어 명쾌하게 설명**하고, 사용자가 에디터에서 직접 구현해 볼 수 있도록 가이드합니다.

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
├── Sprite2D (임시 로켓 기체 텍스처 - icon.svg)
├── CollisionShape2D (CapsuleShape2D / 기체 충돌체)
├── ThrustParticles (CPUParticles2D / 메인 엔진 분사 화염)
├── RCSLeftParticles (CPUParticles2D / 좌측 RCS 자세제어 화염)
├── RCSRightParticles (CPUParticles2D / 우측 RCS 자세제어 화염)
└── LandingGearRay (RayCast2D / 착륙 지면 감지용 레이캐스트)
```

---

## ⚙️ 3. 구현 및 검증 현황

### ✅ 1) 로켓 물리 및 역학 시스템 (`rocket.gd`)
- **F6 단독 실행 검증 완료**: 로켓 노드가 물리 엔진(중력)의 영향을 받아 정상 낙하하는 물리 인스턴스화 확인.
- **물리 적분 제어 (`_integrate_forces`)**:
  - 엔진 추력: `-global_transform.y` 방향 `apply_central_force()` 가속.
  - 자세 제어: A/D 입력에 따른 `apply_torque()` 각운동량 제어.
- **가변 질량 시스템 ($F = ma$)**: `mass = dry_mass + current_fuel` 실시간 갱신.

---

## 🚧 4. 미해결 이슈 및 학습 과제
- [ ] **2D 좌표계 및 뷰포트 원점 이해**: `(0, 0)` 위치와 화면 렌더링 기준점 이해.
- [ ] **카메라 추종 시스템 (`Camera2D`)**: 로켓을 화면 중앙에 두고 따라가게 만드는 방법.
- [ ] **정적 지형 구성 (`StaticBody2D`)**: 로켓이 착륙할 발사대 및 바닥 생성.
- [ ] **HUD 계기판 (`CanvasLayer`)**: 스크린 고정 UI와 월드 좌표계의 분리.

---

## 🎯 5. 다음 작업할 목표
1. **좌표계 및 카메라 개념 학습**: 왜 로켓이 좌상단에서 떨어졌는지 원리 파악 및 `Camera2D` 노드 역할 학습.
2. **발사대/바닥 지형 실습**: 사용자가 직접 `StaticBody2D`를 배치하여 로켓을 바닥에 세우는 방법 안내.
