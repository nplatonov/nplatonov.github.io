#итог

#предоперации

library(sf)
library(dplyr)
library(ggplot2)
library(ggspatial)
library(ggrepel)
library(extrafont)
library(systemfonts)  # Для проверки шрифтов в системе
library(showtext)     # Для загрузки шрифтов в R

#Какие драйверы поддерживаются?
st_drivers() %>% filter(grepl("ESRI", name))

#Проверка доступных шрифтов
if(!"Century Gothic" %in% fonts()) {
  message("Шрифт Century Gothic не найден, попробуем загрузить... Очень нужно!")
} else { message("Шрифт уже загружен. Наименование - ",
                 main_font <- "Century Gothic")
}

#Функция проверки и загрузки Century Gothic
check_and_load_century_gothic <- function() {
  font_name <- "Century Gothic"
  
  #1. Проверка наличия в системе
  if (font_name %in% system_fonts()$family) {
    message("✅ Шрифт '", font_name, "' уже установлен")
    return(invisible(TRUE))
  }
  
  #2. Если нет - загружаем
  message("⚠️ Шрифт '", font_name, "' не найден. Пробуем установить...")
  
  font_path <- "C:/Fonts/CenturyGothic.ttf"  # Укажите правильный путь!
  
  if (!file.exists(font_path)) {
    message("❌ Файл '", font_path, "' не найден")
    return(invisible(FALSE))
  }
  
  #3. Установка шрифта
  font_add(font_name, font_path)
  showtext_auto()
  
  # 4. Подтверждение
  message("✔ Шрифт успешно загружен из: ", normalizePath(font_path))
  invisible(TRUE)
}

#Вызов функции
check_and_load_century_gothic()

#Иначе самое принудительное (долгая загрузка, импорт шрифтов)
if (!"Century Gothic" %in% fonts()) {
  font_import(prompt = FALSE)
  loadfonts(device = "win")
}

#Путь к данным Natural Earth
root <- "C:/GIS/2 homework/data"

#Проверка доступных файлов
available_shapes <- list.files(root, pattern = "\\.shp$")
print(available_shapes)

# Береговая линия (для точного вычитания морей)
coastline <- st_read(file.path(root, "ne_10m_admin_0_countries.shp")) %>% 
  filter(NAME == "Australia") %>% 
  st_union() %>% 
  st_transform("+proj=longlat +datum=WGS84") %>% 
  st_cast("POLYGON")

#Загрузка данных административных границ (штаты)
aus_states <- st_read(file.path(root, "ne_10m_admin_1_states_provinces.shp")) %>% 
  filter(admin == "Australia")

#Загрузка данных морей (обрезка по береговой линии)
marine_areas <- st_read(file.path(root, "ne_10m_geography_marine_polys.shp")) %>% 
  filter(name %in% c("Timor Sea", "Tasman Sea", "Coral Sea", "Arafura Sea")) %>%
  st_difference(coastline) %>%
  suppressWarnings()

#Города
  cities <- st_read(file.path(root, "ne_10m_populated_places.shp")) %>% 
    filter(ADM0NAME == "Australia") %>%
    mutate(
      NAME_RU = case_when(
        NAME == "Sydney" ~ "Сидней",
        NAME == "Melbourne" ~ "Мельбурн",
        NAME == "Brisbane" ~ "Брисбен",
        NAME == "Perth" ~ "Перт",
        NAME == "Adelaide" ~ "Аделаида",
        NAME == "Canberra" ~ "Канберра",
        NAME == "Hobart" ~ "Хобарт",
        NAME == "Darwin" ~ "Дарвин",
        TRUE ~ NAME
      )
    ) %>% 
    filter(NAME %in% c("Sydney", "Melbourne", "Brisbane", "Perth",
                       "Adelaide", "Canberra", "Hobart", "Darwin"))
  
#Определение оптимальной проекции Альберса для Австралии
albers_proj <- "+proj=aea +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=132 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs"

#Преобразование координат -------------------------------------------------
aus_states_albers <- st_transform(aus_states, albers_proj)
marine_areas_albers <- st_transform(marine_areas, albers_proj)
cities_albers <- st_transform(cities, albers_proj) %>%
  mutate(
    nudge_x = case_when(
      NAME == "Canberra" ~ 1e5,   
      NAME == "Melbourne" ~ 5e5,
      NAME == "Hobart" ~ 3e5,
      NAME == "Sydney" ~ 1.3e5,
      TRUE ~ 0  
    ),
    nudge_y = 0
  )

# Подписи морей
marine_labels <- marine_areas_albers %>% 
  st_centroid() %>%
  suppressWarnings() %>% 
  mutate(
    name_ru = case_when(
      name == "Timor Sea" ~ "Тиморское\nморе",
      name == "Tasman Sea" ~ "Тасманово\nморе",
      name == "Coral Sea" ~ "Коралловое\nморе",
      name == "Arafura Sea" ~ "Арафурское\nморе",
      TRUE ~ name
    )
  )

