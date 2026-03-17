# StudyFlowiOS

StudyFlowiOS, StudyFlow uygulamasının iOS tarafı için geliştirilmiş **Supabase tabanlı veri ve kimlik doğrulama katmanıdır**. Paket; kimlik doğrulama, kullanıcı profili, dersler, çalışma planı ve görev/progress yönetimi için hazır repository ve view model bileşenleri sunar.

## Özellikler

- Supabase Auth ile kayıt, giriş, çıkış ve şifre sıfırlama
- Supabase Postgres üzerinde kullanıcı, ders, plan, görev ve ilerleme kayıtları
- Asenkron Swift API’leri (`async/await`) ile temiz servis katmanı
- UI katmanı için hazır `AuthViewModel` ve `StudyPlannerViewModel`
- Hata durumları için merkezi `AppError` modeli

## Teknoloji Yığını

- **Swift 5.9+**
- **iOS 16+ / macOS 13+**
- **supabase-swift 2.x**
- **Swift Package Manager**

## Proje Yapısı

```text
StudyFlowiOS/
├── Sources/StudyFlowiOS/
│   ├── Config/              # Supabase konfigürasyonu
│   ├── Domain/              # Entity ve AppError tanımları
│   ├── Repositories/        # Profil, ders ve plan repository’leri
│   ├── Services/            # Supabase client ve auth servisleri
│   └── ViewModels/          # UI için durum yöneten view model’ler
├── Database/
│   └── supabase_schema.sql  # Tablo, FK ve RLS politikaları
├── Config/
│   └── Supabase.xcconfig    # Ortam değişkenleri (URL, anon key)
└── Package.swift
```

> Not: Repository içinde ayrıca kök dizinde bazı SwiftUI ekran dosyaları (`Views/`, `Models/`, `Services/`) da bulunur. Paketlenmiş ve modüler veri katmanı `Sources/StudyFlowiOS/` altında yer alır.

## Kurulum

1. Repoyu projene ekle (Swift Package olarak veya doğrudan kaynak kodla).
2. `Config/Supabase.xcconfig` dosyasında aşağıdaki değerleri gerçek Supabase projen ile doldur:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Xcode yapılandırmanda bu `.xcconfig` dosyasını ilgili configuration’a bağla.
4. `Info.plist` içindeki `INFOPLIST_KEY_*` passthrough ayarlarının aktif olduğundan emin ol (veya değerleri environment variable olarak enjekte et).

## Veritabanı Kurulumu (Supabase)

Supabase SQL Editor’da aşağıdaki dosyayı çalıştır:

- `Database/supabase_schema.sql`

Bu script; tabloları, foreign key ilişkilerini ve kullanıcı bazlı RLS politikalarını oluşturur.

## Paket Bağımlılıkları

`Package.swift` içinde aşağıdaki bağımlılık tanımlıdır:

- `supabase-swift` (`from: "2.0.0"`)

Paket tek bir library ürünü yayınlar:

- `StudyFlowiOS`

## Sunulan API Katmanı

- `SupabaseAuthService`
  - `signUp`, `signIn`, `signOut`, `resetPassword`
- `SupabaseProfileRepository`
  - `users` tablosu için profil CRUD işlemleri
- `SupabaseSubjectRepository`
  - ders CRUD işlemleri
- `SupabaseStudyPlannerRepository`
  - plan, görev ve progress log okuma/yazma işlemleri
- `AuthViewModel` ve `StudyPlannerViewModel`
  - UI tüketimi için hata/senaryo odaklı durum yönetimi

## Geliştirme Notları

- Supabase anahtarlarını doğrudan kaynak kodda tutma.
- RLS politikalarını devre dışı bırakmadan geliştirme yap.
- ViewModel katmanında kullanıcıya gösterilecek hata mesajlarını `AppError` üzerinden normalize et.

## Lisans

Bu proje `LICENSE` dosyasında belirtilen koşullar altında lisanslanmıştır.
