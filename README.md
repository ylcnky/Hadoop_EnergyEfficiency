# BigData for Energy Efficiency

## Project Explanation

This project is to provide a proof of concept for using Big Data along with advanced analytics techniques to solve issues for improving energy efficiency. In this project we used some sample data sets provided by "Technical Research Centre of Finland - VTT". These data sets were collected using specialized metering devices installed by VTT in a group of buildings. For sake of of anonymity the names and locations of the buildings are replaced by hypothetical labels. Following is a list of energy efficiency use cases that were considered as part of this proof of concept. The implementation procedures of highlighted use cases in list below are explained.

1. Calculating the base load of the building to identify non user consumption of buildings.
2. **_Classifying the buildings on the basis of the energy efficiency and analyse the seasonal shifts in this classification._**
3. Predicting daily energy consumption of various household devices on the basis of previous consumption pattern.
4. Collecting Twitter data for energy related topics using keyword filtering (not implemented yet).
</font>
Following is the list of tools used for Big Data, advanced analytics and results visualization.

* Apache Hadoop (big data)
* Apache Pig (big data)
* Apache Flume (big data)
* Apache Hive (big data)
* Apache Oozie (big data)
* Cloudera Impala (big data Cloudera VM)
* SQL on Hadoop and Neo4j Graph Database (Optional)
* R Programming for Statistical Computing (Python is option)
* Tableau Public (visualization)
* Web interface for run-time visualization (with fake data to imitate the scenario)

The implementation is performed both locally installed Hadoop Cluster and also Cloudera CDH5.10 VM for Apache Hadoop, Pig, Hive, Flume, Ozzie and Cloudera Imapala.

## Implementation
### Cloudera CDH5.10
For this proof of concept or any demo use Cloudera CDH5.10 quick virtual machine can be used that is available via [Cloudera official website for Quick VM ](https://www.cloudera.com/downloads/quickstart_vms/5-10.html).

For using the concept presented in this proof concept in a production environment, It is recommended that you install Cloudera CDH 5.10 in pseudo distributed single node or multi node modes. Detailed Cloudera documentation are official via their official documentation pages,[Ways to install CDH5.10](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Installation-Guide/cdh4ig_topic_4_2.html).


### Using Apache Pig and R scripts to classify buildings on basis of energy efficiency

Following steps can be used to analyze the data for given use cases. These steps can be used with CDH4 in any configuration. We have tested it using Cloudera CDH5.10 VM.

1. Download material in this repository using following command. (Git installation is a pre-requisite)

`git clone https://github.com/ylcnky/Hadoop_EnergyEfficiency.git`

2. Extract and copy the data to HDFS

`cd Hadoop_EnergyEfficiency/`

`unzip data.zip`

`hadoop fs -copyFromLocal hld_masked.csv .`
The above command will copy the data file with hourly consumption data to HDFS in user's home hdfs directory.

To view if the file is copied correctly, use following command
`hadoop fs -ls`

3. Using the Apache Pig script to pre-process data

  `hadoop fs -ls`

  `pig -f energy_consumption_matrix.pig`

  `hadoop fs -copyToLocal energy_consumption_matrix ` .

  `cd energy_consumption_matrix`

  `mv part-r-00000 ../energy_consumption_matrix.csv`

  File "energy_consumption_matrix.csv" can then be used as input file for R script "K-means_clustering_pig_to_R.R" for applying K-means clustering. This script needs another input file "hld_addresses_area.csv" with Real estate data of the building to calculate energy efficiency i.e. by dividing each hourly consumption value per building per month by ground floor area.

4. Now you can use R within Centos of Cloudera virtual machine. However, the analysis can be run in the local machine as well (Mac/Windows/Linux) when the necesarry programming modules are installed. To run the R script on local machine, we recommend to use Anaconda. It is a user preference. In any case open R or Rstudio and set current working directory to the git folder where K-means_clustering_pig_to_R.R script is available and type following command.

 `source("K-means_clustering_pig_to_R.R")`

During execution of script you will be prompted twice to select input files. On first prompt please select "energy_consumption_matrix.csv" and on second prompt select "hld_addresses_area.csv". After the execution of script an output .txt file "energy_classes" with appended timestap in format "%Y-%j-%H%M%S" e.g. "energy_classes2017-274-224603" should be available in current working directory.

The output file should have following columns

"building" - Building Lablel masking the building name and address.

"area" - Ground Floor Area of the building in metere squares.

"month"  - Name of the month

"elec_Wh_per_m2" - Electricity , energy effeciency in watt hours per meter square.

"heat_Wh_per_m2" - Electricity used for heating , energy effeciency in watt hours per meter square

"cluster"  - Assigned cluster number by K-means algorithms. Please note that we are using predefined K value of 4 because we wanted to classify buildings into four groups i.e. corresponding to low, Average low, Average High, and High effeciency.

### Interactive Visualization of the results with Tableau Public

1. Open Tableau public and click open data. Select the data output file from last step of previous section i.e. <energy_classes%Y-%j-%H%M%S.txt> file.
2. Both Tableau Public and server can be used visualization.
3. Press go to worksheet.
4. In the worksheet. Ensure that month and building values are in Dimension list on left hand side panel. While rest of the values should be in Mesaure list.
5. Drag and drop elec_wh_per_m2 to Columns, while heat_Wh_per_m2 to Rows in the graph area.
6. Size and color on basis of assigned K-means cluster values.
7. Put filters of your choice like in our case we used months and buildings as filters to see the beahviour of building in each month.
8. In addition a web interface is also developed to imitate the run-time data visualization scenario. This interface has also been embedded to the Tableau later.

Followings are the snapshots of the generated visualizations from Tableau and the Web Development platform

![alt tag](https://github.com/ylcnky/Hadoop_EnergyEfficiency/blob/master/img/Tableau1.png)

![alt tag](https://github.com/ylcnky/Hadoop_EnergyEfficiency/blob/master/img/Web_Interface.png)
