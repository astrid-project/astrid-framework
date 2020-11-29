from invoke import task
from screenutils import Screen
from rich import pretty
from rich.console import Console

pretty.install()
console = Console()

WARN = '[bold yellow]WARN[/bold yellow] '
ERROR = '[bold red]ERROR[/bold red]'
INFO = '[bold cyan]INFO[/bold cyan] '


def out(level, msg):
    console.print(f'{level} {msg}')


def frmt(service):
    return f'[purple]{service}[/purple]'


cb_manager_path = '/opt/cb-manager'
kafka_path = '/opt/kafka'
log_viewer_path = '/opt/log-viewer'

services = {
    'cb-manager': f'/usr/bin/python 3 {cb_manager_path}/main.py --es-endpoint localhost:9200',
    'log-viewer': f'{log_viewer_path}/logviewer.sh',
    'kafka': f'{kafka_path}/bin/kafka-server-start.sh {kafka_path}/config/server.properties',
    'zookeeper': f'{kafka_path}/bin/zookeeper-server-start.sh {kafka_path}/config/zookeeper.properties'
}

def check(service):
    msg = 'Service available: ' + ', '.join(map(frmt, services))
    if service is None:
        out(ERROR, 'Missing service.')
        out(INFO, msg)
        return 1
    elif not service in services:
        out(ERROR, f'Service {frmt(service)} unknown.')
        out(INFO, msg)
        return 2
    return 0


@task
def start(c, service=None):
    code = check(service)
    if code == 0:
        s = Screen(service)
        if s.exists:
            out(WARN, f'Service {frmt(service)} already started.')
        else:
            s.initialize()
            s.send_commands(services[service])
    exit(code)


@task
def stop(c, service=None):
    code = check(service)
    if code == 0:
        s = Screen(service)
        if not s.exists:
            out(WARN, f'Service {frmt(service)} not started.')
        else:
            s.kill()
    exit(code)


@task
def status(c, service=None):
    code = check(service)
    if code == 0:
        s = Screen(service)
        msg = f'Service {frmt(service)}'
        if s.exists:
            out(INFO, f'{msg} started.')
        else:
            out(INFO, f'{msg} not started.')
    exit(code)
