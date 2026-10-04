"""Explicit remote smoke test; creates disposable accounts and deletes its task/subject."""
import datetime
import json
import secrets
import sys
import urllib.error
import urllib.request

base = sys.argv[1].rstrip('/')
if not base.startswith('https://') or not base.endswith('/api/v1'):
    raise SystemExit('Use an HTTPS API URL ending in /api/v1')

def call(method, path, token=None, data=None, expected=200):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    request = urllib.request.Request(base + path, data=None if data is None else json.dumps(data).encode(), headers=headers, method=method)
    try:
        response = urllib.request.urlopen(request, timeout=60)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        payload = response.read()
        if response.status != expected:
            raise RuntimeError(f'{method} {path}: expected {expected}, received {response.status}')
        return json.loads(payload) if payload else None

assert call('GET', '/health')['status'] == 'UP'
credentials = []
for label in ('A', 'B'):
    data = {'name': 'Verification Render ' + label, 'email': 'render-smoke-' + secrets.token_hex(12) + '@example.invalid', 'password': secrets.token_urlsafe(24)}
    session = call('POST', '/auth/register', data=data, expected=201)
    credentials.append((data, session['token']))
a, b = credentials[0][1], credentials[1][1]
subject = call('POST', '/subjects', a, {'name': 'Verification distante', 'description': 'Test technique temporaire'}, 201)
task = call('POST', '/tasks', a, {'title': 'Verifier Render', 'description': '', 'subjectId': subject['id'], 'dueDate': datetime.datetime.now(datetime.timezone.utc).date().isoformat(), 'priority': 'HIGH', 'status': 'TODO'}, 201)
assert any(item['id'] == task['id'] and item['subjectName'] == subject['name'] for item in call('GET', '/tasks', a))
assert not call('GET', '/tasks', b)
call('DELETE', '/tasks/' + str(task['id']), b, expected=404)
assert call('GET', '/dashboard', a)['todo'] == 1
call('POST', '/auth/logout', a, expected=204)
call('GET', '/tasks', a, expected=401)
data = credentials[0][0]
a = call('POST', '/auth/login', data={'email': data['email'], 'password': data['password']})['token']
assert any(item['id'] == task['id'] for item in call('GET', '/tasks', a))
call('DELETE', '/tasks/' + str(task['id']), a, expected=204)
call('DELETE', '/subjects/' + str(subject['id']), a, expected=204)
for token in (a, b):
    call('POST', '/auth/logout', token, expected=204)
print(json.dumps({'health': 'UP', 'registration': 'PASS', 'login': 'PASS', 'subject_task': 'PASS', 'dashboard': 'PASS', 'cross_account_isolation': 'PASS', 'revoked_token_401': 'PASS', 'data_after_relogin': 'PASS', 'test_task_subject_cleanup': 'PASS'}, indent=2))
