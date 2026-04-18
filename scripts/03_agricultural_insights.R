# ================================================
# ADIM 3: TARIMSAL BAGLANTI ANALİZİ
# ================================================
# Bu kisim normal bir analistten farkini ortaya koyar!
# Satis verisi + Tarimsal yorum = Gercek deger

library(tidyverse)
library(scales)

train <- read.csv("data/Train.csv")
train$date  <- as.Date(train$date)
train$year  <- year(as.Date(train$date))
train$month <- month(as.Date(train$date), label = TRUE)
train$month_num <- month(as.Date(train$date))

# -----------------------------------------------
# ANALIZ 1: PRODUCE aylik ortalama satis
# -----------------------------------------------
# Neden? Mevsimsellik varsa ciftciye
# "su ayda uret" diyebiliriz

produce_aylik <- train %>%
  filter(family == "PRODUCE") %>%
  group_by(month, month_num) %>%
  summarise(ort_satis = mean(sales, na.rm = TRUE)) %>%
  arrange(month_num)

print(produce_aylik)

# Grafik
ggplot(produce_aylik,
       aes(x = reorder(month, month_num),
           y = ort_satis)) +
  geom_bar(stat = "identity",
           fill = "#27ae60") +
  geom_hline(yintercept = mean(produce_aylik$ort_satis),
             color = "red", linetype = "dashed",
             size = 1) +
  annotate("text", x = 2, 
           y = mean(produce_aylik$ort_satis) + 5,
           label = "Yillik ortalama",
           color = "red", size = 3.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "PRODUCE: Aylik Ortalama Satis",
       subtitle = "Kirmizi cizgi = yillik ortalama",
       x = "Ay", y = "Ortalama Satis") +
  theme_minimal()

ggsave("output/05_produce_mevsimsellik.png",
       width = 10, height = 6)

# -----------------------------------------------
# ANALIZ 2: Mevsimsel endeks hesapla
# -----------------------------------------------
# Neden? "Aralik ortalamanin yuzde kaci?"
# sorusunu sayiyla cevaplariz

genel_ort <- mean(produce_aylik$ort_satis)

produce_aylik <- produce_aylik %>%
  mutate(endeks = round(ort_satis / genel_ort * 100, 1))

print(produce_aylik %>% select(month, endeks))

# -----------------------------------------------
# ANALIZ 3: Tarimsal urunleri karsilastir
# -----------------------------------------------

tarimsal <- c("PRODUCE", "MEATS", "POULTRY",
              "EGGS", "DAIRY")

tarimsal_karsilastirma <- train %>%
  filter(family %in% tarimsal) %>%
  group_by(family, month, month_num) %>%
  summarise(ort_satis = mean(sales, na.rm = TRUE))

ggplot(tarimsal_karsilastirma,
       aes(x = reorder(month, month_num),
           y = ort_satis,
           fill = family)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Tarimsal Urunlerin Aylik Karsilastirmasi",
       x = "Ay", y = "Ortalama Satis",
       fill = "Kategori") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1))

ggsave("output/06_tarimsal_karsilastirma.png",
       width = 12, height = 7)