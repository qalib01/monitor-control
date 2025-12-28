# Android TV Nəzarət sistemi (ADB)

Bu layihə yerli (lokal/daxili) şəbəkə üzərindən ADB (Android Debug Bridge) vasitəsilə eyni vaxtda birdən çox Android TV ƏS üzərində qurulan hər növ TV-i (TCL, KiVi və s.) idarə etmək üçün Bash skripti təmin edir. O, toplu yandırmaq-söndürmək nəzarətini, fərdi URL yönləndirməsini, Android TV-nin defolt ana səhifəsinin yönləndirilməsini və avtomatlaşdırılmış ardıcıllığı dəstəkləyir. Qeyd: Bu skriptə əlavə edilmiş txt faylında olan cihazlar ardıcıl olaraq işə düşür hamısını eyni anda idarə etmir.


## 🚀 Xüsusiyyətlər

* **Toplu monitor idarəsi:** Standby rejimində olan bütün TVləri yandırmaq və ya söndürmək mümkündür.
* **URL yönləndirməsi:** Hər bir TV özünə uyğun olan txt faylında qeyd olunmuş linkə yönləndirilir.
* **Avtomatlaşdırılmış idarə:** Yandırma -> Gözləmə (5 saniyə) -> Linkə yönləndirmə.
* **Fərqli yönləndirmə:** Hər bir TV-i txt faylından kənar sadəcə İP adresini qeyd edərək yönləndirmə.


## 📋 Tələblər

* **ADB Platform Aləti:** `adb.exe` və lazımi alətlərin layihə qovluğunda olduğundan və ya sistem PATH-nə əlavə olunduğundan əmin olun. Windows-da System Environments-də bu əlavə edilməlidir. Ardıcıllıq: System Properties -> Advanced -> Environment Variables -> System Variables -> Path -> bu yolla Edit edib daha sonrasında yenisini əlavə edirik. Və burada qeyd olunacaq PATH məhz sizin proyekti saxladığınız yer olmalıdır. Proyekt və adb.exe (içindəki lazımi alətlər) hamısı bir qovluq içində saxlanılmalıdır. Həmin qovluğun adresini burada saxlayırıq ki, daha sonrasında yükləyəcəyimiz GitBash bu komandaları çağıra bilsin.
* **Bash Mühiti:**
    1. Linux/macOS: Öz terminalı ilə mümkündür.
    2. Windows: Gitbash (Tövsiyyə edirəm) və ya WSL istifadə edilə bilər.
* **Network/USB Debugging:** Hər bir TV-nin Developer Mode aktivləşdirilməlidir. Qeyd: Tərtibatçı seçimlərini aktivləşdirmə yolları hər bir TV üçün fərqlidir. Hər bir model üçün İnternetdə araşdırma aparmalısınız. Ancaq əksər TV-lərdə Settings -> About içində olan Version-a 7 dəfə basmaqla aktifləşdirmək olur. Developer Mode aktif olduqdan sonra qeyd olunan ayarı açmaq mümkündür.
* **İcazə verilmiş cihazlar:** Siz hər bir televizorda bir dəfə kompüterə əl ilə icazə verməlisiniz (“Always allow from this computer” seçin və təsdiq edin. Əks təqdirdə hər dəfə TV qoşulmaq istəyəndə icazə tələb edəcək). Kompüterinizdən adb vasitəsilə TV-yə qoşulmaq istədiyiniz zaman TV ekranında təsdiqləmə dialoqu görünür, Allow düyməsini kliklədikdən sonra siz televizorunuzu idarə etmək üçün hər bir əmrdən istifadə edə bilərsiniz.


## ⚙️ Konfiqurasiya

Əsas qovluqda `ip_link_map.txt` adlı fayl yaradın. Aşağıdakı formatdan istifadə edin:

```bash
# IP_Address:Port      Gediləcək URL
192.168.1.101:5555    http://your-local-link.com/screen-1
192.168.1.102:5555    http://your-local-link.com/screen-2
# # simvolu ilə comment əlavə edə bilərsiniz. Bu script tərəfindən oxunmur
```


## 🛠 İstifadəsi

Aşağıdakı komandları istifadə edərək Gitbash-da çağırın. Qeyd: İlk növbədə Gitbash terminalı açdıqdan sonra əsas qovluğa keçid etməlisiniz. Bunu cd QOVLUQ_ADI edərək giriş edə bilərsiniz.

```bash
sh monitor_control.sh power       Bütün TVləri yandırıb söndürmək üçün istifadə olunur.
sh monitor_control.sh home        Bütün TVləri TV-in əsas ekranına (Home) qayıtmaq üçün istifadə olunur.
sh monitor_control.sh redirect    Hər TV üçün təyin edilmiş linkə yönləndirmə edir.
sh monitor_control.sh sequence    Avtomatlaşdırılmış rejimdə işləyir. Yandır -> Gözlə (5 saniyə) -> Linkə yönləndir.
```

