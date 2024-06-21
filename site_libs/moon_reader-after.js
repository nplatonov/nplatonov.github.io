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

$(".sidebar.narrow").hover(function () { $(this).toggleClass("hovered"); });

//.mainbar.scale:not(.broad) 
// document.getElementsByTagName(".mainbar").style.setProperty('--pointsize', '13px');
//document.getElementsByClassName('vertical-tabs-active-tab')

//$(".remark-slide-content.inverse")(function () { $(".remark-slide-container").css('background','blue')});
//$(".remark-slide-content:not(.inverse)")(function () { $(".remark-slide-container").css('background','green')});
   
//$(".remark-slide-container")(function() { $(".remark-slide-container").css('background','red')});

expandBackgroundColor();

document.addEventListener('DOMContentLoaded', function() {
    const class2Element = document.querySelector('.class2');
    function toggleBisClassOnClass1() {
        const class1Element = document.querySelector('.class1');
        if (class2Element.classList.contains('bis')) {
            class1Element.classList.add('bis');
        } else {
            class1Element.classList.remove('bis');
        }
    }
    toggleBisClassOnClass1();
    class2Element.addEventListener('classAdded', toggleBisClassOnClass1);
    class2Element.addEventListener('classRemoved', toggleBisClassOnClass1);
    class2Element.addEventListener('DOMAttrModified', function(e) {
        if (e.target === class2Element && e.attributeName === 'class') {
            toggleBisClassOnClass1();
        }
    });
});
