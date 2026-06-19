# InSight - Bugunku Calisma Ozeti

## Push Guncelleme Kaydi

Bu dosya bundan sonra her push oncesinde veya push hazirligi sirasinda
guncellenecek proje ilerleme gunlugu olarak kullanilacak. Her kayitta tarih,
yapilan degisiklikler, etkiledigi dosyalar ve dogrulama adimlari yazilacak.

---

## 19 Haziran 2026 - Profile, Scan ve Saved Review Iyilestirmeleri

Commit: `fb23be9`

### Genel Ozet

- Gercek cihaz testlerinde ortaya cikan profile, scan, saved review ve UI
  yerlesim problemleri giderildi.
- Barkod scan sonucu, urun detaylari, kaydetme akisi ve profile edit deneyimi
  daha gercek backend verisiyle calisacak hale getirildi.
- Farkli Wi-Fi aginda gercek cihaz testleri icin lokal API IP ayari
  guncellendi.

### Backend Degisiklikleri

- Open Beauty Facts entegrasyonu scan akisina baglandi.
- Lokal DB'de olmayan barkodlarda urun Open Beauty Facts'ten cekilip
  `products`, `ingredients` ve `product_ingredients` tablolarina yazilacak
  hale getirildi.
- Urun fotografi icin `imageURL` alani eklendi.
- `006_add_product_image_url.sql` migration'i eklendi ve uygulandi.
- Email degisimi icin iki asamali OTP altyapisi eklendi:
  - once mevcut email adresine kod gonderme,
  - mevcut email kodunu dogrulama,
  - yeni email adresine kod gonderme,
  - yeni email kodunu dogrulayip email'i guncelleme.
- Email degisimi icin `email_change_requests` tablosu ve
  `007_add_email_change_requests.sql` migration'i eklendi ve uygulandi.
- Profile response icine `gender` alani eklendi.
- Content/profile route'larinda token kullanicisi esas alinarak `Forbidden`
  hatalari giderildi.
- Saved review listesi artik `productID` donduruyor; iOS tarafinda ayni isimli
  urunler karismasin diye kayit kontrolu product ID ile yapiliyor.
- Risk siniflandirma icin ilk basit icerik heuristikleri eklendi.

### iOS Degisiklikleri

- Gercek cihaz icin `API_BASE_URL` yeni Wi-Fi IP adresine guncellendi:
  `http://192.168.1.119:3000`.
- Backend logundaki `From Network` IP bilgisi ayni adrese cekildi.
- Scan ekranina manuel barkod girisi eklendi.
- Barkod bulunamadiginda yanlis sekilde basarili scan mesaji gosterilmesi
  engellendi.
- Farkli barkodlarda onceki urun sonucunun tekrar gosterilmesi problemi
  giderildi.
- Scan hata durumunda retry akisi iyilestirildi.
- Barkod sonucundan scan ekranina donebilmek icin geri butonu eklendi.
- Urun detay ekranina geri butonu eklendi.
- Urun sonucunda urun adi, barkod ve fotograf bilgisi gosterimi iyilestirildi.
- `Save Review` butonu gercek backend saved review akisina baglandi.
- Saved Reviews listesi DB'den cekilen kayitlarla guncellenir hale getirildi.
- Welcome sayfasi animasyonlu ve daha dolu bir tasarima cekildi.
- Home, Profile, Saved Reviews, urun sonuc ve detay ekranlarinda safe-area
  sorunlari giderildi.
- Home ve urun sonuc ekranlari kucuk ekranlarda asagi kaydirilabilir hale
  getirildi.
- Input text/prompt renkleri okunabilir hale getirildi.

### Profile Degisiklikleri

- Profile ekrani placeholder veriler yerine gercek kullanici bilgisini
  gosterecek hale getirildi.
- Header altinda email yerine ad soyad gosterimi duzeltildi.
- `Condition` ve `Sensitivity` alanlari kayit sirasinda sorulmadigi icin
  profile ekranindan ve edit ekranindan kaldirildi.
- Edit Profile ekrani uygulama tasarimina uygun bolumlu bir forma
  donusturuldu:
  - Basic Information,
  - Skin Profile,
  - Allergy Notes,
  - Email Address.
