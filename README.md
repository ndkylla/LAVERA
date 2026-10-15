# LAVÉRA Full-Stack Starter (GitHub Pages + Supabase)

Starter ini mempertahankan identitas visual hijau forest/sage/ivory dan menyediakan alur halaman:
1. Landing page
2. Daftar pelanggan dan login
3. Form pemesanan dengan ringkasan harga
4. Struk yang bisa dicetak / disimpan PDF
5. Riwayat pesanan pelanggan
6. Dashboard pemilik untuk melihat pesanan dan mengubah status

## Arsitektur
- **Frontend:** `index.html`, di-host di GitHub Pages.
- **Backend + database + autentikasi:** Supabase (PostgreSQL + Supabase Auth + Row Level Security).
- **Akun:** password ditangani oleh Supabase Auth, bukan disimpan sendiri di browser.
- **Database:** profil, layanan, dan pesanan disimpan di Supabase.

> GitHub Pages sendiri tidak menjalankan backend Python. Supabase digunakan sebagai layanan backend terpisah.

## A. Buat proyek Supabase
1. Buka https://supabase.com/ dan buat akun / login.
2. Buat project baru, pilih nama misalnya `lavera-laundry`, buat password database yang kuat, dan pilih region terdekat yang tersedia.
3. Setelah project aktif, buka **SQL Editor** → **New query**.
4. Buka file `supabase_schema.sql` dari paket ini, salin seluruh isinya ke SQL Editor, lalu klik **Run**.
5. Di Supabase, buka **Project Settings → API** (atau halaman API Keys pada dashboard terbaru). Salin **Project URL** dan **anon/public key**. Key publik/anon boleh dipakai di frontend dengan RLS yang benar; JANGAN pernah pakai `service_role` key di HTML.

## B. Sambungkan frontend
1. Buka `index.html` di editor teks.
2. Cari dua baris:
   ```js
   const SUPABASE_URL = "PASTE_YOUR_SUPABASE_PROJECT_URL";
   const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY";
   ```
3. Ganti nilainya dengan Project URL dan anon/public key milik project Supabase.
4. Simpan file.

## C. Upload ke GitHub Pages
1. Di repository GitHub kamu, upload `index.html` dan `supabase_schema.sql` (README boleh ikut).
2. Buka **Settings → Pages**.
3. Pada **Build and deployment**, pilih **Deploy from a branch**, branch `main`, folder `/(root)`, lalu **Save**.
4. Tunggu hingga website Pages diterbitkan.

## D. Buat akun pemilik
1. Buka website yang sudah online, lalu pilih **Masuk / Daftar → Daftar pelanggan**.
2. Daftarkan email milikmu dan selesaikan verifikasi email jika diminta.
3. Di Supabase, buka **SQL Editor** dan jalankan query ini, ganti email contoh dengan email yang kamu daftarkan:
   ```sql
   update public.profiles
   set role = 'owner'
   where id = (
     select id from auth.users where email = 'email-pemilik-kamu@example.com'
   );
   ```
4. Logout lalu login lagi. Akun dengan role `owner` akan masuk ke dashboard pemilik.

Jangan menjadikan semua pengunjung sebagai owner. Hanya promosikan akun milik pemilik yang kamu percaya.

## E. Catatan verifikasi email
Supabase dapat meminta verifikasi email sebelum pengguna bisa login. Konfigurasikan **Authentication → URL Configuration**:
- Site URL: alamat GitHub Pages kamu, contoh `https://USERNAME.github.io/REPOSITORY/`
- Tambahkan alamat tersebut ke Redirect URLs jika diperlukan.

## F. Keamanan & batasan starter
- Jangan pernah memasukkan `service_role` key ke `index.html`.
- RLS di schema membatasi pelanggan melihat pesanan miliknya dan pemilik melihat semua pesanan.
- Untuk penggunaan produksi, tinjau kebijakan RLS dan validasi server-side. Pada starter ini harga total dihitung di browser ketika membuat pesanan; untuk mencegah manipulasi harga, idealnya buat database function/Edge Function yang mengambil harga resmi dari tabel `services` dan menghitung total di server.
- Pastikan kebijakan email, reset password, dan verifikasi email sesuai kebutuhan.
- Dashboard pemilik starter dapat mengubah status pesanan, tetapi pengelolaan harga langsung dari UI belum disediakan; harga dapat diubah melalui tabel `services` di Supabase.
- Pembayaran online dan notifikasi WhatsApp belum terhubung.

## Troubleshooting
- **"Backend belum disambungkan"**: cek dua konstanta Supabase di `index.html`.
- **Layanan tidak muncul**: jalankan `supabase_schema.sql` sepenuhnya dan periksa tab Table Editor.
- **Profil belum siap**: pastikan trigger `on_auth_user_created` terbentuk; jika akun dibuat sebelum schema, daftar akun baru atau buat profile untuk user tersebut di SQL Editor.
- **Tidak bisa login setelah daftar**: cek email verifikasi dan Authentication → Users.
- **Owner masuk sebagai pelanggan**: jalankan query promote owner, lalu logout/login kembali.
