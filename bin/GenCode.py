class CommandLine:
    
    def __init__(self):
        
        import argparse
        
        self.parser = argparse.ArgumentParser()
        
        self.parser.add_argument('-Gene', help = 'Path to csv containing ranges of Exons and Introns')
        self.parser.add_argument('-Repeats', help = 'Path to csv containing ranges of Insertions')
        
        self.args = self.parser.parse_args()

class readCSV:
    
    def __init__(self, filename= None):
        self.filename = filename
    
    def csvreader(self):
        csvdata = [] 
        with open(self.filename,'r') as file:
            csvreader = csv.reader(file)
            header = next(csvreader)
            for row in csvreader:
                csvdata.append(row)
        return csvdata        

class GENCODE_decipher:
    def 