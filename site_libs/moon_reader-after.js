/*
---
js:
 - https://zachleat.github.io/BigText/dist/bigtext.js
 - https://cdn.staticfile.org/FitText.js/1.2.0/jquery.fittext.min.js
---

if( 'querySelectorAll' in document ) {
   $('.bigtext').bigtext();
}

// $('.remark-slide-content').fitText(1.2, { minFontSize: '14px', maxFontSize: '136px' });
$('.fitText').fitText(1.2, { minFontSize: '14px', maxFontSize: '936px' });

*/

//$(".sidebar.narrow").hover(function () { $(this).toggleClass("hovered"); });

//.mainbar.scale:not(.broad) 
// document.getElementsByTagName(".mainbar").style.setProperty('--pointsize', '13px');
//document.getElementsByClassName('vertical-tabs-active-tab')

//$(".remark-slide-content.inverse")(function () { $(".remark-slide-container").css('background','blue')});
//$(".remark-slide-content:not(.inverse)")(function () { $(".remark-slide-container").css('background','green')});
   
//$(".remark-slide-container")(function() { $(".remark-slide-container").css('background','red')});

function expandBackgroundColor() {
   document.querySelectorAll('.remark-slides-area').forEach(container => {
      const contentGrandchild = container.querySelector('.remark-slide-content');
      if (contentGrandchild) {
         const computedStyle = window.getComputedStyle(contentGrandchild);
         const backgroundColor = computedStyle.backgroundColor;
         container.style.backgroundColor = backgroundColor;
      }
   });
   document.querySelectorAll('.remark-slide-container').forEach(container => {
      const contentGrandchild = container.querySelector('.remark-slide-content');
      if (contentGrandchild) {
         const computedStyle = window.getComputedStyle(contentGrandchild);
         const backgroundColor = computedStyle.backgroundColor;
         container.style.backgroundColor = backgroundColor;
      }
   });
   const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
         if (mutation.type === 'attributes') {
            mutation.target.classList.forEach((className, index) => {
               if (className === 'remark-slide-content' && index === 0) {
                  const container = mutation.target.closest('.remark-slide-container');
                  if (container) {
                     container.style.backgroundColor = window.getComputedStyle(mutation.target).backgroundColor;
                  }
               }
            });
         }
      });
   });
   const config = { attributes: true, subtree: true };
   observer.observe(document.body, config);
}
expandBackgroundColor();

//window.onload = resizeImage;
// window.addEventListener('load', resizeImage);
// // // window.addEventListener('resize', resizeImage); 

//window.addEventListener('load', adjustFontSize);
// window.addEventListener('resize', adjustFontSize);

// resizeImage before adjustFontSize: adjustFontSize removes class scrollable
