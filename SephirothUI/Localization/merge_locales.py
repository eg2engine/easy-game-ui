"""将 Git 中的换线名称增量翻译合并到完整客户端语言资源，不部署客户端。"""

from __future__ import annotations

import argparse
from datetime import datetime
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile


LANGUAGES = ("chn", "cht", "kor", "int")
SECTION = "ServerSetNames"
KEYS = ("LocalLine", "CrossBattle")
SECTION_PATTERN = re.compile(r"^[ \t]*\[([^\]\r\n]+)\][ \t]*(?:[;#].*)?$")
KEY_PATTERN = re.compile(r"^([ \t]*)([^=\r\n]+?)([ \t]*=[ \t]*)(.*)$")


def strip_line_ending(line: str) -> tuple[str, str]:
    """拆出单行原有换行符，修改目标键时保留该行的换行方式。"""
    for ending in ("\r\n", "\n", "\r"):
        if line.endswith(ending):
            return line[:-len(ending)], ending
    return line, ""


def parse_key(line: str):
    """识别非注释配置行；返回正则匹配，便于保留目标键的缩进和等号格式。"""
    if line.lstrip().startswith((";", "#", "//")):
        return None
    return KEY_PATTERN.fullmatch(line)


def read_source(path: Path) -> dict[str, str]:
    """严格读取无 BOM UTF-8 增量片段，要求仅含目标节和两个唯一翻译键。"""
    data = path.read_bytes()
    if data.startswith(b"\xef\xbb\xbf"):
        raise ValueError(f"{path}: 增量源文件应为无 BOM UTF-8")
    text = data.decode("utf-8")
    values = {}
    section_count = 0
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith((";", "#", "//")):
            continue
        section = SECTION_PATTERN.fullmatch(line)
        if section:
            section_count += 1
            if section.group(1).strip().casefold() != SECTION.casefold() or section_count != 1:
                raise ValueError(f"{path}: 增量源只能包含一个 [{SECTION}] 节")
            continue
        match = parse_key(line)
        if section_count != 1 or match is None:
            raise ValueError(f"{path}: 无效的增量配置行: {line}")
        key = match.group(2).strip()
        if key not in KEYS or key in values:
            raise ValueError(f"{path}: 未定义或重复的增量键: {key}")
        value = match.group(4)
        if not value:
            raise ValueError(f"{path}: 翻译不能为空: {key}")
        values[key] = value
    if section_count != 1 or set(values) != set(KEYS):
        raise ValueError(f"{path}: 必须提供 [{SECTION}] 中的 {', '.join(KEYS)}")
    return values


def read_target(path: Path) -> tuple[str, str, bytes, str]:
    """读取完整资源及明确的 BOM 编码；无 BOM 只接受 ASCII，返回原文及新增行换行符。"""
    if not path.exists():
        return "", "utf-16-le", b"\xff\xfe", "\r\n"
    data = path.read_bytes()
    if data.startswith((b"\xff\xfe\x00\x00", b"\x00\x00\xfe\xff")):
        raise ValueError(f"{path}: 不支持 UTF-32 资源，不自动转换原有编码")
    if data.startswith(b"\xff\xfe"):
        encoding, bom = "utf-16-le", b"\xff\xfe"
    elif data.startswith(b"\xfe\xff"):
        encoding, bom = "utf-16-be", b"\xfe\xff"
    elif data.startswith(b"\xef\xbb\xbf"):
        encoding, bom = "utf-8", b"\xef\xbb\xbf"
    else:
        if any(byte >= 128 for byte in data):
            raise ValueError(f"{path}: 无 BOM 文件包含非 ASCII 字节；请先确认并显式标明原有编码")
        encoding, bom = "ascii", b""
    text = data[len(bom):].decode(encoding)
    newline = next((ending for ending in ("\r\n", "\n", "\r") if ending in text), "\r\n")
    return text, encoding, bom, newline