- Age ve Gender editlenebilir hale getirildi.
- Age secimi ozel `- / yas / +` kontrolune cevrildi.
- Allergies serbest metin yerine coklu secim chip listesine cevrildi.
- Yaygin alerji/reaksiyon secenekleri eklendi:
  - Fragrance
  - Essential Oils
  - Alcohol Denat.
  - Parabens
  - Sulfates
  - SLS
  - Lanolin
  - Nickel
  - Latex
  - Benzoyl Peroxide
  - Salicylic Acid
  - Retinoids
  - Formaldehyde Releasers
  - Methylisothiazolinone
  - Cocamidopropyl Betaine
  - Propylene Glycol

### Dogrulamalar

Calistirilan kontroller:

```sh
cd Backend
npm test
```

Sonuc:

```text
22 test gecti.
0 test basarisiz.
```

```sh
xcodebuild -scheme InSight -project InSight.xcodeproj -destination generic/platform=iOS -derivedDataPath /private/tmp/InSightDerivedData CODE_SIGNING_ALLOWED=NO build
```

Sonuc:

```text
BUILD SUCCEEDED
```

```sh
cd Backend
npm run migrate
```

Sonuc:

```text
007_add_email_change_requests.sql uygulandi.
```

### Notlar

- Backend degisiklikleri sonrasinda `node index.js` yeniden baslatilmali.
- Email degisimi icin OTP mailleri gercek email konfiguru calisiyorsa mail
  olarak gider; lokal test sirasinda kodlar backend terminal loglarindan da
  izlenebilir.
- Bu kayit, `fb23be9` commitinden sonra `TODAY_PROGRESS.md` icine eklendi.

---

## Gecmis Commit/Push Kayitlari

Bu bolum Git gecmisinden geriye donuk olarak olusturuldu. Git, "push zamani"
bilgisini lokal commitlerde saklamadigi icin kayitlar commit tarihleri ve commit
icerikleri uzerinden hazirlandi.

### 16 Mart 2026 - Initial commit

Commit: `0254387`

- Projenin Git gecmisi baslatildi.
- Ilk `README.md` dosyasi eklendi.
- Henuz uygulama iskeleti veya backend yapisi bulunmuyordu.

### 16 Mart 2026 - Ilk iOS Uygulama Iskeleti

Commit: `646f980`

- Xcode projesi ve temel SwiftUI uygulama dosyalari eklendi.
- `InSightApp.swift`, `ContentView.swift` ve `MainTabView.swift` ile ana uygulama
  yapisi kuruldu.
- Ilk ekranlar olusturuldu:
  - Home
  - Lists
  - Login
  - Profile
  - Scan
  - Welcome
- Asset catalog ve app icon/accent color yapisi eklendi.
- Bu commit, InSight'in iOS uygulamasi olarak ilk calisir iskeletini olusturdu.

### 17 Mart 2026 - Gitignore ve Ilk Sayfa Taslaklari

Commit: `667d94e`

- `.gitignore` dosyasi eklendi.
- Loading ekrani eklendi.
- Review akisi icin ilk product page taslaklari eklendi:
  - `ProductPageOneView`
  - `ProductPageTwoView`
  - `ProductPageThreeView`
- Sign-up akisi icin ilk sayfa taslaklari eklendi:
  - `PageOneView`
  - `PageTwoView`
  - `PageThreeView`
- Uygulama akisi henuz prototip seviyesindeydi.

### 20 Mart 2026 - Sign Up ve Barkod Tarama Sayfalari

Commit: `5764ec5`

- Kamera tabanli barkod tarama ekrani baslatildi.
- `BarcodeScanner.swift` ve `CameraPreview.swift` eklendi.
- Eski `ScanView` yerine `View/Camera/ScanView.swift` altinda daha gercekci
  kamera/tarama akisi olusturuldu.
- Verification ekrani eklendi.
- Sign-up sayfalarinda veri toplama ve ilerleme akisi gelistirildi.
- Login ve sign-up ekranlarinda kucuk akış duzenlemeleri yapildi.

### 20 Mart 2026 - Product Review Sayfalarinin Baslatilmasi

Commit: `a0e85ed`

- Urun inceleme/detail review akisi baslatildi.
- `ProductPageTwoView.swift`, `DetailReview.swift` olarak yeniden adlandirildi.
- `ProductPageOneView` buyuk olcude genisletildi.
- Kullaniciya urun hakkinda daha detayli inceleme gosterecek UI temeli atildi.

### 21 Mart 2026 - Detail Page Tasarim Duzenlemeleri

