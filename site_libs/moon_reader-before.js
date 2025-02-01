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
    // $(".mainbar").addClass("scrollable");
     $(".remark-slide-content").toggleClass("modified");
    // $(".mainbar").toggleClass("scale");
    // simulateMouseOver();
     var scaleElements = document.querySelectorAll('.mainbar.scale');
     if (scaleElements) {
       scaleElements.forEach(function(element) {
         if (!element.classList.contains('broad')) {
            element.style.fontSize = "100%"; /* 92% */
         } else {
            element.style.fontSize = "100%";
         }
       });
     }
    // adjustFontSize();
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

  const newSize = go_up ? currentSize + 0.5 : currentSize - 0.5;
  document.documentElement.style.setProperty('--pointsize', newSize + 'px');
});
function resizeImage() {
   const startTime = performance.now();
   // Функция для проверки наличия вертикальной прокрутки
   function hasVerticalScrollbar(element) {
      return element.scrollHeight > element.clientHeight;
   }
   const slideList = document.querySelectorAll('.remark-slide-scaler');
   let counter=0;
   var multi;
   slideList.forEach(slide => {
      if (!slide)
         return;
      // const slide = document.querySelector('.remark-slide-scaler');
      const scroller = slide.querySelector('.scrollable');
      if (!scroller)
         return;
      if (!scroller.clientHeight)
         return;
      if (false && !hasVerticalScrollbar(scroller)) {
        // scroller.classList.remove('scrollable')
        // scroller.classList.add('imageresized')
         return;
      }
      const imageList = scroller.querySelectorAll('img, iframe, .framed');
      multi = Object.keys(imageList).length > 1
      const columns = scroller.querySelector('.pulling, .double');
      if (multi) {
        // alert('scroller scrollHeight=' + scroller.scrollHeight +' clientHeight='+scroller.clientHeight);
        // alert('slide scrollHeight=' + slide.scrollHeight +' clientHeight='+slide.clientHeight);
        // availableHeight = image.naturalHeight;
         let k = 1;
         var imageHeight;
         var imageWidth;
        // scroller.style.height = "600px";
         while (hasVerticalScrollbar(scroller)) {
            k = k * 0.99;
            if (k < 0.5)
               break;
            imageList.forEach(image => {
              // aspectRatio = image.naturalWidth / image.naturalHeight;
              // newWidth = availableHeight * aspectRatio * 1;
              // newHeight = availableHeight;
               imageHeight = Math.floor(image.naturalHeight * k);
              // newWidth = image.naturalWidth * k;
              // const aspectRatio = image.naturalWidth / image.naturalHeight;
               image.style.height = `${imageHeight}px`;
            })
         }
         if (k >= 0.5) {
            scroller.classList.remove('scrollable1')
            imageList.forEach(image => {
               image.style.objectFit = `contain`
            });
         }
         return;
      }
      const image = scroller.querySelector('img, iframe, .framed');
      if (!image)
         return;
      counter++;
      const isAlert = counter==0;
      var availableHeight;
      const parentElement = image.parentElement;
      const parentWidth = parentElement.offsetWidth;
      if (true && columns) {
         availableHeight = image.naturalHeight; //clientHeight - totalTextHeight;
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
      while (hasVerticalScrollbar(scroller)) {
         // newHeight *= 0.95;
         // newWidth *= 0.95;
         newHeight -= 1;
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
      if (columns) {
         newWidth = newHeight * aspectRatio;
         if (newWidth > parentWidth) {
            newHeight = Math.round(parentWidth / aspectRatio);
            image.style.height = `${newHeight}px`;
         }
        // newWidth = newHeight * aspectRatio / 2;
        // image.style.width = `${newWidth}px`;
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
      scroller.classList.remove('scrollable1')
      if (isAlert)
         alert('newHeight (image): ' + newHeight);
      // alert('size: ' + newHeight + ' x ' + Math.round(newHeight * aspectRatio));

       // Включаем вертикальную прокрутку контейнера, если она все еще нужна
      // scroller.style.overflowY = hasVerticalScrollbar(scroller) ? 'scroll' : 'hidden';
   })
   const endTime = performance.now();
   const durationInMilliseconds = endTime - startTime;
   const durationInSeconds = durationInMilliseconds / 1000;
   if (durationInSeconds>10)
      alert(`Image size adjustment took ${durationInSeconds} seconds`);
   return;
}
function adjustFontSize() {
   const startTime = performance.now();
   // Функция для проверки наличия вертикальной прокрутки
   function hasVerticalScrollbar(element) {
      return element.scrollHeight > element.clientHeight;
   }
   const slideList = document.querySelectorAll('.remark-slide-scaler');
   let count=0;
   slideList.forEach(slide => {
      const container = slide.querySelector('.fixprecode');
      if (!container)
         return;
      const scroller = slide.querySelector('.scrollable');
      if (!hasVerticalScrollbar(scroller))
         return;
      container.setAttribute('style', `font-size: 100%;`);
      // Проверяем наличие img и iframe внутри контейнера
      const hasImagesOrIframes = container.querySelectorAll('img, .framed, iframe').length > 0;
      
      if (hasImagesOrIframes) {
         return; // Если есть img или iframe, ничего не делаем
      }
      const forced = scroller.querySelectorAll('pre > code, table').length > 0;
      var admit;
      if (forced)
         admit = 70;
      else
         admit = 60;
      count++;
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
      const step=0.2;
      while (hasVerticalScrollbar(scroller)) {
         if (!reduced)
            reduced = true
         fontSize -= step;
         if (fontSize <= admit) { // Ограничиваем минимальный размер шрифта
            reduced = false;
            break; 
         }
         container.style.fontSize = `${fontSize}%`;
      }
      if (reduced) {
         while (!hasVerticalScrollbar(scroller)) {
            fontSize += step;
            container.style.fontSize = `${fontSize}%`;
         }
         fontSize -= step;
         if (!forced)
            scroller.classList.remove('scrollable')
      }
      else {
         fontSize = 100;
         container.style.fontSize = `${fontSize}%`;
         if (!hasVerticalScrollbar(scroller))
            scroller.classList.remove('scrollable')
      }
      // Устанавливаем найденный размер шрифта в стиле контейнера
      container.setAttribute('style', `font-size: ${(fontSize).toFixed(1)}%;`);
      return;
   })
   const endTime = performance.now();
   const durationInMilliseconds = endTime - startTime;
   const durationInSeconds = durationInMilliseconds / 1000;
   if (durationInSeconds>10)
      alert(`Font size adjustment took ${durationInSeconds} seconds`);
}
window.addEventListener('load', resizeImage);
window.addEventListener('load', adjustFontSize);
