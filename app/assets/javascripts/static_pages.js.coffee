# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready( ->
  $('.jquery_tabs').accessibleTabs({
    fx: 'fadeIn',
    syncheight: true,
    tabbody: '.tab-content'
  })
  console.log $('.jquery_tabs')

  $( ->
    $('#slides').slides({
      preload: true,
      preloadImage: '/assets/loading.gif',
      container: 'slides_container',
      pagination: true,
      crossfade: true,
      play: 3500,
    })
  )
)
