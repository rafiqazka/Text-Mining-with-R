Persepsi Masyarakat Terhadap Vaksin COVID-19 di Indonesia // dengan bantuan Wordcloud & Sentiment Analysis menggunakan metode Text Mining pada Software R
Oleh: Dhiya' Rafiq Azka (14417044) dalam rangka menyelesaikan UAS mata kuliah Data Science and Machine Learning (MR4103)

## Latar Belakang
+ Pandemi yang diakibatkan oleh virus COVID-19 adalah salah satu peristiwa paling berdampak besar pada abad ke-21 karena hampir seluruh sektor kehidupan terkena dampak dari adanya pandemi COVID-19. 

+ Salah satu usaha yang dilakukan untuk melewati masa sulit akibat pandemi COVID-19 adalah dengan membuat vaksin COVID-19 untuk mengubah hidup manusia di seluruh dunia menjadi sedia kala seperti sebelum adanya pandemi COVID-19.

+ Per 13 Desember tahun 2020, Indonesia telah memiliki beberapa vaksin, yaitu vaksin Bio Farma, vaksin Moderna, vaksin Pfizer, vaksin Sinopharm, dan vaksin Sinovac. 

+ Pengadaan vaksin COVID-19 menuai pro dan kontra di masyarakat.

+ Pemerintah sebagai pemangku kepentingan yang mengurus hajat hidup orang banyak harus dapat mengambil kebijakan dan keputusan berdasarkan suara rakyat (terkait vaksin COVID-19).

## Struktur Data
Data diambil dari [Twitter](https://www.twitter.com) terhadap tweet yang mengandung kata kunci “Vaksin COVID Indonesia”.
Terdapat 1000 tweets yang diambil pada tanggal 12 Desember 2020 dengan 16 variabel pada dataset-nya. Seluruh tweets tersebut merupakan 1000 tweets terakhir yang di-post di Twitter hingga tanggal 12 Desember 2020

```
text: Isi tweet
favorited: Status favorite pada tweet tersebut (telah di-favorite atau belum)
favoriteCount: Jumlah favorite pada tweet tersebut
replytoSN: Reply terhadap pembuat tweet pada variabel text
created: Tanggal dibuatnya tweet pada variabel text
truncated: Status terpotongnya tweet pada variabel text
replytoSID: Reply terhadap orang yang me-reply tweet pada variabel text
id: Identifier tweet
replytoUID: Identifier suatu tweet yang me-reply tweet pada variabel text
statusSource: Status beserta link tweet pada variabel text
screenName: Nama akun dari pembuat tweet
retweetCount: Jumlah retweet dari tweet tersebut
isRetweet: Status tweet tersebut merupakan retweet atau tweet original
Retweeted: Status retweet pada tweet tersebut (telah di-retweet atau belum)
longitude: Koordinat pembuat tweet pada saat melakukan tweet
latitude: Koordinat pembuat tweet pada saat melakukan tweet
```

## Hasil
Hasil dari analisis sentimen terhadap data tweets:
+ Sentimen paling banyak dari tweets adalah netral, disusul dengan negatif, kemudian positif.
+ Skor sentimen 0 memiliki jumlah tweet paling banyak, diikuti dengan skor sentimen 1, kemudian -1.
