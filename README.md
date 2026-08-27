# Global Layoffs (2020–2023) — SQL Data Cleaning & Analysis

Bu proje, Mart 2020 – Mart 2023 arası dünya genelindeki şirket işten çıkarmalarını (layoffs) içeren ham bir veri setini MySQL ile temizleyip analiz ediyor. Amaç; veri temizleme adımlarını (duplicate temizleme, standardizasyon, eksik veri yönetimi) ve pencere fonksiyonlarıyla (window functions) yapılan keşifsel veri analizini (EDA) uçtan uca göstermek.

## Veri Seti

- **Kaynak:** [Kaggle – Layoffs 2022 Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- **Kapsam:** ~2360 satır, şirket, lokasyon, sektör, işten çıkarılan kişi sayısı/oranı, şirket aşaması (funding stage), ülke ve toplanan fon bilgisi.
- **Zaman aralığı:** 11 Mart 2020 – 6 Mart 2023

## Proje Yapısı

| Dosya | Açıklama |
|---|---|
| `layoffs.csv` | Ham veri seti |
| `world_layoffs_data_cleaning.sql` | Veri temizleme script'i |
| `data_analysis.sql` | Keşifsel veri analizi (EDA) sorguları |

## Veri Temizleme Adımları

1. **Duplicate temizleme** — `ROW_NUMBER() OVER(PARTITION BY ...)` ile tüm kolonlara göre tekrarlayan satırlar tespit edilip silindi. (Not: MySQL'de CTE üzerinden doğrudan `DELETE` çalışmadığı için ara bir staging tablosu (`layoffs_staging2`) oluşturularak bu sınırlama aşıldı.)
2. **Standardizasyon** — `company` alanındaki baştaki/sondaki boşluklar `TRIM` ile temizlendi; `Crypto`, `Crypto Currency` gibi varyasyonlar tek bir `Crypto` kategorisinde birleştirildi; `United States.` gibi noktalı ülke isimleri normalize edildi; `date` metin alanı gerçek `DATE` tipine dönüştürüldü.
3. **Eksik veri yönetimi** — Boş string olarak gelen `industry` değerleri `NULL`'a çevrildi; aynı şirketin başka satırlarındaki dolu `industry` bilgisi self-join ile eksik satırlara aktarıldı; hem `total_laid_off` hem `percentage_laid_off` alanı boş olan (analiz için kullanılamaz) satırlar veri setinden çıkarıldı.
4. **Gereksiz kolon temizliği** — Duplicate tespiti için kullanılan geçici `row_num` kolonu işlem sonunda silindi.

**Bilinçli tasarım kararı:** `total_laid_off` ve `percentage_laid_off` ikisi de boş olan satırlar silindi çünkü bu satırlar analiz açısından bilgi taşımıyordu; ancak bu satırlarda hâlâ şirket/lokasyon bilgisi olduğu için farklı bir analiz sorusu (örn. "hangi şirketler layoff duyurdu ama sayı açıklamadı") için ayrı tutulabilirdi.

## Analiz & Bulgular

Aşağıdaki bulgular, temizlenmiş veri üzerinde çalıştırılan sorgulardan elde edildi:

- **En büyük tek seferlik işten çıkarma:** 12.000 kişi (Google), tek bir duyuruda.
- **En çok toplam işten çıkaran şirketler:** Amazon (18.150), Google (12.000), Meta (11.000), Salesforce (10.090) ve Microsoft (10.000) veri setindeki en yüksek toplamlara sahip.
- **Ülke bazında:** ABD tek başına ~258.000 kişiyle toplam işten çıkarmaların büyük çoğunluğunu oluşturuyor; Hindistan (~36.000) ve Hollanda (~17.000) onu takip ediyor.
- **Yıllara göre trend:** 2022 (~162.000) ve 2023'ün ilk çeyreği (~127.000, sadece Ocak-Mart) en yoğun dönemler — 2023'ün sadece 3 aylık verisiyle 2020'nin tamamını (~81.000) geride bıraktığı görülüyor. Bu, teknoloji sektöründeki kesintilerin 2022 sonu – 2023 başında hızlandığını gösteriyor.
- **Sektör bazında:** Consumer (~46.700), Retail (~43.600) ve "Other" (~36.300) en çok etkilenen kategoriler; saf teknoloji şirketleri tek bir kategoride toplanmadığı için dağılım farklı sektörlere yayılmış görünüyor.
- **Şirket aşamasına göre:** Halka arz sonrası (Post-IPO) şirketler toplam işten çıkarmaların en büyük kısmını (~205.000) oluşturuyor — büyük, halka açık teknoloji şirketlerinin bu dönemde en çok kesinti yapan grup olduğunu doğruluyor.
- **%100 işten çıkarma (şirket kapanışı):** En çok fon toplamış olup tamamen kapanan şirketler arasında Britishvolt (2,4 milyar $) ve Quibi (1,8 milyar $) dikkat çekiyor — yüksek fonlamanın tek başına ayakta kalmayı garanti etmediğini gösteren çarpıcı örnekler.
- * **Finansman Hacmi vs. Küçülme Oranı (Ters Orantı):** Alınan yatırım büyüklüğü ile işten çıkarma yüzdesi arasında güçlü bir ters orantı bulundu. 50 milyon doların altında fon toplayan erken aşama şirketler ortalama **%41,4** oranında küçülürken, 500 milyon dolar üzeri mega şirketlerde bu oran ortalama **%16,7** seviyesinde kaldı.
* **Mutlak Hacim vs. Oransal Kayıp:** 500 milyon dolar üzeri fon toplayan dev şirketler oransal olarak (%16,7) en düşük kayba uğrasa da, olay başına ortalama **~503 kişi** ile piyasaya mutlak sayı olarak en çok iş gücü salan grup oldu.
* **Kriz Öncesi Tahmini Şirket Büyüklükleri:** İşten çıkarılan kişi sayısı ve yüzde oranı üzerinden yapılan tersine mühendislikle (`total_laid_off / percentage_laid_off`), Big Tech şirketlerinin (Amazon, Google, Microsoft) binlerce çalışanı işten çıkarmalarına rağmen kadrolarının yalnızca **%2 ila %6'lık** küçük bir dilimini kestiği doğrulandı.

## Kullanılan SQL Teknikleri

- Window functions: `ROW_NUMBER()`, `DENSE_RANK() OVER(PARTITION BY ...)`
- CTE'ler (tekli ve zincirlenmiş)
- Self-join ile eksik veri doldurma
- Kümülatif toplam (rolling total) hesaplama: `SUM(...) OVER(ORDER BY ...)`
- Tarih/string fonksiyonları: `STR_TO_DATE`, `SUBSTRING`, `TRIM`
- Veri Segmentasyonu (Binning): Sürekli sayısal verileri (`funds_raised_millions`) analiz edilebilir kategorik aralıklara bölmek için `CASE WHEN` kullanımı.
- Türetilmiş Metrik Hesabı & Yuvarlama: Oransal verilerden kriz öncesi tahmini şirket büyüklüğünü modellemek için matematiksel operatörler ve `ROUND()` fonksiyonu.

## Geliştirme Fikirleri (Sonraki Adımlar)

- [x] Finansman miktarı (`funds_raised_millions`) ile işten çıkarma oranı arasındaki ilişkiyi inceleyen korelasyon/segmentasyon analizi eklemek *(Tamamlandı)*
- [ ] Bulguları Python (Matplotlib/Seaborn) veya Tableau / Power BI ile görselleştirerek interaktif bir dashboard oluşturmak
- [ ] Silinen (her iki metrik de boş olan) satırları "şeffaflık/duyuru analizi" için ayrı bir tabloda incelemek
- [ ] `percentage_laid_off` kolonunu doğrudan `DECIMAL` tipinde modelleyerek veri tiplerini optimize etmek
## Nasıl Çalıştırılır

1. `layoffs.csv` dosyasını MySQL'e `layoffs` tablosu olarak import edin.
2. `world_layoffs_data_cleaning.sql` script'ini sırayla çalıştırarak temizlenmiş `layoffs_staging2` tablosunu oluşturun.
3. `data_analysis.sql` içindeki sorguları `layoffs_staging2` üzerinde çalıştırarak analiz sonuçlarını görüntüleyin.
