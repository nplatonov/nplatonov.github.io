document.addEventListener('DOMContentLoaded', function() {
   const originalElement = document.querySelector('.author');
   const result1 = originalElement.textContent.replace(/, /g, '<br>');
   document.querySelector('.author').innerHTML = result1;
})
