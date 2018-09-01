(($) ->
  'use strict'
  # Navigation
  if $(window).outerWidth() > 800
    $('ul.menu li.menu-item-has-children').append '<div class=\'menu-dropdown-trigger\'></div>'
    $('ul.menu li.menu-item-has-children ul.sub-menu li.menu-item-has-children .menu-dropdown-trigger').attr 'style', 'display:none;'
    $('.menu-dropdown-trigger').click (e) ->
      # binding onclick
      if $(this).parent().hasClass('selected')
        $('.menu-item-has-children.selected .sub-menu').slideUp 100
        # hiding popups
        $('.menu-item-has-children.selected').removeClass 'selected'
      else
        $('.menu-item-has-children.selected .sub-menu').slideUp 100
        # hiding popups
        $('.menu-item-has-children.selected').removeClass 'selected'
        if $(this).parent().find('.sub-menu').length
          $(this).parent().addClass 'selected'
          # display popup
          $(this).parent().find('.sub-menu').slideDown 200
      e.stopPropagation()
      return

  # Forms
  $('form br').remove()
  $('form span').removeClass 'wpcf7-form-control-wrap'
  $('.page-navigation a.next').addClass 'newer-posts'
  $('.page-navigation a.prev').addClass 'older-posts'
  $('p.form-submit input[type=submit]').addClass 'button submit-button'
  $('ul.children').addClass 'comment-response'

  _warrior =
    "bg_body_image": "",
    "mobile_menu_text": "Navigate to...",
    "sticky_text":"Sticky"

  # Strecth body background image
  if _warrior.bg_body_image != ''
    $('body').backstretch _warrior.bg_body_image, centeredY: false

  # Posts carousel
  $('.carousel').flexslider
    animation: 'slide'
    slideshow: false
    animationLoop: false
    itemWidth: 291
    itemMargin: 0
    pausePlay: false
    controlNav: false

  # Post format gallery slider
  $('.post-slider').flexslider
    animation: 'slide'
    slideshow: false
    animationLoop: true
    pausePlay: false
    controlNav: false
  $('.button').hover ->
    $(this).find('icon').animate width: 30
    return

  # Audio
  $('article.format-audio .thumbnail').find('iframe').each ->
    $(this).closest('.thumbnail').find('img.wp-post-image').hide()
    return

  # Fitvids
  $('.video-holder, .fb_iframe_widget').fitVids()
  # jPanelMenu
  # jPM = $.jPanelMenu(
  #   menu: '#sidebar-wrappers'
  #   trigger: '.menu-trigger'
  #   duration: 300
  #   direction: 'left'
  #   openPosition: '300px'
  #   keyboardShortcuts: false)
  # jPM.on()
  # Mobile Menu

  $('.widget_nav_menu ul.menu, .menu-navigation ul.menu').mobileMenu
    defaultText: _warrior.mobile_menu_text
    className: 'menu-mobile'
    subMenuDash: '&ndash;'

  $('body').click ->
    # binding onclick to body
    $('.menu-item-has-children.selected .sub-menu').slideUp 100
    # hiding popups
    $('.menu-item-has-children.selected').removeClass 'selected'
    return

  # Animate
  $('article, #author-bio, #related-posts, #comments, #respond, .post-inner').addClass 'wow fadeIn'
  $('#logo, .social').addClass 'wow fadeIn'
  $('article.post-quote').removeClass 'wow fadeIn'

  wow = new WOW(
    boxClass: 'wow'
    animateClass: 'animated'
    offset: 100
    delay: 2000
    mobile: false)
  wow.init()

  # Clickable Quote Post Format
  $('article.format-quote').click ->
    window.location = $(this).find('a').attr('href')
    false

  # Sticky Article
  $('#content-wrappers article.sticky .post-title h3').before '<label class="sticky">' + _warrior.sticky_text + '</label>'
  # prettyPhoto

  $('dl.gallery-item dt a[href*=".jpg"], dl.gallery-item dt a[href*=".png"], dl.gallery-item dt a[href*=".gif"]').attr 'rel', 'prettyPhoto["gallery"]'
  $('a[rel^="prettyPhoto"], a[rel="prettyPhoto"]').prettyPhoto
    theme: 'pp_default'
    deeplinking: false
    social_tools: false

  # Go to Top
  $('a[href="#top"]').click ->
    $('html, body').animate { scrollTop: 0 }, 'slow'
    false
  $('#jPanelMenu-menu').hide()

  # Parallax effect
  $.stellar
    horizontalScrolling: false
    verticalOffset: 10

  $(window).scroll ->
    menu = jQuery('#sidebar-wrappers')
    if menu.length == 0
      return

    pos = menu.offset()

    if $(this).scrollTop() > pos.top + menu.height()
      $('.widget_nav_menu').addClass('fixed').fadeIn 'medium'
    else
      $('.widget_nav_menu').removeClass('fixed').fadeIn 'medium'

    # Scroll to top button
    if $(this).scrollTop() > 600
      $('#scroll-top').fadeIn()
    else
      $('#scroll-top').fadeOut()
    $('article.format-quote').each ->
      quoteHeight = $(this).outerHeight()
      $(this).find('.bg-opacity').css 'height', quoteHeight
      return
    return

  return
) jQuery
