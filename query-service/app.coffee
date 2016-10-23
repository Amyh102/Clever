
_                 = require 'lodash'
fs                = require 'fs'
Promise           = require 'bluebird'
moment            = require 'moment'
{Service, errors} = require 'service'
Loader            = require './loader'
Indices           = require './indices'
Clover            = require './clover'
Utils             = require './utils'
EmailReport       = require './email-report'
EmailService      = require './email-service'


config = require('./config')
clover = new Clover(config.merchant.token, config.merchant.id)

console.log "Loading data..."
now = Date.now()

Loader.load().then (collections) ->
    console.log "Data loaded in #{Date.now() - now}ms."
    indices = Indices.indexify(collections)

    emailHtml = EmailReport.render(indices)
    fs.writeFileSync('./report.html', emailHtml)

    handlers =

        home:
            spec:
                path:        "/"
                description: "root"
                method:      "GET"
                notes:       ""
                params: []
                errorResponses: []
            action: (req) ->
                return "Hello World!"

        revenue:
            spec:
                path:        "/reports/revenue/{time}"
                description: "What's my revenue for <date>."
                method:      "GET"
                notes:       ""
                params: []
                errorResponses: []
            action: (req) ->
                time = req.params.time
                console.log "TIME:", time
                throw new errors.controller.MissingArgumentError('time') if not time
                tyValue = indices.revenue[time] or indices.revenue.today
                lyValue = indices.revenue["ly_#{time}"] or indices.revenue.ly_today
                ty:     parseInt(tyValue)
                ly:     parseInt(lyValue)
                growth: Utils.growth(tyValue, lyValue)

        orders:
            spec:
                path:        "/reports/orders/{time}"
                description: "How many orders did I do for <time>."
                method:      "GET"
                notes:       ""
                params: []
                errorResponses: []
            action: (req) ->
                time = req.params.time
                throw new errors.controller.MissingArgumentError('time') if not time
                tyValue = indices.orders[time] or indices.orders.today
                lyValue = indices.orders["ly_#{time}"] or indices.orders.ly_today
                ty:     parseInt(tyValue)
                ly:     parseInt(lyValue)
                growth: Utils.growth(tyValue, lyValue)

        topItemsByProperty:
            spec:
                path:          "/reports/top/{limit}/{property}"
                description:   "What are my top <limit> <property> today?"
                method:        "GET"
                notes:         ""
                params:        []
                errorResponse: []
            action: (req) ->
                {limit, property} = req.params
                property = property.toLowerCase().trim()
                property = 'category' if property is 'categories'
                property = 'name'     if property in ['items', 'item']
                console.log "Property:", property
                throw new errors.controller.MissingArgumentError('property') if not property
                time = 'today'
                index = indices.top[time].revenue[property]
                throw new errors.controller.InvalidArgumentError({property}) if not index
                limit = Math.max(1, limit)
                result = index[0..limit-1]
                return result.map ([key, sum]) -> [key, parseInt(sum)]

        topItemsByPropertyWithTime:
            spec:
                path:          "/reports/top/{limit}/{property}/{time}"
                description:   "What are my top <limit> <property> this <time>?"
                method:        "GET"
                notes:         ""
                params:        []
                errorResponse: []
            action: (req) ->
                {limit, property, time} = req.params
                console.log "Top Items By Property With Time"
                console.log {limit, property, time}
                property = property.toLowerCase().trim()
                property = 'category' if property is 'categories'
                property = 'name'     if property in ['items', 'item']
                console.log "Property:", property
                throw new errors.controller.MissingArgumentError('time') if not property
                throw new errors.controller.MissingArgumentError('property') if not property
                index = indices.top[time].revenue[property]
                throw new errors.controller.InvalidArgumentError({property}) if not index
                limit = Math.max(1, limit)
                result = index[0..limit-1]
                return result.map ([key, sum]) -> [key, parseInt(sum)]

        getMerchantInfo:
            spec:
                path:        "/merchant"
                description: "Get the merchant's info."
                method:      "GET"
                notes:       ""
            action: (req) ->
                console.log "Get Merchant Info"
                clover.getMerchant().then (merchant) ->
                    delete merchant.owner.id
                    delete merchant.owner.href
                    delete merchant.owner.orders
                    delete merchant.owner.inviteSent
                    delete merchant.address.href
                    createdAt: merchant.owner.claimedTime
                    name:      merchant.name
                    owner:     merchant.owner
                    address:   merchant.address
                    website:   merchant.website
                    revenue:   parseInt(indices.revenue.year)

        createOrder:
            spec:
                path:        "/orders/create"
                description: "Create an order"
                method:      "GET"
                notes:       ""
            action: (req) ->
                console.log "ORDER CREATE"
                clover.createOrder({state:null})
                .then (order) ->
                    clover.updateOrder(order.id, {state:'open'})
                    .then ->
                        clover.addLineItemsToOrder(order.id, {item:{id:"7R43F4ERHT5JT"}})

        closeOrder:
            spec:
                path:        "/orders/close"
                description: "Close all open orders"
                method:      "GET"
                notes:       ""
            action: (req) ->
                console.log "ORDER CLOSE"
                clover.getOrders().filter((order) -> order.state is 'open').map (order) ->
                    clover.updateOrder(order.id, {state:'locked'})

        getOpenOrders:
            spec:
                path:        "/orders/open"
                description: "List all open orders"
                method:      "GET"
                notes:       ""
            action: (req) ->
                console.log "GET OPEN ORDERS"
                clover.getOrders().filter((order) -> order.state is 'open').then (orders) ->
                    order = orders[0]
                    return [] if not order
                    order.lineItems.elements.map (lineItem) -> lineItem.name

        deleteOrders:
            spec:
                path:        "/orders/delete"
                description: "2"
                method:      "GET"
                notes:       ""
            action: (req) ->
                console.log "DELETE ORDERS"
                clover.getOrders().map (order) -> clover.deleteOrder(order.id)

        offers:
            spec:
                path:        "/offers"
                description: "2"
                method:      "GET"
                notes:       ""
            action: (req) ->

        pushEmailSummary:
            spec:
                path:        "/reports/email"
                description: "Send an email summary."
                method:      "GET"
                notes:       ""
            action: (req) ->
                now = moment.utc().format('YYYY-MM-DD')
                EmailService.send
                    from:     config.email.username
                    password: config.email.password
                    body:     emailHtml
                    to:       "porter.nicolas@gmail.com"
                    subject:  "Clever Report for #{now}"


    service = new Service
        name:     'query-service'
        version:  '0.1'
        handlers:  handlers

    HOST = 'localhost'
    PORT = 2020
    service.listen(PORT, HOST, 'http://localhost')
