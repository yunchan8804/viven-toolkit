# GitHub 및 npm 배포 가이드

## 1. GitHub 저장소 설정

### 1.1 GitHub에서 새 저장소 생성
1. https://github.com/new 접속
2. Repository name: `viven-sdk-claude-toolkit`
3. Description: "Claude Code development toolkit for Viven SDK Unity VR projects"
4. Public 선택 (npm 공개 배포 시)
5. "Create repository" 클릭

### 1.2 로컬 Git 초기화 및 연결
```bash
cd D:\workspace\viven-sdk-claude-toolkit

# Git 초기화
git init

# 모든 파일 스테이징
git add .

# 첫 커밋
git commit -m "Initial commit: Viven SDK Claude Toolkit v1.0.0"

# GitHub 저장소 연결 (YOUR_USERNAME을 본인 GitHub 아이디로 변경)
git remote add origin https://github.com/YOUR_USERNAME/viven-sdk-claude-toolkit.git

# main 브랜치로 푸시
git branch -M main
git push -u origin main
```

## 2. npm 배포

### 2.1 npm 계정 준비
```bash
# npm 계정이 없다면 https://www.npmjs.com/signup 에서 가입

# npm 로그인
npm login
```

### 2.2 package.json 수정
`package.json`에서 다음 항목 업데이트:
```json
{
  "author": "YOUR_NAME <your.email@example.com>",
  "repository": {
    "type": "git",
    "url": "https://github.com/YOUR_USERNAME/viven-sdk-claude-toolkit.git"
  }
}
```

### 2.3 배포 전 테스트
```bash
# 로컬에서 패키지 테스트
cd D:\workspace\viven-sdk-claude-toolkit
npm link

# 테스트용 Unity 프로젝트에서
cd D:\workspace\TestUnityProject
viven-toolkit install
```

### 2.4 npm 배포
```bash
cd D:\workspace\viven-sdk-claude-toolkit

# 배포 (처음)
npm publish

# 이후 버전 업데이트 시
npm version patch  # 1.0.0 -> 1.0.1 (버그 수정)
npm version minor  # 1.0.0 -> 1.1.0 (기능 추가)
npm version major  # 1.0.0 -> 2.0.0 (큰 변경)
npm publish
```

## 3. 버전 관리 전략

### 3.1 Semantic Versioning (SemVer)
- **MAJOR** (1.x.x): 호환되지 않는 API 변경
- **MINOR** (x.1.x): 하위 호환되는 기능 추가
- **PATCH** (x.x.1): 하위 호환되는 버그 수정

### 3.2 Git 브랜치 전략
```
main (또는 master)
  └── develop
        ├── feature/새기능명
        └── fix/버그수정명
```

### 3.3 일반적인 워크플로우
```bash
# 새 기능 개발
git checkout -b feature/add-new-snippet
# ... 작업 ...
git add .
git commit -m "feat: Add new Lua snippet for XYZ"
git push origin feature/add-new-snippet
# GitHub에서 Pull Request 생성 후 병합

# main으로 병합 후
git checkout main
git pull
npm version minor
npm publish
git push --tags
```

## 4. 릴리스 관리

### 4.1 GitHub Release 생성
1. GitHub 저장소 → "Releases" → "Create a new release"
2. Tag: `v1.0.0` (npm 버전과 일치)
3. Release title: `v1.0.0 - Initial Release`
4. Description: 변경 사항 요약
5. "Publish release"

### 4.2 CHANGELOG.md 유지 (선택)
```markdown
# Changelog

## [1.0.0] - 2025-01-XX
### Added
- Initial release
- CLAUDE.md guide for Viven SDK
- 9 Lua code snippets
- 11 slash commands
- WebFetch permissions for Viven docs
```

## 5. 유지보수

### 5.1 이슈 관리
- GitHub Issues 탭 활용
- 버그 리포트, 기능 요청 템플릿 설정 가능

### 5.2 정기 업데이트
- Viven SDK 업데이트 시 CLAUDE.md 반영
- 새로운 패턴 발견 시 스니펫 추가
- 사용자 피드백 반영

## 6. 빠른 참조 명령어

```bash
# Git
git status                    # 상태 확인
git add .                     # 모든 변경 스테이징
git commit -m "메시지"         # 커밋
git push                      # 푸시
git pull                      # 풀

# npm
npm version patch/minor/major # 버전 업
npm publish                   # 배포
npm link                      # 로컬 테스트용 링크
npm unlink                    # 링크 해제

# 배포 원클릭 (커밋 후)
npm version patch && npm publish && git push --tags
```

## 7. 문제 해결

### npm publish 오류
- `npm ERR! 403`: 패키지명 중복 → package.json의 name 변경
- `npm ERR! 401`: 로그인 필요 → `npm login`

### Git 푸시 오류
- `rejected`: 먼저 `git pull` 후 다시 푸시
- 인증 오류: GitHub Personal Access Token 확인
