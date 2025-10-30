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
      const adjust = !false;
      var allSlides = document.querySelectorAll('.remark-slide-container');
      var image;
      const hide = false;
      if (true || hide) {
         allSlides.forEach(function(slide) {
            slide.style.display = "block";
         });
      }
     // alert('Key \'L\' is pressed is pressed!');
     // $(".narrow").toggleClass("extend");
      $(".sidebar").toggleClass("narrow");
      $(".banner").toggleClass("narrow");
     // $(".sidebar").toggleClass("scale");
      $(".mainbar").toggleClass("broad");
     // $(".mainbar").addClass("scrollable");
      $(".remark-slide-content").toggleClass("modified");
     // $(".mainbar").toggleClass("scale");
     // simulateMouseOver();
      if (adjust) {
         var scaleElements = document.querySelectorAll('.mainbar');
         if (scaleElements) {
            var counter = 0;
            scaleElements.forEach(function(element) {
               const container = element.querySelector('.fixprecode');
               if (!container)
                  return;
               counter++;
              // alert(counter);
               element.classList.add("scrollable");
               container.style.fontSize = ''; // "100%";
              // container.removeAttribute("style");
               const imageList = element.querySelectorAll(':not(.inline) img, iframe:not(.ursa-widgetize), .framed:has(> iframe)');
              /* const imageList = element.querySelectorAll('.framed, iframe'); */
               imageList.forEach(function(image) {
                 // console.log('Class Name (as string):', image.className);
                 // console.log(image.parentNode.className);
                  image.style.height = "700px";
               })
              /* 
               if (!element.classList.contains('broad')) {
                 // alert('toc');
                 // element.classList.remove("yyyy");
                 // element.classList.add("xxxx");
               } else {
                 // alert('broad');
                 // element.classList.remove("xxxx");
                 // element.classList.add("yyyy");
               }
              */ 
            });
         }
         adjustBundle();
         if (hide) {
            allSlides.forEach(function(slide) {
               if (!slide.classList.contains('remark-visible'))
                  slide.style.display = "none";
            });
         }
     }
     e.preventDefault();
  }
});
document.addEventListener('keydown', function(e) {
   if (e.code === 'KeyI') {
    // $(".remark-slides-area").toggleClass("inverse");
     $(".remark-slide-content").toggleClass("inverse");
    // $(".remark-slide-container").toggleClass("inverse");
    // $(".remark-slide-container").css('background','black');
     e.preventDefault();
  }
});

