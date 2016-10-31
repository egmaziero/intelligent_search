#!/usr/bin/env python
# coding=utf-8

from __future__ import print_function

import os
import sys
import os.path
import subprocess
import click

def _get_version():
    """Return the project version from VERSION file."""

    with open(os.path.join(os.path.dirname(__file__), 'blabs_nlp/VERSION'), 'rb') as f:
        version = f.read().decode('ascii').strip()
    return version


@click.group('common_tasks')
def cli():
    pass


@cli.command('example')
@click.option('--option', '-o', prompt='Option', default='value', help='Command option')
@click.argument('argument')
def example(option, argument):
    print('Running example command with option={opt} and argument={arg}'.format(opt=option, arg=argument))


@cli.command('notebook')
@click.option('--port', '-p', default=8888, help='Jupyter server port')
def notebook(port):
    notebookdir = 'docs'
    command = ['jupyter', 'notebook', '--notebook-dir', notebookdir, '--ip', '0.0.0.0', '--port', str(port), '--no-browser']
    ret = os.system(' '.join(command))
    sys.exit(ret)


@cli.command('bumpversion')
@click.argument('part', default='patch')
@click.option('--allow-dirty', is_flag=True, default=False, help='Allow dirty')
def bumpversion(part, allow_dirty):
    args = [part]
    if allow_dirty:
        args.append('--allow-dirty')
    command = ['bumpversion'] + args

    old_version = _get_version()
    exitcode = subprocess.call(command)
    new_version = _get_version()

    print('Bump version from {old} to {new}'.format(old=old_version, new=new_version))
    sys.exit(exitcode)


@cli.command('tag')
def tag():
    tag = 'v{}'.format(_get_version())
    print('Creating git tag {}'.format(tag))
    command = ['git', 'tag', '-m', '"version {}"'.format(tag), tag]
    sys.exit(subprocess.call(command))


@cli.command('tox')
@click.argument('args', default='')
def tox(args):
    if args:
        args = ['-a'] + args.split(' ')
    else:
        args = []
    command = ['python', 'setup.py', 'test'] + args
    sys.exit(subprocess.call(command))


@cli.command('test')
@click.option('--cov/--no-cov', default=True)
@click.option('--capture/--no-capture', default=True)
@click.argument('args', default='')
def test(cov, capture, args):
    if args:
        args = args.split(' ')
    else:
        args = []

    if not capture:
        args += ['--capture=no']

    cov_args = []
    if cov:
        cov_args += '--cov', 'blabs_nlp', '--cov-report', 'html', '--cov-report', 'xml'

    command = ['py.test'] + cov_args + args
    print(' '.join(command))
    exitcode = subprocess.call(command)
    sys.exit(exitcode)


@cli.command('pep8')
def pep8():
    command = ['pep8', 'blabs_nlp']
    exitcode = subprocess.call(command)
    if exitcode == 0:
        print('Congratulations! Everything looks good.')
    sys.exit(exitcode)


if __name__ == '__main__':
    cli()
