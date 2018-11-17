(($) ->
  'use strict'

  window.loadAssetImages = (elements) ->
    $.each elements, (_, e) ->
      $(this).css('background-image', 'url(' + $(this).data('url') + ')').removeData 'url'
    return

  return
) jQuery
