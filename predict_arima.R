#  Copyright 2015 Aalto University, Ahmed Hussnain
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
fileloc <- file.choose()

energy_predict <- function (filename = fileloc, device ="Freezer"){
        #print(device)
        data <- read.table (file=fileloc, header=TRUE,sep=";")
        
        splited <- split(data,data$Device)
        
        device_data <- splited[[device]]
        device_data$Timestamp  <- strptime(device_data$Timestamp, "%Y-%m-%d")
        device_data <- data.frame(device_data$Timestamp,device_data$Consumption.Wh.)
        #colnames(device_data) <- c("day","consumption_wh")
        colnames(device_data)[1] <- "day"
        colnames(device_data)[2] <- "consumption_wh"
        device_data <- aggregate(consumption_wh ~ day, data=device_data , FUN=sum)
        days = seq(as.Date("2013-05-01"), as.Date("2014-02-03"), by="1 day")
        timeser <- data.frame(days)
        colnames(timeser)[1] <- "day"
        timeser$consumption_wh <- rep(0,nrow(timeser))
        data_ts<- merge(device_data,timeser,all=TRUE)
        
        data_ts$day  <- strptime(data_ts$day, "%Y-%m-%d")
        data_ts$day <- as.POSIXct(data_ts$day)
        data_ts <- aggregate(consumption_wh ~ day, data=data_ts , FUN=sum)
        
        
        data_ts
        #device_data
        
}
dishwasher <- energy_predict(device ="Dishwasher")
laundry <- energy_predict(device ="Laundry machine")
oven<- energy_predict(device ="Oven")
coffee <- energy_predict(device ="Coffee maker")
microwave <- energy_predict(device ="Microwave")
fridge <- energy_predict(device ="Fridge")
freezer <- energy_predict(device ="Freezer")
stove <- energy_predict(device ="Stove")
pc_tv <- energy_predict(device ="PC/TV")

freezer <- freezer[-nrow(freezer),]
fridge <- fridge[-nrow(fridge),]
coffee <- coffee[-nrow(coffee),]
microwave <- microwave[-nrow(microwave),]
#dev_matrix <- data.frame(dishwasher$day,dishwasher$consumption_wh,laundry$consumption_wh,oven$consumption_wh,coffee$consumption_wh,microwave$consumption_wh,fridge$consumption_wh,freezer$consumption_wh,stove$consumption_wh,pc_tv$consumption_wh)
#colnames(dev_matrix) <- c("date","dishwasher_wh","laundry_wh","Oven","coffee_wh","microwave_wh","fridge_wh","freezer_wh","stove_wh","pc_tv_wh")
library(forecast)
fr <- freezer
fr$day <- NULL 
fr <- ts(fr[,1],start=2013.5,freq=365)
fit_fr <- Arima(fr, order=c(30,0,30))
fr_forecast <- forecast(fit_fr, h=30)
plot(fr_forecast)



