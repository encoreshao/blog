(($) ->
  $(document).on 'change', 'select#article_category_id', (e) ->
    e.preventDefault()
    selected = $(this).find(':selected').data('type')

    if selected == 'audio' || selected == 'video'
      $('.article_embed_link').removeClass('hide')
    else
      $('.article_embed_link').addClass('hide')

) jQuery
