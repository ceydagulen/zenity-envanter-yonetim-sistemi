# 🏷️ Zenity ile Basit Envanter Yönetim Sistemi

Bu proje, **Zenity** araçlarını kullanarak geliştirilen kullanıcı dostu bir **Envanter Yönetim Sistemi**dir. **Linux Bash betiği** kullanılarak oluşturulmuş olup, **grafik arayüz** ile kolayca ürün ekleme, güncelleme, silme ve listeleme işlemleri yapılabilir.  
Ek olarak, **kullanıcı yönetimi**, **stok raporları** ve **hata loglama** gibi ek özellikler içerir.  


## 📥 **Kurulum & Çalıştırma**
**Adım 1:** **Zenity**'yi yükleyin (eğer sisteminizde yoksa):  

 sudo apt install zenity

---

## 🚀 **Özellikler**
✔ **Kullanıcı Rolleri** (Yönetici & Kullanıcı)  
✔ **Ürün Yönetimi** (Ekleme, Listeleme, Güncelleme, Silme)  
✔ **Raporlama** (Azalan Stoklar & En Yüksek Stok)  
✔ **Kullanıcı Yönetimi** (Yeni kullanıcı ekleme, düzenleme ve silme)  
✔ **Şifre Yönetimi** (Şifre sıfırlama ve hesap kilitleme)  
✔ **Hata Yönetimi** (Hata kayıtları, log dosyası)  
✔ **Disk Yönetimi** (Depo yedekleme ve disk alanı kontrolü)  



---
🎯 Nasıl Kullanılır?

📌 1. Giriş Ekranı:İlk olarak kullanıcı adı ve şifre girerek giriş yapabilirsiniz.

  <img src="resimler/giris.png" alt="Giriş Ekranı 1" width="228" height="178">    <img src="resimler/giris2.png" alt="Giriş Ekranı 2" width="228" height="178">

📌 Yönetici: Ürün ekleme, güncelleme ve kullanıcı yönetimi yapabilir.
 

📌 Kullanıcı: Sadece ürünleri listeleyebilir ve rapor alabilir.

  <img src="resimler/yetki.png" alt="Giriş Ekranı 2" width="228" height="178">

📌Kullanıcının şifreyi doğru girmek için 3 hakkı bulunmaktadır.Eğer şifre 3 defa hatalı girilirse hesap kilitlenir.Kilitli hesabı sadece yönetici, hesabı aç kısmından tekrar aktive edebilir.

<img src="resimler/hata.png" alt="Giriş Ekranı 1" width="228" height="178">           <img src="resimler/hesapac.png" alt="Giriş Ekranı 1" width="228" height="178">              

  
 
---







📌 2. Ana Menü
Kullanıcı yetkisine bağlı olarak aşağıdaki menü seçenekleri görüntülenir.

 <img src="resimler/gene.png" alt="Giriş Ekranı 1" width="228" height="178">    <img src="resimler/genel2.png" alt="Giriş Ekranı 1" width="228" height="178"> 


🔹 Ürün Ekle

🔹 Ürün Listele

🔹 Ürün Güncelle

🔹 Ürün Sil

🔹 Rapor Al

🔹 Kullanıcı Yönetimi

🔹 Program Yönetimi

🔹 Takvim Göster : Bu seçenek envanter sisteminde tarihlerin önemli olduğu için eklenmiştir.



---


📌 3. Ürün Ekleme

Ürün bilgilerini girerek envantere yeni bir ürün ekleyebilirsiniz.

 <img src="resimler/urunekle.png" alt="Giriş Ekranı 1" width="228" height="178">   <img src="resimler/ilerleme.png" alt="Giriş Ekranı 1" width="228" height="178"> 


🔹 Ürün Adı

🔹 Stok Miktarı

🔹 Birim Fiyatı


👉 Zenity Forms arayüzü ile kolay kullanım sağlanmaktadır.



---


📌 4. Ürün Listeleme

Kayıtlı ürünleri görüntülemek için "Ürün Listele" seçeneği kullanılır.

<img src="resimler/urunlistesi.png" alt="Giriş Ekranı 1" width="228" height="178">


📌 Özellikler:


✔ CSV dosyasından okunan veriler Zenity --text-info ile gösterilir.
✔ Arama ve filtreleme seçenekleri.
<br><br><br>
📌 5. Ürün Güncelleme

Bir ürünün stok miktarı veya fiyatını değiştirmek için "Ürün Güncelle" seçeneği kullanılır.

<img src="resimler/urunguncelle.png" alt="Giriş Ekranı 1" width="228" height="178">

🔹 Güncellenecek ürünün adı girilir.

🔹 Yeni stok veya fiyat bilgisi girilir.




---

📌 6. Ürün Silme
Ürün silme işlemi için kullanıcıdan onay alınır ve ardından işlem tamamlanır.

<img src="resimler/sil.png" alt="Giriş Ekranı 1" width="228" height="178">

✔ Zenity --question ile silme onayı alınır.

✔ İşlem log.csv dosyasına kaydedilir.


---
📌 7. Rapor Alma

Sistem, stok seviyelerini analiz ederek raporlama sunar.

<img src="resimler/rapor.png" alt="Giriş Ekranı 1" width="228" height="178">

🔹 Stokta Azalan Ürünler

🔹 En Yüksek Stok Miktarına Sahip Ürünler


---
📌 8. Kullanıcı Yönetimi

📌 Yalnızca Yönetici tarafından erişilebilir.

<img src="resimler/kullanıcı.png" alt="Giriş Ekranı 1" width="228" height="178">



✔ Yeni kullanıcı ekleme

✔ Kullanıcı listeleme

✔ Kullanıcı güncelleme

✔ Kullanıcı silme

---

⚙ Geliştirme Süreci

Bu proje, Bash Scripting ve Zenity GUI entegrasyonu ile geliştirilmiştir.

📌 Kullanılan Komutlar: awk, grep, chmod, df, touch, cp, mv

📌 Veri depolama formatı: CSV dosyaları (depo.csv, kullanici.csv, log.csv)

---
🎥 Demo Videosu

📌 Projenin nasıl çalıştığını görmek için aşağıdaki bağlantıya tıklayın:

🎥 Demo Videosunu İzle

---
🛠️ Sistem Gereksinimleri

✅ Linux Dağıtımı: Ubuntu, Debian, Arch, Fedora

✅ Gereksinimler: Bash, Zenity, CSV işlem desteği





📞 İletişim
📌 Geliştirici: [ceydagulen]
📌 E-posta: [ceyda_glnn_@hotmail.com]
📌 GitHub: [github.com/kullaniciadi]
