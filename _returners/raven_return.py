# -*- coding: utf-8 -*-
'''
Salt returner that reports execution results back to sentry via raven.
The returner will inspect the payload to identify errors and changes
and flag them as such.

Mandatory pillar settings:

.. code-block:: yaml

    raven:
      dsn: https://aaaa:bbbb@app.getsentry.com/12345
      # add grain names as tags to your preference, will clear default tags

optional settings, showing defaults:

.. code-block:: yaml

    raven:
      hide_pillar: true
      hide_grains: true
      report_errors_only: true
      change_level: info
      error_level: error
      tags:
        - os
        - master
        - saltversion
        - cpuarch

https://pypi.python.org/pypi/raven and
https://pypi.python.org/pypi/requests must be installed.

The tags list (optional) specifies grains items that will be used as sentry
tags, allowing tagging of events in the sentry ui.

To also report changes to states in addition to errors set report_errors_only to false.

'''
from __future__ import absolute_import

# Import Python libs
import logging

# Import Salt libs
import salt.loader
import salt.utils.jid
import salt.ext.six as six

try:
    from raven import Client
    from raven.transport.requests import RequestsHTTPTransport
    has_raven = True
except ImportError:
    has_raven = False


logger = logging.getLogger(__name__)

# Define the module's virtual name
__virtualname__ = 'raven'


def __virtual__():
    if not has_raven:
        return False, 'Could not import raven returner; ' \
                      'raven python client is not installed.'
    __grains__ = salt.loader.grains(__opts__)
    __salt__ = salt.loader.minion_mods(__opts__)
    return __virtualname__

def get_config_value(name, default=None):
    return __salt__['pillar.get'](name, default)

def has_failed(result):
    return not (result.get('success') and result.get('retcode', 0) == 0)

def connect_sentry(result):
    '''
    Connect to the Sentry server
    '''
    raven_config = get_config_value('raven', False)

    if not raven_config:
        return False, 'No \'raven\' key was found in the configuration'
    if 'dsn' not in raven_config:
        return False, 'Raven returner needs key raven:dsn in the configuration'

    sentry_data = {
        'pillar': 'HIDDEN' if raven_config.get('hide_pillar', True) else __salt__['pillar.raw'](),
        'grains': 'HIDDEN' if raven_config.get('hide_grains', True) else __salt__['grains.items'](),
    }
    data = {
        'platform': 'python',
        'culprit': 'salt-call',
    }
    tags = {}
    for tag in raven_config.get('tags', ['os', 'master', 'saltversion', 'cpuarch']):
        tags[tag] = __salt__['grains.get'](tag)

    failed_states = {}
    changed_states = {}
    if result.get('return'):
        if isinstance(result['return'], dict):
            for state_id, state_result in six.iteritems(result['return']):
                if not state_result['result']:
                    failed_states[state_id] = state_result
                if (state_result['result'] and
                    len(state_result['changes']) > 0):
                    changed_states[state_id] = state_result
        else:
            if not result.get('success') or result.get('retcode', 0) != 0:
                failed_states[result['fun']] = result['return']

    client = Client(raven_config.get('dsn'), transport=RequestsHTTPTransport)

    if has_failed(result):
        data['level'] = raven_config.get('error_level', 'error')
        message = "Salt error on " + result['id']
        sentry_data['result'] = failed_states

        try:
            msgid = client.capture('raven.events.Message',
                message=message, data=data, extra=sentry_data, tags=tags)
            logger.info('Message id %s written to sentry', msgid)
        except Exception as exc:
            logger.error('Can\'t send message to sentry: {0}'.format(exc), exc_info=True)

    if raven_config.get('report_errors_only', True):
        return

    if result['changed_states']:
        data['level'] = raven_config.get('change_level', 'info')
        message = "Salt change(s) on " + result['id']
        sentry_data['result'] = changed_states

        try:
            msgid = client.capture('raven.events.Message',
                message=message, data=data, extra=sentry_data, tags=tags)
            logger.info('Message id %s written to sentry', msgid)
        except Exception as exc:
            logger.error('Can\'t send message to sentry: {0}'.format(exc), exc_info=True)

def returner(ret):
    '''
    Log outcome to sentry. The returner tries to identify errors and report
    them as such. Changes will be reported at info level.
    '''
    try:
        connect_sentry(ret)
    except Exception as err:
        logger.error('Can\'t run connect_sentry: {0}'.format(err), exc_info=True)
