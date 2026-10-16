# LAVÉRA — Laundry Care

Aplikasi web laundry dengan frontend HTML, CSS, JavaScript, GitHub Pages, dan Supabase.

## Isi repository

```text
LAVERA_GitHub_Project/
├── index.html
├── README.md
├── .nojekyll
└── supabase/
    └── schema.sql
```

- `index.html`: frontend LAVÉRA (HTML, CSS, dan JavaScript dalam satu file).
- `supabase/schema.sql`: schema database, trigger profil, RLS policies, dan data layanan awal.
- `.nojekyll`: membantu GitHub Pages menyajikan file tanpa pemrosesan Jekyll.
- `README.md`: panduan setup dan deployment.

## 1. Upload ke GitHub

1. Buat atau buka repository GitHub untuk LAVÉRA.
2. Upload **isi folder ini**, bukan file ZIP-nya.
3. Pastikan `index.html` berada langsung di root repository, sejajar dengan `README.md`.
4. Klik **Commit changes**.

Struktur root harus seperti ini:

```text
repository/
├── index.html
├── README.md
├── .nojekyll
└── supabase/
    └── schema.sql
```

Jangan menaruh `index.html` hanya di dalam folder lain jika GitHub Pages diarahkan ke root.

## 2. Setup Supabase

1. Buka project Supabase yang digunakan LAVÉRA.
2. Buka **SQL Editor → New query**.
3. Buka `supabase/schema.sql`, salin seluruh isinya, tempel ke SQL Editor, lalu klik **Run**.
4. Pastikan query selesai tanpa error.
5. Buka **Authentication → Providers** dan pastikan Email provider aktif.
6. Jika konfirmasi email aktif, pengguna mungkin perlu memverifikasi email sebelum login.
7. Pastikan project URL dan public anon/publishable key di `index.html` mengarah ke project Supabase yang benar.

Schema membuat tabel `profiles`, `services`, dan `orders`, serta kebijakan Row Level Security (RLS). Untuk project yang sudah berisi tabel atau policy lama, baca SQL dan periksa hasilnya sebelum menjalankan ulang. Selalu simpan cadangan sebelum mengubah database yang sudah digunakan.

### Jadikan akun sebagai pemilik (owner)

1. Daftarkan akun melalui website LAVÉRA terlebih dahulu.
2. Di Supabase, buka **SQL Editor** dan jalankan query berikut setelah mengganti email dengan email akun pemilik:

```sql
update public.profiles
set role = 'owner'
where id = (
  select id
  from auth.users
  where email = 'owner@email.com'
);
```

3. Logout lalu login kembali agar aplikasi memuat role terbaru.

Jangan pernah memasukkan `service_role` key atau secret key ke dalam `index.html`. Frontend hanya boleh memakai public anon/publishable key, dengan RLS yang benar.

## 3. Setup GitHub Pages

1. Di repository, buka **Settings → Pages**.
2. Pada **Build and deployment**, pilih **Deploy from a branch** jika opsi itu tersedia.
3. Pilih branch `main` dan folder `/(root)`.
4. Klik **Save**.
5. Tunggu workflow/deployment selesai, lalu buka URL yang ditampilkan di halaman Pages.

Setiap kali `index.html` di-commit ke branch dan folder publikasi tersebut, GitHub Pages akan memperbarui website setelah deployment selesai.

## 4. Fitur yang tersedia

- Landing page dan daftar layanan.
- Registrasi dan login pelanggan melalui Supabase Auth.
- Pemilihan layanan laundry dan estimasi harga.
- Metode layanan:
  - `drop_off` — antar sendiri ke outlet.
  - `pickup` — pakaian dijemput.
  - `pickup_delivery` — pakaian dijemput dan diantar kembali.
- Penyimpanan pesanan di Supabase.
- Riwayat pesanan dan struk yang dapat dicetak/disimpan sebagai PDF.
- Dashboard pemilik untuk melihat pesanan dan mengubah status.

Metode layanan belum mengenakan biaya transportasi terpisah dan belum memiliki tanggal pengantaran terpisah. Total estimasi masih berdasarkan harga layanan dikalikan jumlah/berat.

## 5. Jika website hanya menampilkan README

Itu biasanya berarti yang dibuka adalah tampilan repository atau GitHub Pages belum diarahkan ke file HTML yang benar.

- Buka URL Pages yang ditampilkan pada **Settings → Pages**, bukan URL tampilan file README.
- Pastikan file bernama persis `index.html`.
- Pastikan `index.html` berada di folder publikasi yang dipilih.
- Periksa status deployment di tab **Actions**.
- Setelah deployment sukses, refresh browser dengan `Ctrl + Shift + R`.

## 6. Jika login atau pesanan gagal

Periksa hal berikut:

- URL dan public key Supabase di `index.html` benar dan berasal dari project yang sama.
- `supabase/schema.sql` berhasil dijalankan.
- Tabel `profiles`, `services`, dan `orders` tersedia.
- Akun sudah terdaftar dan, bila diwajibkan, email sudah diverifikasi.
- RLS policies sesuai dengan kebutuhan aplikasi.
- Browser DevTools → **Console** dan **Network** untuk melihat pesan error.

Jangan menonaktifkan RLS hanya untuk menghilangkan error. Perbaiki policy yang diperlukan dan uji dengan akun pelanggan serta owner secara terpisah.

## Catatan

Ini adalah starter project. Uji seluruh alur sebelum dipakai oleh pelanggan sungguhan, terutama autentikasi, RLS, akses owner, pembuatan pesanan, dan perubahan status. Struk adalah ringkasan pesanan, bukan bukti pembayaran.
