
Promise = require 'bluebird'
fs      = require 'fs'


module.exports = do ->

    loadFile = (filepath) -> new Promise (resolve, reject) ->
        fs.readFile filepath, (err, data) ->
            return reject(err) if err
            data = data.toString().split('\n').map (x) -> x.split('|')
            [header, rows...] = data
            return resolve rows.map (row) -> header.reduce ((result, k, index) ->
                result[k] = row[index]
                return result
            ), {}

    load: ->
        result = {}
        return Promise.all([
            ['customers',        './dataset/customers.tsv']
            ['stores',           './dataset/stores.tsv']
            ['items',            './dataset/items.tsv']
            ['transactionItems', './dataset/transaction_items.tsv']
            ['transactions',     './dataset/transactions.tsv']
        ])
        .map ([key, filepath]) ->
            loadFile(filepath).then (data) -> result[key] = data
        .then ->
            return result
