// Beginner note: Finds the button and the empty paragraph inside it so we can change them with JavaScript.
const tipButton = document.querySelector('#tip-button');
const tipText = document.querySelector('#tips');

// Beginner note: A list (array) of tips. Each click shows the next one.
const tips = [
  'Understand the risks before investing.',
  'Start small and invest only what you can afford to lose.',
  'Diversify: do not put all your money in one stock.',
  'Think long term. Time in the market beats timing the market.',
  'Ownership builds wealth. Learn before you leap.'
];

// Beginner note: Keeps track of which tip to show next.
let tipIndex = 0;

// Beginner note: Shows the current tip, then moves to the next one. The % wraps back to the start.
const showTip = () => {
  tipText.textContent = tips[tipIndex];
  tipIndex = (tipIndex + 1) % tips.length;
};
tipButton.addEventListener('click', showTip);

// Beginner note: Finds the paragraph in the app bar that will hold the greeting and clock.
const greetingClock = document.querySelector('#greeting-clock');

// Beginner note: Builds a greeting based on the hour, adds the current time, and puts it on the page.
const updateClock = () => {
  const now = new Date();
  const hour = now.getHours();

  let greeting = 'Good evening';
  if (hour < 12) {
    greeting = 'Good morning';
  } else if (hour < 18) {
    greeting = 'Good afternoon';
  }

  greetingClock.textContent = `${greeting}! It's ${now.toLocaleTimeString()}.`;
};

// Beginner note: Runs once right away, then every second so the clock stays current.
updateClock();
setInterval(updateClock, 1000);