import requests


hostname = 'http://localhost:3030'


def revenue(timeframe):
    http = _request('reports/revenue', [camel_case(timeframe)])
    return float(http.content)


def top_n(timeframe, grouping, limit):
    http = _request('reports/top', [limit, grouping, camel_case(timeframe)])
    return [x[0] for x in http.json()]


def orders(timeframe):
    http = _request('reports/orders', [camel_case(timeframe)])
    return int(http.content)


def kitchen_sandwich():
    return _request('orders/create', [])


def kitchen_openorders():
    http = _request('orders/open', [])
    return http.json()


def kitchen_closerders():
    return _request('orders/close', [])


def _request(endpoint, params):

    if params and len(params) > 0:
        url = '{}/{}/{}'.format(hostname, endpoint, '/'.join(params))
    else:
        url = '{}/{}'.format(hostname, endpoint)

    return requests.get(url)


def camel_case(string):
    components = string.split(' ')

    if len(components) == 1:
        return string

    return components[0] + "".join(x.title() for x in components[1:])
