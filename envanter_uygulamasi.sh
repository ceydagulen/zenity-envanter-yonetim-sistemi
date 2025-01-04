#!/bin/bash



# 1. Dosya Kontrolü
function dosyaKontrol() {
    if [ ! -f depo.csv ]; then
        touch depo.csv
        echo "ID,Ad,Stok,Fiyat,Kategori" > depo.csv
    fi
    if [ ! -f kullanici.csv ]; then
        touch kullanici.csv
        echo "KullaniciAdi,Parola,Rol" > kullanici.csv
    fi
    if [ ! -f log.csv ]; then
        touch log.csv
        echo "HataNo,Tarih,Kullanici,HataMesaji" > log.csv
    fi
}


# 2. Giriş Fonksiyonu
function giris() {
    while true; do
        KULLANICI=$(zenity --entry --title="Giriş" --text="Kullanıcı Adı:")
        DENEME_HAKKI=3

        while [ $DENEME_HAKKI -gt 0 ]; do
            PAROLA=$(zenity --password --title="Giriş")
            if grep -q "^$KULLANICI," kullanici.csv; then
                # Kullanıcı bilgilerini al
                KAYIT=$(grep "^$KULLANICI," kullanici.csv)
                STORED_PASS=$(echo "$KAYIT" | cut -d',' -f2)
                ROL=$(echo "$KAYIT" | cut -d',' -f3)

                # Şifreyi hash'le ve karşılaştır
                MD5_PASS=$(echo -n "$PAROLA" | md5sum | awk '{print $1}')
                if [ "$MD5_PASS" == "$STORED_PASS" ]; then
                    zenity --info --text="Giriş Başarılı: $ROL"
                    menuGenel "$KULLANICI" "$ROL"
                    return  # Başarılı giriş, fonksiyondan çık
                else
                    # Hatalı şifre
                    DENEME_HAKKI=$((DENEME_HAKKI - 1))
                    hataKaydi "$KULLANICI" "Hatalı Şifre"
                    zenity --error --text="Hatalı Şifre! Kalan Hakkınız: $DENEME_HAKKI"
                fi
            else
                # Kullanıcı bulunamadı
                hataKaydi "$KULLANICI" "Kullanıcı Bulunamadı"
                zenity --error --text="Kullanıcı Bulunamadı!"
                break
            fi

            if [ $DENEME_HAKKI -eq 0 ]; then
                sed -i "s/^$KULLANICI,.*/$KULLANICI,$STORED_PASS,kilitli/" kullanici.csv
                hataKaydi "$KULLANICI" "Hesap Kilitlendi"
                zenity --error --text="Hesap kilitlendi. Yöneticiyle iletişime geçin."
                break
            fi
        done
    done
}

# 3.Genel Menü Fonksiyonu

function menuGenel() {
    local KULLANICI=$1
    local ROL=$2

    while true; do
        SECIM=$(zenity --list --title="Genel Menü" --column="İşlemler" \
        "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil" "Rapor Al" \
        "Kullanıcı Yönetimi" "Program Yönetimi" "Takvim Göster" "Çıkış")

        case $SECIM in
            "Ürün Ekle")
                if [ "$ROL" == "Yonetici" ]; then
                    urunEkle "$KULLANICI"
                else
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                fi
                ;;
            "Ürün Listele")
                urunListele
                ;;
            "Ürün Güncelle")
                if [ "$ROL" == "Yonetici" ]; then
                    urunGuncelle "$KULLANICI"
                else
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                fi
                ;;
            "Ürün Sil")
                if [ "$ROL" == "Yonetici" ]; then
                    urunSil "$KULLANICI"
                else
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                fi
                ;;
            "Rapor Al")
                raporAl
                ;;
            "Kullanıcı Yönetimi")
                if [ "$ROL" == "Yonetici" ]; then
                    kullaniciYonetimi "$KULLANICI"
                else
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                fi
                ;;
            "Program Yönetimi")
                if [ "$ROL" == "Yonetici" ]; then
                    programYonetimi
                else
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                fi
                ;;
            "Takvim Göster")
                takvimGoster
                ;;
            "Çıkış")
                cikis
                ;;
            *)
                zenity --error --text="Geçersiz Seçim!"
                ;;
        esac
    done
}

