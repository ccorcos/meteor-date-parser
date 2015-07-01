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

close = (a,b) ->
  Math.abs(a.diff(b)) < 2000

Tinytest.add 'today, time', (test) ->
  test.isTrue close(parseDate('today, 12pm'), moment().hour(12).minute(0))
  test.isTrue close(parseDate('today, 1pm'), moment().hour(13).minute(0))
  test.isTrue close(parseDate('today, 1am'), moment().hour(1).minute(0))
  test.isTrue close(parseDate('today, 1:21am'), moment().hour(1).minute(21))
