import os
from twilio.rest import TwilioRestClient

account_sid = os.environ.get('TWILIO_ACCOUNT_SID', '')
auth_token = os.environ.get('TWILIO_AUTH_TOKEN', '')
from_number = '+14154948588'

client = TwilioRestClient(account_sid, auth_token)


def send_confirmation_text(to_number, message):
    return client.messages.create(body=message, to=to_number, from_=from_number)
