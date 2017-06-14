###*
# jQuery Mobile Menu
# Turn unordered list menu into dropdown select menu
# version 1.1(27-JULY-2013)
#
# Built on top of the jQuery library
#   http://jquery.com
#
# Documentation
#    http://github.com/mambows/mobilemenu
###

(($) ->

  $.fn.mobileMenu = (options) ->
    defaults =
      defaultText: 'Navigate to...'
      className: 'select-menu'
      subMenuClass: 'sub-menu'
      subMenuDash: '&ndash;'
    settings = $.extend(defaults, options)
    el = $(this)
    @each ->
      `var $select_menu`
      $el = $(this)
      $select_menu = undefined
      # ad class to submenu list
      $el.find('ul').addClass settings.subMenuClass
      # Create base menu
      $select_menu = $('<select />', 'class': settings.className + ' ' + el.get(0).className).insertAfter($el)
      # Create default option
      $('<option />',
        'value': '#'
        'text': settings.defaultText).appendTo $select_menu
      # Create select option from menu
      $el.find('a').each ->
        $this = $(this)
        optText = '&nbsp;' + $this.text()
        optSub = $this.parents('.' + settings.subMenuClass)
        len = optSub.length
        dash = undefined
        # if menu has sub menu
        if $this.parents('ul').hasClass(settings.subMenuClass)
          dash = Array(len + 1).join(settings.subMenuDash)
          optText = dash + optText
        # Now build menu and append it
        $('<option />',
          'value': @href
          'html': optText
          'selected': @href == window.location.href).appendTo $select_menu
        return
      # End el.find('a').each
      # Change event on select element
      $select_menu.change ->
        locations = $(this).val()
        if locations != '#'
          window.location.href = $(this).val()
        return
      return
    # End this.each
    this

  return
) jQuery
