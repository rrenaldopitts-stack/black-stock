// 1. Establish the starting stock price
let stockPrice = 128.40;

// 2. Select the HTML elements using their IDs
const priceDisplay = document.getElementById("featured-price"); // the <p> that shows the price
const refreshButton = document.getElementById("refresh-price-btn"); // the button the user clicks

// 3. Create a function that updates the price shown on the screen
function updatePrice() {
  // Pick a random change between -2.00 and +2.00 dollars
  const change = (Math.random() * 4) - 2;

  // Add the change to the current price
  stockPrice = stockPrice + change;

  // Write the new price into the page, formatted to 2 decimal places
  priceDisplay.innerText = `$${stockPrice.toFixed(2)}`;
}

// 4. Run the function once when the page loads so the display starts correct
updatePrice();

// 5. Add an Event Listener so clicking the button updates the price
refreshButton.addEventListener("click", updatePrice);a
gbopgrbprgbbgrgp