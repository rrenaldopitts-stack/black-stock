const tipButton = document.querySelector('#tip-button');
const tipText = document.querySelector('#tips');



const showTip = () =>{
tipText.innerHTML = 'Understand the risks before investing.';
}
tipButton.addEventListener('click',showTip)