Commit: `f3aef06`

- Detail/review ekraninda kucuk tasarim iyilestirmeleri yapildi.
- `MainTabView` ve `ProductPageOneView` tarafinda UI duzenlemeleri uygulandi.
- Bu commit agirlikli olarak gorsel ve sayfa akisi polish calismasiydi.

### 20 Nisan 2026 - Backend'e Hazirlik ve App Model Katmani

Commit: `fbbcee0`

- Backend'e baglanmaya hazirlanmak icin iOS tarafinda model ve state yapisi
  genisletildi.
- `AppModels.swift` eklendi.
- `AppStateViewModel.swift` eklendi ve uygulama durum yonetimi merkezi hale
  getirilmeye baslandi.
- Home, Lists, Loading, Login, Profile, Scan, Review ve Sign-up ekranlarinda
  kapsamli UI/akış guncellemeleri yapildi.
- Bu committe uygulama prototipten daha veri odakli bir yapıya gecmeye basladi.

### 30 Nisan 2026 - Mock Backend Servis Katmani

Commit: `cbabb66`

- iOS tarafinda servis mimarisi eklendi:
  - `APIAuthService.swift`
  - `APIClient.swift`
  - `APIEndpoint.swift`
  - `AppServices.swift`
  - `NetworkConfiguration.swift`
- Backend henuz tam kurulmadan uygulamanin API ile calisabilecek sekilde
  ayrismasi saglandi.
- Auth, verification ve scan ekranlari servis katmanina baglanmaya baslandi.
- `AppStateViewModel` daha sade ve servis odakli hale getirildi.
- Kamera dosyalarinda kucuk temizlikler yapildi.

### 1 Mayis 2026 - Node Backend ve Register Akisinin Baglanmasi

Commit: `036465e`

- Backend klasoru ve Node/Express yapisi eklendi.
- PostgreSQL baglantisi icin `Backend/config/db.js` eklendi.
- Auth controller ve auth route yapisi eklendi.
- `Backend/package.json` ve `package-lock.json` eklendi.
- iOS tarafinda register akisi backend'e baglanmaya baslandi.
- `Info.plist`, API servisleri ve sign-up modelleri backend ihtiyacina gore
  guncellendi.
- Not: Bu committe `node_modules` da repoya eklenmisti; daha sonra bu durum
  duzeltildi.
- Register endpoint'i dogrulanmis durumdaydi, email verification eksigi devam
  ediyordu.

### 5 Mayis 2026 - Verification Code Duzeltmeleri

Commit: `d4fa0a1`

- OTP/verification code akisi duzeltildi.
- `authController.js` icinde verification logic'i iyilestirildi.
- iOS auth service ve sign-up ekranlari verification akisi icin guncellendi.
- `PageTwoView` buyuk olcude genisletilerek kullanici kayit/verifikasyon akisi
  daha tamamlanmis hale getirildi.
- App model ve state tarafinda verification ile ilgili alanlar duzenlendi.

### 19 Mayis 2026 - Backend Endpointlerinin Genisletilmesi

Commit: `17441d4`

- Backend kapsamli sekilde genisletildi.
- Yeni controller ve route dosyalari eklendi:
  - `contentController.js`
  - `profileController.js`
  - `scanController.js`
  - `contentRoutes.js`
  - `profileRoutes.js`
  - `scanRoutes.js`
- Auth middleware ve header/security middleware eklendi.
- PostgreSQL schema ve migration yapisi baslatildi.
- Scan source, profile gender check gibi migrationlar eklendi.
- Email gonderimi icin `emailService.js` eklendi.
- `.env.example` ve README backend calisma mantigini aciklayacak sekilde
  genisletildi.
- iOS tarafinda `APIDataServices.swift`, profile, scan, home, lists ve review
  ekranlari yeni backend endpointlerine gore guncellendi.
- Not: Commit mesajinda backend baglantisinda hata oldugu belirtilmisti; bu
  nedenle bu commit endpoint kapsamını buyutse de entegrasyon tamamen stabil
  kabul edilmiyordu.

### 27 Mayis 2026 - Auth, Profile ve Migration Duzeltmeleri

Commit: `c7ea1fb`

- Auth controller kapsamli sekilde guncellendi.
- Profile controller tarafinda duzeltmeler yapildi.
- Birth date alani ile ilgili migrationlar eklendi:
  - `004_fix_profile_birth_date_column.sql`
  - `005_replace_birth_date_with_age.sql`
