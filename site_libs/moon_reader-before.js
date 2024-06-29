remark.macros.scale = function (percentage) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + percentage + '" />';
};
/*
function simulateMouseOver1() {
  var item2 = document.querySelector(".narrow");
  var event = new MouseEvent('mouseover', {view: window, bubbles: true, cancelable: true});
  var cancelled = !item2.dispatchEvent(event); // item1 or item2
  if (cancelled) {
    // A handler called preventDefault.
    //  alert("cancelled");
  } else {
    // None of the handlers called preventDefault.
    // alert("not cancelled");
  }
};
function simulateMouseOver1() {
   const node = document.querySelector(".remark-visible .narrow");
   node.toggleClass("hovered2");
  // node.classList.add("hovered2");  // Add newone class
}
function simulateMouseOver2() {
   const nodeList = document.querySelectorAll(".narrow.hovered2");
   if (nodeList != null) {
      for (let i = 0; i < nodeList.length; i++) {
        nodeList[i].classList.remove("hovered3");  // Remove mystyle class
      }
   }
   else {
      const node = document.querySelector(".remark-visible .narrow");
      node.classList.add("hovered2");  // Add newone class
   }
}
function simulateMouseOver3() {
   const nodeList = document.querySelectorAll(".narrow");
   if (nodeList != null) {
      for (let i = 0; i < nodeList.length; i++) {
        nodeList[i].toggleClass("hovered2");
      }
   }
}
*/
/*
function simulateMouseOver() {
   $(".narrow").toggleClass("hovered2");
}
// html: <button onclick="simulateMouseOver()">simulate onMouseOver</button>
*/
document.addEventListener('keydown', function(e) {
   if (e.code === 'KeyL') {
     // alert('Key \'L\' is pressed is pressed!');
     // $(".narrow").toggleClass("extend");
      $(".sidebar").toggleClass("narrow");
      $(".banner").toggleClass("narrow");
     // $(".sidebar").toggleClass("scale");
      $(".mainbar").toggleClass("broad");
     // $(".mainbar").toggleClass("scale");
     // simulateMouseOver();
      var scaleElements = document.querySelectorAll('.mainbar.scale');
      if (scaleElements) {
         scaleElements.forEach(function(element) {
            if (!element.classList.contains('broad')) {
               element.style.fontSize = "92%";
            } else {
               element.style.fontSize = "100%";
            }
         });
      }
      e.preventDefault();
  }
});
document.addEventListener('keydown', function(e) {
   if (e.code === 'KeyI') {
      $(".remark-slide-content").toggleClass("inverse");
     // $(".remark-slide-container").toggleClass("inverse");
     // $(".remark-slide-container").css('background','black');
      e.preventDefault();
  }
});

function expandBackgroundColor() {
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

document.addEventListener('keydown', function(event) {
  if (!event.altKey) return;
  const go_up = event.code === 'Equal';
  const go_down = event.code === 'Minus';
  const go_reset = event.code === 'Digit0';

  if (!(go_up || go_down || go_reset)) return;
  event.preventDefault();

  if (go_reset) {
    document.documentElement.style.removeProperty('--pointsize');
    return;
  }

  const currentSize = parseFloat(
    getComputedStyle(document.documentElement)
      .getPropertyValue('--pointsize')
  );

  const newSize = go_up ? currentSize + 1 : currentSize - 1;
  document.documentElement.style.setProperty('--pointsize', newSize + 'px');
});
