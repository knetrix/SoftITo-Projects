# Rutino Geliştirici ve Ajan Kuralları (Workspace Rules)

## DONE.md Güncelleme Kuralı (Zorunlu ve Bağlayıcı)

Yapılan her değişiklikten sonra, küçük düzeltmeler dahil, proje kökündeki `DONE.md` güncellenir.

### Biçim ve Standartlar
1. **En Üstte Durum Tablosu:**
   `| Aşama | Durum |` tablosu en üstte yer alır.

2. **Adım Başlıkları:**
   Her adımın başlığı `## [YYYY-MM-DD] Aşama X – Başlık` biçiminde olmalıdır.

3. **Adım İçeriği Sıralaması:**
   Her adımda sırasıyla şu bölümler yer alır:
   - **Yapılanlar:** Yapılan işlemlerin maddeler halinde özeti.
   - **Dosyalar:** `Oluşturulan`, `Güncellenen`, `Silinen` alt başlıkları altında gruplanır; **her dosya tek bir cümleyle** açıklanır.
   - **Doğrulama:** `flutter analyze` ve `flutter test` sonuçları.
   - **Alınan Kararlar:** İlgili adımda alınan mimari veya teknik kararlar.
   - **Açık Konular:** Bir sonraki adıma devreden veya yanıt bekleyen açık noktalar.

4. **Final Özet:**
   Dosyanın sonundaki genel ilerleme ve final özet tablosu/bölümü daima güncel tutulur.

5. **Gerekçe:**
   Kullanıcı projeyi `DONE.md` üzerinden takip eder ve her dosyanın tek cümlelik açıklamasını bekler.