# 4. Program Yönetimi

function programYonetimi() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    while true; do
        SECIM=$(zenity --list --title="Program Yönetimi" --column="İşlemler" \
        "Diskte Kapladığı Alan Gösterimi" "Diske Yedek Alma" "Hata Kayıtlarını Görüntüleme" "Geri Dön")

        case $SECIM in
            "Diskte Kapladığı Alan Gösterimi") diskAlaniGoster ;;
            "Diske Yedek Alma") yedekAl ;;
            "Hata Kayıtlarını Görüntüleme") hataKayitlariniGoster ;;
            "Geri Dön") break ;;
            *) zenity --error --text="Geçersiz Seçim!" ;;
        esac
    done
}

function diskAlaniGoster() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."

    ALAN=$(du -sh . 2>/dev/null)
    zenity --info --title="Diskte Kapladığı Alan" --text="Proje klasörünün kapladığı alan:\n$ALAN"
}

function yedekAl() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."
    
    TARAYICI=$(zenity --file-selection --directory --title="Yedeklemek için bir dizin seçin")
    if [ -z "$TARAYICI" ]; then
        zenity --error --text="Hiçbir dizin seçilmedi, işlem iptal edildi."
        return
    fi

    TAR_FILE="$TARAYICI/backup_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$TAR_FILE" depo.csv kullanici.csv log.csv 2>/dev/null
    zenity --info --text="Yedekleme tamamlandı:\n$TAR_FILE"
}

function hataKayitlariniGoster() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."

    if [ -s log.csv ]; then
        zenity --text-info --title="Hata Kayıtları" --filename=log.csv
    else
        zenity --info --text="Hata kaydı bulunmamaktadır."
    fi
}



# 5. Kullanıcı Yönetimi

function kullaniciYonetimi() {
    local KULLANICI=$1
    while true; do
        SECIM=$(zenity --list --title="Kullanıcı Yönetimi" --column="İşlemler" \
        "Yeni Kullanıcı Ekle" "Kullanıcıları Listele" "Kullanıcı Güncelle" "Kullanıcı Sil" "Şifre Sıfırla" "Hesap Aç" "Geri Dön")

        case $SECIM in
            "Yeni Kullanıcı Ekle") yeniKullaniciEkle "$KULLANICI" ;;
            "Kullanıcıları Listele") kullanicilariListele ;;
            "Kullanıcı Güncelle") kullaniciGuncelle "$KULLANICI" ;;
            "Kullanıcı Sil") kullaniciSil "$KULLANICI" ;;
            "Şifre Sıfırla") sifreSifirla "$KULLANICI" ;;
            "Hesap Aç") hesapAc "$KULLANICI" ;;
            "Geri Dön") break ;;
            *) zenity --error --text="Geçersiz Seçim!" ;;
        esac
    done
}

function hesapAc() {
    local YONETICI=$1
    local KULLANICI=$(zenity --entry --title="Hesap Açma" --text="Açılacak Kullanıcı Adı:")
    
    if grep -q "^$KULLANICI," kullanici.csv; then
        sed -i "s/^$KULLANICI,.*kilitli\$/$KULLANICI,827ccb0eea8a706c4c34a16891f84e7b,Kullanici/" kullanici.csv
        hataKaydi "$YONETICI" "$KULLANICI hesabı açıldı"
        zenity --info --text="Hesap başarıyla açıldı: $KULLANICI"
    else
        hataKaydi "$YONETICI" "$KULLANICI bulunamadı"
        zenity --error --text="Kullanıcı bulunamadı!"
    fi
}



function yeniKullaniciEkle() {
    local KULLANICI=$1
    FORM=$(zenity --forms --title="Yeni Kullanıcı Ekle" --text="Kullanıcı Bilgileri" \
    --add-entry="Kullanıcı Adı" --add-password="Parola" --add-list="Rol" --list-values="Yonetici|Kullanici")
    IFS='|' read -r KULLANICI_ADI PAROLA ROL <<< "$FORM"

    if [ -z "$KULLANICI_ADI" ] || [ -z "$PAROLA" ] || [ -z "$ROL" ]; then
        zenity --error --text="Tüm alanları doldurmanız gerekiyor!"
        return
    fi

    HASHLI_SIFRE=$(echo -n "$PAROLA" | md5sum | awk '{print $1}')
    echo "$KULLANICI_ADI,$HASHLI_SIFRE,$ROL" >> kullanici.csv
    hataKaydi "$KULLANICI" "Yeni kullanıcı eklendi: $KULLANICI_ADI"
    zenity --info --text="Yeni kullanıcı başarıyla eklendi: $KULLANICI_ADI"
    yedekle
}



