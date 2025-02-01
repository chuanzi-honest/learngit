import re
import csv
from collections import defaultdict

def parse_log_file(log_path):
    variables = []
    current_var = None
    
    with open(log_path, 'r') as f:
        for line in f:
            # Match variable name and description
            var_match = re.match(r'^([A-Z0-9_]+)\s+(.+)$', line.strip())
            if var_match:
                if current_var:
                    variables.append(current_var)
                current_var = {
                    'name': var_match.group(1),
                    'description': var_match.group(2).strip(),
                    'missing_counts': defaultdict(int)
                }
                continue
                
            # Match missing values per wave
            missing_match = re.match(r'^\s+Missing\s+\.:\s+(\d+)/(\d+)$', line)
            if missing_match and current_var:
                missing_count = int(missing_match.group(1))
                total = int(missing_match.group(2))
                current_var['missing_counts']['total'] = missing_count
                
            # Match wave-specific missing values
            wave_match = re.match(r'^-> wave = (\d{4})', line)
            if wave_match and current_var:
                wave = wave_match.group(1)
                next_line = next(f)
                missing_match = re.match(r'^\s+Missing\s+\.:\s+(\d+)/(\d+)$', next_line.strip())
                if missing_match:
                    current_var['missing_counts'][wave] = int(missing_match.group(1))
                    
    if current_var:
        variables.append(current_var)
        
    return variables

def generate_csv(variables, output_path):
    with open(output_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        
        # Write header
        header = ['Variable', 'Description']
        waves = sorted({wave for var in variables for wave in var['missing_counts'] if wave != 'total'})
        header.extend(waves)
        writer.writerow(header)
        
        # Write data
        for var in variables:
            if var['name'] == 'wave':
                continue
                
            row = [var['name'], var['description']]
            for wave in waves:
                row.append(var['missing_counts'].get(wave, 0))
            writer.writerow(row)

if __name__ == '__main__':
    log_path = 'chnscomm/1m07comfm_variable_index.log'
    output_path = 'chnscomm/1m07comfm_variable_missing_table.csv'
    
    variables = parse_log_file(log_path)
    generate_csv(variables, output_path)
    print(f"Generated missing value table at {output_path}")
