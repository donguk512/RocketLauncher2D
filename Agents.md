# 🚀 Spaceflight Simulator (SFS) Homage 개발 관리 문서

> 본 문서는 데스크탑/노트북 크로스 플랫폼 개발 및 AI-개발자 간 컨텍스트 동기화를 위해 매 작업마다 자동으로 업데이트됩니다.

---

## 🤝 0. 멘토링 & 협업 원칙 (중요!)
- **직접 코딩 & 학습 중심 멘토링 (USER 최우선 방침)**: 사용자가 직접 작성하며 배우는 것을 목표로 합니다. AI는 사전 코드 생성을 지양하고 개념 가이드, 구조 비유, 코드 블록 가이드 제시 위주로 서포트합니다.
- **사전 요청 원칙**: 사용자가 명시적으로 "코드를 작성해줘", "씬을 생성해줘"라고 요청할 때만 파일 생성 및 수정을 수행합니다.
- **Roblox 비유 우선**: Godot의 구조, 노드의 기능, 작동 원리를 **Roblox의 대응 개념에 빗대어 명쾌하게 설명**하여 사용자가 에디터에서 직접 구현해 볼 수 있도록 도웁니다.

---

## 📌 1. 프로젝트 개요 및 환경
- **엔진**: Godot 4.x (Standard GDScript 버전)
- **렌더러**: Compatibility (OpenGL 3 / WebGL 2 기반, 구형 기기 및 내장 그래픽 최적화)
- **목표 사양**: 15년 전 구형 듀얼코어 노트북에서도 60fps 안정적 구동
- **물리 스케일링 표준**: `1 px = 10 cm (0.1 m)` (Roblox `1 Stud = 28 cm`와 같은 단위 기준)
- **핵심 아키텍처**:
  - `RigidBody2D` 단일체 및 `_integrate_forces` 직접 물리 적분
  - 가벼운 `CPUParticles2D` 기반 화염 이펙트 (GPU 파티클 배제)
  - `RayCast2D` 기반 지형 거리 측정 및 착륙/충돌 감지
  - 신호(`Signal`) 기반 비동기 UI(`CanvasLayer`) 데이터 브로드캐스팅
  - `planet.tscn` 단일 템플릿의 `@export` 변수 인스턴스화 기반 태양계 천체 재활용

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

### 🌍 `res://Scenes/launchpad.tscn` (평면 발사대 & 구 테스트 스테이지)
```text
Launchpad (Node2D)
├── Rocket (Rocket 인스턴스 - rocket.tscn)
└── StaticBody2D (바닥 지형 / Anchored Part)
    ├── ColorRect (바닥 비주얼 / 1152x40)
    └── CollisionShape2D (RectangleShape2D 충돌체 / 1152x40)
```

### 🪐 `res://Scenes/planet.tscn` (원형 지구 행성 & 방사형 중력장 템플릿)
```text
Planet (StaticBody2D) [@Scripts/planet.gd]
├── Collider (CollisionShape2D / CircleShape2D, radius 실시간 연동)
└── GravityArea (Area2D / Point Gravity=On, Space Override=Replace)
    ├── CollisionShape2D (CircleShape2D, atmosphere_ratio 실시간 연동)
    └── Rocket (테스트용 인스턴스 - rocket.tscn)
```

---

## ⚙️ 3. 구현 및 최적화 현황

### ✅ 1) 물리-카메라 동기화 및 지평선 추종 (Horizon Camera)
- **카메라 처리 주기 동기화**: `Camera2D`의 `Process Callback`을 `Physics`로 두고, `_physics_process`에서 직접 `camera.global_rotation = up_dir.angle() + PI * 0.5`를 대입하여 물리 틱과 1:1 동기화 완료 (화면 떨림/지터 완벽 해소).
- **카메라 하드락 해제**: `camera.ignore_rotation = false` 처리로 뷰포트 회전 활성화.
- **2D 픽셀 물리 스케일 튜닝**: `Max Thrust = 3,500,000 N` 적용으로 시원한 이륙 가속 확보.

### ✅ 2) 원형 행성 & 방사형 중력 시스템 (Radial Gravity)
- **`Area2D` Point Gravity**: 엔진 빌트인 점 중력(`Gravity Point = true`, `Replace` 모드)을 활용해 코드 0줄로 완벽한 구형 행성 중력장 구축.
- **반지름-충돌체 자동 동기화 (`planet.gd`)**: 스크립트 내 `@export var radius` 및 `@export var atmosphere_ratio`에 Setter를 도입하여, 인스펙터에서 행성 반지름 크기를 변경하면 지표면 비주얼(`_draw()`), 지표면 충돌체(`Collider`), 중력 영향권(`GravityArea`) 세 가지가 실시간 100% 자동 동기화 연동 완료.

---

## 🚧 4. 주말 구현 목표 & 학습 과제
- [ ] **`planet.tscn` 재활용 멀티 행성 배치 (`solar_system.tscn`)**: 지구, 달, 화성 씬 중첩 인스턴스화 및 공전 스크립트 작성.
- [ ] **M 키 지도 뷰 트랜지션 (Map View)**: `Camera2D` + `Tween` 기반 줌아웃 및 지도 모드 카메라 전환.
- [ ] **착륙 판정 로직 (`LandingGearRay`)**: 속도 및 각도에 따른 착륙 성공 vs 폭발 구현.
- [ ] **UI 계기판 (`CanvasLayer`)**: 실시간 고도, 수직 속도(VSI), 연료 게이지 HUD 제작.

---

## 🎯 5. 스프린트 진행 현황
1. [x] **발사대 및 바닥 만들기**: `StaticBody2D` 바닥 구축 완료!
2. [x] **추종 카메라 달기**: `Camera2D` 연동 및 부드러운 물리 동기화 완료!
3. [x] **원형 행성 & 방사형 중력장 구축**: `planet.tscn` + `Area2D Point Gravity` 완료!
4. [x] **지평선 자동 추종 카메라**: 지구 둘레 비행 시 부드럽게 지평선 정렬 완료!
5. [x] **행성 반지름-충돌체 자동 연동**: `@tool` 및 Setter 기반 충돌 영역 & 중력 범위 자동 동기화 완료!
6. [ ] **주말 직접 코딩 스프린트**: 태양계 멀티 행성 배치 & M 키 Map View 줌 트랜지션.
