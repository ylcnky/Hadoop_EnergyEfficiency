
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

energy_file <- file.choose()
baseload <- function (fileloc = energy_file , type = "electricity"){
        
        if(type=="electricity" | type=="heating"){
                main_table <- read.csv(fileloc, header=TRUE, sep=",")
                #colnames(main_table) <- c("dev_id","building","meter","type","date","hour","consumption")
                main_table$date <- as.POSIXct(as.character(main_table$date),format="%Y%m%d")
                main_table["month"] <- NA
                main_table$month <- months(main_table$date, abbreviate = TRUE)
                main_table <- main_table[main_table!="Dec",]
                require(sqldf)
                
        
        
                if(type =="electricity") {
                main_elec = sqldf("SELECT BuildingID AS did, vac AS building,type,date,hour,Consumption AS consumption, month FROM main_table WHERE type='elect' ")
                main_elec
                }
                else {
                main_heating = sqldf("SELECT BuildingID AS did, vac AS building,type,date,hour,Consumption AS consumption, month FROM main_table WHERE type='Dist_Heating' ")
                main_heating
                }
        }
        else stop("Not a valid energy type")
    
}

readinteger <- function()
{ 
        n <- readline(prompt="Enter an integer: ")
        return(as.integer(n))
}

select <- readinteger()

#if(select[1] == 1 | select[1]==2) {
#print(readinteger())
        if(select ==1 ){
                data <- baseload(type="electricity")
                feature = "elec"
        }
        if(select ==2 ) {
                data <- baseload(type="heating")
                feature = "heating"
        }

        base <- data[data$hour==0 |data$hour==1|data$hour==2|data$hour==23,]
        base <- sqldf(c("update base set building = 'NA'  where building LIKE '%                 %'", "select * from base"), method = "raw")
        base <- sqldf("SELECT * from base where building!='NA'")
        base_daily <- sqldf("SELECT building, date, month, AVG(consumption) AS baseload_daily FROM base GROUP by date,building ORDER BY building DESC")
        base_monthly<- sqldf("SELECT building, month, AVG(baseload_daily) AS baseload FROM base_daily GROUP by building,month ORDER BY building,month DESC")
        path <- getwd() 
        appendage <- ".txt" 
        t_string <- format(Sys.time(), format = "%Y-%j-%H%M%S") 
        base_file <- file.path(path, paste0("/",feature,"_baseload",t_string, appendage,sep="")) 
        write.table(base_monthly, file = base_file,row.names=FALSE)
#}
       # if(select[1]!=1 | select[1]!=2){
        #        stop("Wrong input for energy type")        
        #}
        