function kullaniciGuncelle() {
    local KULLANICI=$1

    # Kullanıcının rolünü öğren
    KULLANICI_ROL=$(grep "^$KULLANICI," kullanici.csv | cut -d',' -f3)

    # Eğer rolü "Yonetici" değilse işlemi engelle
    if [ "$KULLANICI_ROL" != "Yonetici" ]; then
        logHata "$KULLANICI" "Yetkisiz İşlem" "Kullanıcı güncelleme yetkisi yok"
        zenity --error --text="Yetkiniz yok! Kullanıcı güncelleme işlemini yalnızca yöneticiler yapabilir."
        return
    fi

    local GUNCELLENECEK_KULLANICI=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellenecek kullanıcı adını girin:")

    if grep -q "^$GUNCELLENECEK_KULLANICI," kullanici.csv; then
        FORM=$(zenity --forms --title="Kullanıcı Güncelle" --text="Yeni Bilgileri Girin" \
        --add-entry="Yeni Kullanıcı Adı" --add-password="Yeni Parola" --add-list="Rol" --list-values="Yonetici|Kullanici")
        IFS='|' read -r YENI_KULLANICI_ADI YENI_PAROLA YENI_ROL <<< "$FORM"

        if [ -z "$YENI_KULLANICI_ADI" ] || [ -z "$YENI_PAROLA" ] || [ -z "$YENI_ROL" ]; then
            logHata "$KULLANICI" "Eksik Bilgi" "Kullanıcı güncelleme için eksik alan bırakıldı"
            zenity --error --text="Tüm alanları doldurmanız gerekiyor!"
            return
        fi

        HASHLI_SIFRE=$(echo -n "$YENI_PAROLA" | md5sum | awk '{print $1}')
        
        # Güncelleme işlemi
        sed -i "s/^$GUNCELLENECEK_KULLANICI,.*/$YENI_KULLANICI_ADI,$HASHLI_SIFRE,$YENI_ROL/" kullanici.csv

        # Log kaydı ekle
        logIslem "$KULLANICI" "Kullanıcı Güncelleme" "$GUNCELLENECEK_KULLANICI" "$GUNCELLENECEK_KULLANICI" "$YENI_KULLANICI_ADI, $HASHLI_SIFRE, $YENI_ROL"

        zenity --info --text="Kullanıcı başarıyla güncellendi: $YENI_KULLANICI_ADI"
    else
        logHata "$KULLANICI" "Kullanıcı Bulunamadı" "Güncellenmek istenen kullanıcı bulunamadı: $GUNCELLENECEK_KULLANICI"
        zenity --error --text="Kullanıcı bulunamadı!"
    fi
}



function kullaniciSil() {

    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    AD=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcının adını girin:")
    if grep -q "^$AD," kullanici.csv; then
        if zenity --question --text="Bu kullanıcıyı silmek istediğinizden emin misiniz?"; then
            sed -i "/^$AD,/d" kullanici.csv
            zenity --info --text="Kullanıcı Başarıyla Silindi!"
        fi
    else
        zenity --error --text="Kullanıcı Bulunamadı!"
    fi
}

function hesapAc() {
    local KULLANICI=$(zenity --entry --title="Hesap Açma" --text="Açılacak Kullanıcı Adı:")
    if grep -q "^$KULLANICI," kullanici.csv; then
        sed -i "s/^$KULLANICI,.*/$KULLANICI,827ccb0eea8a706c4c34a16891f84e7b,Yonetici/" kullanici.csv
        zenity --info --text="Hesap başarıyla açıldı: $KULLANICI"
    else
        zenity --error --text="Kullanıcı bulunamadı!"
    fi
}






# HATA KAYDI

