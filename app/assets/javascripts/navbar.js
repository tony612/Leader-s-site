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
