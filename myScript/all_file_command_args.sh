#!/bin/bash

# =============================================================================
# MetaTransformer Batch Processing Script (Parameterized Version)
# =============================================================================
# Usage:
#   bash all_file_command_args.sh [OPTIONS]
#
# Options:
#   -b, --base-dir          MetaTransformer base directory (default: /home/$USER/MetaTransformer)
#   -i, --input-dir         Input test data directory name (default: test_data_summer)
#   -o, --output-dir        Output directory name (default: test_Output_model_summer)
#   -c, --concat-dir        Concatenated output directory name (default: test_Output_Concatenated)
#   -m, --model-dir         Model directory name (default: pretrained_Model)
#   -f, --config-file       Config file name (default: config_species.yaml)
#   -w, --model-weights     Model weights file name (default: classification_species_transformer_ckpt_bt_500000.pt)
#   -s, --species-mapping   Species mapping file path (default: sequence_metadata/species_mapping.tab)
#   -v, --vocab-file        Vocab file path (default: vocab_file/vocab_13mer.txt)
#   -l, --log-file          Log file name (default: train_species.log)
#   -n, --n-reads           Number of reads per split (default: 65000)
#   -t, --threads           Number of threads per batch (default: 32)
#   -h, --help              Show this help message
#
# Example:
#   bash all_file_command_args.sh -b /home/user/MetaTransformer -i my_test_data -o my_output
# =============================================================================

set -e

# Default values
BASE_DIR="/home/$USER/MetaTransformer"
INPUT_DIR_NAME="test_data_summer"
OUTPUT_DIR_NAME="test_Output_model_summer"
CONCAT_DIR_NAME="test_Output_Concatenated"
MODEL_DIR_NAME="pretrained_Model"
CONFIG_FILE="config_species.yaml"
MODEL_WEIGHTS="classification_species_transformer_ckpt_bt_500000.pt"
SPECIES_MAPPING="sequence_metadata/species_mapping.tab"
VOCAB_FILE="vocab_file/vocab_13mer.txt"
LOG_FILE="train_species.log"
N_READS=65000
THREADS=32

# Function to display help
show_help() {
    head -35 "$0" | tail -30
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base-dir)
            BASE_DIR="$2"
            shift 2
            ;;
        -i|--input-dir)
            INPUT_DIR_NAME="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR_NAME="$2"
            shift 2
            ;;
        -c|--concat-dir)
            CONCAT_DIR_NAME="$2"
            shift 2
            ;;
        -m|--model-dir)
            MODEL_DIR_NAME="$2"
            shift 2
            ;;
        -f|--config-file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -w|--model-weights)
            MODEL_WEIGHTS="$2"
            shift 2
            ;;
        -s|--species-mapping)
            SPECIES_MAPPING="$2"
            shift 2
            ;;
        -v|--vocab-file)
            VOCAB_FILE="$2"
            shift 2
            ;;
        -l|--log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        -n|--n-reads)
            N_READS="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help to see available options"
            exit 1
            ;;
    esac
done

# Construct full paths
INPUT_DIR="${BASE_DIR}/${INPUT_DIR_NAME}"
OUTPUT_DIR="${BASE_DIR}/${OUTPUT_DIR_NAME}"
CONCAT_DIR="${BASE_DIR}/${CONCAT_DIR_NAME}"
MODEL_DIR="${BASE_DIR}/${MODEL_DIR_NAME}"
CONFIG_PATH="${MODEL_DIR}/${CONFIG_FILE}"
MODEL_PATH="${MODEL_DIR}/${MODEL_WEIGHTS}"
MAPPING_PATH="${BASE_DIR}/${SPECIES_MAPPING}"
VOCAB_PATH="${BASE_DIR}/${VOCAB_FILE}"
LOG_PATH="${MODEL_DIR}/${LOG_FILE}"
SUBSET_SCRIPT="${BASE_DIR}/src/scripts/subset_fasta.py"
INVOKE_SCRIPT="${BASE_DIR}/src/scripts/invoke_multi_abundance.sh"
CONCAT_SCRIPT="${BASE_DIR}/myScript/folder_output_concatenation.py"
REMOVE_TMP_SCRIPT="${BASE_DIR}/myScript/remove_tmp_folder.sh"

# Display configuration
echo "=============================================="
echo "MetaTransformer Batch Processing"
echo "=============================================="
echo "Base Directory:     $BASE_DIR"
echo "Input Directory:    $INPUT_DIR"
echo "Output Directory:   $OUTPUT_DIR"
echo "Concat Directory:   $CONCAT_DIR"
echo "Model Directory:    $MODEL_DIR"
echo "Config File:        $CONFIG_PATH"
echo "Model Weights:      $MODEL_PATH"
echo "Species Mapping:    $MAPPING_PATH"
echo "Vocab File:         $VOCAB_PATH"
echo "N-Reads per split:  $N_READS"
echo "Threads per batch:  $THREADS"
echo "=============================================="

# Validate paths
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Config file does not exist: $CONFIG_PATH"
    exit 1
fi

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model weights file does not exist: $MODEL_PATH"
    exit 1
fi

# Move to input directory
cd "$INPUT_DIR"

