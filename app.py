import clover
import echo
import json
import os
import synchrony

from flask import Flask, request
from flask.ext.cors import CORS


app = Flask(__name__)
CORS(app)


@app.route('/', methods=['GET'])
def home():
    return 'Hello, Clever!'


@app.route('/echo/', methods=['GET', 'POST'])
def echo_api():
    if request.method == 'POST':
        data = request.get_json()
        return echo.data_handler(data)


@app.route('/synchrony/confirm', methods=['GET', 'POST'])
def synchrony_confirm():
    info = clover.merchant_info()
    status = synchrony.apply(None, info)

    credit_line = status['applyResponse']['applyResponse']['dcTempCreditLine']
    card_number = status['applyResponse']['applyResponse']['accountNumber']
    return "<br /><br /><center style='font-family: Helvetica, Sans-Serif'>Congratulations, you have been approved with a ${} credit line.<br /><br /><br />{}</center>".format(credit_line, card_number)


if __name__ == '__main__':
    app.run(debug=True,
            host='0.0.0.0',
            port=int(os.environ.get('PORT', 2020)))
