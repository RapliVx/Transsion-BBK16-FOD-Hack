# Ultimate FOD Patch Guide - ColorOS 17 (Android 14+)
> [!NOTE] 
> **This document is the Perfected Edition of the `Transsion-BBK16-FOD-Hack` repository.**
> It has been specifically revised and optimized to fix compatibility issues, Force Closes, and security architecture changes present in ColorOS 17 (Android 17 / SDK 34+).

---

## Why Was This Guide Created? (Bug & Crash Analysis)
If you blindly follow the old BBK16 guide on OS 17, **your SystemUI will definitely crash or experience bugs**. Here are the 6 main issues and how this guide fixes them:

| Issue / Bug | Cause in OS 17 | Solution in This Guide |
| :--- | :--- | :--- |
| **`NullPointerException`** | Register `p1` (Context) gets destroyed by the system right before initialization finishes. | Safely fetch the *Context* using `invoke-virtual {p0}, ImageView;->getContext()`. |
| **`SecurityException`** | Android 14+ strictly rejects external receivers that lack security flags. | Inject the `RECEIVER_EXPORTED` (`0x2`) flag into the `registerReceiver` parameter. |
| **`NoSuchMethodError` (Icon)** | The old guide forgot to instruct users to copy the HBM and fingerprint touch methods. | Explicitly inject 5 vital HBM *methods* at the bottom of `OnScreenFingerprintIcon.smali`. |
| **`NoSuchMethodError` (Receiver)** | The `updateOpticalUI` function has been moved by Oplus developers to the `KeyguardFingerprintUtils` class in OS 17. | Change the *invoke-static* target inside the `FingerKeyReceiver.smali` file to the new class. |
| **White Icon Stuck** | After a successful unlock, the system hides the original icon but our custom HBM gets left behind until the finger is lifted. | Hook into the `setVisibility(I)V` method to automatically destroy the HBM. |
| **Pitch Black Screen** | The screen suddenly goes pitch black on the Lockscreen/fingerprint enrollment because the system renders a *Dim Layer* (black overlay). | Manipulate the `isDisableAppDimLayer()` function in the UiMech file to return `True`. |

---

## Prerequisites
> [!IMPORTANT]
> Make sure you have the following ready before starting:
- **MT Manager** app (or Dex Editor Plus).
- The original `SystemUI.apk` pulled from your device.
- The supporting `.smali` files from the BBK16 repo.
- 💡 **CRUCIAL COS17 INFO:** In ColorOS 17, all files and codes related to *Fingerprint on Display* (FOD) are located inside **`classes3.dex`**. Do not look for them in `classes.dex` or `classes2.dex`.

---

## Execution Steps

### Step 1: Add 4 New Smali Files
1. Open `SystemUI.apk` in MT Manager.
2. Select the **`classes3.dex`** file and open it using **Dex Editor Plus**.
3. Navigate to the following directory:
   📁 `com/oplus/systemui/biometrics/finger/udfps/`
4. Add *(Copy/Add)* these 4 smali files into the folder:
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver.smali`
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver$1.smali`
   - 📄 `OnScreenFingerprintIcon$FingerKeyReceiver$2.smali`
   - 📄 `OnScreenFingerprintIcon$1.smali` *(Overwrite if the original file exists)*

---

### Step 2: Check & Patch `FingerKeyReceiver.smali` (IF NOT ALREADY PATCHED)
> [!NOTE] 
> ***Skip this step if you are using pre-patched smali files provided by the author. Do this only if your smali files are the original untouched ones from the old BBK16 repository.***

The architecture changes in ColorOS 17 mean the default BBK16 receiver file calls a class that has been moved, triggering an instant *Crash/Force Close* as soon as you touch the fingerprint icon.

1. Open the **`OnScreenFingerprintIcon$FingerKeyReceiver.smali`** file that you just added in Step 1.
2. Use the search feature to find:
   🔍 `updateOpticalUI`
3. You will find it in **2 lines**. Change the calling code from `OnScreenFingerprintUiMech` to `KeyguardFingerprintUtils`.

**Change these lines (OLD CODE):**
```smali
invoke-static {v3}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->updateOpticalUI(Ljava/lang/Runnable;)V
```
and
```smali
invoke-static {v4}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->updateOpticalUI(Ljava/lang/Runnable;)V
```

**To this (NEW OS 17 CODE):**
```smali
invoke-static {v3}, Lcom/oplus/systemui/biometrics/finger/KeyguardFingerprintUtils;->updateOpticalUI(Ljava/lang/Runnable;)V
```
and
```smali
invoke-static {v4}, Lcom/oplus/systemui/biometrics/finger/KeyguardFingerprintUtils;->updateOpticalUI(Ljava/lang/Runnable;)V
```

---

