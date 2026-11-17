#!/usr/bin/env python3
"""check_path_deps.py — fail when a `path:` dependency points outside the repo.

Usage:
  check_path_deps.py [repo-root]        # default: the parent of scripts/

The fleet "mono-version alignment" pass (`update_fleet.sh` in `arrrrny/zuraffa`)
appends a sibling path override to the root and/or example pubspec:

    dependency_overrides:
      zuraffa:
        path: ../../zuraffa      # only exists on a developer checkout

In CI those paths do not exist, so `flutter pub get` — the first step of
`.github/workflows/test.yml` — dies before any test runs, and the red base then
blocks every later PR in the repo (#15, #16, #17, #25, #26, #27).

This guard is the repo-local half of the fix: it names the offender in the
change that introduces it, instead of in every change after it. It scans every
`pubspec.yaml` under the root, looks at `dependencies:`, `dev_dependencies:`
and `dependency_overrides:` only, and exits non-zero when a `path:` value
resolves outside the repo root. `path: ../` in `example/` resolves back to the
repo root and is fine — that is how an example depends on its parent.

Exit codes: 0 = every path dependency stays inside; 1 = at least one escapes;
2 = usage error (no such directory, no pubspec at all).
"""
import os
import re
import sys

DEP_SECTIONS = ('dependencies', 'dev_dependencies', 'dependency_overrides')
SKIP_DIRS = ('.dart_tool', '.git', 'build', 'node_modules')

TOP_KEY = re.compile(r'^([^\s#][^:]*):')
ENTRY = re.compile(r'^(\s*)([\w-]+):[ \t]*(.*)$')
PATH_LINE = re.compile(r'^\s+path:[ \t]*(\S.*?)[ \t]*$')
FLOW_PATH = re.compile(r'^\s*[\w-]+:[ \t]*\{[^}]*\bpath:[ \t]*([^,}}\s]+)')


def pubspecs(root):
    """Every pubspec.yaml under root, skipping build and cache directories."""
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        if 'pubspec.yaml' in filenames:
            yield os.path.join(dirpath, 'pubspec.yaml')


def dep_entries(path):
    """Yield (lineno, dep_name, target) for each path: dependency in a pubspec."""
    with open(path, encoding='utf-8') as f:
        lines = f.read().split('\n')
    section = None
    dep = None
    for lineno, line in enumerate(lines, 1):
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        top = TOP_KEY.match(line)
        if top:
            key = top.group(1).strip()
            section = key if key in DEP_SECTIONS else None
            dep = None
            continue
        if section is None:
            continue
        entry = ENTRY.match(line)
        if entry:
            indent = len(entry.group(1).expandtabs(2))
            if indent <= 2:
                dep = entry.group(2)
                flow = FLOW_PATH.match(line)
                if flow:
                    yield lineno, dep, flow.group(1).strip('"\'')
                continue
        found = PATH_LINE.match(line)
        if not found:
            continue
        yield lineno, dep or section, found.group(1).strip('"\'')


def main(argv):
    root = argv[1] if len(argv) > 1 else os.path.dirname(os.path.dirname(
        os.path.abspath(__file__)))
    if not os.path.isdir(root):
        print(f'path dependency guard: {root} is not a directory', file=sys.stderr)
        return 2
    root = os.path.realpath(root)

    scanned = 0
    offenders = []
    inside = 0
    for pubspec in pubspecs(root):
        scanned += 1
        base = os.path.dirname(os.path.abspath(pubspec))
        rel = os.path.relpath(pubspec, root)
        for lineno, dep, value in dep_entries(pubspec):
            target = os.path.realpath(os.path.join(base, value))
            if target == root or target.startswith(root + os.sep):
                inside += 1
                continue
            offenders.append((rel, lineno, dep, value, target))

    if scanned == 0:
        print(f'path dependency guard: no pubspec.yaml under {root}',
              file=sys.stderr)
        return 2

    if offenders:
        print('FAIL — path dependencies pointing outside the repo '
              '(they resolve only on a developer checkout, so '
              '`flutter pub get` dies on them in CI):', file=sys.stderr)
        for rel, lineno, dep, value, target in offenders:
            print(f'  {rel}:{lineno}: {dep}: path: {value}', file=sys.stderr)
            print(f'    resolves to {target}, outside {root}', file=sys.stderr)
        print('\nDrop the sibling path override, or point it at a path '
              'inside this repo.', file=sys.stderr)
        return 1

    print(f'path dependencies: {inside} in-repo, 0 outside the repo '
          f'({scanned} pubspec.yaml scanned)')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))