function hataKaydi() {
    local KULLANICI=$1
    local MESAJ=$2

    # İlerleme çubuğu
    ilerlemeCubugu "Hata Kaydı İşlemi" "Hata kaydediliyor..."

    # Hata numarasını belirle
    HATA_NO=$(tail -n 1 log.csv | cut -d',' -f1)

    # HATA_NO'yu kontrol et, boşsa 0 yap
    if [[ -z "$HATA_NO" ]] || ! [[ "$HATA_NO" =~ ^[0-9]+$ ]]; then
        HATA_NO=0
    fi

    # Hata numarasını artır
    HATA_NO=$((HATA_NO + 1))

    # Tarih formatını düzenle
    TARIH=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Hata kaydını log dosyasına yaz
    echo "$HATA_NO,$TARIH,$KULLANICI,$MESAJ" >> log.csv
}









#  Şifre Sıfırlama Fonksiyonu
function sifreSifirla() {
    local YONETICI=$1
    local KULLANICI=$(zenity --entry --title="Şifre Sıfırlama" --text="Şifresi sıfırlanacak kullanıcı adını girin:")

    if grep -q "^$KULLANICI," kullanici.csv; then
        local YENI_SIFRE=$(zenity --password --title="Yeni Şifre" --text="Yeni şifreyi girin:")
        local HASHLI_SIFRE=$(echo -n "$YENI_SIFRE" | md5sum | awk '{print $1}')

        sed -i "s/^$KULLANICI,.*/$KULLANICI,$HASHLI_SIFRE,Yonetici/" kullanici.csv
        hataKaydi "$YONETICI" "$KULLANICI şifresi sıfırlandı"
        zenity --info --text="Şifre başarıyla sıfırlandı: $KULLANICI"
    else
        hataKaydi "$YONETICI" "$KULLANICI bulunamadı"
        zenity --error --text="Kullanıcı bulunamadı!"
    fi
}


function takvimGoster() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."

    SEÇİLEN_TARİH=$(zenity --calendar --title="Takvim Göster" --text="Bir tarih seçin:" --date-format=%Y-%m-%d)
    if [ -n "$SEÇİLEN_TARİH" ]; then
        zenity --info --text="Seçilen Tarih: $SEÇİLEN_TARİH"
    else
        zenity --error --text="Hiçbir tarih seçilmedi."
    fi
}



#  İlerleme Çubuğu Fonksiyonu
function ilerlemeCubugu() {
    local BASLIK=$1
    local MESAJ=$2
    ( 
        echo "50"; sleep 2
         echo "80"; sleep 2
        echo "100"; sleep 2
     
    ) | zenity --progress --title="$BASLIK" --text="$MESAJ" --auto-close --width=300
}


# Raporlama Fonksiyonu
function raporAl() {

    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."
    
    SECIM=$(zenity --list --title="Raporlama" --column="Rapor Türü" \
    "Stokta Azalan Ürünler" "En Yüksek Stok Miktarı")

    case $SECIM in
        "Stokta Azalan Ürünler") azalanStoklar ;;
        "En Yüksek Stok Miktarı") yuksekStoklar ;;
        *) zenity --error --text="Geçersiz seçim!" ;;
    esac
}

function azalanStoklar() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    ESIK=$(zenity --entry --title="Stokta Azalan Ürünler" --text="Eşik stok değerini girin:" --entry-text="10")
    if [[ -z "$ESIK" || ! $ESIK =~ ^[0-9]+$ ]]; then
        zenity --error --text="Geçerli bir sayı girin!"
        return
    fi

    AZALAN=$(awk -F',' -v esik=$ESIK '$3 < esik {print $0}' depo.csv)

    if [ -z "$AZALAN" ]; then
        zenity --info --text="Eşik değerin altında stokta azalan ürün bulunamadı."
    else
        echo "$AZALAN" | zenity --text-info --title="Stokta Azalan Ürünler"
    fi
}


function yuksekStoklar() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    ESIK=$(zenity --entry --title="En Yüksek Stok Miktarı" --text="Eşik stok değerini girin:" --entry-text="100")
    if [[ -z "$ESIK" || ! $ESIK =~ ^[0-9]+$ ]]; then
        zenity --error --text="Geçerli bir sayı girin!"
        return
    fi

    YUKSEK=$(awk -F',' -v esik=$ESIK '$3 > esik {print $0}' depo.csv)

    if [ -z "$YUKSEK" ]; then
        zenity --info --text="Eşik değerin üzerinde stoklu ürün bulunamadı."
    else
        echo "$YUKSEK" | zenity --text-info --title="En Yüksek Stok Miktarı"
    fi
}






