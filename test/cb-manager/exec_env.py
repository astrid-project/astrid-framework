import random
import uuid

from locust import between, task

from base_user import BaseUser


class User(BaseUser):
    wait_time = between(1, 2.5)

    @task(10)
    def get(self):
        for endpoint in ['/exec-env', '/type/exec-env']:
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
        self.op('post', '/type/exec-env', json={
            'id': uuid.uuid4().hex,
            'name': uuid.uuid4().hex,
            'partner': 'locust'
        })

        resp_data_exec_env_type = self.op('get', '/type/exec-env', json={
            'select': ['id'],
            'where': self.filter
        })
        if isinstance(resp_data_exec_env_type, list) and len(resp_data_exec_env_type) > 0:
            self.op('post', '/exec-env', json={
                'id': uuid.uuid4().hex,
                'partner': 'locust',
                'type_id': random.choice(self.get_ids(resp_data_exec_env_type)),
                'description': uuid.uuid4().hex,
                'hostname': uuid.uuid4().hex,
                'enabled': random.choice([True, False]),
                'lcp': {
                    'port': random.randint(4000, 10000),
                    'https': random.choice([True, False]),
                },
                'stage': 'test'
            })

    @task(5)
    def put(self):
        for endpoint in ['/exec-env', '/type/exec-env']:
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
        for endpoint in ['/exec-env', '/type/exec-env']:
            self.op('delete', endpoint, json={
                'where': self.filter
            })
