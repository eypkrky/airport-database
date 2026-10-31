# Airport Database

SQL Server için tasarlanmış, uluslararası bir havaalanı operasyon veritabanı örneği.

## Kapsam

Şema; havaalanları, pistler, terminaller, kapılar, havayolları, uçaklar, uçuşlar, yolcular, biletler, bagajlar, çalışanlar, uçuş ekipleri ve bakım kayıtlarını kapsar. İlişkisel bütünlük için birincil/yabancı anahtarlar, benzersizlik ve veri doğrulama kısıtları kullanılır.

## İçerik

- `Airport.sql`: Şema, view, örnek sorgu ve demo veri scripti

## Gereksinimler

- Microsoft SQL Server
- SQL Server Management Studio (SSMS) veya SQL Server destekleyen başka bir istemci

## Kurulum

1. SSMS içinde yeni bir veritabanı oluşturun (örneğin `AirportDB`).
2. Hedef veritabanını seçin.
3. `Airport.sql` dosyasını açıp çalıştırın.

## Veri Modeli

Uçuşlar; rota, uçak ve isteğe bağlı kapı ile ilişkilidir. Biletler yolcu ile uçuşu bağlar; bagaj kayıtları biletler üzerinden tutulur. Çalışanlar havaalanına bağlıdır ve uçuş ekibi atamaları ile uçuşlara bağlanabilir.

## Not

Script demo amaçlı veri ekleme, güncelleme ve silme örnekleri de içerir. İhtiyaca göre bu örnek bloklar ayrı bir test verisi dosyasına taşınabilir.
