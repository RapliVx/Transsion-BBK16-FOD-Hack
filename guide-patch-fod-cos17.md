# 🚀 Panduan Ultimate Patch FOD - ColorOS 17 (Android 14+)
> [!NOTE] 
> **Dokumen ini adalah versi penyempurnaan (Perfected Edition) dari repositori `Transsion-BBK16-FOD-Hack`.**
> Direvisi dan dioptimalkan secara khusus untuk mengatasi masalah kompatibilitas, *Force Close*, dan perubahan arsitektur keamanan pada ColorOS 17 (Android 17 / SDK 34+).

---

## 📜 Kenapa Panduan Ini Dibuat? (Analisa Bug & Crash)
Jika kamu menggunakan panduan lama BBK16 mentah-mentah pada OS 17, **SystemUI dipastikan akan mengalami *Crash* atau *Bug***. Berikut adalah 5 kendala utama dan bagaimana panduan ini memperbaikinya:

| Jenis Masalah | Penyebab di OS 17 | Solusi di Panduan Ini |
| :--- | :--- | :--- |
| 💥 **`NullPointerException`** | Register `p1` (Context) dihancurkan oleh sistem sesaat sebelum inisialisasi selesai. | Mengambil *Context* secara aman menggunakan `invoke-virtual {p0}, ImageView;->getContext()`. |
| 💥 **`SecurityException`** | Aturan ketat Android 14+ menolak receiver eksternal yang tidak memiliki *flag* keamanan. | Menambahkan *flag* `RECEIVER_EXPORTED` (`0x2`) ke parameter `registerReceiver`. |
| 💥 **`NoSuchMethodError`** | Panduan lama lupa menyertakan instruksi untuk meng-*copy* method HBM & interaksi sentuhan jari. | Menginjeksi 5 *method* vital pembentuk HBM di akhir file `OnScreenFingerprintIcon.smali`. |
| 🐛 **Ikon Putih Nyangkut** | Saat berhasil *unlock*, sistem menghapus ikon asli tapi HBM buatan kita tertinggal di layar sampai jari dilepas. | Melakukan *hooking* ke dalam method `setVisibility(I)V` untuk otomatis menghancurkan HBM. |
| 🐛 **Layar Gelap Total** | Layar mendadak gelap pekat di Lockscreen/pengaturan sidik jari karena sistem me-render *Dim Layer* (overlay hitam). | Memanipulasi fungsi `isDisableAppDimLayer()` di file UiMech agar bernilai `True`. |

---

## 🛠️ Persiapan (Prerequisites)
> [!IMPORTANT]
> Pastikan kamu sudah menyiapkan hal-hal berikut sebelum memulai:
- Aplikasi **MT Manager** (atau Dex Editor Plus).
- APK `SystemUI.apk` ori yang sudah ditarik dari perangkat.
- File-file `.smali` pendukung dari repo BBK16.
- 💡 **INFO PENTING COS17:** Di ColorOS 17, seluruh file dan kode yang berhubungan dengan *Fingerprint on Display* (FOD) berada di dalam **`classes3.dex`**. Jangan mencarinya di `classes.dex` atau `classes2.dex`.

---

## 🚀 Langkah-langkah Eksekusi

### Langkah 1: Tambahkan 4 File Smali Baru
1. Buka `SystemUI.apk` di MT Manager.
2. Pilih file **`classes3.dex`** lalu buka menggunakan **Dex Editor Plus**.
3. Navigasi ke direktori berikut:
   📁 `com/oplus/systemui/biometrics/finger/udfps/`
4. Tambahkan *(Copy/Add)* 4 file smali ini ke dalam folder tersebut:
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver.smali`
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver$1.smali`
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver$2.smali`
   - 📄 `OnScreenFingerprintIcon$1.smali` *(Timpa jika sudah ada file aslinya)*

---

### Langkah 2: Patch `OnScreenFingerprintIcon.smali` (Inti FOD)
Masih di dalam **`classes3.dex`**, buka file **`OnScreenFingerprintIcon.smali`** lalu eksekusi tahap A, B, C, dan D di bawah ini secara teliti.

#### 2A. Injeksi Variabel (Fields)
Cari blok dengan nama `# instance fields` (biasanya ada di bagian paling atas). Tambahkan 3 variabel penampung memori ini di bawahnya:

