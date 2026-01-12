# Enter your username 
username=ymj1123ntu
#move to test_data_summer folder
cd /home/$username/MetaTransformer/test_data_summer
# cd /home/$username/MetaTransformer/
# Access every folder in /home/$username/MetaTransformer/test_data_summer as $folder
for folder in */; do
    bash /home/$username/MetaTransformer/myScript/remove_tmp_folder.sh 
    # Move to the folder
    # cd "$folder" || exit
    echo "Processing $folder..."
	# # move the $folder.interleaved.fa to the interleaved folder
	# mv "$folder.interleaved.fa" "/home/$username/MetaTransformer/test_data_summer/$folder/interleaved/"
    #Create a folder with the same name as the folder you are in below "/home/$username/MetaTransformer/test_data_summer"
    # mkdir -p "/home/$username/MetaTransformer/test_Output_model_summer/$folder"
    mkdir -p "/home/$username/MetaTransformer/test_Output_model_summer/$folder"
    #################### Model path ####################

    # remove thr "/" from the folder name
    foldername=${folder%/}

    #if /home/$username/MetaTransformer/test_Output_model_summer/$folder does not include any files, then run the following command
    # if [ ! "$(ls -A /home/$username/MetaTransformer/test_Output_model_summer/$folder)" ]; then
    echo "Output Empty"
    ############################################################
    #check if the split_result folder does not exist or is empty
    if [ ! -d "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result" ] || [ ! "$(ls -A /home/$username/MetaTransformer/test_data_summer/$foldername/split_result)" ]; then 
        echo "split_result folder does not exist, running subset_fasta.py..."
        mkdir -p "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result"
        #Calculate the number of reads in the fasta file
        num_reads=$(grep -c "^>" "/home/$username/MetaTransformer/test_data_summer/$foldername/$foldername.interleaved.fa")
        echo "num_reads: $num_reads"
        
        # if [ "$num_reads" -gt 65000000 ]; then # if the fasta file contains more than 65000 reads
        #     echo "num_reads > 65000000, file too big..."
        #     # move the folder to "/home/$username/MetaTransformer/test_data_too_big/$foldername"
        #     mkdir -p "/home/$username/MetaTransformer/test_data_too_big/$foldername"
        #     echo "Moving $foldername to /home/$username/MetaTransformer/test_data_too_big/$foldername"
        #     mv "/home/$username/MetaTransformer/test_data_summer/$foldername" "/home/$username/MetaTransformer/test_data_too_big/$foldername"
        #     continue
        # else
        #     echo "num_reads <= 65000"
           
        #     #Run the ommand like this "python /home/$username/MetaTransformer/src/scripts/subset_fasta.py  --input /home/$username/MetaTransformer/test_data_summer/AU145/AU145.interleaved.fa    --n-reads   --out-folder /home/$username/MetaTransformer/test_data_summer/AU145/split_result"
        #     python /home/$username/MetaTransformer/src/scripts/subset_fasta.py  --input "/home/$username/MetaTransformer/test_data_summer/$foldername/$foldername.interleaved.fa"    --n-reads 65000  --out-folder "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result"
        #     #calculate the number of threads to use for "invoke_multi_abundance.sh" based on the number of files in the split_result folder
        #     num_files=$(ls -1 /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | wc -l)
        #     echo "num_files: $num_files"
        # fi

        #Run the ommand like this "python /home/$username/MetaTransformer/src/scripts/subset_fasta.py  --input /home/$username/MetaTransformer/test_data_summer/AU145/AU145.interleaved.fa    --n-reads   --out-folder /home/$username/MetaTransformer/test_data_summer/AU145/split_result"
        python /home/$username/MetaTransformer/src/scripts/subset_fasta.py  --input "/home/$username/MetaTransformer/test_data_summer/$foldername/$foldername.interleaved.fa"    --n-reads 65000  --out-folder "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result"
        #calculate the number of threads to use for "invoke_multi_abundance.sh" based on the number of files in the split_result folder
        num_files=$(ls -1 /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/*.fa | wc -l)
        echo "num_files: $num_files"

        cd /home/$username/MetaTransformer/
    else
        echo "split_result not Empty"
        #Run the following command to use MetaTransformer: "bash src/scripts/invoke_multi_abundance.sh /home/$username/MetaTransformer/test_Output_model_summer/$folder /home/$username/MetaTransformer/test_data_summer/$folder/interleaved/  pretrained_Model/config_species.yaml classification_species_transformer_ckpt_bt_500000.pt  1 /home/$username/MetaTransformer/sequence_metadata/species_mapping.tab /home/$username/MetaTransformer/vocab_file/vocab_13mer.txt /home/$username/MetaTransformer/pretrained_Model/train_species.log 1 True False False"
        # num_files=$(ls -1 /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | wc -l)-$(ls -d /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/*/ | wc -l)
        num_files=$(ls -1 /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/*.fa | wc -l)
        # minus the number of folders in the split_result folder (only count the files, not any folder in the split_result folder)
        
        echo "num_files: $num_files"
        cd /home/$username/MetaTransformer/
    fi
    ############################################################
    #Save every 32 files in the split_result folder as a folder if the split_result folder contains more than 32 files
    if [ "$num_files" -gt 32 ]; then # if the split_result folder contains more than 32 files
        echo "num_files > 32"
    #Save every 32 files in the split_result folder in a folder called "split_split*" (* is the nober of the folder)
        split_split_num=0
        while [ "$num_files" -gt 32 ]; do
            # echo "num_files > 32"
            #Create a folder called "split_split*" (* is the number of the folder)
            mkdir -p "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result/split_split$split_split_num"
            #Move the first 32 files in the split_result folder to the "split_split*" folder (use cp)
            ls /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | head -32 | xargs -I{} cp /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/{} /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/split_split$split_split_num
            #Remove the first 32 files in the split_result folder (only remove the files, not any folder in the split_result folder)
            # only remove the files, not any folder in the split_result folder
            ls /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | head -32 | xargs -I{} rm /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/{}
            # ls /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | head -32 | xargs -I{} rm /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/{}
            
            #Calculate the number of files in the split_result folder
            num_files=$(ls -1 /home/$username/MetaTransformer/test_data_summer/$foldername/split_result | wc -l)
            echo "num_files that remains: $num_files"
            #Add 1 to the split_split_num
            split_split_num=$((split_split_num+1))
        done
        find /home/$username/MetaTransformer/test_data_summer/$foldername/split_result -type d -empty -delete
        #move the remaining files in the split_result folder in a folder called "split_split*" 
        mkdir -p "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result/split_split$split_split_num"
        mv /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/*.fa /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/split_split$split_split_num
        
        echo "Finished saving the remaining files in the split_result folder "
    else
        echo "num_files <= 32 "
        $split_split_num=0
    fi
    ############################################################
    #Run the following command to use MetaTransformer: "bash src/scripts/invoke_multi_abundance.sh /home/$username/MetaTransformer/test_Output_model_summer/$folder /home/$username/MetaTransformer/test_data_summer/$folder/interleaved/  pretrained_Model/config_species.yaml classification_species_transformer_ckpt_bt_500000.pt  1 /home/$username/MetaTransformer/sequence_metadata/species_mapping.tab /home/$username/MetaTransformer/vocab_file/vocab_13mer.txt /home/$username/MetaTransformer/pretrained_Model/train_species.log 1 True False False"
    cd /home/$username/MetaTransformer/
    # Use for loop to access every split_split* folder in the split_result folder
    for split_split_folder in /home/$username/MetaTransformer/test_data_summer/$foldername/split_result/split_split*/; do
        #remove the "/" from the split_split* folder name and get the last folder name
        split_split_folder_num_file=$(ls -1 $split_split_folder | wc -l)
        split_split_folder_name=${split_split_folder%/}
        split_split_folder_name=${split_split_folder_name##*/}        
        echo "Processing $split_split_folder_name..."   
             
        #do the following if the folder does not exist or is empty
        # if [ ! -d "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name" ] || [ ! "$(ls -A /home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name)" ]; then
        if [ ! -d "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name" ] || [ ! "$(ls -A /home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name)" ]; then
            echo "$split_split_folder Output Empty"
            #Create a folder with the same name as the folder you are in below "/home/$username/MetaTransformer/test_data_summer"                
            # mkdir -p "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name"                     
            mkdir -p "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name"    
            #run the invoke_multi_abundance.sh for the split_split* folder if the folder has exactly 32 files
            if [ "$split_split_folder_num_file" -eq 32 ]; then
                echo "num_files = 32"
                bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name" "$split_split_folder"  "/home/$username/MetaTransformer/pretrained_Model/config_species.yaml" "/home/$username/MetaTransformer/pretrained_Model/classification_species_transformer_ckpt_bt_500000.pt"  "32" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "False" "False" "False"
            else
                echo "num_files != 32, last folder"
                bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name" "$split_split_folder"  "/home/$username/MetaTransformer/pretrained_Model/config_species.yaml" "/home/$username/MetaTransformer/pretrained_Model/classification_species_transformer_ckpt_bt_500000.pt"  $split_split_folder_num_file "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "True" "False" "False"
            fi
            # bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$foldername/result_$split_split_folder_name" "$split_split_folder"  "pretrained_Model/config_species.yaml" "classification_species_transformer_ckpt_bt_500000.pt"  "32" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "False" "False" "False"
        else
            echo "$split_split_folder_name Output not Empty"
        fi
    done
    # bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$folder" "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result/"  "pretrained_Model/config_species.yaml" "classification_species_transformer_ckpt_bt_500000.pt"  "32" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "False" "False" "False"
    # bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$folder" "/home/$username/MetaTransformer/test_data_summer/$folder"  "pretrained_Model/config_species.yaml" "classification_species_transformer_ckpt_bt_500000.pt"  "1" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "True" "False" "False"
    # bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$folder" "/home/$username/MetaTransformer/test_data_summer/$foldername/split_result/test/"  "pretrained_Model/config_species.yaml" "classification_species_transformer_ckpt_bt_500000.pt"  "1" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "True" "False" "False"
    
    echo "Finished processing $foldername, concatenating the output files..."
    #Check if /home/$username/MetaTransformer/test_Output_Concatenated/ folder exists
    if [ ! -d /home/$username/MetaTransformer/test_Output_Concatenated ]; then
        #If it doesn't exist, create the folder
        mkdir -p /home/$username/MetaTransformer/test_Output_Concatenated
    fi
    #Check if /home/$username/MetaTransformer/test_Output_Concatenated/$foldername"_abundance.csv doesn't exist
    if [ ! -f /home/$username/MetaTransformer/test_Output_Concatenated/$foldername"_abundance.csv" ]; then
        #Concatenate all the abundance.csv files in the folder
        full_folder_path=/home/$username/MetaTransformer/test_Output_model_summer/$foldername
        python3 /home/$username/MetaTransformer/myScript/folder_output_concatenation.py --folder $full_folder_path --output /home/$username/MetaTransformer/test_Output_Concatenated/$foldername"_abundance.csv"
        echo "Finished, concatenated $foldername"_abundance.csv" in $full_folder_path "
    else
        #If it exists, then skip it
        echo "$foldername"_abundance.csv" already exists in $folder"
    fi

    for job in $(jobs -p); do
       wait $job
    done
    cd /home/$username/MetaTransformer/test_data_summer
    # else
    #     echo "Prediction files exist" 
    #     cd /home/$username/MetaTransformer/test_data_summer
    # fi

    # #Run the following command to use MetaTransformer: "bash src/scripts/invoke_multi_abundance.sh /home/$username/MetaTransformer/test_Output_model_summer/$folder /home/$username/MetaTransformer/test_data_summer/$folder/interleaved/  pretrained_Model/config_species.yaml classification_species_transformer_ckpt_bt_500000.pt  1 /home/$username/MetaTransformer/sequence_metadata/species_mapping.tab /home/$username/MetaTransformer/vocab_file/vocab_13mer.txt /home/$username/MetaTransformer/pretrained_Model/train_species.log 1 True False False"
    # cd /home/$username/MetaTransformer/
    # bash "/home/$username/MetaTransformer/src/scripts/invoke_multi_abundance.sh" "/home/$username/MetaTransformer/test_Output_model_summer/$folder" "/home/$username/MetaTransformer/test_data_summer/$folder"  "pretrained_Model/config_species.yaml" "classification_species_transformer_ckpt_bt_500000.pt"  "1" "/home/$username/MetaTransformer/sequence_metadata/species_mapping.tab" "/home/$username/MetaTransformer/vocab_file/vocab_13mer.txt" "/home/$username/MetaTransformer/pretrained_Model/train_species.log" "1" "True" "False" "False"
	# cd /home/$username/MetaTransformer/test_data_summer
done 