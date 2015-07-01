# Semantic Data Parser

This package converts semantic date strings into Moment data object. Note that this package will interpret numbered dates the American way -- Month/Day -- as opposed to the Rest-of-the-World way -- Day/Month.

Check out the [demo](https://date-parser.meteor.com)!

# Getting Started

Add to your Meteor project

    meteor add ccorcos:date-parser

Then simply pass your string into `parseDate`. If the result is a moment object, then you're good. If it failed to parse, it will come out as `undefined`.

# How it works

All I'm doing is combinatorically combining differnt ways of specifying dates and inferring certain meanings when information is left out. For example, "Jan 4" will call `autoYear` and `autoTime`. `autoYear` will pick the next upcoming year with that date, not necessarily the current year. `autoTime` will pick noon.

I'm also cleaning and tokenizing the strings to remove undesired characers like `/` and `.`. I simply replace these with spaces and then clean everything up so all the tokens are space-separated. Then I simply parse the data with a ton of different Moment.js strict formats. You can see all of then in `parseDate.patterns`.


# To Do

There's an [issue](https://github.com/moment/moment/issues/2423) with Moment.js right now where it doesn't properly match "tuesday" or other days of the week without other context like a time. Once this is the solved, the package will be updated.