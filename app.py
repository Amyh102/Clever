import clover
import echo
import os
import re
import synchrony

from flask import Flask, request, render_template
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
    card_split = " ".join(re.findall('....', card_number))

    data = {
        'header': 'Congratulations, you have been approved with a ${} credit line.'.format(credit_line),
        'name': clover.merchant_info()['owner']['name'],
        'number': card_split
    }
    return render_template('card.html', data=data)


if __name__ == '__main__':
    app.run(debug=True,
            host='0.0.0.0',
            port=int(os.environ.get('PORT', 2020)))
