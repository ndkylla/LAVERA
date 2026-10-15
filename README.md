# LAVÉRA — GitHub Pages

Website statis LAVÉRA dengan HTML, CSS, dan JavaScript. Tidak menggunakan Streamlit.

## Cara upload ke GitHub

1. Buka https://github.com/new dan buat repository bernama `lavera-laundry`.
2. Pilih **Public** (atau sesuai kebutuhan), lalu klik **Create repository**.
3. Klik **Add file → Upload files**.
4. Upload `index.html` dari folder ini.
5. Klik **Commit changes**.

## Cara mengaktifkan GitHub Pages

1. Buka repository → **Settings**.
2. Pilih **Pages** pada menu samping.
3. Pada **Build and deployment**, pilih **Deploy from a branch**.
4. Pilih branch `main` dan folder `/(root)`, lalu klik **Save**.
5. Tunggu proses publikasi, kemudian buka alamat Pages yang ditampilkan pada halaman tersebut.

## Area pemilik

Website menampilkan bagian informasi Area Pemilik, tetapi belum menyediakan login/dashboard sungguhan karena GitHub Pages hanya menjalankan file statis.

## Batasan penting

- Website ini adalah versi statis/demo dari LAVÉRA; bukan konversi backend Python/SQLite secara penuh.
- Formulir pesanan, kode pesanan, struk cetak, dan riwayat hanya disimpan pada `localStorage` browser/perangkat yang digunakan. Pesanan tidak terkirim ke pemilik laundry, dan data tidak dibagikan antar-pengunjung.
- Login pelanggan/pemilik, pengelolaan layanan oleh admin, serta status pesanan yang tersinkron tidak dapat dibuat aman hanya dengan GitHub Pages. Untuk fitur tersebut dibutuhkan backend/API dan database terpisah.
- Jangan masukkan password, data pelanggan asli, atau rahasia ke file website publik.
- Harga layanan mengikuti daftar awal aplikasi: Cuci Komplit Rp8.000/kg, Cuci Kering Rp5.000/kg, Setrika Rp4.000/kg, Express Rp15.000/kg, Bed Cover & Selimut Rp20.000/pcs. Sesuaikan sebelum digunakan secara nyata.


## Akun pelanggan demo

Website menyediakan form daftar/login pelanggan berlapis. Data akun demo disimpan di localStorage browser, dengan password di-hash di sisi browser. Ini bukan autentikasi server: data hanya ada di browser/perangkat tersebut, dapat hilang jika data browser dihapus, dan tidak aman untuk data sensitif. Untuk akun lintas perangkat dan login produksi diperlukan backend serta database.


## Form pemesanan

Halaman pemesanan menggunakan sidebar pelanggan, pilihan layanan, detail alamat/berat/tanggal penjemputan, dan ringkasan estimasi biaya. Data tetap demo browser-side; tidak ada sinkronisasi server.
