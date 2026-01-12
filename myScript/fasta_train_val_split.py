import random
import argparse

def split_fasta(input_file, train_file, val_file, train_ratio=0.8):
    train_entries = []
    val_entries = []

    with open(input_file, 'r') as file:
        current_entry = []
        for line in file:
            if line.startswith('>'):
                if current_entry:
                    if random.random() < train_ratio:
                        train_entries.append(''.join(current_entry))
                    else:
                        val_entries.append(''.join(current_entry))
                    current_entry = []
            current_entry.append(line)
        if current_entry:
            if random.random() < train_ratio:
                train_entries.append(''.join(current_entry))
            else:
                val_entries.append(''.join(current_entry))

    with open(train_file, 'w') as file:
        file.writelines(train_entries)

    with open(val_file, 'w') as file:
        file.writelines(val_entries)

def main():
    parser = argparse.ArgumentParser(description='Split a FASTA file into Train and Validation files.')
    parser.add_argument('input_fasta', type=str, help='Input FASTA file')
    parser.add_argument('train_fasta', type=str, help='Output Train FASTA file')
    parser.add_argument('val_fasta', type=str, help='Output Validation FASTA file')
    parser.add_argument('--train_ratio', type=float, default=0.8, help='Ratio of Train set (default: 0.8)')

    args = parser.parse_args()

    split_fasta(args.input_fasta, args.train_fasta, args.val_fasta, args.train_ratio)

if __name__ == "__main__":
    main()
