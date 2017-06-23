(($) ->

  $(document).on 'click', 'span.btn-action', (e) ->
    e.preventDefault()
    currentElement = $(this)
    return if currentElement.data('disabled')

    if currentElement.data('name') == 'up'
      action = 'like'
    else
      action = 'dislike'
    pathnames = document.location.pathname.split(/\//)

    ajaxOptions =
      headers:
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      type: 'POST'
      url: '/articles/' + action + '.json'
      dataType: 'JSON'
      data:
        year: pathnames[1]
        month: pathnames[2]
        day: pathnames[3]
        permalink: pathnames[4]
      beforeSend: () ->
        currentElement.data('disabled', true)
      success: (response) ->
        currentElement.find('count').text(response.count)

    $.ajax ajaxOptions

  $("#commentForm").validate()

  window.loadingTagsColor = ->
    tags_a = $('.tagcloud a')
    tags_a.each ->
      x = 9
      y = 0
      rand = parseInt(Math.random() * (x - y + 1) + y)
      $(this).addClass 'tags' + rand
      return
    return
    
  loadingTagsColor()
) jQuery
