import csv
import pandas as pd
import numpy as np



df = pd.DataFrame()

dictTemp  = dict()
dictTemp['countAccountDR'] = 1
dictTemp['countAccountCR'] = 2
dictTemp['Output'] = 3
dictTemp['accountInt'] = 4

df = df.append(dictTemp,ignore_index=True)

with open('my_csv.csv', 'a') as f:
    df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)