### Step 3: Patch `OnScreenFingerprintIcon.smali` (FOD Core)
Open the **`OnScreenFingerprintIcon.smali`** file and carefully execute steps A, B, C, and D below.

#### 3A. Variable Injection (Fields)
Search for the `# instance fields` block (usually near the top). Add these 3 memory variables right below it:

```smali
.field public mHbmDummyView:Landroid/view/View;
.field public mHbmSurfaceControl:Landroid/view/SurfaceControl;
.field private mFingerKeyReceiver:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;
```

#### 3B. Patch the Constructor (Fix SecurityException & NullPointer)
Use the search feature and look for: 
🔍 `.method public constructor <init>(`

Scroll to the **very bottom** of that method, right **ABOVE** `return-void`. Change its receiver registration ending lines by using the `0x2` flag exactly like this:

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

    # --- FETCH CONTEXT DIRECTLY FROM VIEW ---
    invoke-virtual {p0}, Landroid/widget/ImageView;->getContext()Landroid/content/Context;
    move-result-object v2

    # --- INJECT RECEIVER_EXPORTED FLAG (0x2) FOR ANDROID 14+ ---
    const/4 v3, 0x2
    invoke-virtual {v2, v0, v1, v3}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    return-void
.end method
```

#### 3C. Auto-Destroy HBM Injection (Fix Stuck Icon on Unlock)
To ensure our custom HBM Icon disappears when the phone enters the *Home Screen* without waiting for the finger to lift, we inject an instruction into the system's native icon hider.

Use the search feature and look for this method: 
🔍 `.method public setVisibility(I)V`

Right **below** the `.registers` declaration (e.g., below the `.registers 11` line), insert this short code block:
```smali
    # --- [START] FIX WHITE ICON STUCK ON UNLOCK ---
    if-eqz p1, :cond_skip_hbm_destroy
    invoke-virtual {p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->destroyHbmSurfaceControl()V
    :cond_skip_hbm_destroy
    # --- [END] FIX WHITE ICON STUCK ON UNLOCK ---
```


#### 3D. HBM Methods Injection (Fix Missing Icon & Touch Crash)
To teach SystemUI how to create a "bright screen" and receive touches, you must add the following 5 new methods.

Scroll all the way to the **very bottom** of the `OnScreenFingerprintIcon.smali` file (make sure it's outside any `.end method` blocks). **Copy and paste these five methods sequentially:**

**1. HBM Creator Method (`createHbmSurfaceControl`)**
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

**2. HBM Destroyer Method (`destroyHbmSurfaceControl`)**
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

**3. Touch Detection Method (`handleFingerprintKeyPress`)**
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

**4. Touch Release Method (`handleFingerprintKeyRelease`)**
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

**5. HBM Sync Method (`setHbmSurfaceControl`)**
```smali
.method public setHbmSurfaceControl(Landroid/view/SurfaceControl;)V
    .registers 2
    iput-object p1, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->mHbmSurfaceControl:Landroid/view/SurfaceControl;
    return-void
.end method
```

---

### Step 4: Patch `OnScreenFingerprintUiMech.smali` (Pitch Black Screen Fix)
The issue where the screen suddenly goes pitch black (even without touching it) while on the Lockscreen or in the fingerprint enrollment is caused by a black overlay (*Dim Layer*) created by the system. We must disable it.

1. Open the **`OnScreenFingerprintUiMech.smali`** file.
2. Use the search feature to find this line of code:
   🔍 `isDisableAppDimLayer()`
3. You will find it in **2 different locations** (usually around lines 1200+ and 6600+).
4. In **BOTH** locations, add the code `const/4 v0, 0x1` right beneath `move-result v0`, making the structure look exactly like this:

```smali
    invoke-static {}, Lcom/oplusos/systemui/common/feature/KeyguardFeatureOption;->isDisableAppDimLayer()Z
    move-result v0

    # --- [START] FIX PITCH BLACK SCREEN ---
    const/4 v0, 0x1
    # --- [END] FIX PITCH BLACK SCREEN ---
```
*(Explanation: This modification manipulates the parameter in memory, tricking the system into thinking the "Disable Dim Layer" setting is True/1, which forces the system to abort rendering the black overlay).*

---

## Final Stage: Repack & Sign
> [!WARNING]  
> **NEVER USE THE AUTO-SIGN FEATURE!**  
> The signature on the *SystemUI* file is a crucial identity mark. Auto-signing it will alter the signature and cause your phone to Bootloop (stuck on the boot logo).

1. Click the Save button in the MT Manager text editor.
2. Exit the editor (*Back*).
3. When the `Update file in the archive?` dialogue pops up, make sure the **Auto Sign box is UNCHECKED**.
4. Click OK.
5. Push/install your modified `SystemUI.apk` and *Reboot* the device.
