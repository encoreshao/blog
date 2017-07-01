(($) ->
  $(document).on 'change', 'input#user_avatar', (e) ->
    e.preventDefault()

    console.log $(this)

) jQuery
