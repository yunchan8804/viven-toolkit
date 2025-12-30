#!/usr/bin/env python3
"""
DocFX API 문서 동기화 스크립트

DocFX로 생성된 YML 파일을 파싱하여 toolkit의 API 정보를 업데이트합니다.

사용법:
    python sync-docfx-api.py --docfx-path <docfx_api_path> --output <output_path>

예시:
    python sync-docfx-api.py --docfx-path "E:/viven-client/Documentation/api/VivenAPI" --output "./api-reference.md"
"""

import os
import sys
import yaml
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional


class DocFXParser:
    """DocFX YML 파일 파서"""

    def __init__(self, docfx_path: str):
        self.docfx_path = Path(docfx_path)
        self.apis: Dict[str, Any] = {}
        self.deprecated_apis: List[Dict] = []
        self.new_apis: List[Dict] = []

    def parse_all(self) -> Dict[str, Any]:
        """모든 YML 파일을 파싱"""
        if not self.docfx_path.exists():
            raise FileNotFoundError(f"DocFX 경로를 찾을 수 없습니다: {self.docfx_path}")

        yml_files = list(self.docfx_path.glob("*.yml"))
        print(f"[INFO] {len(yml_files)}개의 YML 파일 발견")

        for yml_file in yml_files:
            if yml_file.name == "toc.yml":
                continue
            self._parse_yml_file(yml_file)

        return self.apis

    def _parse_yml_file(self, yml_file: Path):
        """단일 YML 파일 파싱"""
        try:
            with open(yml_file, 'r', encoding='utf-8') as f:
                content = f.read()

            # YamlMime 헤더 제거
            if content.startswith("### YamlMime"):
                content = '\n'.join(content.split('\n')[1:])

            data = yaml.safe_load(content)

            if not data or 'items' not in data:
                return

            for item in data['items']:
                self._process_item(item)

        except Exception as e:
            print(f"[WARN] {yml_file.name} 파싱 실패: {e}")

    def _process_item(self, item: Dict):
        """API 항목 처리"""
        uid = item.get('uid', '')
        item_type = item.get('type', '')

        # 클래스/인터페이스만 처리
        if item_type not in ['Class', 'Method', 'Property']:
            return

        # API 정보 추출
        api_info = {
            'uid': uid,
            'name': item.get('name', ''),
            'full_name': item.get('fullName', ''),
            'type': item_type,
            'summary': item.get('summary', ''),
            'remarks': item.get('remarks', ''),
            'syntax': item.get('syntax', {}),
            'namespace': item.get('namespace', ''),
            'source_file': item.get('source', {}).get('remote', {}).get('path', ''),
        }

        # Deprecated 확인
        attributes = item.get('attributes', [])
        for attr in attributes:
            if 'ObsoleteAttribute' in str(attr.get('type', '')):
                api_info['deprecated'] = True
                api_info['deprecated_message'] = attr.get('arguments', [{}])[0].get('value', '')
                self.deprecated_apis.append(api_info)

        # 카테고리별 저장
        category = self._extract_category(uid)
        if category not in self.apis:
            self.apis[category] = []
        self.apis[category].append(api_info)

    def _extract_category(self, uid: str) -> str:
        """UID에서 카테고리 추출"""
        # TwentyOz.VivenSDK.Scripts.Core.VivenAPI.PlayerAPI.Player.Mine
        parts = uid.split('.')

        # VivenAPI 이후 부분 추출
        if 'VivenAPI' in parts:
            idx = parts.index('VivenAPI')
            if idx + 1 < len(parts):
                return parts[idx + 1]  # PlayerAPI, UIAPI, RoomAPI 등

        return 'Other'


