(($) ->

  window.typingRotateCarousel = (class_name) ->
    textElement = $('.' + class_name)
    return if textElement.length == 0

    options =
      strings: textElement.data('text')
      typeSpeed: textElement.data('period')

    new Typed '.' + class_name, options
    return

) jQuery
