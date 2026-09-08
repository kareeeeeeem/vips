#!/usr/bin/env python3
"""Static source inventory. Route matches are NOT evidence of UI execution."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / 'lib/vips-backend'


def stripped(source):
    # Preserve line counts and quoted strings while excluding comments.
    pattern = r'''("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`)|(//[^\n]*|/\*[\s\S]*?\*/)'''
    return re.sub(pattern, lambda match: match[1] if match[1] else '\n' * match[0].count('\n'), source)


routes = []
seen = set()


def inspect_router(file, prefix):
    key = (str(file), prefix)
    if key in seen or not file.exists():
        return
    seen.add(key)
    source = stripped(file.read_text())
    imports = dict(re.findall(r"(?:const|let)\s+(\w+)\s*=\s*require\(['\"]([^'\"]+)['\"]\)", source))
    for match in re.finditer(r"(?:app|router)\.(get|post|put|patch|delete)\(\s*(['\"])([^'\"]+)\2", source):
        routes.append({'method': match[1].upper(), 'path': (prefix + match[3]).rstrip('/') or '/',
                       'file': str(file.relative_to(ROOT)), 'line': source[:match.start()].count('\n') + 1})
    for match in re.finditer(r"(?:app|router)\.(get|post|put|patch|delete)\(\s*\[([^]]+)\]", source):
        for route in re.findall(r"['\"]([^'\"]+)['\"]", match[2]):
            routes.append({'method': match[1].upper(), 'path': (prefix + route).rstrip('/') or '/',
                           'file': str(file.relative_to(ROOT)), 'line': source[:match.start()].count('\n') + 1})
    for match in re.finditer(r"(?:app|router)\.use\(\s*['\"]([^'\"]+)['\"]\s*,\s*(?:require\(['\"]([^'\"]+)['\"]\)|(\w+))", source):
        dependency = match[2] or imports.get(match[3])
        if dependency and dependency.startswith('.'):
            inspect_router((file.parent / (dependency + '.js')).resolve(), prefix + match[1])
    # The shared CRUD factory registers four operations for each model.
    if 'function crudRouter(' in source:
        factory = source[source.index('function crudRouter('):source.index('  return r;', source.index('function crudRouter('))]
        operations = re.findall(r"r\.(get|post|put|delete)\(['\"]([^'\"]+)['\"]", factory)
        for mount in re.finditer(r"router\.use\(['\"]([^'\"]+)['\"]\s*,\s*crudRouter\(", source):
            for method, suffix in operations:
                routes.append({'method': method.upper(), 'path': (prefix + mount[1] + suffix).rstrip('/'),
                               'file': str(file.relative_to(ROOT)), 'line': source[:mount.start()].count('\n') + 1,
                               'source': 'crudRouter factory'})


inspect_router(BACKEND / 'index.js', '')
actions = []
api_calls = []
named_routes = []
registered_names = set()
for directory in ['appuser/routes', 'appmerchant/routes']:
    for file in (ROOT / 'lib' / directory).glob('*.dart'):
        registered_names.update(re.findall(r"=\s*['\"](/[^'\"]+)['\"]", stripped(file.read_text())))

for app in ['appuser', 'appmerchant']:
    for file in sorted((ROOT / 'lib' / app).rglob('*.dart')):
        source = stripped(file.read_text())
        relative = str(file.relative_to(ROOT))
        for match in re.finditer(r'\b(onPressed|onTap|onChanged|onSubmitted|onCompleted)\s*:\s*', source):
            callback = source[match.end():match.end() + 180].split('\n')[0].strip()
            empty = bool(re.match(r'\([^)]*\)\s*(?:async\s*)?\{\s*\}', source[match.end():]))
            actions.append({'app': app, 'file': relative, 'line': source[:match.start()].count('\n') + 1,
                            'event': match[1], 'callback': callback,
                            'status': 'empty_callback' if empty else 'requires_ui_verification'})
        for match in re.finditer(r"\.(get|post|put|patch|delete)\(\s*['\"](/[^'\"]+)['\"]", source):
            path = re.sub(r'\$\{[^}]+\}|\$[\w.]+', ':dynamic', match[2].split('?')[0]).rstrip('/')
            path = path if path.startswith('/api/') else '/api' + path
            candidates = []
            for route in routes:
                pattern = re.sub(r':[\w]+', '[^/]+', route['path'])
                if route['method'] == match[1].upper() and re.fullmatch(pattern, path):
                    candidates.append(route['path'])
            api_calls.append({'app': app, 'file': relative, 'line': source[:match.start()].count('\n') + 1,
                              'method': match[1].upper(), 'path': path,
                              'matched_routes': candidates, 'status': 'static_match' if candidates else 'needs_review'})
        for match in re.finditer(r"Get\.(?:toNamed|offNamed|offAllNamed)\(\s*['\"](/[^'\"]+)['\"]", source):
            named_routes.append({'file': relative, 'line': source[:match.start()].count('\n') + 1,
                                 'path': match[1], 'declared': match[1] in registered_names})

report = {
    'scope': 'Static inventory of both mobile apps; excludes shared/admin widgets. Dynamic factories and URL variables require manual review. A match does not prove functional behavior.',
    'summary': {'actions': len(actions), 'api_calls': len(api_calls), 'backend_routes': len(routes),
                'empty_callbacks': sum(action['status'] == 'empty_callback' for action in actions),
                'unmatched_api_calls': sum(call['status'] == 'needs_review' for call in api_calls),
                'undeclared_literal_navigation': sum(not route['declared'] for route in named_routes)},
    'actions': actions, 'api_calls': api_calls, 'named_navigation': named_routes, 'backend_routes': routes,
}
destination = ROOT / 'docs/qa/action-inventory.json'
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
print(json.dumps(report['summary'], indent=2))
for call in api_calls:
    if call['status'] == 'needs_review':
        print(f"REVIEW {call['method']} {call['path']} {call['file']}:{call['line']}")
for route in named_routes:
    if not route['declared']:
        print(f"NAVIGATION {route['path']} {route['file']}:{route['line']}")