# Подписи штатов с ручной корректировкой
state_labels <- aus_states_albers %>%
  st_centroid() %>% suppressWarnings %>%
  filter(!name %in% c("Australian Capital Territory", "Lord Howe Island", "Jervis Bay Territory")) %>%
  mutate(
    name_ru = case_when(
      name == "New South Wales" ~ "Новый\nЮжный\nУэльс",
      name == "Western Australia" ~ "Западная\nАвстралия",
      name == "South Australia" ~ "Южная\nАвстралия",
      name == "Queensland" ~ "Квинсленд",
      name == "Victoria" ~ "Виктория",
      name == "Tasmania" ~ "Тасмания",
      name == "Northern Territory" ~ "Северная\nТерритория",
      TRUE ~ name
    ),
    # Определяем, какие штаты будут с засечками
    use_repel = ifelse(name %in% c("Victoria", "Tasmania"), TRUE, FALSE),
    # Параметры для repel (только Виктория и Тасмания будут с линиями)
    segment.color = ifelse(name %in% c("Victoria", "Tasmania"), "black", NA),
    segment.size = ifelse(name %in% c("Victoria", "Tasmania"), 0.3, 0),
    # Ручная корректировка позиций
    nudge_x = case_when(
      name == "Victoria" ~ -5e5,
      name == "Tasmania" ~ -6e5,
      TRUE ~ 0
    ),
    nudge_y = case_when(
      name == "Victoria" ~ -2.2e5,
      name == "Tasmania" ~ 2e5,
      TRUE ~ 0
    ) 
  )

coastline_albers <- st_transform(coastline, albers_proj)

# Создаем искусственный bounding box для всей карты
expanded_bbox <- st_bbox(c(
  xmin = -3e6,  # Расширяем на 30% за пределы карты
  xmax = 4e6,
  ymin = -10e6,
  ymax = 0.5
), crs = albers_proj) %>% 
  st_as_sfc()

  # Создаем координатную сетку с шагом 10° по широте
  graticule <- st_graticule(expanded_bbox,
                            ndiscr = 100,  # Количество точек для smooth-линий
                            lon = seq(-180, 180, by = 10),  # Шаг 10° по долготе
                            lat = seq(-90, 90, by = 10)      # Фиксированный шаг 10° по широте
  ) %>% 
    st_transform(albers_proj) %>% 
    suppressWarnings({  # Подавляем предупреждение для st_intersection
      st_intersection(st_as_sfc(st_bbox(c(
        xmin = -3e6, xmax = 3.5e6, 
        ymin = -5e6, ymax = 0.5e6
      ), crs = albers_proj)))
    })
    

# Создаем полигон суши для исключения подписей морей
land_polygon <- coastline_albers

# Фильтруем подписи морей, чтобы они не попадали на сушу
marine_labels_filtered <- marine_labels %>% 
  # Сохраняем атрибуты перед операцией st_difference
  mutate(
    original_name = name,
    original_name_ru = name_ru
  ) %>% 
  # Выполняем разность с полигоном суши
  st_difference(land_polygon) %>% 
  # Восстанавливаем атрибуты после операции
  mutate(
    name = original_name,
    name_ru = original_name_ru
  ) %>% 
  filter(!st_is_empty(.)) %>% 
  
  # Ручная корректировка позиций для морей
  mutate(
    nudge_y = case_when(
      name == "Timor Sea" ~ 1e5,
      name == "Tasman Sea" ~ 1e5,
      name == "Coral Sea" ~ 0.5e5,
      name == "Arafura Sea" ~ -1e5,
      TRUE ~ 0
    ),
    nudge_x = case_when(
      name == "Timor Sea" ~ -2e5,
      name == "Coral Sea" ~ -2e5,
      name == "Arafura Sea" ~ 3.5e5,
      TRUE ~ 0
    )
  ) %>%
  suppressWarnings()

