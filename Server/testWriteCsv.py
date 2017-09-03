import csv
import pandas as pd
import numpy as np



df = pd.DataFrame()

dictTemp  = dict()
dictTemp['hp_weight'] = 1
dictTemp['distance_weight'] = 2
dictTemp['baseDamage_weight'] = 3
dictTemp['attackSpeed_weight'] = 4
dictTemp['creepDamageTaken_weight'] = 4
dictTemp['maxReward'] = 4

df = df.append(dictTemp,ignore_index=True)

with open('my_csv.csv', 'a') as f:
    df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)