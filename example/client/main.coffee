Session.setDefault('prediction', '')

Template.main.helpers
  prediction: () ->
    Session.get('prediction')

Template.main.events
  'keyup input': (e,t) ->
    text = t.find('input').value
    if text is ''
      Session.set('prediction', '')
    else
      Session.set('prediction', parseDate(text)?.format('LLLL') or "invalid date")