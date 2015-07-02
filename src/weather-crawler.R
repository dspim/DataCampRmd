library(jsonlite)
library(foreach)

we <- read.csv("dataset/sample-weathertp.csv")

current_time <- as.POSIXct("2014-12-08 00:00")
stamp <- unclass(current_time)[1]
url0 <- "http://weather.tp.edu.tw/Ajax/jsonp/allnews.ashx?callback=WeatherTime&by=hour&start="
wea <- foreach(i=1:(35*13), .combine = rbind)%do%{
  url <- paste(url0, stamp, "000", sep="")
  json <- iconv(readLines(url,warn = F), from="utf8")
  dat <- fromJSON(substr(json, 13, nchar(json)-2))$result
  stamp <- stamp + 3600
  out <- data.frame(dat[,c(4,5,6,7,8,9,14,24,23,12)],
                    經度=we$經度, 緯度=we$緯度, 海拔=we$海拔)
  #Sys.sleep(1)
  cat(i,"/")
  out
}

a <- transmute(wea, 
                  日期=substr(開始時間,1,10),
                  時間=substr(開始時間,12,16),
                  測站=學校名稱, 氣溫, 最高溫, 最低溫,
                  溼度=濕度, 氣壓, 最大風速, 降雨量,
                  經度, 緯度, 海拔)


#a <- rbind(wea1, wea2, wea3)
write.csv(a, "dataset/weathertp-big5.csv",quote=F, row.names=F)
write.csv(toUTF8(a), "dataset/weathertp-utf8.csv",quote=F, row.names=F)

