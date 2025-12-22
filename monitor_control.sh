#!/bin/bash

# --- PARAMETRLƏR ---
IP_LINK_MAP_FILE="ip_link_map.txt" 
ADB_PATH="./adb"
# Vergüllə ayrılmış hədəf IP-ləri saxlayır
TARGET_DEVICES="" 

# --- FUNKSIYALAR ---

# Cihazların Siyahısını Hazırlayan Köməkçi Funksiya
get_device_list() {
    if [[ -n "$TARGET_DEVICES" ]]; then
        # İstifadəçi xüsusi IP-lər daxil edibsə, onları vergüllə ayırıb siyahı hazırlayırıq
        echo "$TARGET_DEVICES" | tr ',' '\n'
    else
        # Əks halda, bütün cihazları IP_LINK_MAP_FILE-dan götürürük
        # (Yalnız IP:PORT hissəsini çıxarır)
        awk '!/^#/ && !/^$/ {print $1}' "$IP_LINK_MAP_FILE"
    fi
}

# Ümumi əmr göndərən funksiya (universal, home, power)
send_adb_command_universal() {
    COMMAND=$1
    echo "--- Ümumi Komanda: $COMMAND ---"

    DEVICES=$(get_device_list)
    
    # get_device_list tərəfindən hazırlanan siyahı üzərində dövr edir
    for DEVICE_IP in $DEVICES
    do
        echo "-> $DEVICE_IP üçün icra edilir..."
	
        # İcra: Qoşul, Əmr Göndər
        $ADB_PATH connect $DEVICE_IP > /dev/null 2>&1
        $ADB_PATH -s $DEVICE_IP shell "$COMMAND"
        $ADB_PATH disconnect $DEVICE_IP > /dev/null 2>&1
    done
    echo "--------------------------"
}


# Hər bir TV-yə fərdi link göndərən funksiya
send_adb_command_redirect_link() {
    echo "--- Fərdi Link Yönləndirilməsi Başlayır ---"
    
    DEVICES=$(get_device_list)

    # Fayldan oxumaq əvəzinə, hədəf IP-lər üzərində dövr edirik
    for DEVICE_IP in $DEVICES
    do
        # Fayldan fərdi URL-i çıxarırıq
        INTERNAL_URL=$(grep "^$DEVICE_IP" "$IP_LINK_MAP_FILE" | awk '{print $2}')

        if [ -z "$INTERNAL_URL" ]; then
             echo "XƏBƏRDARLIQ: $DEVICE_IP üçün link tapılmadı, ötürülür."
             continue
        fi

        COMMAND="am start -a android.intent.action.VIEW -d \"$INTERNAL_URL\""
        
        echo "-> $DEVICE_IP üçün link göndərilir: $INTERNAL_URL"

        $ADB_PATH connect $DEVICE_IP > /dev/null 2>&1
        $ADB_PATH -s $DEVICE_IP shell "$COMMAND"
        $ADB_PATH disconnect $DEVICE_IP > /dev/null 2>&1
        
    done
    echo "--------------------------"
}

# Avtomatik Ardıcıllıq Funksiyası (Power ON -> Redirect)
send_automatic_sequence() {
    
    echo "--- Avtomatik Ardıcıllıq Başlayır (Yandır -> Yönləndir) ---"
    
    DEVICES=$(get_device_list)

    # Fayldan oxumaq əvəzinə, hədəf IP-lər üzərində dövr edirik
    for DEVICE_IP in $DEVICES
    do
        echo "========================================"
        echo "Cihaz: $DEVICE_IP üçün Ardıcıllıq Başlayır"
        
        # 1. TV-ni Yandır (Power ON)
        echo "1. Power ON (5s gözlə)"
        $ADB_PATH connect $DEVICE_IP > /dev/null 2>&1
        $ADB_PATH -s $DEVICE_IP shell "input keyevent 26"
        sleep 5 
        
        # 2. Fərdi Linkə Yönləndir
        INTERNAL_URL=$(grep "^$DEVICE_IP" "$IP_LINK_MAP_FILE" | awk '{print $2}')
        if [ -z "$INTERNAL_URL" ]; then
             echo "XƏBƏRDARLIQ: Link tapılmadı, bu cihaz ötürülür."
             continue
        fi
        
        echo "2. Linkə Yönləndir ($INTERNAL_URL)"
        $ADB_PATH -s $DEVICE_IP shell "am start -a android.intent.action.VIEW -d \"$INTERNAL_URL\""
        sleep 5
        
        # 4. Qoşulmanı Kəs
        $ADB_PATH disconnect $DEVICE_IP > /dev/null 2>&1
        echo "========================================"
        
    done
    echo "--- Ardıcıllıq Başa Çatdı ---"
}


# --- İSTİFADƏÇİ KOMANDALARI VƏ İP TƏYİNATI ---

# Əgər 2-ci parametr vergüllə ayrılmış IP siyahısıdırsa, onu qeyd edirik
if [[ "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(,[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?)*$ ]]; then
    TARGET_DEVICES=$(echo "$2" | tr -d ' ' | tr -d '\n')
fi

# Əsas Komandalar
case "$1" in
    "power")
        send_adb_command_universal "input keyevent 26"
        ;;
    "home")
        send_adb_command_universal "input keyevent 3"
        ;;
    "redirect")
        send_adb_command_redirect_link
        ;;
    "sequence")
        send_automatic_sequence
        ;;
    *)
        echo "İstifadə: $0 [power | home | redirect | sequence] [IP1:port,IP2:port,...]"
        echo ""
        echo "Əmrlər:"
        echo "  power: Yandırır/Söndürür."
        echo "  home: Ana səhifəyə yönləndirir."
        echo "  redirect: 'ip_link_map.txt' faylındakı fərdi linklərə yönləndirir."
        echo "  sequence: Yandır -> 5s gözlə -> Fərdi linkə yönləndir -> 5s gözlə -> Söndür ardıcıllığını icra edir."
        echo ""
        echo "İP Seçimi (İsteğe Bağlı):"
        echo "  Əgər İP daxil etməsəniz, bütün cihazlar üzərində icra olunur."
        echo "  Nümunə: $0 power 192.168.1.101:5555,192.168.1.105:5555"
        ;;
esac