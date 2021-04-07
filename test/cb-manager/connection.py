import random
import uuid

from locust import between, task

from base_user import BaseUser


class User(BaseUser):
    wait_time = between(1, 2.5)

    @task(10)
    def get(self):
        for endpoint in ['/connection']:
            self.op('get', endpoint)
            self.op('get', endpoint, json={
                'select': ['id']
            })
            self.op('get', endpoint, json={
                'select': ['id'],
                'where': self.filter
            })

    @task(5)
    def post(self):
        resp_data_net_lnk = self.op('get', '/network-link', json={
            'select': ['id'],
            'where': self.filter
        })
        resp_data_exec_env = self.op('get', '/exec-env', json={
            'select': ['id'],
            'where': self.filter
        })
        if isinstance(resp_data_net_lnk, list) and isinstance(resp_data_exec_env, list) and \
                len(resp_data_net_lnk) > 0 and len(resp_data_exec_env) > 0:
            self.op('post', '/connection', json={
                'id': uuid.uuid4().hex,
                'exec_env_id': random.choice(self.get_ids(resp_data_exec_env)),
                'network_link_id': random.choice(self.get_ids(resp_data_net_lnk)),
                'partner': 'locust'
            })

    @task(5)
    def put(self):
        for endpoint in ['/connection']:
            resp_data = self.op('get', endpoint, json={
                'select': ['id'],
                'where': self.filter
            })
            if isinstance(resp_data, list) and len(resp_data) > 0:
                data = random.choice(resp_data)
                data['updated'] = True
                self.op('put', endpoint, json=data)

    @task(1)
    def delete(self):
        for endpoint in ['/connection']:
            self.op('delete', endpoint, json={
                'where': self.filter
            })
