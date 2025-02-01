import re
import csv
import os

base_dir = '/Users/zingli/learngit/chnscomm'
files = ['2m16comfp', '3m07comin', '4m16comtv', '5m16hlth1']

for file in files:
    log_file_path = os.path.join(base_dir, f'{file}_variable_index.log')
    csv_file_path = os.path.join(base_dir, f'{file}_variable_missing_table.csv')

    # 读取log文件内容
    with open(log_file_path, 'r', encoding='utf-8') as log_file:
        log_content = log_file.read()

    # 提取变量名和变量含义
    variable_pattern = re.compile(r'-{76}\n(.*?)\n-{76}\n(.*?)\n', re.DOTALL)
    variables = variable_pattern.findall(log_content)

    # 提取每个wave的缺失值数量
    wave_pattern = re.compile(r'-> wave = (\d+)\n\n    Variable \|         N\n-------------\+----------\n(.*?)\n-{24}', re.DOTALL)
    waves = wave_pattern.findall(log_content)

    # 解析每个wave的缺失值数量
    missing_values = {}
    for wave, data in waves:
        wave = f'Wave{wave}_Missing'
        missing_values[wave] = {}
        for line in data.split('\n'):
            if line.strip() and '|' in line:
                var, n = line.split('|')
                var = var.strip()
                n = n.strip()
                missing_values[wave][var] = n

    # 生成CSV文件
    with open(csv_file_path, 'w', newline='', encoding='utf-8') as csv_file:
        csv_writer = csv.writer(csv_file)
        header = ['Variable', 'Description'] + list(missing_values.keys())
        csv_writer.writerow(header)

        for var, desc in variables:
            var = var.strip()
            desc = desc.strip()
            # 跳过包含冗余信息的行
            if 'Type:' in desc or 'Range:' in desc or 'Unique values:' in desc or 'Mean:' in desc or 'Std. dev.:' in desc or 'Percentiles:' in desc:
                continue
            # 跳过文件头信息
            if 'log:' in desc or 'log type:' in desc or 'opened on:' in desc:
                continue
            # 跳过空行
            if not var or not desc:
                continue
            row = [var, desc]
            for wave in missing_values.keys():
                row.append(missing_values[wave].get(var, '0'))
            csv_writer.writerow(row)