- Email configuration test script'i eklendi:
  - `Backend/scripts/verifyEmail.js`
- Email service tarafinda kucuk iyilestirmeler yapildi.
- Backend `.env` ve README email/SMTP kurulumuna gore genisletildi.
- iOS sign-up modeli ve ekranlari age/profile alanlarina gore guncellendi.

### 27 Mayis 2026 - iOS Session, Migration ve Test Stabilizasyonu

Commit: `f82c4a9`

- iOS minimum deployment target daha gercekci bir seviyeye cekildi.
- `Info.plist` uzerinden `API_BASE_URL` okuma akisi eklendi.
- Keychain tabanli session saklama eklendi:
  - `KeychainSessionStore.swift`
- Auth token ve refresh token akislari iyilestirildi.
- `401 Unauthorized` durumunda refresh token ile session yenileme destegi
  eklendi.
- Kamera izni icin gerekli plist ayarlari eklendi.
- Kullanilmayan/prototip `ProductPageThreeView.swift` kaldirildi.
- Ingilizce ve Turkce localization dosyalari eklendi.
- Backend tarafinda header middleware testleri eklendi.
- Fresh migration dogrulama script'i eklendi:
  - `Backend/scripts/verifyFreshMigrations.js`
- `.gitignore` guncellendi ve `node_modules` kaynak kontrolunden cikarilmaya
  baslandi.
- README backend kurulum, test, migration, iOS setup ve smoke test adimlariyla
  genisletildi.
- `TODAY_PROGRESS.md` ilk ayrintili calisma ozeti olarak eklendi.

### 29 Mayis 2026 - OTP, Scan Analyze ve Backend Controller Testleri

Commit: `f0a71ab`

- Backend test kapsami buyuk olcude genisletildi.
- Yeni test dosyalari eklendi:
  - `authController.test.js`
  - `contentController.test.js`
  - `controllerTestUtils.js`
  - `profileController.test.js`
  - `scanController.test.js`
- OTP verification, login, content, profile ve scan analyze akislari testlerle
  dogrulanmaya baslandi.
- iOS tarafinda app acilisi, loading state ve auth/scan veri servisleri
  iyilestirildi.
- `AppStateViewModel` session restore ve backend veri akislari icin
  genisletildi.
- Localization dosyalarina yeni metinler eklendi.
- `Info.plist` ve network configuration tarafinda API ayarlari guncellendi.

### 18 Haziran 2026 - Open Beauty Facts Entegrasyonu

Commit: `77a1542`

- Backend'e Open Beauty Facts entegrasyonu eklendi.
- `Backend/services/openBeautyFactsService.js` eklendi.
- Barkod DB'de yoksa Open Beauty Facts API'den urun ve icerik bilgisi cekme
  akisi kuruldu.
- Cekilen urun ve icerikler lokal PostgreSQL tablolarina kaydedilecek hale
  getirildi.
- `scanController.js` icinde yeni urun bulma/olusturma akisi guncellendi.
- Open Beauty Facts icin `.env.example` ayarlari eklendi.
- `PROJECT_TODO.md` eklendi ve ileride yapilacak veri senkronizasyon/risk
  zenginlestirme isleri kayda alindi.
- Open Beauty Facts servis ve scan controller testleri eklendi.
- README'ye Open Beauty Facts entegrasyon ve lisans/rate-limit notlari eklendi.

---

## 18 Haziran 2026 - Open Beauty Facts Entegrasyonu

### Genel Ozet

Bu guncellemede InSight backend tarafina Open Beauty Facts entegrasyonu eklendi.
Amac, kullanici barkod okuttugunda urun lokal PostgreSQL veritabaninda yoksa
kozmetik urun bilgisini Open Beauty Facts API uzerinden cekmek, ardindan urun ve
icerik bilgisini projenin kendi veritabanina kaydetmek.

Bu sayede ayni barkod daha sonra tekrar okutuldugunda sistem dis API'ye tekrar
gitmeden lokal DB uzerinden daha hizli cevap verecek.

### Backend Degisiklikleri

- `Backend/services/openBeautyFactsService.js` dosyasi eklendi.
- Open Beauty Facts API icin ayarlanabilir istemci yapisi kuruldu:
  - `OPEN_BEAUTY_FACTS_BASE_URL`
  - `OPEN_BEAUTY_FACTS_TIMEOUT_MS`
  - `OPEN_BEAUTY_FACTS_USER_AGENT`
