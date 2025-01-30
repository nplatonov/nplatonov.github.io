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
    const container = document.querySelector('.remark-slide-scaler');
    const scroller = document.querySelector('.scrollable');
    const image = container.querySelector('img, iframe, .framed');
    const isAlert = false;

    if (container && image) {
        // Вычисляем общую высоту текста с учетом стандартных отступов
        let totalTextHeight = 0;
        const clientHeight = container.clientHeight - 0;
        const textNodes = container.querySelectorAll('p:not(:has(> img))'); // '*:not(p > img)'
       // const textNodes = container.querySelectorAll('*:not(.figure > .framed)'); // '*:not(p > img)'
        if (isAlert)
           alert('clientHeight: ' + clientHeight);
        if (isAlert)
           alert('clientWidth: ' + container.clientWidth);
        textNodes.forEach(node => {
            if (isAlert)
                alert('node.offsetHeight: ' + node.offsetHeight);
            totalTextHeight += node.offsetHeight;
        });

        // Определяем доступную высоту для изображения
        const availableHeight = clientHeight - totalTextHeight;

        // Если доступная высота меньше или равна нулю, уменьшаем высоту контейнера до минимальной возможной
        if (availableHeight <= 0) return;

        // Сохраняем пропорции изображения
        const aspectRatio = image.naturalWidth / image.naturalHeight;

        // Начальная ширина и высота изображения
        let newWidth = availableHeight * aspectRatio * 1;
        let newHeight = availableHeight;
        let changableHeight = availableHeight;
        if (isAlert)
            alert('changableHeight: ' + changableHeight);

        // Проверяем, если новая ширина больше ширины контейнера, то меняем размеры изображения
        if (newWidth > container.clientWidth) {
            newHeight = container.clientWidth / aspectRatio;
            newWidth = container.clientWidth;
        }
        // Функция для проверки наличия вертикальной прокрутки
        function hasVerticalScrollbar(element) {
            return element.scrollHeight > element.clientHeight;
        }

        // Уменьшаем размеры изображения до тех пор, пока не исчезнет вертикальная прокрутка
        if (isAlert)
            alert('newHeight (itit): ' + newHeight);
        while (hasVerticalScrollbar(scroller)) {
           // newHeight *= 0.95;
           // newWidth *= 0.95;
            newHeight -= 1;
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
            changableHeight = container.clientHeight - totalTextHeight;

            // Если доступная высота меньше или равна нулю, завершаем процесс
            if (changableHeight <= 0) break;
            */
        }
        if (isAlert)
            alert('changableHeight: ' + changableHeight);
       // alert(availableHeight);

        // Дополнительный шаг для гарантии отсутствия прокрутки
       // newHeight *= 0.95;
       // newWidth *= 0.95;
       // image.style.width = `${newWidth}px`;
        image.style.height = `${newHeight}px`;
        if (isAlert)
            alert('newHeight (image): ' + newHeight);

        // Включаем вертикальную прокрутку контейнера, если она все еще нужна
       // container.style.overflowY = hasVerticalScrollbar(container) ? 'scroll' : 'hidden';
    }
}
function adjustFontSize() {
    const container = document.querySelector('.fixprecode');
    const scroller = document.querySelector('.scrollable');
    
    if (!container) return;

    // Проверяем наличие img и iframe внутри контейнера
    const hasImagesOrIframes = container.querySelectorAll('img, .framed, iframe, pre > code').length > 0;
    
    if (hasImagesOrIframes) {
        return; // Если есть img или iframe, ничего не делаем
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
    // Функция для проверки наличия вертикальной прокрутки
    function hasVerticalScrollbar(element) {
        return element.scrollHeight > element.clientHeight;
    }

    // Если есть вертикальная прокрутка, начинаем уменьшать размер шрифта
    let fontSize = 100; // Начальный размер шрифта в процентах
    let reduced = false;
    const step=0.2;
    while (hasVerticalScrollbar(scroller)) {
        if (!reduced)
           reduced = true
        fontSize -= step;
        if (fontSize <= 20) { // Ограничиваем минимальный размер шрифта
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
       scroller.classList.remove('scrollable')
    }
    // Устанавливаем найденный размер шрифта в стиле контейнера
    container.setAttribute('style', `font-size: ${(fontSize).toFixed(1)}%;`);
}