```smali
.field public mHbmDummyView:Landroid/view/View;
.field public mHbmSurfaceControl:Landroid/view/SurfaceControl;
.field private mFingerKeyReceiver:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;
```

#### 2B. Patch Constructor (Fix SecurityException & NullPointer)
Gunakan fitur pencarian dan cari: 
🔍 `.method public constructor <init>(`

Scroll ke bagian **paling bawah** method tersebut, tepat di **ATAS** `return-void`. Ubah baris penutup pendaftaran *receiver*-nya menggunakan *flag* `0x2` persis seperti ini:

```smali
    new-instance v0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;
    invoke-direct {v0, p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;-><init>(Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;)V
    iput-object v0, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mFingerKeyReceiver:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;

    new-instance v1, Landroid/content/IntentFilter;
    invoke-direct {v1}, Landroid/content/IntentFilter;-><init>()V
    const-string v2, "com.rianixia.FINGER_DOWN"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V
    const-string v2, "com.rianixia.FINGER_UP"
    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    # --- AMBIL CONTEXT DARI VIEW ---
    invoke-virtual {p0}, Landroid/widget/ImageView;->getContext()Landroid/content/Context;
    move-result-object v2

    # --- INJEKSI FLAG RECEIVER_EXPORTED (0x2) UNTUK ANDROID 14+ ---
    const/4 v3, 0x2
    invoke-virtual {v2, v0, v1, v3}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    return-void
.end method
```

#### 2C. Injeksi Otomatis Hapus HBM (Fix Ikon Nyangkut Saat Unlock)
Agar Ikon HBM buatan kita ikut hilang ketika HP masuk ke *Home Screen* tanpa perlu menahan jari, kita sisipkan instruksi ke dalam sistem penyembunyi ikon bawaan.

Gunakan fitur pencarian dan cari method ini: 
🔍 `.method public setVisibility(I)V`

Tepat di **bawah** deklarasi `.registers` (misalnya di bawah baris `.registers 11`), selipkan blok kode pendek ini:
```smali
    # --- [START] FIX ICON PUTIH NYANGKUT SAAT UNLOCK ---
    if-eqz p1, :cond_skip_hbm_destroy
    invoke-virtual {p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->destroyHbmSurfaceControl()V
    :cond_skip_hbm_destroy
    # --- [END] FIX ICON PUTIH NYANGKUT SAAT UNLOCK ---
```


#### 2D. Injeksi Method HBM (Fix Ikon Hilang & Crash Sentuhan)
Agar SystemUI tahu cara membuat "layar terang" dan menerima sentuhan, kamu wajib menambahkan 5 method baru di bawah ini.

Scroll terus ke **baris paling bawah** file `OnScreenFingerprintIcon.smali` (pastikan di luar blok `.end method` mana pun). **Copy dan Paste kelima method ini secara berurutan:**

