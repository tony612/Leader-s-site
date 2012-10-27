function setActive(){
  liObj = document.getElementById('cssmenu').getElementsByTagName('li');
  aObj = document.getElementById('cssmenu').getElementsByTagName('a');
  spanObj = document.getElementById('cssmenu').getElementsByTagName('span');
  find_it = false;
  for(i=aObj.length - 1;i >= 0;i--) {
    if (document.location.href.indexOf(aObj[i].href) >= 0){
      if(i != aObj.length - 5){
        find_it = true;
      } else{
        if(find_it) return;
      }
      liObj[i].className = 'active';
      spanObj[i].className = 'active';
      console.log(i)
    }
    if(i == aObj.length - 4) {
      i--;
    }
  }
  if(!find_it) {
    liObj[aObj.length - 5].className = 'active';
    spanObj[aObj.length - 5].classname = 'active';
  }
}

window.onload = setActive;
