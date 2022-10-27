import csv
from logging.handlers import SYSLOG_TCP_PORT
import sys

class readBED:
    
    def __init__(self, filename ):
        self.filename = filename

    def bedreader(self):
        beddata = []
        with open(self.filename)as f:
            for line in f:
                beddata.append(line.strip().split())  
        return beddata         

class MYSQL_query:
    
    def __init__(self):
        self.rangelist = []
    
    def rangesplit(beddata):
 
        rangefind=[]
    
        for entry in beddata: 
            rangetemp=[]
            rangetemp.append(entry[0])
            rangetemp.append(entry[1])
            rangetemp.append(entry[2])
            rangetemp.append(entry[5])
            rangefind.append(rangetemp)
            
        return rangefind
            
        

def main():
    filereader = readBED(sys.argv[1])
    
    rawdata = filereader.bedreader()
    
    
    query = MYSQL_query.rangesplit(rawdata)
    
    filename = (sys.argv[2]+'.csv')
    
    with open(filename, "w") as f:
        writer = csv.writer(f)
        writer.writerows(query)
     
    

if __name__ == "__main__":
    main()
