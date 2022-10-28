import csv

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
    
    filereader = readBED("flair.collapse.isoforms.bed")
    
    rawdata = filereader.bedreader()
    
    query = MYSQL_query.rangesplit(rawdata)
    
    with open("query.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerows(query)
     
    

if __name__ == "__main__":
    main()
