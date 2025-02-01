*****对6份comm数据集进行筛选、重命名、合并

// 1. 变量索引和缺失值分析
foreach file in 1m07comfm 2m16comfp 3m07comin 4m16comtv 5m16hlth1 6m16hlth2 {
    local data_dir "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）"
    use "`data_dir'/`file'_副本.dta", clear
    
    // 生成变量索引报告
    codebook, compact
    misstable summarize
    
    // 按wave分组统计变量有效值
    capture log close
    local log_dir "`base_dir'/logs"
    log using "`log_dir'/`file'_variable_index.log", replace text
    codebook
    misstable summarize
    
    // 按wave分组统计各变量有效值数量
    foreach var of varlist _all {
        bysort wave: tabstat `var', statistics(n) format(%9.0f) save
        matrix stats = r(StatTotal)
        local wave_count = rowsof(stats)
        forvalues i = 1/`wave_count' {
            local wave_val = stats[`i',1]
            local valid_count = stats[`i',2]
            display "Wave `wave_val': Variable `var' has `valid_count' valid values"
        }
    }
    
    log close
    display "Variable index with wave statistics saved to `file'_variable_index.log"
    
}

//tohere，根据经济含义，与log，人工筛选……

// 2. 变量筛选和重命名【遍历6份文件，对各个变量及其标签 生成一份 varlist，以表格形式，可以以txt文件；结合各自的file_variable_index,将各个变量在 wave每个取值的缺失值情况 列在标签后，即，每个变量作为行名称，wave的各个取值作为列 】
// 根据分析目的筛选变量并重命名
foreach file in 1m07comfm 2m16comfp 3m07comin 4m16comtv 5m16hlth1 6m16hlth2 {
    use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/`file'_副本.dta", clear
    
    // 示例：筛选交通基础设施相关变量
    keep commid wave road* highway* transport* T1-T4 O23 O23A O24
    
    // 重命名变量
    rename road* road_*
    rename highway* highway_*
    rename transport* transport_*
    
    // 保存处理后的数据
    save "`file'_cleaned.dta", replace
}

// 3. 数据合并
use "1m07comfm_cleaned.dta", clear
foreach file in 2m16comfp 3m07comin 4m16comtv 5m16hlth1 6m16hlth2 {
    merge 1:1 commid wave using "`file'_cleaned.dta"
    drop _merge
}

// 4. 面板数据清洗
gen wave_index = .
replace wave_index = 1 if wave == 1989
replace wave_index = 2 if wave == 1991
replace wave_index = 3 if wave == 1993
replace wave_index = 4 if wave == 1997
replace wave_index = 5 if wave == 2000
replace wave_index = 6 if wave == 2004
replace wave_index = 7 if wave == 2006
replace wave_index = 8 if wave == 2009
replace wave_index = 9 if wave == 2011
replace wave_index = 10 if wave == 2015

xtset commid wave_index
xtbalance, range(1,10)
distinct commid

// 保存最终数据集
save "chns_comm_panel.dta", replace

// 后面需要把code拆分成几个do：dataclean、featurecap、modeloutcomes
// do file最后一行多留出来
