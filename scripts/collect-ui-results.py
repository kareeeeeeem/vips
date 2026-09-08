#!/usr/bin/env python3
"""Extract observed simulator actions; never convert taps into business passes."""
import collections
import json
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--app', choices=['consumer', 'merchant'], default='consumer')
parser.add_argument('logs', nargs='*')
args = parser.parse_args()
sources = [Path(p) for p in args.logs] or [Path(f'/tmp/vips-{args.app}-buttons.log')]
records = []
for source in sources:
    for line in source.read_text(errors='replace').splitlines():
        if 'UI_ACTION ' not in line:
            continue
        try:
            record = json.loads(line.split('UI_ACTION ', 1)[1])
            record['source_log'] = str(source)
            records.append(record)
        except json.JSONDecodeError:
            continue
counts = dict(collections.Counter(record['kind'] for record in records))
screens = sorted({record['route'] for record in records if record['kind'] == 'screen'})
result = {
    'scope': 'Actual iOS simulator exploration. Tapped means a gesture was dispatched; business outcomes need assertions.',
    'source_logs': [str(source) for source in sources], 'counts': counts, 'screens': screens,
    'finished': all(any(record['kind'] == 'summary' and record['source_log'] == str(source)
        for record in records) for source in sources),
    'records': records,
}
target = Path(__file__).resolve().parents[1] / f'docs/qa/{args.app}-simulator-actions.json'
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'screens': len(screens), 'finished': result['finished'], **counts}))