# Process each folder
for folder in */; do
    # Run cleanup script if exists
    if [ -f "$REMOVE_TMP_SCRIPT" ]; then
        bash "$REMOVE_TMP_SCRIPT"
    fi
    
    echo "Processing $folder..."
    
    # Remove trailing slash from folder name
    foldername=${folder%/}
    
    # Create output directory
    mkdir -p "${OUTPUT_DIR}/${folder}"
    
    echo "Output Empty"
    
    ############################################################
    # Check if split_result folder exists and is not empty
    SPLIT_RESULT_DIR="${INPUT_DIR}/${foldername}/split_result"
    
    if [ ! -d "$SPLIT_RESULT_DIR" ] || [ ! "$(ls -A "$SPLIT_RESULT_DIR" 2>/dev/null)" ]; then 
        echo "split_result folder does not exist, running subset_fasta.py..."
        mkdir -p "$SPLIT_RESULT_DIR"
        
        # Calculate number of reads in fasta file
        FASTA_FILE="${INPUT_DIR}/${foldername}/${foldername}.interleaved.fa"
        num_reads=$(grep -c "^>" "$FASTA_FILE")
        echo "num_reads: $num_reads"
        
        # Run subset_fasta.py
        python "$SUBSET_SCRIPT" \
            --input "$FASTA_FILE" \
            --n-reads "$N_READS" \
            --out-folder "$SPLIT_RESULT_DIR"
        
        # Count number of split files
        num_files=$(ls -1 "${SPLIT_RESULT_DIR}"/*.fa 2>/dev/null | wc -l)
        echo "num_files: $num_files"
        
        cd "$BASE_DIR"
    else
        echo "split_result not Empty"
        num_files=$(ls -1 "${SPLIT_RESULT_DIR}"/*.fa 2>/dev/null | wc -l)
        echo "num_files: $num_files"
        cd "$BASE_DIR"
    fi
    
    ############################################################
    # If more than THREADS files, organize into batches
    if [ "$num_files" -gt "$THREADS" ]; then
        echo "num_files > $THREADS"
        split_split_num=0
        
        while [ "$num_files" -gt "$THREADS" ]; do
            BATCH_DIR="${SPLIT_RESULT_DIR}/split_split${split_split_num}"
            mkdir -p "$BATCH_DIR"
            
            # Copy first THREADS files to batch directory
            ls "${SPLIT_RESULT_DIR}"/*.fa 2>/dev/null | head -"$THREADS" | xargs -I{} cp {} "$BATCH_DIR"
            
            # Remove copied files from split_result
            ls "${SPLIT_RESULT_DIR}"/*.fa 2>/dev/null | head -"$THREADS" | xargs -I{} rm {}
            
            # Recalculate remaining files
            num_files=$(ls -1 "${SPLIT_RESULT_DIR}"/*.fa 2>/dev/null | wc -l)
            echo "num_files that remains: $num_files"
            
            split_split_num=$((split_split_num+1))
        done
        
        # Remove empty directories
        find "$SPLIT_RESULT_DIR" -type d -empty -delete
        
        # Move remaining files to last batch
        LAST_BATCH_DIR="${SPLIT_RESULT_DIR}/split_split${split_split_num}"
        mkdir -p "$LAST_BATCH_DIR"
        mv "${SPLIT_RESULT_DIR}"/*.fa "$LAST_BATCH_DIR" 2>/dev/null || true
        
        echo "Finished organizing files into batches"
    else
        echo "num_files <= $THREADS"
        split_split_num=0
    fi
    
    ############################################################
    # Process each batch
    cd "$BASE_DIR"
    
    for split_split_folder in "${SPLIT_RESULT_DIR}"/split_split*/; do
        [ -d "$split_split_folder" ] || continue
        
        split_split_folder_num_file=$(ls -1 "$split_split_folder"/*.fa 2>/dev/null | wc -l)
        split_split_folder_name=$(basename "$split_split_folder")
        
        echo "Processing $split_split_folder_name..."
        
        RESULT_DIR="${OUTPUT_DIR}/${foldername}/result_${split_split_folder_name}"
        
        if [ ! -d "$RESULT_DIR" ] || [ ! "$(ls -A "$RESULT_DIR" 2>/dev/null)" ]; then
            echo "$split_split_folder_name Output Empty"
            mkdir -p "$RESULT_DIR"
            
            if [ "$split_split_folder_num_file" -eq "$THREADS" ]; then
                echo "num_files = $THREADS"
                bash "$INVOKE_SCRIPT" \
                    "$RESULT_DIR" \
                    "$split_split_folder" \
                    "$CONFIG_PATH" \
                    "$MODEL_PATH" \
                    "$THREADS" \
                    "$MAPPING_PATH" \
                    "$VOCAB_PATH" \
                    "$LOG_PATH" \
                    "1" "False" "False" "False"
            else
                echo "num_files != $THREADS, last folder"
                bash "$INVOKE_SCRIPT" \
                    "$RESULT_DIR" \
                    "$split_split_folder" \
                    "$CONFIG_PATH" \
                    "$MODEL_PATH" \
                    "$split_split_folder_num_file" \
                    "$MAPPING_PATH" \
                    "$VOCAB_PATH" \
                    "$LOG_PATH" \
                    "1" "True" "False" "False"
            fi
        else
            echo "$split_split_folder_name Output not Empty"
        fi
    done
    
    ############################################################
    # Concatenate output files
    echo "Finished processing $foldername, concatenating the output files..."
    
    mkdir -p "$CONCAT_DIR"
    
    CONCAT_OUTPUT="${CONCAT_DIR}/${foldername}_abundance.csv"
    
    if [ ! -f "$CONCAT_OUTPUT" ]; then
        FULL_OUTPUT_PATH="${OUTPUT_DIR}/${foldername}"
        python3 "$CONCAT_SCRIPT" \
            --folder "$FULL_OUTPUT_PATH" \
            --output "$CONCAT_OUTPUT"
        echo "Finished, concatenated ${foldername}_abundance.csv"
    else
        echo "${foldername}_abundance.csv already exists"
    fi
    
    # Wait for background jobs
    for job in $(jobs -p); do
        wait $job
    done
    
    cd "$INPUT_DIR"
done

echo "=============================================="
echo "All processing complete!"
echo "=============================================="