#  Ürün İşlemleri

function urunEkle() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."

    FORM=$(zenity --forms --title="Ürün Ekle" --text="Ürün Bilgileri" \
    --add-entry="Ürün Adı" --add-entry="Stok" --add-entry="Birim Fiyat" --add-entry="Kategori")
    IFS='|' read -r AD STOK FIYAT KATEGORI <<< "$FORM"

    if ! [[ $STOK =~ ^[0-9]+$ ]] || ! [[ $FIYAT =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        hataKaydi "$KULLANICI" "Geçersiz Stok veya Fiyat"
        zenity --error --text="Stok ve Fiyat pozitif sayı olmalıdır."
        return
    fi

    if echo "$AD" | grep -q ' '; then
        hataKaydi "$KULLANICI" "Boşluk İçeren Ürün Adı"
        zenity --error --text="Ürün adında boşluk bulunamaz."
        return
    fi

    if grep -q "$AD" depo.csv; then
        hataKaydi "$KULLANICI" "Aynı İsimde Ürün"
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
        return
    fi

    # ID Hesaplama
    if [ -s depo.csv ] && [ $(wc -l < depo.csv) -gt 1 ]; then
        # Depo.csv doluysa ID'yi hesapla
        ID=$(tail -n 1 depo.csv | cut -d',' -f1)
        if [[ $ID =~ ^[0-9]+$ ]]; then
            ID=$((ID + 1))
        else
            ID=1
        fi
    else
        # Depo.csv boşsa ID'yi 1 olarak başlat
        ID=1
    fi

    # Ürün bilgilerini dosyaya ekleme
    echo "$ID,$AD,$STOK,$FIYAT,$KATEGORI" >> depo.csv
    zenity --info --text="Ürün Başarıyla Eklendi!"
    yedekle
}


function urunListele() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    cat depo.csv | zenity --text-info --title="Ürün Listesi"
    
}

function urunGuncelle() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    local KULLANICI=$1
    AD=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:")
    if grep -q "^.*,$AD," depo.csv; then
        FORM=$(zenity --forms --title="Yeni Bilgiler" --text="Ürünü Güncelle" \
        --add-entry="Yeni Stok" --add-entry="Yeni Birim Fiyat")

        IFS='|' read -r YENI_STOK YENI_FIYAT <<< "$FORM"

        # Eski satırı bul ve ID'yi koru
        SATIR=$(grep "^.*,$AD," depo.csv)
        ID=$(echo "$SATIR" | cut -d',' -f1)
        KATEGORI=$(echo "$SATIR" | cut -d',' -f5)

        # Yeni satır oluştur
        YENI_SATIR="$ID,$AD,$YENI_STOK,$YENI_FIYAT,$KATEGORI"

        # Güncelle
        sed -i "/^.*,$AD,/c\\$YENI_SATIR" depo.csv
        zenity --info --text="Ürün Güncellendi:\n\n$YENI_SATIR"
    else
        zenity --error --text="Ürün Bulunamadı!"
    fi
    yedekle
}
    

function urunSil() {
    local KULLANICI=$1
    ilerlemeCubugu "Ürün Ekleme İşlemi" "Ürün bilgileri işleniyor..."


    local KULLANICI=$1
    AD=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını girin:")
    if grep -q "$AD" depo.csv; then
        if zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?"; then
            sed -i "/$AD/d" depo.csv
            zenity --info --text="Ürün Silindi!"
        fi
    else
        hataKaydi "$KULLANICI" "Ürün Bulunamadı"
        zenity --error --text="Ürün Bulunamadı!"
    fi
    yedekle
}

#  Çıkış Fonksiyonu


function cikis() {
    if zenity --question --text="Sistemden çıkmak istediğinize emin misiniz?"; then
        exit
    fi
}

function yedekle() {
    cp kullanici.csv yedek_kullanicilar.csv
    cp depo.csv yedek_urunler.csv
}




# Script Başlangıcı
dosyaKontrol
giris
menuGenel
programYonetimi
kullaniciYonetimi

