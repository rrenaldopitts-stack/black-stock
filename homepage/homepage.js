let readMore = document.getElementsByClassName('info');
let moreInfo = document.getElementsByClassName('more-info');


const showInfo = () =>{
 moreInfo.style.display = 'block' 
}
readMore.addEventListener('click',showInfo)