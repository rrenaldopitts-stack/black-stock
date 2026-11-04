const tipButton = document.querySelector('#tip-button');
const tipText = document.querySelector('#tip');



const showTp = () =>{
tipText.innerHTML = 'Understand the risks before investing.';
}
tipButton.addEventListener('click',showTip)