**1. Method Pembuat HBM (`createHbmSurfaceControl`)**
```smali
.method public createHbmSurfaceControl()V
    .registers 16

    const-string v12, "OnScreenFingerprintIcon"
    const-string v13, "createHbmSurfaceControl: calling hwcomposer"
    invoke-static {v12, v13}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v0, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmSurfaceControl:Landroid/view/SurfaceControl;
    if-eqz v0, :cond_11
    const-string v0, "HBM is already enabled"
    invoke-static {v12, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :cond_11
    invoke-virtual {p0}, Landroid/widget/ImageView;->getContext()Landroid/content/Context;
    move-result-object v2
    const-string/jumbo v0, "window"
    invoke-virtual {v2, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/view/WindowManager;

    const/4 v11, 0x2
    new-array v5, v11, [I
    invoke-virtual {p0, v5}, Landroid/widget/ImageView;->getLocationOnScreen([I)V

    const/4 v6, 0x0
    aget v7, v5, v6
    const/4 v6, 0x1
    aget v8, v5, v6

    invoke-virtual {p0}, Landroid/widget/ImageView;->getWidth()I
    move-result v4
    invoke-virtual {p0}, Landroid/widget/ImageView;->getHeight()I
    move-result v9

    new-instance v10, Landroid/view/WindowManager$LayoutParams;
    invoke-direct {v10}, Landroid/view/WindowManager$LayoutParams;-><init>()V
    iput v4, v10, Landroid/view/WindowManager$LayoutParams;->width:I
    iput v9, v10, Landroid/view/WindowManager$LayoutParams;->height:I
    iput v7, v10, Landroid/view/WindowManager$LayoutParams;->x:I
    iput v8, v10, Landroid/view/WindowManager$LayoutParams;->y:I
    const/16 v0, 0x7f7
    iput v0, v10, Landroid/view/WindowManager$LayoutParams;->type:I
    const v0, 0x1080028
    iput v0, v10, Landroid/view/WindowManager$LayoutParams;->flags:I
    const/4 v0, -0x3
    iput v0, v10, Landroid/view/WindowManager$LayoutParams;->format:I
    const-string v0, "RianixiaHBMController"
    invoke-virtual {v10, v0}, Landroid/view/WindowManager$LayoutParams;->setTitle(Ljava/lang/CharSequence;)V
    const/16 v0, 0x33
    iput v0, v10, Landroid/view/WindowManager$LayoutParams;->gravity:I

    new-instance v11, Landroid/view/View;
    invoke-direct {v11, v2}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const/4 v0, 0x0
    invoke-virtual {v11, v0}, Landroid/view/View;->setAlpha(F)V
    invoke-interface {v3, v11, v10}, Landroid/view/WindowManager;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V
    iput-object v11, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmDummyView:Landroid/view/View;

    invoke-virtual {v11}, Landroid/view/View;->getViewRootImpl()Landroid/view/ViewRootImpl;
    move-result-object v0
    if-nez v0, :cond_76

    const-string v1, "ViewRootImpl is null - waiting for attachment"
    invoke-static {v12, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    new-instance v1, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$1;
    invoke-direct {v1, p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$1;-><init>(Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;)V
    invoke-virtual {v11, v1}, Landroid/view/View;->post(Ljava/lang/Runnable;)Z
    return-void

    :cond_76
    invoke-virtual {v0}, Landroid/view/ViewRootImpl;->getSurfaceControl()Landroid/view/SurfaceControl;
    move-result-object v1
    if-eqz v1, :cond_84
    iput-object v1, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmSurfaceControl:Landroid/view/SurfaceControl;
    const-string v2, "Triggered FULL_HBM_SET"
    invoke-static {v12, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :cond_84
    const-string v2, "Failed to get SurfaceControl from ViewRootImpl"
    invoke-static {v12, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    invoke-interface {v3, v11}, Landroid/view/WindowManager;->removeView(Landroid/view/View;)V
    return-void
.end method
```

**2. Method Penghancur HBM (`destroyHbmSurfaceControl`)**
```smali
.method public destroyHbmSurfaceControl()V
    .registers 7

    const-string v0, "OnScreenFingerprintIcon"
    const-string v1, "destroyHbmSurfaceControl: onFingerUp"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v2, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmDummyView:Landroid/view/View;
    if-eqz v2, :cond_2c

    invoke-virtual {v2}, Landroid/view/View;->getContext()Landroid/content/Context;
    move-result-object v3
    const-string/jumbo v1, "window"
    invoke-virtual {v3, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/view/WindowManager;

    :try_start_18
    invoke-interface {v3, v2}, Landroid/view/WindowManager;->removeView(Landroid/view/View;)V
    :try_end_1b
    .catch Ljava/lang/Exception; {:try_start_18 .. :try_end_1b} :catch_1c

    goto :goto_22
    :catch_1c
    move-exception v1
    const-string v3, "Error stopping hbm"
    invoke-static {v0, v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_22
    const-string v1, "Removed FULL_HBM_SET"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v4, 0x0
    iput-object v4, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmDummyView:Landroid/view/View;
    iput-object v4, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmSurfaceControl:Landroid/view/SurfaceControl;

    :cond_2c
    return-void
.end method
```