def merge_text(text: str, values: dict[str, str], newline: str, path: Path) -> str:
    """仅替换目标节的两个键；重复目标节或键先拒绝，其他行保留原文。"""
    lines = text.splitlines(keepends=True)
    headers = []
    target_headers = []
    for index, line in enumerate(lines):
        content, _ = strip_line_ending(line)
        section = SECTION_PATTERN.fullmatch(content)
        if section:
            headers.append(index)
            if section.group(1).strip().casefold() == SECTION.casefold():
                target_headers.append(index)
    if len(target_headers) > 1:
        raise ValueError(f"{path}: 存在重复的 [{SECTION}] 节，拒绝猜测修改位置")
    if not target_headers:
        prefix = text
        if prefix and not prefix.endswith(("\r", "\n")):
            prefix += newline
        if prefix and not prefix.endswith(newline + newline):
            prefix += newline
        return prefix + f"[{SECTION}]" + newline + "".join(f"{key}={values[key]}{newline}" for key in KEYS)

    start = target_headers[0]
    end = next((index for index in headers if index > start), len(lines))
    found = {}
    for index in range(start + 1, end):
        content, ending = strip_line_ending(lines[index])
        match = parse_key(content)
        if match is None:
            continue
        key = next((key for key in KEYS if match.group(2).strip().casefold() == key.casefold()), None)
        if key is None:
            continue
        if key in found:
            raise ValueError(f"{path}: [{SECTION}] 中存在重复键 {key}")
        found[key] = (index, match, ending)
    for key, (index, match, ending) in found.items():
        lines[index] = match.group(1) + match.group(2) + match.group(3) + values[key] + ending

    missing = [key for key in KEYS if key not in found]
    if missing:
        if end > 0 and not lines[end - 1].endswith(("\r", "\n")):
            lines[end - 1] += newline
        lines[end:end] = [f"{key}={values[key]}{newline}" for key in missing]
    return "".join(lines)


def write_output(path: Path, data: bytes, backup_dir: Path | None) -> None:
    """内容改变时先备份已有文件，再以同目录临时文件原子替换，失败时清理临时文件。"""
    if path.exists() and backup_dir is not None:
        backup_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, backup_dir / path.name)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(prefix=path.name + ".", suffix=".tmp", dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def main() -> int:
    """解析目标及备份目录；先检查全部语言，检查通过后合并，已一致的文件保持不变。"""
    source_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description="合并换线名称增量翻译到完整客户端语言资源")
    parser.add_argument("--bin-dir", type=Path, default=source_dir.parents[1] / "Bin", help="完整资源目录，默认项目 Bin")
    parser.add_argument("--backup-dir", type=Path, help="替换前备份目录；每次写入使用独立时间戳子目录")
    arguments = parser.parse_args()
    bin_dir = arguments.bin_dir.resolve()
    if bin_dir == source_dir:
        parser.error("目标目录不能是增量源目录，片段不能作为完整资源覆盖")
    try:
        plans = []
        # 先对四份资源完成编码、重复节和重复键检查，避免验证失败时只更新部分语言。
        for language in LANGUAGES:
            filename = "SephirothUI." + language
            target = bin_dir / filename
            values = read_source(source_dir / filename)
            text, encoding, bom, newline = read_target(target)
            merged = merge_text(text, values, newline, target)
            try:
                data = bom + merged.encode(encoding)
            except UnicodeEncodeError as error:
                raise ValueError(f"{target}: 新翻译不能用原有 {encoding} 编码表示，拒绝自动转换编码") from error
            if target.exists() and target.read_bytes() == data:
                continue
            plans.append((target, data))
        backup_dir = None
        if arguments.backup_dir is not None:
            backup_dir = arguments.backup_dir.resolve() / datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        if plans:
            bin_dir.mkdir(parents=True, exist_ok=True)
        for target, data in plans:
            write_output(target, data, backup_dir)
            print(f"已合并: {target}")
        if not plans:
            print("四种语言的目标翻译已一致，无需写入。")
        return 0
    except (OSError, ValueError, UnicodeError) as error:
        print(f"合并失败: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