- Barkod ile urun sorgulama akisi eklendi.
- API cevabindan su alanlar normalize edildi:
  - urun adi
  - marka
  - barkod
  - icerik listesi
- `ingredients`, `ingredients_tags` ve `ingredients_text` alanlarindan gelen
  icerikler tekillestirilerek uygulamanin mevcut ingredient modeline cevrildi.
- Open Beauty Facts'ten gelen icerikler simdilik dusuk risk varsayimi ile
  kaydediliyor. Gercek risk siniflandirmasi daha sonra CosIng, EU Annexes ve
  Health Canada Hotlist gibi kaynaklarla zenginlestirilecek.

### Scan Akisi Degisiklikleri

- `Backend/controllers/scanController.js` icinde `findOrCreateProduct` akisi
  guncellendi.
- Yeni barkod akisi su sekle getirildi:
  1. Once lokal `products` tablosunda barkod aranir.
  2. Urun varsa dis API'ye gidilmez.
  3. Urun yoksa Open Beauty Facts API'ye gidilir.
  4. Urun bulunursa `products` tablosuna yazilir.
  5. Icerikler `ingredients` ve `product_ingredients` tablolarina yazilir.
  6. Scan sonucu mevcut `safe`, `mostlySafe`, `risky` mantigi ile hesaplanir.
- Open Beauty Facts API yanit vermezse veya urun bulunamazsa mevcut demo
  fallback akisi korunur.

### Konfigurasyon

- `Backend/.env.example` dosyasina Open Beauty Facts ayarlari eklendi.
- `README.md` icine Open Beauty Facts entegrasyon bolumu eklendi.
- README'de `OPEN_BEAUTY_FACTS_USER_AGENT` icin gercek iletisim e-postasi
  kullanilmasi gerektigi belirtildi.
- Open Beauty Facts/Open Food Facts verilerinin lisans ve attribution
  yukumlulukleri oldugu not edildi.

### Testler

- `Backend/tests/openBeautyFactsService.test.js` eklendi.
- Open Beauty Facts API cevabinin urun modeline dogru normalize edildigi test
  edildi.
- Urun bulunamadiginda `null` dondugu test edildi.
- `Backend/tests/scanController.test.js` icine yeni test eklendi.
- Lokal DB'de olmayan barkodun Open Beauty Facts'ten ice aktarilip scan
  sonucunda kullanildigi dogrulandi.

### Yapilacaklar Listesi

- `PROJECT_TODO.md` dosyasi eklendi.
- Ileride yapilacak Open Beauty Facts yenileme/senkronizasyon isi kayda alindi:
  - `external_source`
  - `external_updated_at`
  - `last_synced_at`
  - eskiyen urunleri belirli araliklarla tekrar kontrol etme
- Ayrica gercek risk skorlamasi icin CosIng, EU Annexes ve Health Canada Hotlist
  entegrasyonu TODO olarak eklendi.

### Dogrulamalar

Calistirilan kontrol:

```sh
cd Backend
npm test
```

Sonuc:

```text
21 test gecti.
0 test basarisiz.
```

### Notlar

- Bu guncelleme iOS tarafindaki mevcut dosyalara bilerek dokunmadi.
- Calisma agacinda daha onceden var olan Xcode/Info.plist degisiklikleri
  korunarak backend entegrasyonu ayri tutuldu.
- Open Beauty Facts entegrasyonu ilk surum olarak urun ve icerik verisini
  projeye kazandiriyor; risk skoru tarafinda henuz regülasyon tabanli nihai
  siniflandirma yapmiyor.

---

Tarih: 27 Mayis 2026

## Genel Ozet

Bugun iOS ve backend tarafinda daha once belirlenen kritik, orta ve dusuk oncelikli eksiklerin buyuk bolumu toparlandi. Proje artik daha gercekci bir iOS deployment target ile derleniyor, backend testleri placeholder durumundan cikarildi, migration akisi sifirdan dogrulanabilir hale getirildi ve auth + scan + save review akisi backend API seviyesinde test edildi.

## iOS Tarafi

