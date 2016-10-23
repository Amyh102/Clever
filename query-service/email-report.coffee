
Utils = require './utils'
juice = require 'juice'

numeral    = require 'numeral'
numeral.language 'dongs',
  delimiters:
    thousands: ','
    decimal:   '.'
  abbreviations:
    thousand: 'k'
    million:  'm'
    billion:  'b'
    trillion: 't'
  currency:
    symbol: '$'
numeral.language('dongs')

formatNumber = (x) ->
    result = numeral(x).format('0,0a')
    result = result.replace(/\.00/, '')
    return result


LE_STYLESHEET = \
"""
/**
 * Eric Meyer's Reset CSS v2.0
(http://meyerweb.com/
eric/tools/css/reset/)
 * http://cssreset.com
 */
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
    display: block;
}
body {
    line-height: 1;
}
ol, ul {
    list-style: none;
}
blockquote, q {
    quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
    content: '';
    content: none;
}
table {
    border-collapse: collapse;
    border-spacing: 0;
}
html, body {
  width: 100%;
  font-family: 'Helvetica Neue', Helvetica;
  color: #444;
}
* {
  box-sizing: border-box;
}
.container {
  width: 700px;
  margin: auto;
  padding: 30px;
  padding-top: 15px;
  padding-bottom: 50px;
  height: 100%;
  background: white;
  text-align: center;
}
.card {
  padding: 15px;
  border: 1px solid #aaa;
  display: inline-block;
  text-align: center;
  border-radius: 10px;
  border-bottom: 2px solid #888;
  margin: 7px;
  min-width: 150px;
}
.cards {
  padding-bottom: 20px;
}
.cards h1, .lists h1 {
  letter-spacing: 1px;
  font-size: 20px;
  font-weight: 200;
  margin-bottom: 30px;
  margin-top: 20px;
  text-align: left;
  border-bottom: 1px solid #ddd;
  padding-bottom: 5px;
  text-indent: 10px;
}
.card h1 {
  text-transform: uppercase;
  font-size: 12px;
  margin-top: 0;
  margin-bottom: 10px;
  font-weight: 600;
  padding-bottom: 5px;
  border-bottom: 1px solid #ccc;
  text-align: left;
  color: #666;
}
.card-negative, .card-negative h1 {
  color: #a8294d;
  border-color: #a8294d;
}
.card-positive, .card-positive h1 {
  color: #31a341;
  border-color: #31a341;
}

.ty {
  text-align: center;
  font-size: 30px;
  font-weight: 300;
  display: inline-block;
  padding-left: 4px;
  padding-right: 4px;
}
.ly {
  display: none;
}
.dollar {
  font-size: 18px;
  position: relative;
  top: -1px;
  margin-right: 3px;
}
.percentage {
  font-size: 10px;
  position: relative;
  top: -1px;
  margin-right: 2px;
}
.growth {
  font-size: 20px;
  display: inline-block;
}
.list {
    max-width: 600px;
    margin: auto;
}
.card-positive, .item-positive .metric {
  color: #31a341;
}
.card-negative, .item-negative .metric {
  color: #a8294d;
}
.index {
  display: none;
  font-size: 36px;
  color: #444;
  font-weight: 100;
}
.label {
  font-size: 32px;
  display: inline-block;
  font-weight: 300;
  margin-left: 4px;
  margin-right: 20px;
  text-transform: capitalize;
}
.item {
  text-align: left;
  clear: both;
  margin-bottom: 10px;
}

.metric {
  float: right;
  position: relative;
  top: 6px;
}
"""



module.exports = render: (indices) ->

    locals =

        revenue: \
        Object.keys(indices.revenue).reduce ((result, key) ->
            [ty, ly] = [indices.revenue[key], indices.revenue["ly_#{key}"]]
            growth = Utils.growth(ty, ly)
            arrow = if growth > 0 then '⇡' else '⇣'
            ty = formatNumber(ty)
            sign = if growth > 0 then 'positive' else 'negative'
            growth = (growth * 100).toFixed(0)
            growth = growth.replace('-', '')
            result[key] = {ty, ly, sign, growth, arrow}
            return result
        ), {}

        orders: \
        Object.keys(indices.orders).reduce ((result, key) ->
            [ty, ly] = [indices.orders[key], indices.orders["ly_#{key}"]]
            growth = Utils.growth(ty, ly)
            arrow = if growth > 0 then '⇡' else '⇣'
            ty = formatNumber(ty)
            sign = if growth > 0 then 'positive' else 'negative'
            growth = (growth * 100).toFixed(0)
            growth = growth.replace('-', '')
            result[key] = {ty, ly, sign, growth, arrow}
            return result
        ), {}

        topSellingCategories: indices.top.thisWeek.revenue.category[0..2].map(([category, value], index) ->
            """
            <div class="item">
              <div class="index">#{index+1}.</div>
              <div class="label">#{category}</div>
              <div class="metric">
                <div class="ty"><span class="dollar">$</span>#{formatNumber(value)}</div>
              </div>
            </div>
            """
        ).join('\n')


    result = \
    """
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <div class="container">
      <div class="cards">
        <h1>Sales</h1>
        <div class="card card-#{locals.revenue.today.sign}">
          <h1>Today</h1>
          <div class="ty"><span class="dollar">$</span>#{locals.revenue.today.ty}</div>
          <div class="ly"><span class="dollar">$</span>#{locals.revenue.today.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.revenue.today.growth}#{locals.revenue.today.arrow}</div>
        </div>
        <div class="card card-#{locals.revenue.thisWeek.sign}">
          <h1>This Week</h1>
          <div class="ty"><span class="dollar">$</span>#{locals.revenue.thisWeek.ty}</div>
          <div class="ly"><span class="dollar">$</span>#{locals.revenue.thisWeek.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.revenue.thisWeek.growth}#{locals.revenue.thisWeek.arrow}</div>
        </div>
        <div class="card card-#{locals.revenue.thisMonth.sign}">
          <h1>This Month</h1>
          <div class="ty"><span class="dollar">$</span>#{locals.revenue.thisMonth.ty}</div>
          <div class="ly"><span class="dollar">$</span>#{locals.revenue.thisMonth.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.revenue.thisMonth.growth}#{locals.revenue.thisMonth.arrow}</div>
        </div>
      </div>
      <div class="cards">
        <h1>Orders</h1>
        <div class="card card-#{locals.orders.today.sign}">
          <h1>Today</h1>
          <div class="ty">#{locals.orders.today.ty}</div>
          <div class="ly">#{locals.orders.today.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.orders.today.growth}#{locals.orders.today.arrow}</div>
        </div>
        <div class="card card-#{locals.orders.thisWeek.sign}">
          <h1>This Week</h1>
          <div class="ty">#{locals.orders.thisWeek.ty}</div>
          <div class="ly">#{locals.orders.thisWeek.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.orders.thisWeek.growth}#{locals.orders.thisWeek.arrow}</div>
        </div>
        <div class="card card-#{locals.orders.thisMonth.sign}">
          <h1>This Month</h1>
          <div class="ty">#{locals.orders.thisMonth.ty}</div>
          <div class="ly">#{locals.orders.thisMonth.ly}</div>
          <div class="growth"><span class="percentage">%</span>#{locals.orders.thisMonth.growth}#{locals.orders.lastWeek.arrow}</div>
        </div>
      </div>
      <div class="lists">
        <h1>Top Selling Categories - This Week</h1>
        <div class="list">
          #{locals.topSellingCategories}
        </div>
      </div>
    </div>
    """

    return juice.inlineContent(result, LE_STYLESHEET)