class ToolkitUpdater:
    """Toolkit 업데이트 도구"""

    def __init__(self, parser: DocFXParser):
        self.parser = parser

    def generate_api_reference(self) -> str:
        """API 레퍼런스 마크다운 생성"""
        lines = [
            "# VIVEN SDK API Reference",
            "",
            f"> 자동 생성: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
        ]

        # Deprecated API 섹션
        if self.parser.deprecated_apis:
            lines.extend([
                "## Deprecated APIs",
                "",
                "| API | 메시지 |",
                "|-----|--------|",
            ])
            for api in self.parser.deprecated_apis:
                name = api['name']
                msg = api.get('deprecated_message', 'N/A')
                lines.append(f"| `{name}` | {msg} |")
            lines.append("")

        # 카테고리별 API
        for category, apis in sorted(self.parser.apis.items()):
            if not apis:
                continue

            lines.extend([
                f"## {category}",
                "",
            ])

            # 타입별 분류
            classes = [a for a in apis if a['type'] == 'Class']
            methods = [a for a in apis if a['type'] == 'Method']
            properties = [a for a in apis if a['type'] == 'Property']

            if classes:
                lines.append("### Classes")
                for cls in classes:
                    lines.append(f"- `{cls['name']}`: {cls['summary'][:100] if cls['summary'] else 'N/A'}")
                lines.append("")

            if properties:
                lines.append("### Properties")
                lines.append("")
                lines.append("| Property | Type | Description |")
                lines.append("|----------|------|-------------|")
                for prop in properties:
                    name = prop['name']
                    return_type = prop.get('syntax', {}).get('return', {}).get('type', 'N/A')
                    summary = prop['summary'][:50] if prop['summary'] else 'N/A'
                    lines.append(f"| `{name}` | `{return_type}` | {summary} |")
                lines.append("")

            if methods:
                lines.append("### Methods")
                lines.append("")
                lines.append("| Method | Parameters | Returns | Description |")
                lines.append("|--------|------------|---------|-------------|")
                for method in methods:
                    name = method['name']
                    params = method.get('syntax', {}).get('parameters', [])
                    param_str = ', '.join([p.get('id', '') for p in params]) if params else '-'
                    return_type = method.get('syntax', {}).get('return', {}).get('type', 'void')
                    summary = method['summary'][:40] if method['summary'] else 'N/A'
                    lines.append(f"| `{name}` | {param_str} | `{return_type}` | {summary} |")
                lines.append("")

        return '\n'.join(lines)

    def generate_lua_stubs(self) -> str:
        """Lua 타입 스텁 파일 생성"""
        lines = [
            "---@meta",
            "-- VIVEN SDK Lua Type Stubs",
            f"-- 자동 생성: {datetime.now().strftime('%Y-%m-%d')}",
            "",
        ]

        for category, apis in sorted(self.parser.apis.items()):
            # 메서드만 스텁 생성
            methods = [a for a in apis if a['type'] == 'Method']
            properties = [a for a in apis if a['type'] == 'Property']

            if not methods and not properties:
                continue

            # 카테고리 클래스 생성
            class_name = category.replace('API', '')
            lines.append(f"---@class {class_name}")

            for prop in properties:
                prop_type = self._lua_type(prop.get('syntax', {}).get('return', {}).get('type', 'any'))
                lines.append(f"---@field {prop['name']} {prop_type}")

            lines.append(f"{class_name} = {{}}")
            lines.append("")

            for method in methods:
                # 함수 시그니처 생성
                params = method.get('syntax', {}).get('parameters', [])
                param_strs = []
                for p in params:
                    p_name = p.get('id', 'arg')
                    p_type = self._lua_type(p.get('type', 'any'))
                    param_strs.append(f"{p_name}")
                    lines.append(f"---@param {p_name} {p_type}")

                return_info = method.get('syntax', {}).get('return', {})
                if return_info:
                    ret_type = self._lua_type(return_info.get('type', 'void'))
                    if ret_type != 'void':
                        lines.append(f"---@return {ret_type}")

                lines.append(f"function {class_name}.{method['name']}({', '.join(param_strs)}) end")
                lines.append("")

        return '\n'.join(lines)

    def _lua_type(self, csharp_type: str) -> str:
        """C# 타입을 Lua 타입으로 변환"""
        type_map = {
            'System.String': 'string',
            'System.Boolean': 'boolean',
            'System.Int32': 'integer',
            'System.Single': 'number',
            'System.Void': 'void',
            'void': 'void',
            'string': 'string',
            'bool': 'boolean',
            'int': 'integer',
            'float': 'number',
        }

        # 제네릭/복합 타입 처리
        if 'Task<' in csharp_type:
            return 'boolean'  # async task는 boolean으로 단순화

        return type_map.get(csharp_type, 'any')

    def generate_diff_report(self, previous_apis: Optional[Dict] = None) -> str:
        """변경사항 리포트 생성"""
        lines = [
            "# API 변경 리포트",
            f"생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
        ]

        # Deprecated API
        if self.parser.deprecated_apis:
            lines.append("## Deprecated APIs")
            for api in self.parser.deprecated_apis:
                lines.append(f"- `{api['full_name']}`: {api.get('deprecated_message', 'N/A')}")
            lines.append("")

        # 총 API 수
        total = sum(len(apis) for apis in self.parser.apis.values())
        lines.append(f"## 통계")
        lines.append(f"- 총 API 수: {total}")
        lines.append(f"- 카테고리 수: {len(self.parser.apis)}")
        lines.append(f"- Deprecated API 수: {len(self.parser.deprecated_apis)}")

        return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description='DocFX API 문서 동기화 도구')
    parser.add_argument('--docfx-path', required=True, help='DocFX API YML 파일 경로')
    parser.add_argument('--output', default='./api-reference.md', help='출력 파일 경로')
    parser.add_argument('--format', choices=['markdown', 'lua', 'json', 'report'],
                       default='markdown', help='출력 형식')

    args = parser.parse_args()

    print(f"[INFO] DocFX 경로: {args.docfx_path}")
    print(f"[INFO] 출력 형식: {args.format}")

    # 파싱
    docfx_parser = DocFXParser(args.docfx_path)
    docfx_parser.parse_all()

    # 업데이터 생성
    updater = ToolkitUpdater(docfx_parser)

    # 출력 생성
    if args.format == 'markdown':
        output = updater.generate_api_reference()
    elif args.format == 'lua':
        output = updater.generate_lua_stubs()
        args.output = args.output.replace('.md', '.lua')
    elif args.format == 'json':
        output = json.dumps(docfx_parser.apis, indent=2, ensure_ascii=False)
        args.output = args.output.replace('.md', '.json')
    elif args.format == 'report':
        output = updater.generate_diff_report()

    # 파일 저장
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(output)

    print(f"[SUCCESS] 출력 파일 생성: {output_path}")
    print(f"[INFO] 총 {sum(len(apis) for apis in docfx_parser.apis.values())}개 API 처리")
    print(f"[INFO] Deprecated API: {len(docfx_parser.deprecated_apis)}개")


if __name__ == '__main__':
    main()
