# function() for adding area information to energy consumption matrix and calculating energy effeciency
add_area <- function (address_file=realestate_file, data= energy_matrix){

        # reading the file with area information
        address <- read.csv(address_file,header=TRUE, sep=",")

        # filtering out buildings that have all information available and assigning column names to read data
        address <- address[complete.cases(address[,3]),]
        colnames(address) <-c("building","address","area")

        # Assigning the area information to all the buidlings in energy consumption matrix
        merged <- merge(data,address,all=FALSE)

        # Calculating the energy effeciencies for respective energy types
        merged$elec_Wh_per_m2 <- (merged$elec_consumption/merged$area)*1000
        merged$heat_Wh_per_m2 <- (merged$heat_consumption/merged$area)*1000

        # Selecting the required columns in required sequence
        energy_area_matrix <- merged[,c(1,5,2,6,7,8)]

        # Reterning the formulated matrix with energy effeciency
        energy_area_matrix
}

# For selection of the formulated energy consumption matrix file.
# This file should be the output file of the energy_consumption_matrix.pig OR hld.sh scripts

fileloc <- file.choose()

#reading the selected data and naming the columns
data <- read.table(fileloc,header=FALSE,sep=",")
colnames(data) <- c("building","month","elec_consumption","heat_consumption")

# Selecting the data rows with consumption values greater than zero
energy_matrix <- data[data$elec_consumption > 0 & data$heat_consumption > 0,]

# calling the add_area() function to add area information and calculate energy effeciencies.
realestate_file <- file.choose()
energy <- add_area()


# preparing the data for applying K-means algorithm for clustering
energy.features = energy
energy.features[1:4] <- list(NULL)

# Scaling the data to have common unit and variance
# In this case the unit of both energy types are same. Scale() function is required to achieve unit variance
input = scale(energy.features, center=TRUE, scale=TRUE)

# Applying K-means to cluster data into 4 classes
# Number of classes were pre-defined for our use case, So application of K-means was a good enough choice
results = kmeans(input,4)


# Adding the calculated clustering information back to energy effeciency matrix for visualization purpose
building <- c(energy$building)
month <- c(energy$month)
area <- c(round(as.numeric(energy$area),1))
elec_Wh_per_m2 <- c(round(as.numeric(energy$elec_Wh_per_m2),1))
heat_Wh_per_m2 <- c(round(as.numeric(energy$heat_Wh_per_m2),1))
cluster <- c(results$cluster)
main_matrix_k4 <- data.frame(building,area,month,elec_Wh_per_m2,heat_Wh_per_m2,cluster)

# Storing the resulting data into a flat file with time stamp to keep track
path <- getwd()
appendage <- ".txt"
t_string <- format(Sys.time(), format = "%Y-%j-%H%M%S")
energy_file <- file.path(path, paste0("/","energy_classes",t_string, appendage,sep=""))
write.table(main_matrix_k4, file = energy_file,row.names=FALSE)

# The results can be visualized using the output data or file. For our analysis we used Tableau to visualize the results.
