# classes5.dex

.class Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;
.super Landroid/content/BroadcastReceiver;
.source "OnScreenFingerprintIcon.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "FingerKeyReceiver"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;


# direct methods
.method public constructor <init>(Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;)V
    .registers 2

    iput-object p1, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;->this$0:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .registers 10
    .param p1, "context"  # Landroid/content/Context;
    .param p2, "intent"  # Landroid/content/Intent;

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    const-string v0, "OnScreenFingerprintIcon"

    .local v0, "TAG":Ljava/lang/String;
    iget-object v1, p0, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;->this$0:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;

    .local v1, "this$0":Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v2

    .local v2, "action":Ljava/lang/String;
    const-string v3, "com.rianixia.FINGER_DOWN"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_36

    invoke-virtual {v1}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->getVisibility()I

    move-result v3

    .local v3, "visibility":I
    iget-object v6, v1, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->onScreenFingerprintUiMech:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;

    .local v6, "mech":Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;
    if-eqz v3, :cond_64

    if-eqz v6, :cond_35

    invoke-virtual {v6}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->getScreenTurnedOff()Z

    move-result v3

    if-eqz v3, :cond_35

    const-string v3, "FingerKeyReceiver: FINGER_DOWN received, icon not visible, screen OFF. Handling."

    invoke-static {v0, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    new-instance v3, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver$1;

    invoke-direct {v3, p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver$1;-><init>(Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;)V

    invoke-static {v3}, Lcom/oplus/systemui/biometrics/finger/KeyguardFingerprintUtils;->updateOpticalUI(Ljava/lang/Runnable;)V

    invoke-virtual {v1}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->handleFingerprintKeyPress()V

    invoke-virtual {v6, v5}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->onFpTouch(Z)V

    :cond_35
    :goto_35
    return-void

    :cond_36
    const-string v3, "com.rianixia.FINGER_UP"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_35

    const-string v3, "FingerKeyReceiver: FINGER_UP received. Handling."

    invoke-static {v0, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v6, v1, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->onScreenFingerprintUiMech:Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;

    .restart local v6  # "mech":Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;
    const/4 v3, 0x0

    .local v3, "wasScreenOff":Z
    if-eqz v6, :cond_4c

    invoke-virtual {v6}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->getScreenTurnedOff()Z

    move-result v3

    :cond_4c
    invoke-virtual {v1}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->handleFingerprintKeyRelease()V

    if-eqz v6, :cond_54

    invoke-virtual {v6, v4}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->onFpTouch(Z)V

    :cond_54
    if-eqz v3, :cond_35

    const-string v4, "FingerKeyReceiver: FINGER_UP received, screen was off. Hiding icon."

    invoke-static {v0, v4}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    new-instance v4, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver$2;

    invoke-direct {v4, p0}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver$2;-><init>(Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon$FingerKeyReceiver;)V

    invoke-static {v4}, Lcom/oplus/systemui/biometrics/finger/KeyguardFingerprintUtils;->updateOpticalUI(Ljava/lang/Runnable;)V

    goto :goto_35

    :cond_64
    const-string v3, "FingerKeyReceiver: FINGER_DOWN received, icon visible. Handling."

    invoke-static {v0, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    invoke-virtual {v1}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintIcon;->handleFingerprintKeyPress()V

    if-eqz v6, :cond_35

    invoke-virtual {v6, v5}, Lcom/oplus/systemui/biometrics/finger/udfps/OnScreenFingerprintUiMech;->onFpTouch(Z)V

    goto :goto_35
.end method
