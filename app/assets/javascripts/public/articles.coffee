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

  $(document).on 'click', '.cc-btn.cc-dismiss', (e) ->
    e.preventDefault()

    $('.cc-window.cc-banner').remove()
    enabledCookies()
    return

  $("#commentForm").validate()

  window.loadingTagsColor = ->
    cloudTags = $('.tagcloud a')
    $.each cloudTags, (_, e)->
      x = 9
      y = 0
      rand = parseInt(Math.random() * (x - y + 1) + y)
      $(e).addClass 'tags' + rand
      return
    return

  window.loadAssetImages = (elements) ->
    $.each elements, (_, e) ->
      $(this).css('background-image', 'url(' + $(this).data('url') + ')').removeData 'url'
    return

  window.animationKey = () ->
    return 'blog.icmoc.com__animation'

  window.noOpeningAnimation = () ->
    return typeof Cookies.get(animationKey()) == 'undefined'

  window.enabledCookies = () ->
    Cookies.set(animationKey(), 'opened', { expires: 7 })
    return

  window.removeAnimationKeyFromCookies = () ->
    Cookies.remove(animationKey())
    return

  window.openingAnimation = (delayTime) ->
    $boxing = $('.animation .boxing')
    $('body').css('overflow', 'hidden')

    $boxing.animate { width: '100%' }, delayTime, ->
      $boxing.animate { height: '100%' }, delayTime, ->
        $('.fullpage-animated-box').fadeOut('slow')
        if noOpeningAnimation()
          $('.cc-window.cc-banner').css('opacity', '1')

        enableScrollBar()

    return

  enableScrollBar = () ->
    $('body').css('overflow', 'auto')
    return

  loadingArticlesRequest = () ->
    $.get "/dashboards/articles", (response) ->
      $("section #content-wrappers").html(response).fadeIn('slow')

    return

) jQuery
