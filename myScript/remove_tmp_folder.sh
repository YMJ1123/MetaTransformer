# Enter your username 
username=ymj1123ntu
#遍歷 /home/$username/MetaTransformer/test_data_summer 中的所有資料夾，並在將其中的檔案移至上一層後移除所有的tmp*資料夾
cd /home/$username/MetaTransformer/test_data_summer
# Access every folder in the directory as $folder
for folder in */; do
    # Move to the folder
    echo "Processing $folder to remove tmp* folder..."
    foldername=${folder%/}
    # move to the split_result folder in the folder if it exists
    if [ -d "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result" ]; then
    echo "split_result folder exists"
        cd "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result"         
        # if the split_result folder contains any tmp* folder, then move all the files in the tmp* folder to the split_result folder
        mv tmp*/* . 
        # remove all the tmp* folder
        rm -r -f tmp*
        # remove all the tmp* folder in all of the split_split* folder
        for split_folder in */; do
            cd "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result/$split_folder"
            mv tmp*/* . 
            rm -r -f tmp*
            cd "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result"
        done

    fi

    # Move back to the parent directory
    cd "/home/$username/MetaTransformer/test_data_summer/$folder"
    #check if the folder contains any tmp* folder
    
    # if the folder contains any tmp* folder, then move all the files in the tmp* folder to the folder
    mv tmp*/* . 
    # remove all the tmp* folder
    rm -r -f tmp*
   
    cd "/home/$username/MetaTransformer/test_data_summer"
done
