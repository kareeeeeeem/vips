#!/usr/bin/env python3
"""Run one simulator batch with scoped wake protection and a progress watchdog."""
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[1]
log = Path(sys.argv[1] if len(sys.argv) > 1 else '/tmp/vips-consumer-ui-batch.log')
target = sys.argv[2] if len(sys.argv) > 2 else 'integration_test/consumer_buttons_test.dart'
flavor = sys.argv[3] if len(sys.argv) > 3 else 'consumer'
if flavor not in ('consumer', 'merchant'):
    raise SystemExit('Only consumer and merchant QA flavors are supported')
config = '/tmp/vips-merchant-ui-config.json' if flavor == 'merchant' else '/tmp/vips-ui-config.json'
command = ['/usr/bin/caffeinate', '-di', 'flutter', 'test', target,
    '-d', '5A86C7C4-DE3C-4C27-A0E7-AE1A9C553FF9', '--flavor', flavor,
    f'--dart-define-from-file={config}', '--no-pub']
with log.open('w') as output:
    child = subprocess.Popen(command, cwd=root, stdout=output, stderr=subprocess.STDOUT,
        start_new_session=True)
    print(f'Simulator batch started; full output: {log}', flush=True)
    started = time.monotonic()
    progressed = started
    previous_size = 0
    running = False
    stalled = False
    while child.poll() is None:
        size = log.stat().st_size
        if size != previous_size:
            previous_size = size
            progressed = time.monotonic()
            with log.open('rb') as current:
                current.seek(max(0, size - 24000))
                tail = current.read().decode(errors='replace')
            running = running or 'UI_ACTION ' in tail or '[APP] API base URL' in tail or '[MERCHANT] API base URL' in tail
        limit = 120 if running else 600
        if time.monotonic() - progressed > limit:
            stalled = True
            print(f'No test progress for {limit}s; stopping only this test process group.', flush=True)
            os.killpg(child.pid, signal.SIGINT)
            try:
                child.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(child.pid, signal.SIGTERM)
                child.wait(timeout=10)
            break
        time.sleep(1)
    code = 124 if stalled else child.returncode
    print(f'Simulator batch exit status: {code}', flush=True)
    sys.exit(code if code is not None and code >= 0 else 1)
