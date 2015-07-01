{concat, map, reduce, join, pipe, curry, replace} = R

permute = (arr) ->
  reduce(((acc, list) ->
    map(join(' '), R.xprod(acc, list))
  ), arr[0], arr[1...])

spelledMD = permute([
  ['MMM', 'MMMM']
  ['D', 'DD', 'Do']
])

numberedMD = permute([
  ['M', 'MM']
  ['D', 'DD']
])

MD = concat(spelledMD, numberedMD)

spelledMDY = permute([
  spelledMD
  ['YY', 'YYYY']
])

numberedMDY = permute([
  numberedMD
  ['YY', 'YYYY']
])

MDY = concat(spelledMDY, numberedMDY)

times = [
  'H mm'
  'HH mm'
  'Hmm'
  'HHmm'
  'h mm a'
  'hh mm a'
  'hh a'
  'h a'
  'H'
  'HH'
]

TD = ['[today]', '[td]']
TM = ['[tomorrow]', '[tm]']
YD = ['[yesterday]', '[yd]']

TDT = permute([TD, times])
TMT = permute([TM, times])
YDT = permute([YD, times])

N = ['[now]']

MDT = permute([MD, times])
MDYT = permute([MDY, times])

W = ['dd', 'ddd', 'dddd']
NW = permute([['[next]'], W])
LW = permute([['[last]'], W])

WT = permute([W, times])
NWT = permute([NW, times])
LWT = permute([LW, times])

trim = pipe(
  replace(/\s+/g, ' ')
  R.trim
)

escapeRegex = (string) -> 
  str = R.clone(string)
  str = str.replace(new RegExp('[.\\\\+*?\\[\\^\\]$(){}=!<>|:\\-]', 'g'), '\\$&')
  str = str.replace(/\//g, '\\/')

ignore = curry (arr, str) ->
  ignorePatterns = reduce(((func, pattern) ->
    pipe(func, replace(new RegExp(escapeRegex(pattern), 'ig'), ' '))
  ), R.identity, arr)

  pipe(
    ignorePatterns,
    trim
  )(str)

spaceOut = curry (arr, str) ->
  spacePatterns = reduce(((func, pattern) ->
    pipe(func, replace(new RegExp(escapeRegex(pattern), 'ig'), ' '+pattern+' '))
  ), R.identity, arr)

  pipe(
    spacePatterns,
    trim
  )(str)

clean = pipe(
  (str) -> str.toLowerCase()
  ignore([',', 'at', 'this', ':', '/', '-', '\\', '.'])
  spaceOut(['am', 'pm'])
  trim
)

autoTime = (d) ->
  date = d.clone()
  date.hour(12).minute(0)
  return date

autoYear = (d) ->
  date = d.clone()
  now = moment()
  date.year(now.year())
  if date < now
    date.year(now.year() + 1)
  return date

# match [tm] and [today]
isBasicPattern = pipe(R.match(/^\[.*\]$/i), R.complement(R.isNil))
matchBasicPattern = (pattern, string) ->
  match = R.match(new RegExp("^#{escapeRegex(pattern[1...pattern.length-1])}$"))
  if isBasicPattern(pattern)
    if match(string)
      return true
  return false

parseWith = curry (patterns, transform, string) ->
  if moment.isMoment(string)
    return string
  else
    for format in patterns
      if matchBasicPattern(format, string)
        date = moment()
        date._f = format
        return transform(date)
      else
        date = moment(string, format, true)
        if date.isValid()
          return transform(date)
    return string

crawl = curry (key, value, d) ->
  date = d.clone()
  while date[key]() isnt value
    date.add(1, key)
  return date

thisWeek = (d) ->
  date = moment()
  date._f = d._f
  crawl('day', d.day(), date.hour(d.hour()).minute(d.minute()).add(1, 'day'))

nextWeek = (d) ->
  date = moment()
  date._f = d._f
  crawl('day', d.day(), date.hour(d.hour()).minute(d.minute()).add(7, 'day'))

lastWeek = (d) ->
  date = moment()
  date._f = d._f
  crawl('day', d.day(), date.hour(d.hour()).minute(d.minute()).subtract(7, 'day'))

autoNow = (d) -> 
  date = moment()
  date._f = d._f
  return date

autoToday = (d)->
  date = moment()
  date._f = d._f
  date.hour(d.hour()).minute(d.minute())
  return date

autoTomorrow = (d)->
  date = moment()
  date._f = d._f
  date.hour(d.hour()).minute(d.minute()).add(1, 'day')
  return date

autoYesterday = (d)->
  date = moment()
  date._f = d._f
  date.hour(d.hour()).minute(d.minute()).subtract(1, 'day')
  return date

# TDT - today, time
# TMT - tomorrow, time
# YDT - yesterday, time
# N - now
# TD - today, auto now
# TM - tomorrow, auto time
# YD - yesterday, auto time
# MDYT - month, day, year, time
# MDY - month, day, year, auto time
# MDT - month, day, auto year, time
# MD - month, day, auto year, auto time
# W - auto upcoming day of the week, auto time
# NW - auto next upcoming day of the week, auto time
# LW - auto last day of the week, auto time
# WT - auto upcoming day of the week, time
# NWT - auto next upcoming day of the week, time
# LWT - auto last day of the week, time
parseDate = pipe(
  clean
  parseWith(N, autoNow)
  parseWith(TDT, autoToday)
  parseWith(TMT, autoTomorrow)
  parseWith(YDT, autoYesterday)
  parseWith(TD, pipe(autoToday, autoTime))
  parseWith(TM, pipe(autoTomorrow, autoTime))
  parseWith(YD, pipe(autoYesterday, autoTime))
  parseWith(MDYT, R.identity)
  parseWith(MDY, autoTime)
  parseWith(MDT, autoYear)
  parseWith(MD, pipe(autoYear, autoTime))
  # parseWith(W, pipe(thisWeek, autoTime))
  parseWith(NW, pipe(nextWeek, autoTime))
  parseWith(LW, pipe(lastWeek, autoTime))
  parseWith(WT, thisWeek)
  parseWith(NWT, nextWeek)
  parseWith(LWT, lastWeek)
  (result) ->
    if moment.isMoment(result)
      return result
    else
      return undefined
)

parseDate.patterns = R.flatten [MDYT,  MDY,  MDT,  MD,  W,  NW,  LW,  WT,  NWT,  LWT, TD, TM, YD, TDT, TMT, YDT, N]