document.addEventListener('keydown', function(event) {
  if (!event.altKey) return;
  const go_up = event.code === 'Equal';
  const go_down = event.code === 'Minus';
  const go_reset = event.code === 'Digit0';

  if (!(go_up || go_down || go_reset)) return;
  event.preventDefault();

  if (go_reset) {
   document.documentElement.style.removeProperty('--pointsize');
   adjustOutline();
   return;
  }

  const currentSize = parseFloat(
   getComputedStyle(document.documentElement)
     .getPropertyValue('--pointsize')
  );

  const newSize = go_up ? currentSize + 0.5 : currentSize - 0.5;
  document.documentElement.style.setProperty('--pointsize', newSize + 'px');
  adjustOutline();
});
function hasVerticalScrollbar(element, verbose = false) {
   if (verbose)
      alert(element.scrollHeight + ' vs ' + element.clientHeight);
   const footer = element.querySelector('.footer');
   if (!footer)
      return (element.scrollHeight > element.clientHeight);
   footer.style.position = "static";
   const ret = element.scrollHeight > element.clientHeight;
   footer.style.position = "fixed";
   return ret;
}
function hasHorizontalScrollbar(element, verbose = false) {
   if (verbose)
      alert(element.scrollWidth + ' vs ' + element.clientWidth);
   return element.scrollWidth > element.clientWidth;
}
function hasScrollbar(scroller,within = false) {
   if (!within)
      return hasVerticalScrollbar(scroller);
   return hasVerticalScrollbar(scroller) || hasHorizontalScrollbar(scroller);
};
function getCssVariable(variableName) {
   var rootStyle = getComputedStyle(document.documentElement);
   if (!rootStyle)
      return 0;
   rootStyle = rootStyle.getPropertyValue(variableName).trim()
   if (!rootStyle)
      return 0;
   return parseFloat(rootStyle);
}
function scrollableOffset() {
   return getCssVariable('--scrollable-offset');
}
function adjustImageSize(beforeFont = true) {
   const afterFont = !beforeFont;
   const removableClass = "scrollable";
   console.log('before font = ',beforeFont,'afterFont = ',afterFont);
   const startTime = performance.now();
   // Функция для проверки наличия вертикальной прокрутки
   const slideList = document.querySelectorAll('.remark-slide-scaler');
   let counter=0;
   var multi;
   const minScale=0.3;
   slideList.forEach((slide, index) => {
      if (!slide)
         return;
      // const slide = document.querySelector('.remark-slide-scaler');
      let scroller;
      if (beforeFont)
         scroller = slide.querySelector('.scrollable');
      else {
         scroller = slide.querySelector('.smallimages');
      }
      if (!scroller)
         return;
      if (afterFont) {
         scroller.classList.remove("smallimages");
         scroller.classList.add(removableClass);
         console.log('back to scrollable');
      }
      console.log('in: index =',index);
      if (!scroller.clientHeight)
         return;
     // console.log("Image size: ind =", index);
      const oversize = scroller.querySelector('.scrollable, .oversize');
      if (oversize)
         return;
     // if (false && !hasVerticalScrollbar(scroller)) {
        // scroller.classList.remove('scrollable')
        // scroller.classList.add('imageresized')
     //    return;
     // }
      const imageList = scroller.querySelectorAll(':not(.untouchable) img, :not(.inline) img, iframe:not(.ursa-widgetize), .framed:has(> iframe)');
      multi = Object.keys(imageList).length > 1
     // console.log(Object.keys(imageList).length)
      const columns = scroller.querySelector('.pulling, .double');
     // if (columns)
     //    console.log("columns:",Object.keys(columns).length);
     // console.log("multi:",Object.keys(imageList).length);
      if ((multi) || (columns)) {
         let fontStyle = "";
         console.log("Multiple images or multiple columns");
         const predefinedHeights = Array.from(imageList).map(image => image.offsetHeight);
         imageList.forEach((image) => {
            if (true & multi) // `| multi`
               image.style.height = '700px';
            else
               image.style.height = '';
            return;
         });
         const container = scroller.querySelector('.fixprecode');
         if (afterFont) {
            if (!container) {
              // console.log('no container');
              // return;
            }
            else {
               if (hasVerticalScrollbar(scroller)) {
                  fontStyle = container.style.fontSize;
                  container.style.fontSize = "10%";
               }
            }
         }
         if (!hasVerticalScrollbar(scroller)) {
            scroller.classList.remove(removableClass);
            return;
         }
        // alert('scroller scrollHeight=' + scroller.scrollHeight +' clientHeight='+scroller.clientHeight);
        // alert('slide scrollHeight=' + slide.scrollHeight +' clientHeight='+slide.clientHeight);
        // availableHeight = image.naturalHeight;
         var k;
         var imageHeight;
         var imageWidth;
         if (false) {
            while (hasVerticalScrollbar(scroller)) {
               k = k * 0.99;
               if (k < minScale)
                  break;
              // console.log(k);
               imageList.forEach(image => {
                 // aspectRatio = image.naturalWidth / image.naturalHeight;
                 // newWidth = availableHeight * aspectRatio * 1;
                 // newHeight = availableHeight;
                 // imageHeight = Math.floor(image.naturalHeight * k);
                  imageHeight = Math.floor(image.offsetHeight * k);
                 // console.log(imageHeight);
                 // newWidth = image.naturalWidth * k;
                 // const aspectRatio = image.naturalWidth / image.naturalHeight;
                  image.style.height = `${imageHeight}px`;
               })
            }
           // console.log('k=' + k + ', ' + 'height=' + imageHeight);
            if (k >= 0.5) {
               scroller.classList.remove(removableClass)
               imageList.forEach(image => {
                  image.style.objectFit = `contain`;
               });
            }
            return;
         }
         let originalHeights = Array.from(imageList).map(image => image.offsetHeight);
         let heights = [...originalHeights]; // Start with the original heights
         let kset=Array.from(imageList).map(image => 0);
         imageList.forEach((image, index) => {
            const originalHeight = image.offsetHeight;
            image.style.height = `${originalHeight * 0.99}px`;
            Array.from(imageList).forEach((otherImage, otherIndex) => {
               if (otherIndex !== index) {
                  otherImage.style.height = '20px';
               }
            });
            k = 1;
            while (hasVerticalScrollbar(scroller)) {
               k = k * 0.995;
               if (k < minScale)
                  break;
              // imageHeight = Math.floor(image.offsetHeight * 0.995);
               imageHeight = Math.floor(originalHeights[index] * k);
               image.style.height = `${imageHeight}px`;
              // console.log([k, imageHeight, originalHeights[index]]);
            }
            heights[index] = image.offsetHeight;
            kset[index] = k;
            Array.from(imageList).forEach((restoreImage, restoreIndex) => {
               restoreImage.style.height = `${originalHeights[restoreIndex]}px`;
            });
         });
         imageList.forEach((image, index) => {
            image.style.height = `${heights[index]}px`;
         });
         console.log(kset);
         if (beforeFont) {
            if (kset.some(x => x<minScale)) {
               console.log('images so small');
               scroller.classList.add("smallimages");
               return;
            }
         }
         const success = heights.some((height, index) => height < 0.5 * originalHeights[index])
         if (success && !hasVerticalScrollbar(scroller)) {
            scroller.classList.remove(removableClass)
            imageList.forEach(image => {
               image.style.objectFit = `contain`;
            });
         }
         else { // trying proportional decreasing
           // console.log(index,"proportional");
           // console.log("predefinedHeights:",predefinedHeights);
           // console.log("resettedHeights:",originalHeights);
           // console.log("modifiedHeights:",heights);
            Array.from(imageList).forEach((restoreImage, restoreIndex) => {
               restoreImage.style.height = `${originalHeights[restoreIndex]}px`;
            });
            k = 1;
            while (hasVerticalScrollbar(scroller)) {
               if (false) {
                  k = k * 0.99;
                  if (k < 0.2)
                     break;
               }
               else {
                  k++;
                  if (k>200)
                     break;
               }
               imageList.forEach(image => {
                 // aspectRatio = image.naturalWidth / image.naturalHeight;
                 // newWidth = availableHeight * aspectRatio * 1;
                 // newHeight = availableHeight;
                 // imageHeight = Math.floor(image.naturalHeight * k);
                  imageHeight = Math.floor(image.offsetHeight * 0.99);
                 // console.log(imageHeight);
                 // newWidth = image.naturalWidth * k;
                 // const aspectRatio = image.naturalWidth / image.naturalHeight;
                  image.style.height = `${imageHeight}px`;
                 // console.log(k,imageHeight,image.offsetHeight);
               })
            }
            console.log('k=' + k + ', ' + 'height=' + imageHeight);
            if (k>200) {
               Array.from(imageList).forEach((restoreImage, restoreIndex) => {
                 // restoreImage.style.height = `${originalHeights[restoreIndex]}px`;
                  restoreImage.style.height = 'unset';
               });
            }
            else {
               if (k >= 0.5) {
                 // console.log(hasVerticalScrollbar(scroller));
                  scroller.classList.remove(removableClass)
                 // console.log(hasVerticalScrollbar(scroller));
                  k=1;
                  while (hasVerticalScrollbar(scroller)) {
                     k++;
                     if (k>14)
                        break;
                     imageList.forEach(image => {
                        imageHeight = Math.floor(image.offsetHeight-1);
                        image.style.height = `${imageHeight}px`;
                     })
                  }
                  imageList.forEach(image => {
                     image.style.objectFit = `contain`;
                  });
                 // console.log(hasVerticalScrollbar(scroller));
               }
            }
            if (afterFont) {
               if (container)
                  container.style.fontSize = fontStyle;
            }
           // console.log("resultingHeights:",Array.from(imageList).map(image => image.offsetHeight));
            return;
         }
         console.log('ready');
         return;
      }
      const image = scroller.querySelector(':not(.untouchable) img, iframe:not(.ursa-widgetize), .framed:has(> iframe), .html-widget');
      if (!image)
         return;
      counter++;
      const isAlert = counter==0;
      var availableHeight;
      const parentElement = image.parentElement;
      const parentWidth = parentElement.offsetWidth;
      if (true && columns) {
        // console.log(image.offsetHeight);
        // availableHeight = image.naturalHeight; //clientHeight - totalTextHeight;
         availableHeight = image.offsetHeight;
        // const clientHeight = parentWidth;
        // image.style.width = `${parentWidth}px`;
        // const imageList = scroller.querySelectorAll('img, iframe, .framed');
        // if (availableHeight * 2 > slide.clientHeight)
        //    return;
      }
      else {
         // Вычисляем общую высоту текста с учетом стандартных отступов
         let totalTextHeight = 0;
         const clientHeight = slide.clientHeight - 0;
         const textNodes = scroller.querySelectorAll('p:not(:has(> img, > a > img))'); // '*:not(p > img)'
        // const textNodes = slide.querySelectorAll('*:not(.figure > .framed)'); // '*:not(p > img)'
         if (isAlert)
           alert('clientHeight: ' + clientHeight);
        // if (isAlert)
        //   alert('clientWidth: ' + slide.clientWidth);
         textNodes.forEach(node => {
            if (isAlert)
               alert('node.offsetHeight: ' + node.offsetHeight);
            totalTextHeight += node.offsetHeight;
         });

         // Определяем доступную высоту для изображения
         availableHeight = clientHeight - totalTextHeight;
         // Если доступная высота меньше или равна нулю, уменьшаем высоту контейнера до минимальной возможной
         if (availableHeight <= 0) return;
      }
      // Сохраняем пропорции изображения
      const aspectRatio = image.naturalWidth / image.naturalHeight;

      // Начальная ширина и высота изображения
      let newWidth = availableHeight * aspectRatio * 1;
      let newHeight = availableHeight;
      let changableHeight = availableHeight;
      if (isAlert)
         alert('changableHeight: ' + changableHeight);

      // Проверяем, если новая ширина больше ширины контейнера, то меняем размеры изображения
      if (newWidth > scroller.clientWidth) {
         newHeight = scroller.clientWidth / aspectRatio;
         newWidth = scroller.clientWidth;
      }
      // Уменьшаем размеры изображения до тех пор, пока не исчезнет вертикальная прокрутка
      newHeight = Math.floor(newHeight);
      if (isAlert)
         alert('newHeight (itit): ' + newHeight);
      image.style.height = `${newHeight}px`;
     // image.style.height = `700px`;
     // return;
      if (hasVerticalScrollbar(image)) {
         image.style.height = ``;
         if (!hasVerticalScrollbar(scroller))
            return;
      }
     // console.log("in", newHeight);
      if (false) { // false if you want to keep figure size small
         newHeight = 777;
         image.style.height = `${newHeight}px`;
      }
      while (hasVerticalScrollbar(scroller)) {
         // newHeight *= 0.95;
         // newWidth *= 0.95;
         newHeight *= (1-0.01);
        // console.log(newHeight);
         if (newHeight < 10)
            break
         // newWidth -= 1;
         if (isAlert)
            alert('newHeight (loop): ' + newHeight);
         // image.style.width = `${newWidth}px`;
         image.style.height = `${newHeight}px`;
         /*
         // Пересчитываем высоту текста и доступную высоту после изменения изображения
         totalTextHeight = 0;
         textNodes.forEach(node => {
            totalTextHeight += node.offsetHeight;
         });
         changableHeight = scroller.clientHeight - totalTextHeight;

         // Если доступная высота меньше или равна нулю, завершаем процесс
         if (changableHeight <= 0) break;
         */
      }
      if (true) {
         const minHeight = newHeight;
         while (!hasVerticalScrollbar(scroller)) {
            newHeight *= (1+0.01);
            image.style.height = `${newHeight}px`;
         }
         const maxHeight=newHeight;
         image.style.height = `${minHeight}px`;
         hasVerticalScrollbar(scroller);
         newHeight = maxHeight * (1-0.01);
         image.style.height = `${newHeight}px`;
        // console.log(minHeight,maxHeight,newHeight);
      }
      if (columns) {
         newWidth = newHeight * aspectRatio;
         if (newWidth > parentWidth) {
            newHeight = Math.round(parentWidth / aspectRatio);
            image.style.height = `${newHeight}px`;
         }
        // newWidth = newHeight * aspectRatio / 2;
        // image.style.width = `${newWidth}px`;
      }
      else {
         newHeight = Math.floor(newHeight);
         image.style.height = `${newHeight}px`;
      }
      if (isAlert)
         alert('changableHeight: ' + changableHeight);
      // alert(availableHeight);

      // Дополнительный шаг для гарантии отсутствия прокрутки
      // newHeight *= 0.95;
      // newWidth *= 0.95;
      // image.style.width = `${newWidth}px`;
      // newHeight = Math.floor(newHeight);
      // image.style.height = `${newHeight}px`;
     // console.log(hasVerticalScrollbar(scroller), hasHorizontalScrollbar(scroller));
      if (!hasVerticalScrollbar(scroller)) {
         scroller.classList.remove(removableClass);
        // if (hasVerticalScrollbar(scroller))
        //    scroller.classList.add(removableClass);
      }
      if (isAlert)
         alert('newHeight (image): ' + newHeight);
      // alert('size: ' + newHeight + ' x ' + Math.round(newHeight * aspectRatio));

       // Включаем вертикальную прокрутку контейнера, если она все еще нужна
      // scroller.style.overflowY = hasVerticalScrollbar(scroller) ? 'scroll' : 'unset';
      if (!hasHorizontalScrollbar(scroller))
         scroller.style.overflowX = 'unset';
   })
   if (((performance.now() - startTime) / 1000) > 10)
      alert(`Image size adjustment took ${durationInSeconds} seconds`);
   return;
}
function adjustFontSize() {
   const removableClass = "scrollable";
   const startTime = performance.now();
            //~ const remarkDiv = document.querySelector('.remark-slides-area');
            //~ const splashDiv = document.createElement('div');
            //~ splashDiv.className = 'splash';
            //~ splashDiv.textContent = 'Please wait';
            //~ remarkDiv.appendChild(splashDiv);
   // Функция для проверки наличия вертикальной прокрутки
   const slideList = document.querySelectorAll('.remark-slide-scaler');
  // const offset = scrollableOffset();
   let count=0;
   slideList.forEach((slide, index) => {
     // console.log("Font size:", index);
      count++;
      const scroller = slide.querySelector('.scrollable');
      if (!scroller) {
         return;
      }
      const container = slide.querySelector('.fixprecode');
      if (!container) {
         scroller.classList.remove(removableClass);
         return;
      }
      if (false) {
         const footer = container.querySelector('.footer');
         if (false && footer) {
            console.log(footer.clientHeight);
         }
      }
     // const within = scroller.querySelector('.within');
      const within = container.querySelectorAll('.within').length > 0
     // console.log(scroller.parentNode);
     // container.setAttribute('style', `font-size: 100%;`);
      if (!hasScrollbar(scroller,within)) {
         scroller.classList.remove(removableClass);
         return;
      }
     // console.log(count);
     // alert(count + ' D');
      container.setAttribute('style', `font-size: 100%;`);
      // Проверяем наличие img и iframe внутри контейнера
      const hasImagesOrIframes = container.querySelectorAll('img, .framed, iframe').length > 0;
      
      if (hasImagesOrIframes) {
        // console.log(index,"media");
        // return; // Если есть img или iframe, ничего не делаем
      }
      const forced = scroller.querySelectorAll('pre > code, table').length > 0;
      var admit;
      if (forced)
         admit = 70/1;
      else
         admit = 70/1;
      if (within) {
         admit /= 10;
      }
      if (count == 6) {
       // container.addAttribute('style', 'background-color: yellow;');
       // return;
      }
     /*
      const allElements = container.querySelectorAll('*');
      const elementsArray = Array.from(allElements);
      const regex = new RegExp("\\.font\\d{2,3}");
      const filteredElements = elementsArray.filter(element => {
         if (element.classList && element.classList.length > 0) {
            for (let className of element.classList) {
               if (regex.test(className)) {
                  alert('true');
                  return true;
               }
            }
         }
        // alert('false');
         return false;
      });
      alert(filteredElements.length);
      if (filteredElements.some((num) => num))
        return;
     */
      // Если есть вертикальная прокрутка, начинаем уменьшать размер шрифта
      let fontSize = 100; // Начальный размер шрифта в процентах
      let reduced = false;
      const step=1-0.002;
      const step2=1-0.001;
      while (hasScrollbar(scroller,within)) {
     // while (container.clientHeight - scroller.clientHeight > 0) {
         if (!reduced)
            reduced = true
         fontSize *= step;
         if (fontSize <= admit) { // Ограничиваем минимальный размер шрифта
            reduced = false;
            break; 
         }
         container.style.fontSize = `${fontSize}%`;
      }
     // var k=
      if (reduced) {
         while (!hasScrollbar(scroller,within)) {
            fontSize /= step2;
            fontSize /= step2;
            container.style.fontSize = `${fontSize}%`;
         }
         fontSize *= step2;
         if (hasScrollbar(scroller,within)) {
            fontSize *= step2;
            if (hasScrollbar(scroller,within))
               fontSize *= step2;
            if (hasScrollbar(scroller,within))
               fontSize *= step2;
         }
         container.style.fontSize = `${fontSize}%`;
        // alert('1: ' + container.clientHeight - scroller.clientHeight);
        // alert(container.clientHeight - scroller.clientHeight);
         if ((true || !forced)||(!hasScrollbar(scroller,within))) {
            scroller.classList.remove(removableClass)
           // fontSize /= step;
           // scroller.classList.add("scrollable");
           // if (hasVerticalScrollbar(scroller)) {
           //    fontSize *= step;
           // }
           // scroller.classList.remove(removableClass)
         }
      }
      else {
         fontSize = 100;
         container.style.fontSize = `${fontSize}%`;
         if (!hasScrollbar(scroller,within))
            scroller.classList.remove(removableClass)
      }
      // Устанавливаем найденный размер шрифта в стиле контейнера
     // container.setAttribute('style', `font-size: ${(fontSize).toFixed(2)}%;`);
     // container.style.fontSize = `150%`;
      container.style.fontSize = `${(fontSize).toFixed(2)}%`;
      if (fontSize == 100)
         container.style.fontSize = '';
     // console.log(count + ': ' + fontSize);
      return;
   })
   const endTime = performance.now();
   const durationInMilliseconds = endTime - startTime;
   const durationInSeconds = durationInMilliseconds / 1000;
   if (durationInSeconds>10)
      alert(`Font size adjustment took ${durationInSeconds} seconds`);
}
function adjustOutline() {
   const slideList = document.querySelectorAll('.remark-slide-scaler');
   let counter=0;
   if (false)
      setTimeout(() => {
         console.log("Waited 3 seconds!");
      }, 3000); 
   slideList.forEach((slide, index) => {
      if (!slide)
         return;
      const sidebar = slide.querySelector('.sidebar.left-column');
      if (!sidebar)
         return;
      if (sidebar.clientHeight==0)
         return;
      const outline = sidebar.querySelector('.outline');
      if (!outline)
         return;
     // if (outline.clientHeight==0)
     //    return;
      var elem = document.querySelector('.test')
      var style = window.getComputedStyle(sidebar);
      const hideHeight = '200vh'; // sidebar.offsetHeight;
      const hideMargin = '-924px'; // sidebar.style.marginTop;
      const hidePadding = '924px'; // sidebar.style.paddingTop;
      sidebar.style.height = '100%';
      sidebar.style.marginTop = 'revert'; // revert
      sidebar.style.paddingTop = 'revert'; // revert
      counter++;
      const isAlert = counter == 0;
      const banner = slide.querySelector('.banner');
      let totalHeight = 0;
      if (!banner)
         totalHeight = 0; //sidebar.clientHeight;
      else
         totalHeight = banner.offsetHeight; //sidebar.clientHeight - banner.offsetHeight;
     // if (outline.clientHeight + totalHeight < sidebar.clientHeight)
     //    return;
      totalHeight = sidebar.clientHeight - 1 * totalHeight - 0 * scrollableOffset() - 6; /*+6*/
      if (outline.clientHeight <= totalHeight) {
         if (false && !hasVerticalScrollbar(sidebar))
            return;
      }
      if (false) {
         console.log("A",index,hasVerticalScrollbar(sidebar),hasHorizontalScrollbar(sidebar));
         console.log("1", index,outline.clientHeight,totalHeight);
      }
      var header;
      var fontSize;
      if (isAlert) {
         alert(totalHeight);
         alert(outline.clientHeight);
      }
      var k=0;
      var relative=100;
      const elements = outline.querySelectorAll('h1, h2, h3, h4, h5');
      if (false && outline.clientHeight >= totalHeight)
         console.log(index,"B:"
                   // ,"shorttitle:",banner.offsetHeight,"confbanner:",scrollableOffset()
                    ,"outline:",outline.clientHeight,"available:",totalHeight);
      outline.style.fontSize = `${relative}%`;
      while (outline.clientHeight >= totalHeight) {
         k++;
         //~ console.log(index, k);
         if (false) {
            elements.forEach((element) => {
               const computedStyle = window.getComputedStyle(element);
               const currentFontSize = computedStyle.getPropertyValue('font-size');
               const fontSizeNumeric = parseFloat(currentFontSize);
               const reducedFontSize = fontSizeNumeric * (1-0.002);
               element.style.fontSize = `${reducedFontSize}px`;
            });
         } else {
            relative = relative * (1-0.002);
            if (false)
               console.log("C:", relative);
            outline.style.fontSize = `${(relative).toFixed(1)}%`;
           // if (k>10)
           //    break;
         }
        // console.log(counter + ': ' + k);
        // if (isAlert && k==22)
        //    alert('22 ' + outline.clientHeight + ' out of ' + totalHeight);
        // break;
      }
      if (relative == 100)
         outline.style.fontSize = '';
      if (false && k > 0)
         console.log(index,"C:",k
                   // ,"shorttitle:",banner.offsetHeight,"confbanner:",scrollableOffset()
                    ,"outline:",outline.clientHeight,"available:",totalHeight
                    ,"relative:",relative,"scrollbar:",hasVerticalScrollbar(sidebar));
      k = 0;
      while (hasVerticalScrollbar(sidebar)) {
         k++;
         if (k>100)
            break;
         relative = relative * (1-0.002);
         if (false)
            console.log(index, k, "D:", relative);
         outline.style.fontSize = `${(relative).toFixed(1)}%`;
      }
      if (k>1) {
         const keepRelative = relative;
         k = 0;
         while (!hasVerticalScrollbar(sidebar)) {
            k++;
            if (k>100)
               break;
            relative = relative / (1-0.002);
            if (false)
               console.log(index, k, keepIndex, "E:", relative);
            outline.style.fontSize = `${(relative).toFixed(1)}%`;
         }
         var keepIndex = k;
         outline.style.fontSize = `${(keepRelative).toFixed(1)}%`;
         relative = keepRelative;
         for (k=0; k<keepIndex; k++) {
            relative = relative / (1-0.002);
         }
         outline.style.fontSize = `${(relative).toFixed(1)}%`;
      }
      if (isAlert) {
         alert(k + ' final ' + outline.clientHeight + ' out of ' + totalHeight);
      }
      sidebar.style.height = ''; // hideHeight;
      sidebar.style.marginTop = ''; // hideMargin;
      sidebar.style.paddingTop = ''; // hidePadding;
     // sidebar.style.overflowY = "clip";
     // sidebar.style.overflowX = "scroll";
     // sidebar.style.overflowY = "auto";
     // sidebar.style.overflowX = "auto";
   })
   return;
}
adjustBundle=function() {
   const loader = document.querySelector("#loader");
   if (loader)
      loader.style.visibility = "visible";
   const offset = scrollableOffset();
   if (false && offset) {
      const bannerList = document.querySelectorAll('.scrollable-offset');
      bannerList.forEach(banner => {
         banner.remove();
      })
   }
   if (offset > 0) {
      const slideList = document.querySelectorAll('.fixprecode');
      slideList.forEach(slide => {
         const banner = document.createElement('div');
         banner.className = 'scrollable-offset';
         slide.appendChild(banner);
      })
   }
   adjustImageSize(beforeFont=true);
   adjustFontSize();
   adjustImageSize(beforeFont=false);
   if (true && offset) {
      const bannerList = document.querySelectorAll('.scrollable-offset');
      bannerList.forEach(banner => {
         banner.remove();
      })
   }
   if (loader)
      loader.style.visibility = "hidden";
  // document.querySelector("body").style.visibility = "visible";
}
// window.addEventListener('load', adjustImageSize);
// window.addEventListener('load', adjustFontSize);
document.addEventListener('DOMContentLoaded', function() {
   const remarkDiv = document.querySelector('.remark-slides-area');
   function showSplashAndCallAdjust() {
      const splashDiv = document.createElement('div');
      splashDiv.className = 'splash';
      splashDiv.textContent = 'Check JS console ';
      remarkDiv.appendChild(splashDiv);
      adjustBundle();
      adjustOutline();
      remarkDiv.removeChild(splashDiv);
   }
   // Call the function to show splash and then call adjust
   showSplashAndCallAdjust();
});
