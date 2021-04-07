import random
import uuid

from locust import between, task

from base_user import BaseUser


class User(BaseUser):
    wait_time = between(1, 2.5)

    @task(10)
    def get(self):
        for endpoint in ['/network-link', '/type/network-link']:
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
        self.op('post', '/type/network-link', json={
            'id': uuid.uuid4().hex,
            'name': uuid.uuid4().hex,
            'description': uuid.uuid4().hex,
            'partner': 'locust'
        })

        resp_data_net_lnk_type = self.op('get', '/type/network-link', json={
            'select': ['id'],
            'where': self.filter
        })
        resp_data_exec_env = self.op('get', '/exec-env', json={
            'select': ['id'],
            'where': self.filter
        })
        if isinstance(resp_data_net_lnk_type, list) and isinstance(resp_data_exec_env, list) and \
                len(resp_data_net_lnk_type) > 0 and len(resp_data_exec_env) > 0:
            self.op('post', '/network-link', json={
                'id': uuid.uuid4().hex,
                'type_id': random.choice(self.get_ids(resp_data_net_lnk_type)),
                'exec_env_id': random.choice(self.get_ids(resp_data_exec_env)),
                'partner': 'locust'
            })

    @task(5)
    def put(self):
        for endpoint in ['/network-link', '/type/network-link']:
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
        for endpoint in ['/network-link', '/type/network-link']:
            self.op('delete', endpoint, json={
                'where': self.filter
            })