**3. Method Deteksi Sentuh (`handleFingerprintKeyPress`)**
```smali
.method public handleFingerprintKeyPress()V
    .registers 3

    const-string v0, "OnScreenFingerprintIcon"
    const-string v1, "Detected onFingerDown"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    const-string v0, "FINGER_DOWN"
    invoke-virtual {p0, v0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->saveLog(Ljava/lang/String;)V
    invoke-virtual {p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->createHbmSurfaceControl()V
    return-void
.end method
```

**4. Method Deteksi Lepas Jari (`handleFingerprintKeyRelease`)**
```smali
.method public handleFingerprintKeyRelease()V
    .registers 3

    const-string v0, "OnScreenFingerprintIcon"
    const-string v1, "Detected onFingerUp"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    const-string v0, "FINGER_UP"
    invoke-virtual {p0, v0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->saveLog(Ljava/lang/String;)V
    invoke-virtual {p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->destroyHbmSurfaceControl()V
    return-void
.end method
```

**5. Method Sinkronisasi HBM (`setHbmSurfaceControl`)**
```smali
.method public setHbmSurfaceControl(Landroid/view/SurfaceControl;)V
    .registers 2
    iput-object p1, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmSurfaceControl:Landroid/view/SurfaceControl;
    return-void
.end method
```

---

### Langkah 3: Patch `OnScreenFingerprintUiMech.smali` (Fix Layar Gelap)
Masalah layar yang mendadak menjadi gelap pekat (bahkan tanpa disentuh) saat berada di *Lockscreen* atau pengaturan sidik jari disebabkan oleh overlay hitam (*Dim Layer*) yang dibuat sistem. Kita harus menonaktifkannya.

1. Buka file **`OnScreenFingerprintUiMech.smali`**.
2. Gunakan pencarian untuk mencari baris kode ini:
   🔍 `isDisableAppDimLayer()`
3. Kamu akan menemukannya di **2 titik berbeda** (biasanya di sekitar baris 1200-an dan 6600-an).
4. Di **KEDUA** titik tersebut, tambahkan kode `const/4 v0, 0x1` tepat di bawah `move-result v0`, sehingga strukturnya menjadi seperti ini:

```smali
    invoke-static {}, Lcom/oplusos/systemui/common/feature/KeyguardFeatureOption;->isDisableAppDimLayer()Z
    move-result v0

    # --- [START] FIX LAYAR GELAP ---
    const/4 v0, 0x1
    # --- [END] FIX LAYAR GELAP ---
```
*(Penjelasan: Modifikasi ini memanipulasi parameter di memori sehingga sistem mengira bahwa pengaturan "Disable Dim Layer" bernilai True/1, yang mengakibatkan lapisan hitam batal dirender).*

---

## 📦 Tahap Akhir: Repack & Sign
> [!WARNING]  
> **JANGAN PERNAH MENGGUNAKAN FITUR AUTO-SIGN!**  
> Signature pada file *SystemUI* adalah identitas krusial. Melakukan Auto-Sign akan mengubah signature tersebut dan membuat HP mengalami Bootloop (stuck di logo).

1. Klik tombol Save / Simpan di text editor MT Manager.
2. Keluar dari editor (*Back*).
3. Saat muncul kotak dialog `Update file in the archive?`, pastikan kotak **Auto Sign DIMATIKAN (UNCHECK)**.
4. Klik OK.
5. Push/install APK `SystemUI.apk` hasil modifikasimu dan *Reboot* perangkat. 

**Selamat! FOD dan HBM kamu sekarang berjalan sangat mulus & tanpa celah di ColorOS 17. 🚀🔥**
