from locust import HttpUser


class BaseUser(HttpUser):
    abstract = True
    filter = {
        'equals': {
            'target': 'partner',
            'expr': 'locust'
        }
    }

    def op(self, method, endpoint, json=None):
        resp = getattr(self.client, method)(endpoint, json=json)
        try:
            resp_data = resp.json()
            return resp_data
        except Exception:
            return None

    @staticmethod
    def get_ids(data):
        return list(map(lambda x: x.get('id', None), data))
