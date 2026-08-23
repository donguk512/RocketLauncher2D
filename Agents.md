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

### 🚀 `res://scenes/rocket.tscn` (Rocket 기체 단일체)
```text
Rocket (RigidBody2D) [@scripts/rocket.gd]
├── Camera2D (추종 카메라 / Process Callback = Physics, Position Smoothing 활성화)
├── Sprite2D (임시 로켓 기체 텍스처 - icon.svg)
├── CollisionShape2D (CapsuleShape2D / 기체 충돌체)
├── ThrustParticles (CPUParticles2D / 메인 엔진 분사 화염)
├── RCSLeftParticles (CPUParticles2D / 좌측 RCS 자세제어 화염)
├── RCSRightParticles (CPUParticles2D / 우측 RCS 자세제어 화염)
└── LandingGearRay (RayCast2D / 착륙 지면 감지용 레이캐스트)
```

### 🌍 `res://scenes/launchpad.tscn` (발사대 & 테스트 스테이지)
```text
Launchpad (Node2D)
├── Rocket (Rocket 인스턴스 - rocket.tscn)
└── StaticBody2D (바닥 지형 / Anchored Part)
    ├── ColorRect (바닥 비주얼 / 1152x40)
    └── CollisionShape2D (RectangleShape2D 충돌체 / 1152x40)
```

---

## ⚙️ 3. 구현 및 최적화 현황

### ✅ 1) 물리-카메라 동기화 최적화 (Physics Jitter 방지)
- **카메라 처리 주기 동기화**: `Camera2D`의 `Process Callback`을 `Idle`(`_process`)에서 `Physics`(`_physics_process`)로 전환하여 물리 적분 틱과 렌더링 간의 미세 떨림/버벅임 해소.
- **2D 픽셀 물리 스케일 튜닝**: `Max Thrust = 3,500,000 N` 적용으로 시원한 이륙 가속 확보.

---

## 🚧 4. 미해결 이슈 및 학습 과제
- [ ] **착륙 판정 로직 (`LandingGearRay`)**: 속도 및 각도에 따른 착륙 성공 vs 폭발 구현.
- [ ] **UI 계기판 (`CanvasLayer`)**: 실시간 고도, 수직 속도(VSI), 연료 게이지 HUD 제작.

---

## 🎯 5. 1시간 단기 스프린트 진행 현황
1. [x] **발사대 및 바닥 만들기**: `StaticBody2D` 바닥 구축 완료!
2. [x] **추종 카메라 달기**: `Camera2D` 연동 및 부드러운 물리 동기화 완료!
3. [ ] **첫 비행 및 호버링/착륙 테스트**: 발사대 이륙 ➡️ 공중 제어 ➡️ 발사대 착륙 손맛 검증.
