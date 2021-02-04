# Panggil seluruh library yang dibutuhkan untuk analisis sentimen
library(devtools)
devtools::install_github("nurandi/katadasaR")
library(katadasaR)
library(rtweet)
library(twitteR)
library(tidytext)
library(textclean)
library(wordcloud)
library(tidyr)
library(dplyr)
library(stringr)
library(tidyverse)
library(stopwords)
library(readxl)
library(RCurl)
library(tokenizers)
library(tm)
library(reshape)
library(plyr)

# Akses data tweet dari Twitter
reqURL <- "http://api.twitter.com/oath/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
CUSTOMER_KEY <- "q4Yccg2KIno1Pff0dOsKbA2RB" #diisi sesuai dengan data yang diberikan Twitter
ACCESS_TOKEN <- "1471672230-7TKNN3cuuFG1G8JlyRO0bwy3schnnxu50z4GuCB" #diisi sesuai dengan data yang diberikan Twitter
CUSTOMER_SECRET <- "0PJgaCurPorQXkSclIQcFmcE0bBNprGzwqo4W4e6EuIzQf4CV7" #diisi sesuai dengan data yang diberikan Twitter
ACCESS_secret <- "MivFNO8rsUlqnown3D5yYBgHqlSZOhssVHIhZL7rFHoDT" #diisi sesuai dengan data yang diberikan Twitter
setup_twitter_oauth(CUSTOMER_KEY, CUSTOMER_SECRET, ACCESS_TOKEN, ACCESS_secret)
1

# Kata kunci pencarian data
datatweet <- searchTwitteR("vaksin covid indonesia",
                           n=1000,
                           retryOnRateLimit =1)

tweet.df <- twListToDF(datatweet)
unclean_tweet <- tweet.df$text
unclean_tweet <- unique(unclean_tweet)


# ------------------------- Prapemrosesan data -------------------------
# Hapus link
clean_tweet <- str_replace_all(unclean_tweet, "https://t.co/[a-z,A-Z,0-9]*","")
clean_tweet <- str_replace_all(clean_tweet, "http://t.co/[a-z,A-Z,0-9]*","")

# Hapus retweet, hashtag, dan mention
clean_tweet <- str_replace(clean_tweet,"RT @[a-z,A-Z]*: ","")
clean_tweet <- str_replace_all(clean_tweet,"#[a-z,A-Z]*","")
clean_tweet <- str_replace_all(clean_tweet,"@[a-z,A-Z]*","")

# Hapus tanda baca, emoji, dan angka
clean_tweet <- gsub("&amp", " ", clean_tweet)
clean_tweet <- gsub("[[:punct:]]", " ", clean_tweet)
clean_tweet <- gsub("[[:digit:]]", " ", clean_tweet)
clean_tweet <- gsub("\\<U+...>"," ", clean_tweet)

# Case folding
clean_tweet <- tolower(clean_tweet)

# Hapus white space
clean_tweet <- stripWhitespace(clean_tweet)
clean_tweet <- gsub("^ ", "", clean_tweet) # remove blank spaces at the beginning
clean_tweet <- gsub(" $", "", clean_tweet) # remove blank spaces at the end

# Hapus kata-kata yang menjadi keywords pencarian
clean_tweet <- gsub("vaksin", "", clean_tweet)
clean_tweet <- gsub("covid", "", clean_tweet)
clean_tweet <- gsub("indonesia", "", clean_tweet)

# Tokenisasi
word.list <- str_split(clean_tweet, '\\s+')
words <- unlist(word.list)

# Ubah internet slang menjadi kata baku
urlfile<-'https://raw.githubusercontent.com/nasalsabila/kamus-alay/master/colloquial-indonesian-lexicon.csv'
lex<-read.csv(urlfile)


clean_tweet <- replace_internet_slang(clean_tweet, slang = paste0("\\b",
                                                                  lex$slang, "\\b"),
                                      replacement = lex$formal, ignore.case = TRUE)

# Hapus stopwords
urlfile<-'https://raw.githubusercontent.com/masdevid/ID-Stopwords/master/id.stopwords.02.01.2016.txt'
stopwordsbahasa<-read.delim(urlfile, header = FALSE, stringsAsFactors=FALSE)
colnames(stopwordsbahasa) <- "stopwordsbahasaid"
stopwordsbahasa <- as.character(stopwordsbahasa$stopwordsbahasaid)

clean_tweet <- removeWords(clean_tweet, stopwordsbahasa)


# Proses stemming terhadap data tweet
clean_tweet <- as.character(clean_tweet)

stemming <- function(x){
  paste(lapply(x,katadasar),collapse = " ")}

clean_tweet <- lapply(tokenize_words(clean_tweet[]), stemming)

# Buat Wordcloud
require(wordcloud)
lex.corpus <- Corpus(VectorSource(clean_tweet))
lex.dtm <- DocumentTermMatrix(lex.corpus)
m <- as.matrix(lex.dtm)
v <- sort(colSums(m), decreasing=TRUE)
d <- data.frame(word = names(v), freq=v)

