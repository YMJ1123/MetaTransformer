import os
import argparse
import pandas as pd
from tqdm import tqdm
from matplotlib import pyplot as plt

def main():
    parser = argparse.ArgumentParser(description='Concatenate all the prediction output csv files in the folder')
    parser.add_argument('--folder', type=str, help='Folder containing the prediction output csv files')
    parser.add_argument('--output', type=str, help='Output file name')
    args = parser.parse_args()

    folder = args.folder
    output = args.output

    # Go through all the folders that start with "result_split_split" in the folder, and read the csv files inside the smaller folders 
    # and concatenate them into one csv file
    df = pd.DataFrame()
    for root, dirs, files in os.walk(folder):
        for d in dirs:
            if d.startswith('result_split_split'):
                for root2, dirs2, files2 in os.walk(os.path.join(root, d)):
                    for f in files2:
                        if f.endswith('.csv'):
                            df_temp = pd.read_csv(os.path.join(root2, f))
                            # print(df_temp["Norm_Prediction"].sum())
                            #Drop the "Norm_Prediction" column
                            df_temp = df_temp.drop(columns=['Norm_Prediction'])# df_temp = df_temp.groupby(['Taxon']).agg({'Prediction': 'sum'}).reset_index()
                            df = pd.concat([df, df_temp], ignore_index=True)
    #Sort the dataframe by the "Taxon" column
    # df = df.sort_values(by=['Taxon'])
    #If the "Taxon" of a row is the same as the "Taxon" of any other row, just keep the first row, and add the "Prediction" of the other row to the "Prediction" of the first row
    df = df.groupby(['Taxon']).agg({'Prediction': 'sum'}).reset_index()
    # Add the "Norm_Prediction" column
    df['Norm_Prediction'] = 100*(df['Prediction']/df['Prediction'].sum())
    print(df)
    # print(df['Norm_Prediction'].sum())
    # df.to_csv(os.path.join(folder, output), index=False)
    df.to_csv(output, index=False)





if __name__ == '__main__':
    main()