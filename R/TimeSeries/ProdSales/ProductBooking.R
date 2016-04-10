rm(list = ls())
gc()

library(data.table)
library(forecast)
library(tseries)
library(TSA)
library(lmtest)


# setting the directory and importing the raw data
#setwd('D:\\Silpa\\Learning\\TimeSeries\\Mukund')
rawdata <- data.table(read.delim2('~/Downloads/productBookings.txt',header = TRUE,sep = "|",stringsAsFactors=F))
rawdata <- rawdata[,ProductBooking := as.numeric(ProductBooking)]
rawdata <- rawdata[,CommittedProduct := as.numeric(CommittedProduct)]
rawdata <- rawdata[,UpsideProduct := as.numeric(UpsideProduct)]
rawdata <- rawdata[,ProductForecast := as.numeric(ProductForecast)]
str(rawdata)


test_data <- rawdata[FiscalYear == 2016,]
train_data <- rawdata[!(FiscalYear == 2016),]
table(train_data$FiscalWeekOfYear) #To check if all weeks are present

# converting the train_data into time series
train_lst <- lapply(train_data, function (x) ts(x, frequency=52, start=c(2012, 1)))
train_data.ts <- as.data.frame(train_lst)
str(train_data.ts[11])

test_lst <- lapply(test_data, function (x) ts(x, frequency=52, start=c(2016, 1)))
test_data.ts <- as.data.frame(test_lst)
str(test_data.ts[11])

rawdata_lst <- lapply(rawdata, function (x) ts(x, frequency=52, start=c(2012, 1)))
rawdata.ts <- as.data.frame(rawdata_lst)
str(rawdata.ts[11])

## Checking if any columns have NA values 
table(is.na(train_data$ProductBooking))
table(is.na(test_data$ProductBooking))


## Building an automatic arima
arima_model <- auto.arima(train_data.ts[['ProductBooking']])
arima_forecast <- forecast(arima_model, h = 13)
str(arima_forecast)
t <- data.table(arima_forecast$mean)
setnames(t, c("V1"),c("Forecast1"))


### Forecasted values and Checking Accuracy
Final_table <- cbind(t, test_data)
Final_table <- Final_table[, list(FiscalWeek,ProductBooking,Forecast1)]
Final_table <- Final_table[, percdiff := 100*(Forecast1-ProductBooking)/ProductBooking]