wordcloud(words= d$word, 
          freq=d$freq, 
          min.freq = 1, 
          max.words = 100, 
          random.order=FALSE, 
          rot.per=0.35,
          colors = brewer.pal (name = "Dark2", 50),
          scale=c(2.5,0.5))

# ------------------------- Analisis sentimen -------------------------

# Buka file terkait sentimen

pos.words <- scan("D:/Apiq/Tingkat 2, 3, 4 MRI/Semester 7/Data Science and Machine Learning/positive-words.csv", what = 'character')
neg.words <- scan("D:/Apiq/Tingkat 2, 3, 4 MRI/Semester 7/Data Science and Machine Learning/negative-words.csv", what = 'character')

# Buat fungsi untuk analisis sentiment
sentiment.score = function(sentences, pos.words, neg.words, .progress = 'none')
{
  # Akan dihasilkan vektor yang berisi kalimat. Plyr akan mengurus list
  # atau vektor sebagai "l"
  # dibutuhkan array sederhana ("a") yang berisi skor, maka digunakan 
  # "l" + "a" + "ply" = "laply":
  
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
    # bersihkan kalimat dengan R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # ubah seluruh huruf menjadi huruf kecil:
    sentence = tolower(sentence)
    
    # pisahkan kalimat menjadi kata
    word.list = str_split(sentence, '\\s+')
    
    # terkadang list memiliki hierarki yang lebih tinggi sebanyak satu level
    words = unlist(word.list)
    
    # bandingkan kata-kata dengan kamus atau leksikon positif dan negatif
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    # match() menghasilkan posisi dari kata-kata yang dicek atau NA
    # hasilnya adalah TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    # TRUE/FALSE akan dihitung 1/0 oleh sum():
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

# Aplikasikan fungsi sentimen ke dalam tweets
result <- sentiment.score(unclean_tweet,pos.words,neg.words)
sentimen <- c()
for(i in seq_along(result$score)){
  if(result$score[i] == 0) {sentimen[i]="Netral"}
  else if(result$score[i] < 0) {sentimen[i]="Negatif"}
  else if(result$score[i] > 0) {sentimen[i]="Positif"}
}

table.sentiment <- cbind(result, sentimen)
table.sentiment$score <- NULL
table.sentiment$sentimen <- as.factor(table.sentiment$sentimen)

# Visualisasi 
  #score
hist(result$score, col = "yellow", main = 'Score of tweets', ylab = 'Count of tweets')

count(result$score)

qplot(result$score,xlab = "Score of tweets")

summary(result$score)
  #sentiment
hist(table.sentiment$sentimen, col = "yellow", main = 'Sentiment of tweets', ylab = 'Count of tweets')

count(table.sentiment$sentimen)

qplot(table.sentiment$sentimen,xlab = "Sentiment of tweets")

# ---------------------- Pengujian Model ------------------------
# Buat dataset train
inTrain <- createDataPartition(y=table.sentiment$sentimen, p=0.75, list=FALSE)

# Buat matrix
matrix= create_matrix(table.sentiment[,1])
mat = as.matrix(matrix)

# Latih model
# SVM
# Bangun data untuk menspesifikasi variabel respon, dataset training dan testing
container = create_container(matrix, as.numeric(as.factor(table.sentiment[,1])),
                             inTrain,virgin=FALSE)
models = train_models(container, algorithms="SVM")
results = classify_models(container, models)

# Recall accuracy
recall_accuracy(as.numeric(as.factor(table.sentiment$sentimen[length(table.sentiment$sentimen)-
                                                          inTrain])), results[,"SVM_LABEL"])
# Rangkuman model
analytics = create_analytics(container, results)
analytics@algorithm_summary

# Buat wordcloud yang berisi kata-kata beserta jenis sentimennya
lex.corpus <- Corpus(VectorSource(table.sentiment$text))
lex.dtm <- DocumentTermMatrix(lex.corpus)
m <- as.matrix(lex.dtm)
v <- sort(colSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
for(i in 1:nrow(d)){
  word.sentimen <- c()
  index.sentimen <- c()
  tweet.sentimen <- table.sentiment$sentimen[grep(d$word[i], table.sentiment$text)]
  positif <- sum(tweet.sentimen=="Positif")
  negatif <- sum(tweet.sentimen=="Negatif")
  netral <- sum(tweet.sentimen=="Netral")
  word.sentimen <- rbind(positif,negatif,netral)
  index.sentimen <- which(word.sentimen==max(positif,negatif,netral))
  if (index.sentimen == 1){
    d$kelas[i] <- "Positif"
  } else if (index.sentimen == 2){
    d$kelas[i] <- "Negatif"
  } else {
    d$kelas[i] <- "Netral"
  }
}
wc <- wordcloud(words = d$word, freq = d$freq, min.freq = 1,
                max.words=100, random.order=FALSE, rot.per=0.35,
                ordered.colors=TRUE,
                colors=c("#FF0033", "#FFCC33", "#99CCFF")[factor(d$kelas)],
                scale=c(2.5,0.5))