- Deployment target `iOS 26.2` yerine `iOS 17.0` olarak guncellendi.
- Bunun nedeni SwiftUI Observation / `@Observable` kullanimlarinin iOS 17+ gerektirmesi.
- `API_BASE_URL` degeri `Info.plist` uzerinden okunur hale getirildi.
- Kamera izni icin `NSCameraUsageDescription` eklendi.
- Token persistence icin Keychain tabanli session saklama akisi eklendi.
- App acilisinda kayitli session restore edilerek login durumunun kaybolmasi engellendi.
- Auth token protected API cagrisina eklendi.
- `401 Unauthorized` durumunda refresh token ile session yenileme akisi eklendi.
- Backend JSON hatalarinin ham string olarak UI'da gorunmesi yerine kullanici dostu hata mesaji uretilmeye baslandi.
- Bos veya yarim kalmis UI aksiyonlari temizlendi ya da gercek akisa baglandi.
- Kullanilmayan/prototip `ProductPageThreeView` dosyasi kaldirildi.
- UI metinleri icin Ingilizce ve Turkce localization dosyalari eklendi.

## Backend Tarafi

- `npm test` artik bilerek fail eden placeholder degil; Node test runner ile calisiyor.
- Header/security middleware icin testler eklendi.
- PostgreSQL migration akisini sifirdan dogrulamak icin `scripts/verifyFreshMigrations.js` eklendi.
- `package.json` icine `migrate:fresh:verify` script'i eklendi.
- `.env.example` mevcut haliyle backend startup dokumantasyonuna baglandi.
- `README.md` backend kurulum, `.env`, migration, test, iOS setup ve E2E smoke test adimlariyla guncellendi.
- `node_modules` repodan cikarildi ve `.gitignore` icine eklendi.

## Dogrulamalar

Calistirilan kontroller:

```sh
npm test
```

Sonuc: 4 test gecti.

```sh
npm run migrate:fresh:verify
```

Sonuc: 5 migration gecici temiz PostgreSQL veritabanina basariyla uygulandi.

```sh
xcodebuild -scheme InSight -project InSight.xcodeproj -destination generic/platform=iOS -derivedDataPath /private/tmp/InSightDerivedData CODE_SIGNING_ALLOWED=NO build
```

Sonuc: iOS build basarili.

```sh
xcodebuild -scheme InSight -project InSight.xcodeproj -destination id=5CBD5AE3-9824-4993-9D48-11845670B458 -derivedDataPath /private/tmp/InSightDerivedData build
```

Sonuc: iPhone 16 Pro iOS 18.4 simulator hedefinde build basarili.

```sh
xcrun simctl install 5CBD5AE3-9824-4993-9D48-11845670B458 /private/tmp/InSightDerivedData/Build/Products/Debug-iphonesimulator/InSight.app
xcrun simctl launch 5CBD5AE3-9824-4993-9D48-11845670B458 com.diclesara.InSight
```

Sonuc: Uygulama simulator'a yuklendi ve baslatildi.

Backend API smoke testi:

- Register
- OTP kodunu PostgreSQL'den okuma
- OTP verify
- Login
- Barcode scan
- Save review
- Saved reviews listesinden kaydi dogrulama

Sonuc: Tum API akisi basarili.

## Tespit Edilen Blokajlar

### Xcode Signing

Makinede gecerli Apple signing identity bulunamadi:

```text
0 valid identities found
```

Imzali generic iOS build su hata ile durdu:

```text
Signing for "InSight" requires a development team.
```

Bu nedenle gercek cihaz testi henuz tamamlanamadi. Xcode'da Signing & Capabilities altindan Apple Developer Team secilmeli veya proje dosyasina gecerli `DEVELOPMENT_TEAM` Team ID eklenmeli.

### Tam UI E2E Test

Simulator'da uygulama build/install/launch edildi, backend API akisi de dogrulandi. Ancak auth + scan + save review akisi UI uzerinden tam otomatik test edilmedi. Bunun icin XCTest/UI test hedefi eklenmesi veya manuel simulator testi yapilmasi gerekiyor.

## Sonraki En Mantikli Adim

1. Xcode'da Apple Developer Team sec.
2. `API_BASE_URL` degerini test hedefine gore ayarla:
   - Simulator: `http://127.0.0.1:3000`
   - Gercek cihaz: Mac'in LAN IP adresi
3. Gercek cihazda register + OTP + login + scan + save review akisini manuel dogrula.
4. Ardindan ayni akis icin kalici XCTest/UI smoke testi ekle.
