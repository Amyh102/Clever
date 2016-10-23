
Promise    = require 'bluebird'
nodemailer = require 'nodemailer'

module.exports = send: (options = {}) -> new Promise (resolve, reject) ->
    transporter = nodemailer.createTransport
        service: 'gmail'
        auth:
            user: options.from
            pass: options.password
    ,   from: options.from

    transporter.sendMail
        to:          options.to
        subject:     options.subject
        html:        options.body or ""
    , (err, result) ->
        return reject(err) if err
        return resolve(result)
