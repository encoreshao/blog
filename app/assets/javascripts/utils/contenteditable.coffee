(($) ->
  'use strict'

  $('#editControls a').click (e) ->
    switch $(this).data('role')
      when 'h1', 'h2', 'p'
        document.execCommand 'formatBlock', false, '<' + $(this).data('role') + '>'
      else
        document.execCommand $(this).data('role'), false, null
        break
    return

  return
) jQuery
