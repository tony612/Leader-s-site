// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

//$('nav.ym-hlist li').live('click', function(){
//  $('nav.ym-hlist li').removeClass('active');
//  $(this).addClass('active');
//});

function setActive(){
  liObj = document.getElementById('navbar').getElementsByTagName('li');
  aObj = document.getElementById('navbar').getElementsByTagName('a');
  spanObj = document.getElementById('navbar').getElementsByTagName('span');
  find_it = false;
  for(i=aObj.length - 1;i >= 0;i--) {
    if (document.location.href.indexOf(aObj[i].href) >= 0){
      if(i != 0){
        find_it = true;
      } else{
        if(find_it) return;
      }
      liObj[i].className = 'active';
      spanObj[i].className = 'active';
    }
  }
}

window.onload = setActive;
