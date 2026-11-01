// 1. Establish the starting wallet data
let cashBalance = 5000;

// 2. Select the HTML elements using their IDs
const cashDisplay = document.getElementById("portfolio-value");
const bonusButton = document.getElementById('add-funds-btn');

// 3. Create a function to display the formatted balance on the screen
function updateDisplay() {
  cashDisplay.innerText = `$${cashBalance.toLocaleString()}.00`;
}

// 4. Run the function immediately when the page opens
updateDisplay();

// 5. Add an Event Listener to make the button increase the balance
bonusButton.addEventListener('click', function() {
  cashBalance += 500; // Add $500 bonus
  updateDisplay();    // Refresh the number on the screen
});
