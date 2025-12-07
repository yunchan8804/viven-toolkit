# Viven SDK Claude Toolkit

[![npm version](https://badge.fury.io/js/viven-sdk-claude-toolkit.svg)](https://www.npmjs.com/package/viven-sdk-claude-toolkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Viven SDK 기반 Unity VR 프로젝트를 위한 Claude Code 개발 도구입니다.

## 개요

이 툴킷은 Viven SDK 개발 시 Claude Code의 도움을 극대화합니다:

- **CLAUDE.md**: SDK 아키텍처, 패턴, 베스트 프랙티스 가이드
- **슬래시 커맨드**: 11개의 Viven 전용 커맨드
- **코드 스니펫**: 네트워크/RPC 시스템 포함 Lua 템플릿
- **WebFetch 권한**: Viven 공식 문서 실시간 조회

## 설치 방법

### 빠른 설치 (권장)

Unity 프로젝트 디렉토리에서 실행:

```bash
npx viven-sdk-claude-toolkit install
```

### 전역 설치

```bash
npm install -g viven-sdk-claude-toolkit

# 이후 아무 Unity 프로젝트에서:
viven-toolkit install
```

### 수동 설치

1. 이 저장소를 클론
2. 다음 파일들을 프로젝트 루트에 복사:
   - `templates/CLAUDE.md` → `./CLAUDE.md`
   - `templates/.claude/` → `./.claude/`
   - `templates/snippets/` → `./viven-snippets/`

## 설치되는 파일

```
YourProject/
├── CLAUDE.md                    # Claude Code 메인 가이드
├── .claude/
│   └── settings.local.json      # WebFetch 권한
└── viven-snippets/
    └── lua/
        ├── basic-script.lua
        ├── grabbable-handler.lua
        ├── step-manager.lua
        ├── event-callbacks.lua
        ├── pose-detector.lua
        ├── rpc-system.lua
        ├── host-client-manager.lua
        ├── room-prop-encoder.lua
        └── network-event-callback.lua
```

## 주요 기능

### 1. SDK 아키텍처 가이드
- 네임스페이스 구조
- 핵심 컴포넌트 계층
- 필수 컴포넌트 조합

### 2. Lua 스크립팅 패턴
- 의존성 주입 (checkInject)
- 생명주기 함수
- 이벤트 핸들링
- 컴포넌트 접근

### 3. XR 기능
- 손 추적 API
- 햅틱 피드백
- 포즈/제스처 감지

### 4. 게임 플로우
- IStep 기반 단계 관리
- 타임라인 연동
- 이벤트 콜백 시스템

### 5. 네트워크 멀티플레이어
- Room 속성 관리 (RoomProp)
- RPC (Remote Procedure Call) 시스템
- 신뢰성 있는 메시지 전송
- Host-Client 아키텍처
- 플레이어 입장/퇴장 이벤트
- 호스트 전환 처리
- 데이터 인코딩/디코딩 유틸리티

## 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/viven:init` | 새 프로젝트/오브젝트 초기화 |
| `/viven:lua-script` | Lua 스크립트 생성 |
| `/viven:grabbable` | Grabbable 오브젝트 설정 |
| `/viven:component` | 컴포넌트 추가 가이드 |
| `/viven:network` | 네트워크 동기화 설정 |
| `/viven:step` | IStep 게임 플로우 생성 |
| `/viven:docs [topic]` | 온라인 문서 조회 |
| `/viven:troubleshoot` | 문제 해결 가이드 |
| `/viven:rpc` | RPC 멀티플레이어 시스템 |
| `/viven:room` | Room 속성 및 이벤트 |
| `/viven:host-client` | Host-Client 아키텍처 |

## 온라인 문서

- Wiki: https://wiki.viven.app/developer
- API Reference: https://sdkdoc.viven.app/api/SDK/TwentyOz.VivenSDK

## 프로젝트별 커스터마이징

`CLAUDE.md` 끝에 프로젝트별 규칙 추가:

```markdown
---

## 프로젝트 특화 설정

### 커스텀 컴포넌트
- MyGameManager
- MyCustomObject

### 프로젝트 규칙
- Lua 스크립트는 Assets/MyProject/Scripts에 위치
```

## 요구사항

- Node.js 14.0.0+
- Unity 6000.0+
- Viven SDK 설치됨
- Claude Code CLI

## 기여하기

1. 저장소 포크
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시 (`git push origin feature/amazing-feature`)
5. Pull Request 생성

## 라이선스

MIT License - [LICENSE](LICENSE) 파일 참조