a <-
  ggplot() +
  # 1. Фон (подложка)
  geom_sf(data = aus_states_albers, fill = "#E6F2FF", color = NA) +
  # 2. Добавление морей (прозрачными)
  geom_sf(data = marine_areas_albers, fill = NA, color = NA) +
  # 3. Добавление штатов с ручной раскраской
  geom_sf(data = aus_states_albers, aes(fill = name), color = "black", linewidth = 0.1) +
  # 4. Береговая линия (контур)
  geom_sf(data = coastline_albers, fill = NA, color = NA, linewidth = 0.1) +
  # 5. Города (точки с белой обводкой)
  geom_sf(
    data = cities, 
    color = "white",       
    size = 2.5,           
    shape = 21,           
    stroke = 1.2          
  ) +
  # 6. Основные точки городов (красные)
  geom_sf(
    data = cities, 
    color = "red3",     
    size = 2,            
    shape = 16           
  ) +
  # 7. Подписи городов с белой обводкой
  ggrepel::geom_label_repel(
    data = cities_albers,
    aes(label = NAME_RU, geometry = geometry),
    family = "Century Gothic",
    size = 3.5,
    point.padding = 0.3,
    box.padding = 0.5,
    min.segment.length = 0,
    max.overlaps = Inf,
    label.padding = unit(0.2, "lines"),
    label.size = 0,
    fill = alpha("white", 0.7),
    color = "black",
    nudge_x = cities_albers$nudge_x,  # Добавляем горизонтальное смещение
    nudge_y = cities_albers$nudge_y,  # Добавляем вертикальное смещение
    stat = "sf_coordinates"
  ) +
  
  # Подписи штатов - два разных подхода:
  # 1. Для Виктории и Тасмании - с засечками (repel)
  ggrepel::geom_text_repel(
    data = filter(state_labels, use_repel),
    aes(label = name_ru, geometry = geometry),
    family = "Century Gothic",
    size = 3.5,
    color = "black",
    fontface = "bold",
    point.padding = 0.5,
    box.padding = 0.7,
    min.segment.length = 0,
    segment.color = "black",
    segment.size = 0.3,
    nudge_x = filter(state_labels, use_repel)$nudge_x,
    nudge_y = filter(state_labels, use_repel)$nudge_y,
    stat = "sf_coordinates"
  ) +
  # 2. Для остальных штатов - точное центрирование без repel
  geom_sf_text(
    data = filter(state_labels, !use_repel),
    aes(label = name_ru),
    family = "Century Gothic",
    size = 3.5,
    color = "black",
    fontface = "bold"
  ) +
  # 8. Подписи морей
  geom_sf_text(
    data = marine_labels_filtered, 
    aes(label = name_ru), 
    family = "Century Gothic", 
    size = 3.5, 
    color = "darkblue",
    nudge_y = marine_labels_filtered$nudge_y,
    nudge_x = marine_labels_filtered$nudge_x
  ) +
  # 9. Координатная сетка
  geom_sf(
    data = graticule,
    color = "gray50",
    linetype = "dashed",
    linewidth = 0.2,
    alpha = 0.5
  ) +
  # Масштабная линейка
  annotation_scale(
    location = "bl",
    width_hint = 0.3,
    style = "ticks",
    tick_height = 0.5,
    line_width = 1,
    text_cex = 0.8,
    text_family = "Century Gothic"
  ) +
  # 10. Настройка внешнего вида
  theme_minimal() +
  theme(
    text = element_text(family = "Century Gothic"),
    axis.title = element_blank(),  # Убираем технические x и y
    axis.ticks = element_line(color = "black"),  # Добавляем оси
    axis.ticks.length = unit(0.2, "cm"),  # Длина засечек
    panel.background = element_rect(fill = "#E6F2FF", color = NA),  # Фон карты
    panel.grid = element_blank(),  # Отключаем стандартную сетку ggplot
    panel.border = element_rect(fill = NA, color = "black", linewidth = 1),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    legend.position = "right",
    legend.title = element_text(size = 10, face = "bold")
  ) +
  # 11. Цвета для штатов
  scale_fill_manual(
    name = "Штаты Австралии",
    values = c(
      "New South Wales" = "#FFD700",       # Новый Южный Уэльс
      "Western Australia" = "#F4A460",     # Западная Австралия
      "South Australia" = "#DAA520",       # Южная Австралия
      "Queensland" = "#CD853F",            # Квинсленд
      "Victoria" = "#B8860B",              # Виктория
      "Tasmania" = "#A0522D",              # Тасмания
      "Northern Territory" = "#8B4513"     # Северная Территория
    ),
    labels = c(
      "New South Wales" = " \nНовый Южный\nУэльс\n ",
      "Western Australia" = " \nЗападная\nАвстралия\n ",
      "South Australia" = " \nЮжная\nАвстралия\n ",
      "Queensland" = " \nКвинсленд\n ",
      "Victoria" = " \nВиктория\n ",
      "Tasmania" = " \nТасмания\n ",
      "Northern Territory" = " \nСеверная\nТерритория\n "
    ),
    guide = guide_legend(
      keyheight = unit(1.2, "lines"),
      keywidth = unit(1.5, "lines")
    )
  ) +
  # 12. Настройка подписей координат
  scale_x_continuous(labels = function(x) paste0(round(abs(x)), "° в.д.")) +
  scale_y_continuous(labels = function(y) paste0(round(abs(y)), "° ю.ш.")) +
  
  # 13. Обрезка карты
  coord_sf(
    xlim = c(-2.3e6, 3e6),
    ylim = c(-4.9e6, -0.5e6),
    expand = FALSE,
    clip = "on"
  ) +
  # 14. Добавление подписи океана
  annotate("text", x = -0.9e6, y = -4.3e6, label = "Индийский океан", 
           family = "Century Gothic", size = 4, color = "darkblue") +
  labs(title = "Административное деление\nАвстралии")

print(a)


ggsave("Australia1.png", a, width = 10, height = 8, dpi = 300, 
       bg = "white")

#опционально (на мой взгляд, ggsave сохраняет разумнее, в т.ч. местоположение подписей и их размер)
#fileout <- "assets/general/Australia1.png"
#if (!dir.exists(dirname(fileout)))
  #dir.create(dirname(fileout),recursive=TRUE)
#png(fileout, res=300, width=3000, height=1500,
    #type="cairo", pointsize=12, family="Century Gothic",
    #bg = "white")
#print(a)
#dev.off()
#browseURL(fileout)