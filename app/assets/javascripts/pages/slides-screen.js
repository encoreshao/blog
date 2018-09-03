// ICMOC

(function(window, $, undefined) {
  /* Cache vars -----------------  */
  var ICMOC = window.ICMOC || {};
  var $window = $(window);
  var $document = $(document);
  var $slides = $('.slide');
  var $pathname = window.location.pathname;
  var $rootpath = '/pages/fullpanels/slides/';

  ICMOC.inited = false;

  ICMOC.touch = false;
  ICMOC.mobile = false;

  if ($window.width() <= 480) { ICMOC.mobile = true; }

  /*
  if (Modernizr.touch) {
    ICMOC.touch = true;
  }
  */

  /* init */
  ICMOC.init = function() {
    // Initial rendering
    setTimeout(function() {
      $("#slides").addClass('init');
    }, 500);

    ICMOC.events.onPopState();

    // Show view pane
    if ($pathname !== '' && $pathname !== $rootpath) {
      setTimeout(function() {
        ICMOC.events['onKeyTop']();
      }, 250);
    }

    if (ICMOC.touch == false) {
      // Arrow keypress
      $window.keydown(function(event) {
        switch (event.which) {
          case 38:
            ICMOC.events['onKeyTop']();
            break;
          case 39:
            ICMOC.events['onKeyRight']();
            break;
          case 40:
            ICMOC.utils.hideAboutPane();
          case 27:
            ICMOC.events['onKeyBottom']();
            break;
          case 37:
            ICMOC.events['onKeyLeft']();
            break;
        }
      });
    }

    if (ICMOC.mobile == false) {
      // resize slide text
      $slides.fitText(.78);
    }

    // Arrow clicks
    $document.on('click', '#keys a', function(event) {
      event.preventDefault();
      ICMOC.events['on' + $(this).attr('id')]();
    });

    // Open click
    $document.on('click', '.open', function(event) {
      event.preventDefault();
      event.stopPropagation();
      ICMOC.events['onKeyTop']();
    });

    // Close click
    $document.on('click', '.close', function(event) {
      event.preventDefault();
      event.stopPropagation();
      ICMOC.events['onKeyBottom']();
    });

    // Ticker click
    $document.on('click', '#ticker, .slide', function(event) {
      event.preventDefault();
      ICMOC.events['onKeyRight']();
    });

    // about click
    $document.on('click', '#about-trigger', function(event) {
      event.preventDefault();
      ICMOC.utils.showAboutPane();
    });

    $document.on('click', '#about-trigger.close', function(event) {
      event.preventDefault();
      ICMOC.utils.hideAboutPane();
    });
  };

  /* events */
  ICMOC.events = {
    onResize: function() {
      ICMOC.utils.setTickerWidth();
      ICMOC.utils.setTickerPosition();
    },

    onOrientation: function() {
      switch (window.orientation) {
        case 0:
          $('body').removeClass('landscape').addClass('portrait').height($window.height() + 60);
          break;

        case 90:
        case -90:
          $('body').removeClass('portrait').addClass('landscape').height($window.height() + 60);
          break;
      }
      window.scrollTo(0, 1);
    },

    onPopState: function(force) {
      var force = force || false;

      if (ICMOC.inited || force) {
        ICMOC.utils.togglePanes();
        ICMOC.utils.setCurrentSlide(ICMOC.utils.getView());
        ICMOC.utils.redrawView();
      } else {
        ICMOC.inited = true;
      }
    },

    onKeyTop: function(view) {
      if ($('#about-pane').hasClass('show')) {
        ICMOC.utils.hideAboutPane();
      } else {
        if (typeof view == 'undefined') {
          var view = $('.current').data('view');
        }

        ICMOC.utils.hideAboutPane();
        ICMOC.utils.showPanes();
        ICMOC.paths.push({ 'title': view, 'path': $rootpath });
        ICMOC.utils.flashKey('KeyTop');
      }
    },

    onKeyRight: function() {
      ICMOC.utils.nextSlide();
      ICMOC.utils.redrawView();
      ICMOC.utils.flashKey('KeyRight');
      if ($('#panes').hasClass('show')) {
        var view = $('.current').data('view');

        ICMOC.paths.push({ 'title': view, 'path': $rootpath + view });
      }
    },

    onKeyBottom: function() {
      if ($('#panes').hasClass('show')) {
        ICMOC.utils.hidePanes();
        ICMOC.paths.push({ 'title': 'Home', 'path': $rootpath });
        ICMOC.utils.flashKey('KeyBottom');
      } else {
        ICMOC.utils.toggleAboutPane();
      }

      if (ICMOC.touch == true) {
        window.scrollTo(0, 1);
      }
    },

    onKeyLeft: function() {
      ICMOC.utils.prevSlide();
      ICMOC.utils.redrawView();
      ICMOC.utils.flashKey('KeyLeft');
      if ($('#panes').hasClass('show')) {
        var view = $('.current').data('view');
        ICMOC.paths.push({ 'title': view, 'path': $rootpath + view });
      }
    }
  };

  /* utilities */
  ICMOC.utils = {
    setTickerWidth: function() {
      $('#ticker-moment').css({ width: ICMOC.utils.getTickerWidth });
    },

    getTickerWidth: function() {
      // Set the gutter -- the left and right of track
      if (ICMOC.touch == false) {
        var gutter = 292;
      } else {
        var gutter = 145;
      }
      return (($window.width() - gutter) / $('.slide').size());
    },

    setTickerPosition: function() {
      // Set the left gutter
      if (ICMOC.touch == false) {
        var leftGutter = 168;
      } else {
        var leftGutter = 64;
      }
      var newPosition = (($('.slide.current').index()) * ICMOC.utils.getTickerWidth()) + leftGutter;
      $('#ticker-moment').css({ left: newPosition + 'px' });
    },

    setCurrentPane: function(view) {
      ICMOC.utils.setCurrentTitle(view);
      $('.pane').css({ display: 'none' });
      $('.pane[data-view="' + $('.slide.current').data('view') + '"]').css({ display: 'block' });
    },

    setCurrentSlide: function(view) {
      $('.slide.current').removeClass('current');
      $('.slide[data-view="' + view + '"]').addClass('current');
    },

    setCurrentTitle: function(view) {
      $('title').html('ICMOC: ' + $('.pane[data-view="' + $('.slide.current').data('view') + '"] img').attr('alt'));
    },

    nextSlide: function() {
      $slides.each(function() {
        var x = $(this).attr('data-order');
        x = parseInt(x);
        if (x == 1) {
          x = $slides.length;
        } else {
          x--;
        }
        x = x.toString();
        $(this).attr('data-order', x);
        if (x == 1) {
          ICMOC.utils.setCurrentSlide($(this).data('view'));
        }
      });
    },

    prevSlide: function() {
      $slides.each(function() {
        var x = $(this).attr('data-order');
        x = parseInt(x);
        if (x == $slides.length) {
          x = 1;
        } else {
          x++;
        }
        x = x.toString();
        $(this).attr('data-order', x);
        if (x == 1) {
          ICMOC.utils.setCurrentSlide($(this).data('view'));
        }
      });
    },

    setCurrentDate: function(view) {
      $('.date.current').removeClass('current');
      $('.date[data-view="' + $('.slide.current').data('view') + '"]').addClass('current');
    },

    showPanes: function() {
      if (!$('#panes').hasClass('show')) {
        $('#panes').removeClass('hide').addClass('show');
        $('#track, #slides').addClass('adjusted');
      }
    },

    hidePanes: function() {
      if ($('#panes').hasClass('show')) {
        $('#panes').removeClass('show').addClass('hide');
        $('#track, #slides').removeClass('adjusted');
      }
    },

    togglePanes: function() {
      if (!$pathname || $pathname === '/')
        ICMOC.utils.hidePanes();
      else
        ICMOC.utils.showPanes();
    },

    showAboutPane: function() {
      if (!$('#about-pane').hasClass('show')) {
        ICMOC.utils.hidePanes();
        $('#about-trigger').addClass('close');
        $('#about-pane').addClass('show');
        $('#track, #slides').addClass('blur');
      }
    },

    hideAboutPane: function() {
      if ($('#about-pane').hasClass('show')) {
        $('#about-trigger').removeClass('close');
        $('#about-pane').removeClass('show');
        $('#track, #slides').removeClass('blur');
      }
    },

    toggleAboutPane: function() {
      if ($('#about-pane').hasClass('show')) {
        ICMOC.utils.hideAboutPane();
      } else {
        ICMOC.utils.showAboutPane();
      }
    },

    flashKey: function(key) {
      $('#' + key).addClass('active');
      setTimeout(function() {
        $('.active').removeClass('active');
      }, 250);
    },

    getView: function() {
      if (!$pathname || $pathname === $rootpath) {
        return '/pages/fullpanels/slides/intro'; // home
      } else {
        return ICMOC.paths.split()[1];
      }
    },

    redrawView: function() {
      ICMOC.utils.setCurrentPane();
      ICMOC.utils.setCurrentDate();
      ICMOC.utils.setTickerPosition();
      ICMOC.utils.setTickerWidth();
    }
  };

  /* paths */
  ICMOC.paths = {
    split: function() {
      return $pathname.split('/');
    },
    push: function(view) {
      history.pushState(view, view.title, view.path);
    }
  };

  /* initial */
  if (jQuery('body').hasClass('fullpanels-slides')) {
    $(ICMOC.init);
  }

  $window.resize(ICMOC.events.onResize);

  window.onpopstate = function() {
    ICMOC.events.onPopState();
  }
})(window, jQuery);
