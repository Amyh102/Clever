import json
import os

import clover
import synchrony
import sms


# Ugh....
IS_APPLYING = False
SYNCHRONY_ACCOUNT = 100012
APP_TO_PHONE = os.environ.get('APP_TO_PHONE', '')


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
    elif request_name == 'CreditCardNoIntent':
        return creditcardno_intent(request)
    elif request_name == 'CreditCardYesIntent':
        return creditcardyes_intent(request)
    elif request_name == 'GroupingIntent':
        return grouping_intent(request)
    elif request_name == 'OrderIntent':
        return order_intent(request)
    elif request_name == 'ReportIntent':
        return report_intent(request)
    elif request_name == 'RevenueIntent':
        return revenue_intent(request)

    # Nick Special
    elif request_name == 'SandwichIntent':
        return sandwich_intent(request)
    elif request_name == 'OpenOrdersIntent':
        return openorders_intent(request)
    elif request_name == 'CloseOrdersIntent':
        return closeorders_intent(request)
    return [{}]


def advice_intent(request):
    global IS_APPLYING
    IS_APPLYING = True

    spend_last_month = 3024
    discount = 0.10

    category = synchrony.next_purchase(SYNCHRONY_ACCOUNT)
    credit_card = synchrony.next_card(category)


    output_speech = "I've noticed you've spent ${} on {} in the past month, you could save ${} " \
    "through the end of the year with the {}. Would you like me to apply for you?".format(
        spend_last_month, category, int(spend_last_month * discount * 4), credit_card
    )

    # output_speech = 'Based on your spend in the {} category, you may be interested in applying for a {}. Would you like to apply?'
    output_type = 'PlainText'

    # output_speech = output_speech.format(category, credit_card)


    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': False}

    return response


def creditcardno_intent(request):
    global IS_APPLYING
    if not IS_APPLYING:
        return advice_intent(request)
    IS_APPLYING = False

    output_speech = "that's ok, i will look for other suggestions"
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def creditcardyes_intent(request):
    global IS_APPLYING
    if not IS_APPLYING:
        return advice_intent(request)
    IS_APPLYING = False

    output_speech = 'Great! I have conveniently filled out the application form and sent you a text message with a link to confirm. '
    output_type = 'PlainText'

    sms.send_confirmation_text(APP_TO_PHONE, 'Your credit card application is ready, please click this link to confirm: https://money2020.42technologies.com/synchrony/confirm')

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
    orders, ly, g = clover.orders(timeframe)
    growth = int(g * 100)

    growth_string = ''
    if growth > 0:
        growth_string = ', which is a {} percent increase over last year'.format(growth)
    elif growth < 0:
        growth_string = ', which is {} percent lower than last year'.format(growth * -1)

    output_speech = 'Your had {} orders {}'.format(orders, timeframe)
    output_speech += growth_string
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def report_intent(request):
    output_speech = 'Emailing you the end-of-day report. Have a good night.'
    output_type = 'PlainText'

    clover.report()

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def revenue_intent(request):
    timeframe = request['intent']['slots']['timeframe']['value']
    ty, ly, g = clover.revenue(timeframe)

    revenue = int(ty)
    growth = int(g * 100)

    growth_string = ''
    if growth > 0:
        growth_string = ', which is a {} percent increase over last year'.format(growth)
    elif growth < 0:
        growth_string = ', which is {} percent lower than last year'.format(growth * -1)

    output_speech = 'Your revenue {} was {}'.format(timeframe, '{} dollars'.format(revenue))
    output_speech += growth_string
    output_type = 'PlainText'

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def sandwich_intent(request):
    output_speech = 'Okay, I have put in an order for a sandwich'
    output_type = 'PlainText'

    clover.kitchen_sandwich()

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def openorders_intent(request):
    output_speech = 'There is an open order for {}'
    output_type = 'PlainText'

    items = clover.kitchen_openorders()

    if not items or len(items) == 0:
        output_speech = 'You have no open orders'
    if len(items) == 1:
        output_speech = output_speech.format('a ' + items[0])
    else:
        words = ','.join(items)
        if len(items) > 1:
            words = ','.join(items[:-1]) + ', and ' + items[-1]
        output_speech = output_speech.format(words)

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response


def closeorders_intent(request):
    output_speech = 'Ok, done.'
    output_type = 'PlainText'

    clover.kitchen_closerders()

    response = {
        'outputSpeech': {'type': output_type, 'text': output_speech},
        'shouldEndSession': True}

    return response
