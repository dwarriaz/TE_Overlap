import csv
import sys
import pandas as pd


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
    
    def exonparam(self,Ecsvdata):
        
        pos_exon = {}
        neg_exon = {}
        
        for element in Ecsvdata:
            rangelist = []
            if element[1] == '+':
                startlist = element[3].split(',')
                startlist.remove('')

                stoplist = element[4].split(',')
                stoplist.remove('')
                
                for position in range(0,len(startlist)):
                    setinit = range(int(startlist[position]),int(stoplist[position]))
                    rangelist.append(setinit)
                
                pos_exon.update({element[0]:rangelist})

                    
            elif element[1] == '-':
                startlist = element[3].split(',')
                startlist.remove('')

                stoplist = element[4].split(',')
                stoplist.remove('')
                
                for position in range(0,len(startlist)):
                    setinit = range(int(startlist[position]),int(stoplist[position]))
                    rangelist.append(setinit)
                    neg_exon.update({element[0]:rangelist})
            
                    
        return pos_exon, neg_exon
    
    
    def repeatparam(self, Rcsvdata):
        
        repeats = []
        
        for element in Rcsvdata:
            
            #rangelist = []
            
            if element[1] == '+':
                setinit = range(int(element[2]),int(element[3]))
                repeats.append([element[0],'+',setinit,element[2],element[3]])
            
            elif element[1] == '-':
                setinit = range(int(element[2]),int(element[3]))
                repeats.append([element[0],'-',setinit,element[2],element[3]])
        
        return repeats
    
    def overlap(self,dict_of_ranges,repeat_data):
        overlapdata = []
        for isoform in dict_of_ranges:
            for gene_id, values in isoform.items():
                
                for exon in values:
                    exon = set(exon)
                
                    for repeat in repeat_data:
                        set_of_ranges = set(repeat[2])
            
                        #for repeat,ranges in repeat.items():
                            #set_of_ranges = set(ranges)
                            #print(set_of_ranges)
                            
                            
                        if len(exon.intersection(set_of_ranges)) >= 1:
                            if len(set_of_ranges) == len(exon.intersection(set_of_ranges)):
                                overlapdata.append([gene_id,repeat[0],repeat[1],repeat[3],repeat[4],'exon',len(set_of_ranges)])
                                    
                                    
                            elif len(set_of_ranges) != len(exon.intersection(set_of_ranges)):
                                    
                                overlapdata.append([gene_id,repeat[0],repeat[1],repeat[3],repeat[4],'junction',len(exon.intersection(set_of_ranges))])
                                    
                                    
                            
                        elif len(exon.intersection(set_of_ranges)) == 0:
                                
                            overlapdata.append([gene_id,repeat[0],repeat[1],repeat[3],repeat[4],'intron', 0])
        return overlapdata
                        
        

##########################################################################################   
    
def main():
        
    
    ThisCommandLine = CommandLine()

    ExonReader = readCSV(ThisCommandLine.args.Gene)
    Exon_Raw_Data = ExonReader.csvreader()
    
    RepeatsReader = readCSV(ThisCommandLine.args.Repeats)
    Repeats_Raw_Data = RepeatsReader.csvreader()
    
    Ecsvdata = []
    for element in Exon_Raw_Data:
        Ecsvdata.append([element[0],element[2],element[7], element[8], element[9]])
    Rcsvdata = []   
    for element in Repeats_Raw_Data:
        Rcsvdata.append([element[10],element[9],element[6],element[7]])
    
    e_rangedata = ExonReader.exonparam(Ecsvdata)
    
    r_rangedata = RepeatsReader.repeatparam(Rcsvdata)
    
    #intersectiondata = isoform,repeat_name,repeat_strand,start,stop,classification,intersection 
    intersectiondata = RepeatsReader.overlap(e_rangedata,r_rangedata)
    
    
    #gene, isoform, MER5B_range=chr1:11677-11780_strand=-, chrom, start, stop, instrand, genstrand, classification, per overlap
    
    finaldata = []
    
    for index in range(0,len(intersectiondata)):
        intersectiondata[index].append(Exon_Raw_Data[0][1])
        intersectiondata[index].append(Exon_Raw_Data[0][2])
    print('we made it!') 
    
    for element in intersectiondata:
        newlist = [element[0], element[1]+'_range='+element[7]+':'+element[3]+'-'+element[4]+'_strand='+element[2],element[7],element[3],element[4],element[2],element[8],element[5],element[6]]
        finaldata.append(newlist)
    
    overlaps = pd.DataFrame(finaldata, columns= ['isoform','insertion_name','chrom','start','stop','instrand','genstrand','classification','overlap_count'])
    overlaps.to_csv('TE_Overlap.csv', index=False)
    
if __name__ == "__main__":
    main()
    
