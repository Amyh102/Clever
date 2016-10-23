
_      = require 'lodash'
moment = require 'moment'


module.exports = indexify: (collections) ->

    Object.keys(collections).forEach (key) ->
        console.log key, collections[key].length

    latestTransaction = _.maxBy collections.transactions, (transaction) ->
        return new Date(transaction.timestamp).getTime()

    latestTimestamp = moment.utc(latestTransaction.timestamp)
    lastYearLatestTimestamp = latestTimestamp.clone().subtract(1, 'year')

    ty =
        today:     latestTimestamp.format('YYYY-MM-DD')
        yesterday: latestTimestamp.clone().subtract(1, 'day').format('YYYY-MM-DD')
        thisWeek:  latestTimestamp.clone().format('YYYY-WW')
        lastWeek:  latestTimestamp.clone().subtract(1, 'week').format('YYYY-WW')
        thisMonth: latestTimestamp.clone().format('YYYY-MM')

    ly =
        today:     lastYearLatestTimestamp.format('YYYY-MM-DD')
        yesterday: lastYearLatestTimestamp.clone().subtract(1, 'day').format('YYYY-MM-DD')
        thisWeek:  lastYearLatestTimestamp.format('YYYY-WW')
        lastWeek:  lastYearLatestTimestamp.clone().subtract(1, 'week').format('YYYY-WW')
        thisMonth: lastYearLatestTimestamp.format('YYYY-MM')

    console.log "This year:"
    console.log ty

    console.log "Last year:"
    console.log ly

    collections.transactions.forEach (transaction) ->
        date  = moment.utc(transaction.timestamp)
        transaction.month = date.format('YYYY-MM')
        transaction.week  = date.format('YYYY-WW')
        transaction.year  = date.format('YYYY')
        transaction.day   = date.format('YYYY-MM-DD')
        transaction.hour  = date.format('HH')
        transaction.today     = ty.today     is transaction.day
        transaction.yesterday = ty.yesterday is transaction.day
        transaction.thisWeek  = ty.thisWeek  is transaction.week
        transaction.lastWeek  = ty.lastWeek  is transaction.week
        transaction.thisMonth = ty.thisMonth is transaction.month
        transaction.ly_today     = ly.today     is transaction.day
        transaction.ly_yesterday = ly.yesterday is transaction.day
        transaction.ly_thisWeek  = ly.thisWeek  is transaction.week
        transaction.ly_lastWeek  = ly.lastWeek  is transaction.week
        transaction.ly_thisMonth = ly.thisMonth is transaction.month

    joinedData = do ->
        {transactions, transactionItems} = collections
        # Join transactions with transaction items
        result = {}
        transactions.forEach (transaction) ->
            result[transaction.id] = {transaction}
        transactionItems.forEach (transactionItem) ->
            result[transactionItem.transaction_id] ?= {}
            result[transactionItem.transaction_id].transactionItems ?= []
            result[transactionItem.transaction_id].transactionItems.push(transactionItem)
        # Add items to transaction items
        itemsById = _.keyBy collections.items, (x) -> x.id
        transactionItems.forEach (x) -> x.item = itemsById[x.item_id]
        return Object.keys(result).map (key) -> result[key]

    itemsByName     = _.keyBy collections.items, (x) -> x.name
    itemsByCategory = _.groupBy collections.items, (x) -> x.category
    itemsByCode     = _.groupBy collections.items, (x) -> x.code

    revenueByItemProperty = (dataset, getterFn) ->
        reducer = (result, {transaction, transactionItems}) ->
            transactionItems.forEach (x) ->
                key = getterFn(x.item)
                result[key]     ?= {key, sum:0}
                result[key].sum += (x.unit_price * x.quantity)
            return result
        result = dataset.reduce(reducer, {})
        Object.keys(result).map (k) -> result[k] = result[k].sum
        return result

    costByItemProperty = (dataset, getterFn) ->
        reducer = (result, {transaction, transactionItems}) ->
            transactionItems.forEach (x) ->
                key = getterFn(x.item)
                result[key]     ?= {key, sum:0}
                result[key].sum += (x.unit_cost * x.quantity)
            return result
        result = dataset.reduce(reducer, {})
        Object.keys(result).map (k) -> result[k] = result[k].sum
        return result

    result = {}
    joinedDatasets = {}
    ['today', 'yesterday', 'thisWeek', 'lastWeek', 'thisMonth']
    .reduce(((result, key) -> result.concat([key, "ly_#{key}"])), [])
    .forEach (timerange) ->

        # Joined dataset filtered by the time range
        joinedDatasets[timerange] = joinedData.filter((x) -> x.transaction[timerange])

        result.top ?= {}
        result.top[timerange] ?= {revenue:{}, cost:{}}

        result.top[timerange].revenue.category = do ->
            data = revenueByItemProperty joinedDatasets[timerange], (x) -> x.code
            data = Object.keys(data).map (k) -> [k, data[k]]
            return _.sortBy data, ([category, sum]) -> -1 * sum

        result.top[timerange].revenue.name = do ->
            data = revenueByItemProperty joinedDatasets[timerange], (x) -> x.name
            data = Object.keys(data).map (k) -> [k, data[k]]
            return _.sortBy data, ([name, sum]) -> -1 * sum

        result.top[timerange].cost.category = do ->
            data = costByItemProperty joinedDatasets[timerange], (x) -> x.code
            data = Object.keys(data).map (k) -> [k, data[k]]
            return _.sortBy data, ([category, sum]) -> -1 * sum

        result.top[timerange].cost.name = do ->
            data = costByItemProperty joinedDatasets[timerange], (x) -> x.name
            data = Object.keys(data).map (k) -> [k, data[k]]
            return _.sortBy data, ([name, sum]) -> -1 * sum

        result.revenue ?= {}
        result.revenue[timerange] = do ->
            sumRevenueReducer = (result, {transaction, transactionItems}) ->
                totals = transactionItems.map (x) -> (x.unit_price * x.quantity)
                return result + _.sum(totals)
            return joinedDatasets[timerange].reduce(sumRevenueReducer, 0)

        result.orders ?= {}
        result.orders[timerange] = joinedDatasets[timerange].length

        result.averageOrderValue ?= {}
        result.averageOrderValue[timerange] = result.revenue[timerange] / result.orders[timerange]

    return result
