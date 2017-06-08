if [ -f /home/cloudera/BigData_for_Energy_Efficiency/energy_consumption_matrix*.csv];
                then
                rm -r /home/cloudera/BigData_for_Energy_Efficiency/energy_consumption_matrix*.csv
                echo "part files removed"
                else
                echo "No part files exist";
fi

pig -f energy_consumption_matrix.pig

if [ $? -eq 0 ]; then 
	echo “success”
	hadoop fs -copyToLocal energy_consumption_matrix/part-r-00000 .
	mv part-r-00000 "energy_consumption_matrix_$(date +%Y%m%d_%H%M%S).csv" 
else 
	echo “fail”; 
fi

