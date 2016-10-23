import clover
import json


def data_handler(raw_data):
    request = raw_data['request']

    if request['type'] == 'IntentRequest':
        response = {'version': 1.0,
                    'response': intent_handler(request)}

        return json.dumps(response, indent=2, sort_keys=True)

    else:
        print "WARN: Unhandled request type is {}".format(request['type'])

    return json.dumps([{}])


def intent_handler(request):
    request_name = request['intent']['name']

    if request_name == 'AdviceIntent':
        return advice_intent(request)
    elif request_name == 'GroupingIntent':
        return grouping_intent(request)
    elif request_name == 'OrderIntent':
        return order_intent(request)
    elif request_name == 'RevenueIntent':
        return revenue_intent(request)

    return [{}]


def advice_intent(request):
    output_speech = 'You should apply for a credit card.'
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def grouping_intent(request):
    timeframe = 'today'
    if 'value' in request['intent']['slots']['timeframe']:
        timeframe = request['intent']['slots']['timeframe']['value']

    limit = 1
    if 'value' in request['intent']['slots']['topN']:
        limit = request['intent']['slots']['topN']['value']

    grouping = request['intent']['slots']['grouping']['value']
    real_grouping = grouping
    if grouping == 'item':
        grouping = 'name'

    results = clover.top_n(timeframe, grouping, limit)
    words = ','.join(results)
    if len(results) > 1:
        words = ','.join(results[:-1]) + ', and ' + results[-1]

    output_speech = 'Your top {} {} {} are {}'.format(limit, real_grouping, timeframe, words)
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def order_intent(request):
    timeframe = request['intent']['slots']['timeframe']['value']
    orders = clover.orders(timeframe)

    output_speech = 'Your had {} orders {}'.format(orders, timeframe)
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def revenue_intent(request):
    timeframe = request['intent']['slots']['timeframe']['value']
    revenue = int(clover.revenue(timeframe))

    output_speech = 'Your revenue {} was {}'.format(timeframe, '{} dollars'.format(revenue))
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response
