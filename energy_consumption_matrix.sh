if [ -f /home/cloudera/part-r-00000];
                then
                rm -r /home/cloudera/part-r-*
                echo "part files removed"
                else
                echo "No part files exist";
fi

pig -f hld.pig

if [ $? -eq 0 ]; then 
	echo “success”
	hadoop fs -copyToLocal energy_consumption_matrix/part-r-00000 .
	mv part-r-00000 "energy_consumption_matrix_$(date +%Y%m%d_%H%M%S).csv" 
else 
	echo “fail”; 
fi
