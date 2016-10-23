


module.exports =

    growth: (curr, prev) ->
        return 0 if prev is 0
        return null if not prev
        [curr, prev] = [parseFloat(curr), parseFloat(prev)]
        return Math.abs (curr - prev) / prev if prev <= 0 and curr > prev
        return ((curr - prev) / prev) * -1 if prev <= 0 and curr < prev
        return (curr - prev) / prev
