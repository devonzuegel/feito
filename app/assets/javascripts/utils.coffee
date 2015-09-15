@formatted_date = (date) ->
  d = new Date(date)
  moment(d).format('HH:MM MMMM Do, YYYY')

@time_ago = (date) ->
  d = new Date(date)
  moment(d).fromNow()

@word_count = (entry) ->
  (entry.body is not null) && entry.body.split.size || 0

@formatted_body = (entry) ->
  unless entry is null or entry.body is null
    entry.body.replace("\n", "\n\n")

@rand = (min, max) ->
  Math.floor(Math.random() * (max - min) + min)

@visit = (url) ->
  window.location = url

@intersection = (A, B) ->
  [A, B] = [B, A] if A.length > B.length
  value for value in A when value in B