import echo
import os

from flask import Flask, request
from flask.ext.cors import CORS


app = Flask(__name__)
CORS(app)


@app.route('/', methods=['GET'])
def home():
    return 'Hello, Dino!'


@app.route('/echo/', methods=['GET', 'POST'])
def echo_api():
    if request.method == 'POST':
        data = request.get_json()
        return echo.data_handler(data)


if __name__ == '__main__':
    app.run(debug=True,
            host='0.0.0.0',
            port=int(os.environ.get('PORT', 2020)))
