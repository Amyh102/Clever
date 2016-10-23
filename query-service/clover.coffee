
_       = require 'lodash'
_.str   = require 'underscore.string'
request = require 'request'
Promise = require 'bluebird'
RateLimiter = require('limiter').RateLimiter


REQUESTS_PER_SECOND = 16
# MAX_RETRIES         = REQUESTS_PER_SECOND * 30
MAX_RETRIES = 0


class CloverAPI

    constructor: (@accessToken, @merchantId) ->
        @baseUrl ?= "https://api.clover.com"
        @limiter = new RateLimiter(1, Math.ceil(1000 / REQUESTS_PER_SECOND))

    getMerchant: (options) ->
        defaults =
            expand: ['address', 'owner']
        options = _.extend {}, defaults, options
        @get('/v3/merchants/current', options)

    getOrders: (options) ->
        defaults =
            offset: 0
            limit:  100
            expand: [
                'discounts'
                'payments'
                'credits'
                'refunds'
                'refunds.lineItems'
                'serviceCharge'
                'lineItems'
                'lineItems.discounts'
                'lineItems.modifications'
                'lineItems.taxRates'
                'lineItems.payments'
                'payments.tender'
                'customers'
            ]
        options = _.extend {}, defaults, options
        options.expand = options.expand?.join(',')
        @get('/v3/merchants/current/orders', options).then (result) -> result.elements

    createOrder: (data) ->
        @post('/v3/merchants/current/orders', data)

    updateOrder: (orderId, data) ->
        console.log "updating order:", orderId
        @post("/v3/merchants/current/orders/#{orderId}", data)

    deleteOrder: (orderId) ->
        @delete("/v3/merchants/current/orders/#{orderId}")

    addLineItemsToOrder: (orderId, lineItems) ->
        console.log "line items order:", orderId
        @post("/v3/merchants/current/orders/#{orderId}/line_items", lineItems)

    get: (endpoint, options = {}) -> new Promise (resolve, reject) =>
        escape = _.identity

        queryString = do =>
            options = JSON.parse(JSON.stringify(options))
            options.accessToken = @accessToken
            return Object.keys(options)
            .map((key) -> [_.str.underscored(key), escape(options[key])])
            .map((pair) -> pair.join('='))
            .join('&')

        requestOptions = do =>
            method: 'GET'
            json: true
            url: "#{@baseUrl}#{endpoint}?#{queryString}"

        doRequest = (requestOptions, retries = 0) => @limiter.removeTokens 1, =>
            console.log "try:#{retries} #{requestOptions.method} #{requestOptions.url.replace(/access_token=.*&?/, '')}"
            retryRequest = -> _.defer(-> doRequest(requestOptions, retries+1))
            request requestOptions, (err, res, body) =>
                return resolve(body)  if not err and res?.statusCode is 200
                return reject(err)    if res?.statusCode is 401
                return retryRequest() if retries < MAX_RETRIES
                err = err or "Clover API Error: " + do ->
                    return "unknown" if not res?.body
                    try
                        data = JSON.stringify(res?.body)
                        return data.message or data
                    catch error
                        return res?.body
                console.error {statusCode:res?.statusCode, body:res?.body, err}, \
                "request failed (#{res?.statusCode or 'unknown status code'})"
                return reject(err)

        doRequest(requestOptions)


    delete: (endpoint) -> new Promise (resolve, reject) =>
        escape = _.identity

        requestOptions = do =>
            method: 'DELETE'
            json: true
            url: "#{@baseUrl}#{endpoint}"
            headers:
                'Authorization': "Bearer #{@accessToken}"
                'Content-Type':  "application/json"

        doRequest = (requestOptions, retries = 0) => @limiter.removeTokens 1, =>
            console.log "try:#{retries} #{requestOptions.method} #{requestOptions.url.replace(/access_token=.*&?/, '')}"
            retryRequest = -> _.defer(-> doRequest(requestOptions, retries+1))
            request requestOptions, (err, res, body) =>
                return resolve(body)  if not err and res?.statusCode is 200
                return reject(err)    if res?.statusCode is 401
                return retryRequest() if retries < MAX_RETRIES
                err = err or "Clover API Error: " + do ->
                    return "unknown" if not res?.body
                    try
                        data = JSON.stringify(res?.body)
                        return data.message or data
                    catch error
                        return res?.body
                console.error {statusCode:res?.statusCode, body:res?.body, err}, \
                "request failed (#{res?.statusCode or 'unknown status code'})"
                return reject(err)

        doRequest(requestOptions)


    post: (endpoint, data = {}) -> new Promise (resolve, reject) =>
        escape = _.identity

        requestOptions = do =>
            method: 'POST'
            json: true
            body: data
            url: "#{@baseUrl}#{endpoint}"
            headers:
                'Authorization': "Bearer #{@accessToken}"
                'Content-Type':  "application/json"

        console.log '------------------------'
        console.log data
        console.log '------------------------'

        doRequest = (requestOptions, retries = 0) => @limiter.removeTokens 1, =>
            console.log "try:#{retries} #{requestOptions.method} #{requestOptions.url.replace(/access_token=.*&?/, '')}"
            retryRequest = -> _.defer(-> doRequest(requestOptions, retries+1))
            request requestOptions, (err, res, body) =>
                return resolve(body)  if not err and res?.statusCode is 200
                return reject(err)    if res?.statusCode is 401
                return retryRequest() if retries < MAX_RETRIES
                err = err or "Clover API Error: " + do ->
                    return "unknown" if not res?.body
                    try
                        data = JSON.stringify(res?.body)
                        return data.message or data
                    catch error
                        return res?.body
                console.error {statusCode:res?.statusCode, body:res?.body, err}, \
                "request failed (#{res?.statusCode or 'unknown status code'})"
                return reject(err)

        doRequest(requestOptions)


module.exports = CloverAPI