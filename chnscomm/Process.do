*****对6份comm数据集进行筛选、重命名、合并// 1. 变量索引和缺失值分析
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

// 2. 变量筛选和重命名【遍历6份文件，对各个变量及其标签 生成一份 varlist，以表格形式，可以以txt文件；结合各自的file_variable_index,将各个变量在 wave每个取值的缺失值情况 列在标签后，即，每个变量作为行名称，wave的各个取值作为列 】
// 根据分析目的筛选变量并重命名
//for 1m07comfm：wave all 载入文件
use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/1m07comfm_副本.dta", clear
 keep R6J_1 R20D  commid wave T1 T2 T3 T4
  rename R6J_1 han_percent
  label variable han_percent "PERCENT POPULATION: HAN"
  rename R20D local_cadres_fam_planning
  label variable local_cadres_fam_planning "LOCAL CADRES IMPLEMENTED FAM-PLANNING? //当地干部是否计划生育责任制 0=否 1=是，与经济挂钩 2=是，与经济无关"
  label variable commid "COMMUNITY ID"
  label variable wave "SURVEY YEAR"
  drop if wave==1989
save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/1m07comfm_merge.dta", replace
    
//for 2m16comfp：wave all
use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/2m16comfp_副本.dta", clear
 keep  P8_1 P8_2  P8_3  P8_4 P16_1 P32_1  P104_8 commid wave
  drop if wave==1989
  rename P8_1 good_rice_market_price
  label variable good_rice_market_price "GOOD RICE: FREE MARKET PRICE"
 rename P8_2 common_rice_market_price 
 label variable common_rice_market_price "RICE COMMONLY USED: FREE MARKET PRICE"
 rename P8_3 bleached_flour_market_price
 label variable bleached_flour_market_price "BLEACHED FLOUR: FREE MARKET PRICE"
 rename P8_4 unbleached_flour_market_price
 label variable unbleached_flour_market_price "UNBLEACHED FLOUR: FREE MARKET PRICE"
 rename P16_1 rapeseed_oil_market_price
 label variable rapeseed_oil_market_price "RAPESEED OIL: FREE MARKET PRICE"
 rename P32_1 pork_market_price
 label variable pork_market_price "PORK(FATTY&LEAN): FREE MARKET PRICE"
 rename P104_8 electricity_price
 label variable electricity_price "ELECTRICITY: RETAIL PRICE"
 label variable commid "COMMUNITY ID"
 label variable wave "SURVEY YEAR"
save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/2m16comfp_merge.dta", replace

//for 3m07comin：wave all
use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/3m07comin_副本.dta", clear
  keep O40 O42 O43 O44 O45 O52 O53 O63 O64_1 O64_2 O64_3 O64_5 O64_6 commid wave O0 O2 O8A   O16_9 O17_9 O17A_9 O255 O46 O41 O9C O9D O7C O7D      O90 O67_1 O67_2 O68_1 O68_2 O69_1 O69_2 O70_1 O70_2 O71_1 O71_2 O72_1 O72_2 O1 O3 O8B O9A O5 O4 O11 O8 O9 O10 O6 O7 O252 O253 O334 O335 O254 O255_1 O255_2 O255_3 O255_3A O255_4 O23 O25 O26 O342 O27 O28 O30 O31 O32 O33 O34 O35 O36 O39 O54 O56 O56A O57 O67A_1 O13A_2 O14A_2 O13A_4 O14A_4 O284 O285 O286 O294 O295 O16_1 O17_1 O17A_1 O16_2 O17_2 O17A_2 O16_3 O17_3 O17A_3 O16_4 O17_4 O17A_4 O16_7 O17_7 O17A_7 O309 O310 O311 O1A O1B O0A O270 O271 O9K O9L O9M_1 O9M_2 O9M_3 O9M_4 O9M_5 O47A O47C O48 O49 O51 O67A_1 O67A_2 O68A_1 O68A_2 O69A_1 O69A_2 O79 O80 O81 O82 O83 O84 O85 O86
  drop if wave == 1989
  * 交通设施相关变量
  rename O23 common_local_road
  label variable common_local_road "MOST COMMON KIND OF LOCAL ROAD //最常见的当地道路类型 1=土路 2=石头路、碎砂石与混合路 3=铺过的路 4=？【！！！！key traffic 变量】"
  rename O33 bus_stop
  label variable bus_stop "BUS STOP? //该村/居有公交车站/长途汽车站吗"
  rename O34 nearest_bus_stop_distance
  label variable nearest_bus_stop_distance "DISTANCE TO NEAREST BUS STOP (KM) //最近的公交车站/长途汽车站距离km"
  rename O35 train_station
  label variable train_station "TRAIN STATION? //该村/居有火车站吗"
  rename O36 nearest_train_station
  label variable nearest_train_station "DISTANCE TO NEAREST TRAIN STATION (KM) //最近的火车站距离km"
  rename O39 navigable_river
  label variable navigable_river "NEAR A NAVIGABLE RIVER? //该村/居靠近有航运的河流吗"

  * 市场与物价相关变量
  rename O13A_2 cooking_oil_store_location
  label variable cooking_oil_store_location "COOKING OIL: LOCATION OF POPULAR LARGE STORE //地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O14A_2 cooking_oil_store_distance
  label variable cooking_oil_store_distance "COOKING OIL: DISTANCE(KM) TO POPULAR LG STORE //距离km"
  rename O13A_4 meat_poultry_store_location
  label variable meat_poultry_store_location "MEAT/POULTRY: LOCATION OF POPULAR LARGE STORE //地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O14A_4 meat_poultry_store_distance
  label variable meat_poultry_store_distance "MEAT/POULTRY: DISTANCE(KM) TO POPULAR LG STORE //距离km"
  rename O284 supermarkets_within_30min
  label variable supermarkets_within_30min "SUPER/HYPERMKTS WITHIN 30-MIN BUS RIDE? //30分钟公交车内/5公里内有多少大型超市"
  rename O285 supermarkets_location
  label variable supermarkets_location "SUPER/HYPERMKTS LOC. FOR MOST RESIDENTS? //百姓最常去的大超市 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O286 supermarkets_distance
  label variable supermarkets_distance "SUPER/HYPERMARKETS DISTANCE (KM)? //最常去的大超市距离km"
   **需求情况
   rename O294 food_retailers_out_of_business
   label variable food_retailers_out_of_business "FOOD RETAILERS OUT OF BUSINESS IN 3 YRS? //过去3年内有多少食品零售商关门"
   rename O295 new_supermarkets
   label variable new_supermarkets "NEW SUPER/HYPERMARKETS IN 3 YEARS? //过去3年内有多少新的大超市" //reflect 当地的需求情况？
  rename O16_1 grains_market_location
  label variable grains_market_location "GRAINS: LOCATION OF POPULAR FREE MARKET //购买食物与日常用品的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O17_1 grains_market_distance
  label variable grains_market_distance "GRAINS: DISTANCE(KM) TO POPULAR FREE MKT //距离km"
  rename O17A_1 grains_market_days_open
  label variable grains_market_days_open "GRAINS: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"
  rename O16_2 cooking_oil_market_location
  label variable cooking_oil_market_location "COOKING OIL: LOCATION OF POPULAR F-MKT //购买食物与日常用品的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O17_2 cooking_oil_market_distance
  label variable cooking_oil_market_distance "COOKING OIL: DISTANCE(KM) TO POPULAR F-MKT //距离km"
  rename O17A_2 cooking_oil_market_days_open
  label variable cooking_oil_market_days_open "COOKING OIL: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"
  rename O16_3 vegetables_market_location
  label variable vegetables_market_location "VEGETABLES: LOCATION OF POPULAR FREE MKT //购买食物与日常用品的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O17_3 vegetables_market_distance
  label variable vegetables_market_distance "VEGETABLES: DISTANCE(KM) TO POPULAR F-MKT //距离km"
  rename O17A_3 vegetables_market_days_open
  label variable vegetables_market_days_open "VEGETABLES: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"
  rename O16_4 meat_poultry_market_location
  label variable meat_poultry_market_location "MEAT/POULTRY: LOCATION OF POPULAR F-MKT //购买食物与日常用品的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O17_4 meat_poultry_market_distance
  label variable meat_poultry_market_distance "MEAT/POULTRY: DISTANCE(KM) TO POPULAR F-MKT //距离km"
  rename O17A_4 meat_poultry_market_days_open
  label variable meat_poultry_market_days_open "MEAT/POULTRY: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"
  rename O16_7 fish_market_location
  label variable fish_market_location "FISH: LOCATION OF POPULAR FREE MARKET //购买食物与日常用品的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O17_7 fish_market_distance
  label variable fish_market_distance "FISH: DISTANCE(KM) TO POPULAR F-MKT //距离km"
  rename O17A_7 fish_market_days_open
  label variable fish_market_days_open "FISH: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"
  rename O309 free_markets_within_30min
  label variable free_markets_within_30min "# OF FREE MARKETS IN 30-MIN BUS RIDE? //30分钟公交车内/5公里内有多少自由市场"
  rename O310 nearest_free_market_location
  label variable nearest_free_market_location "LOCATION OF NEAREST FREE MARKET?  //最近的自由市场地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类商店"
  rename O311 nearest_free_market_distance
  label variable nearest_free_market_distance "DISTANCE TO FREE MARKET? //最近的自由市场距离km 在本村，距离=0"

  * 工资与劳动力相关变量
  rename O47A wage_male
  label variable wage_male "WAGE/DAY FOR ORDINARY MALE WORKER //普通男工(一般职业)日工资"
  rename O47C wage_female
  label variable wage_female "WAGE/DAY FOR ORDINARY FEMALE WORKER //普通女工(一般职业)日工资"
  rename O48 wage_babysitting
  label variable wage_babysitting "WAGE/DAY FOR BABYSITTING OR CHILDCARE //保姆或托儿日工资"
  rename O49 wage_construction
  label variable wage_construction "WAGE/DAY FOR ORDINARY CONSTRUCTN WORKER //普通建筑工人日工资"
  rename O51 wage_driver
  label variable wage_driver "WAGE/MONTH FOR LOCAL WORK UNIT DRIVER //当地司机月工资"
  rename O46 farm_laborer_wage
  label variable farm_laborer_wage "VILL: WAGE/DAY FOR UNSKILLD FARM LABORER //村居无技术农民工日工资"
  rename O42 workforce_agriculture
  label variable workforce_agriculture "% WORK FORCE ENGAGED IN AGRICULTURE //该村/居委会从事农业的劳动力比例"
  rename O43 workforce_outside_town
  label variable workforce_outside_town "% WORKING OUTSIDE TOWN > 1 MONTH //该村/居委会外出打工超过1个月的劳动力比例"
  rename O44 workforce_large_enterprise
  label variable workforce_large_enterprise "% WORKING IN ENTERPRISE WITH 20+ PEOPLE //该村/居委会在有20人以上的企业工作的劳动力比例"
  rename O45 workforce_small_enterprise
  label variable workforce_small_enterprise "% WORKING IN ENTERPRISE WITH < 20 PEOPLE //该村/居委会在有20人以下的企业工作的劳动力比例"
  
  rename O52 local_collectives //当地本土企业状况
   label variable local_collectives "ENTERPRISE: ANY LOCALLY-RUN COLLECTIVES? //该村/居委会是否有自己的企业"
   rename O53 num_local_collectives
   label variable num_local_collectives "ENTERPRISE: # LOCALLY-RUN COLLECTIVES //该村/居委会有多少个自己的企业"
   replace local_collectives = num_local_collectives if (num_local_collectives > 0 & num_local_collectives != 99)
   replace local_collectives = 0 if local_collectives == .
   label variable local_collectives "ENTERPRISE: ANY LOCALLY-RUN COLLECTIVES? //该村/居委会有多少本土企业"
   drop num_local_collectives
  rename O63 percent_collectives
  label variable percent_collectives "ENTERPRISE: % RUN AS COLLECTIVES //该村/居委会企业中有多少是集体所有制(由村居委会自己经营的)"
  rename O54 specialized_households
  label variable specialized_households "SUB/VILL: ENTERPRISE:# OF SPECIALIZED HH //村居办的企业中有多少个专业户"
  rename O56 self_employed_enterprises
  label variable self_employed_enterprises "ENTERPRISE: # SELF-EMPLOYED ENTERPRISES //村居办的企业中有多少个自雇企业"
  rename O56A private_enterprises
  label variable private_enterprises "ENTERPRISE: # OF PRIVATE ENTERPRISES //村居办的企业中有多少个私营企业"

  * 基础设施与公共服务相关变量
  rename O25 telegraph_service
  label variable telegraph_service "TELEGRAPH SERVICE? //该村/居是否有便利的电报服务"
  rename O26 telephone_service
  label variable telephone_service "TELEPHONE SERVICE? //该村/居是否有便利的电话服务"
  rename O342 cell_phone_service
  label variable cell_phone_service "VIL/N'HOOD SERVICE: CELL PHONE? //该村/居是否有移动电话服务"
  rename O27 postal_service
  label variable postal_service "POSTAL SERVICE? //该村/居是否有邮政服务"
  rename O28 daily_newspaper
  label variable daily_newspaper "REC'V DAILY NEWSPAPER ON DAY PUBLISHED? //该村/居是否当天收到日报"
  rename O30 electricity
  label variable electricity "ELECTRICITY? //该村/居通电了吗？"
  rename O31 daily_electricity_hours
  label variable daily_electricity_hours "AVG # HRS/DAY ELECTRICAL POWER AVAILABLE //每天有多少小时供电"
  rename O32 weekly_eleccutoff_days
  label variable weekly_eleccutoff_days "AVG # DAYS/WK ELECTRICAL POWER CUT OFF //过去的三个月里，每周有多少天停电"
  rename O90 clinics_count
  label variable clinics_count "# OF CLINICS IN NEIGHBORHOOD/VIL //村居诊所数量"

  * 地理与人口相关变量
  rename O1 neighborhood_area
  label variable neighborhood_area "AREA OF NEIGHBORHOOD/VIL (SQ. KM) //村居面积"
  rename O3 city_area
  label variable city_area "AREA OF CITY (SQ. KM) //城市面积"
  rename O8B town_area
  label variable town_area "AREA OF TOWN (SQ. KM) //镇面积"
  rename O9A vil_to_township_dis
  label variable vil_to_township_dis "DISTANCE FROM VIL TO TOWNSHIP SEAT //村居到乡镇政府所在地的距离"
  rename O5 vil_to_township_dis2
  label variable vil_to_township_dis2 "DISTANCE FROM VIL TO TOWNSHIP SEAT //村居到乡镇政府所在地的距离"
  rename O4 city_provcapital
  label variable city_provcapital "IS THE CITY THE PROVINCIAL CAPITAL? //城市是否是省会"
  rename O11 city_to_provcapital_dis
  label variable city_to_provcapital_dis "DISTANCE FROM CITY TO THE PROVINCIAL CAP //城市到省会的距离"
  rename O8 town_to_provcapital_dis
  label variable town_to_provcapital_dis "DISTANCE FROM TOWN TO THE PROVINCIAL CAP //镇到省会的距离"
  rename O9 vil_to_nearest_city_distance
  label variable vil_to_nearest_city_distance "DISTANCE FROM VIL TO NEAREST URBAN CITY //村居到最近的城市的距离"
  rename O10 vil_to_provcapital_dis
  label variable vil_to_provcapital_dis "DISTANCE FROM VIL TO PROVINCIAL CAPI //村居到省会的距离"
  rename O6 vil_to_county_seat_dis
  label variable vil_to_county_seat_dis "DISTANCE FROM VIL TO COUNTY SEAT //村居到县城的距离"
  rename O7 vil_to_provcapital_distance2
  label variable vil_to_provcapital_distance2 "DISTANCE FROM VIL TO PROVINCIAL CAPI //村居到省会的距离"
  rename O0 neighborhood_population
  label variable neighborhood_population "POPULATION OF NEIGHBORHOOD/VIL //村居人口"
  rename O2 city_population
  label variable city_population "CITY NGHBRHD: POPULATION OF CITY //城市居委会人口"
  rename O8A town_population
  label variable town_population "TOWN: POPULATION OF TOWN //镇人口"
  rename O270 county_city_pop
  label variable county_city_pop "COUNTY/CITY TOTAL POPULATION? //相对地位"
  rename O271 county_city_area
  label variable county_city_area "COUNTY/CITY TOTAL AREA (SQ KM)?"
  rename O1A admin_district_2000
  label variable admin_district_2000 "ADMIN DISTRICT: IN 2000 //1=城市居委会 2=郊区村（居委会） 3=县城居委会 4=农村,maybe保留234"
  rename O1B admin_district_changed
  label variable admin_district_changed "ADMIN DISTRICT: CHANGED SINCE 2000?"
  rename O0A householdsnum
  label variable householdsnum "# OF HOUSEHOLDS IN NEIGHBORHOOD/VIL"
  rename O57 farmland
  label variable farmland "FARMLAND: IS THERE FARMLAND? //该村/居委会是否有耕地"
  rename O41 home_ownership
  label variable home_ownership "WHO OWNS HOMES IN NGHBRHD/VIL //村居房屋所有权"

  * 示范乡镇相关变量 级别与类型
    rename O9K model_township
    label variable model_township "SUB/VILL: LOCATED IN A MODEL TOWNSHIP? //是否位于示范乡镇【只问sub/vill，没有县城？】"
    rename O7C vil_model_township
    label variable vil_model_township "VIL: LOCATED IN A MODEL TOWNSHIP? //是否位于示范乡镇"
    rename O9C suburb_model_township
    label variable suburb_model_township "SUBURB: LOCATED IN A MODEL TOWNSHIP? //是否位于示范乡镇"
    gen model_township_combined = .
    replace model_township_combined = model_township if !missing(model_township)
    replace model_township_combined = vil_model_township if !missing(vil_model_township) & missing(model_township_combined)
    replace model_township_combined = suburb_model_township if !missing(suburb_model_township) & missing(model_township_combined)
    replace model_township_combined = 2 if (model_township_combined == 1 & vil_model_township == 0) | (model_township_combined == 0 & vil_model_township == 1)
    replace model_township_combined = 2 if (model_township_combined == 1 & suburb_model_township == 0) | (model_township_combined == 0 & suburb_model_township == 1)
    replace model_township_combined = 2 if (vil_model_township == 1 & suburb_model_township == 0) | (vil_model_township == 0 & suburb_model_township == 1)
    replace model_township_combined = 1 if model_township_combined == 2 //check后认为符合1
    label variable model_township_combined "合并后的示范乡镇标识 (0=否, 1=是)"
    drop model_township vil_model_township suburb_model_township
    replace model_township_combined = 0 if missing(model_township_combined)
    rename model_township_combined model_township
    rename O7D vil_model_township_level
    label variable vil_model_township_level "VIL: LEVEL OF MODEL TOWNSHIP //示范乡镇的级别"
    rename O9L model_township_level
    label variable model_township_level "SUB/VILL: LEVEL OF MODEL TOWNSHIP? //示范乡镇的级别 1=县级 2=市级 3=省级 4=国家级"
    rename O9D suburb_model_township_level
    label variable suburb_model_township_level "SUBURB: LEVEL OF MODEL TOWNSHIP //示范乡镇的级别"
    gen model_township_level_combined = .
    replace model_township_level_combined = model_township_level if !missing(model_township_level)
    replace model_township_level_combined = vil_model_township_level if !missing(vil_model_township_level) & missing(model_township_level_combined)
    replace model_township_level_combined = suburb_model_township_level if !missing(suburb_model_township_level) & missing(model_township_level_combined)
    replace model_township_level_combined = 5 if (model_township_level_combined != vil_model_township_level & !missing(model_township_level_combined) & !missing(vil_model_township_level))
    replace model_township_level_combined = 5 if (model_township_level_combined != suburb_model_township_level & !missing(model_township_level_combined) & !missing(suburb_model_township_level))
    replace model_township_level_combined = 5 if (vil_model_township_level != suburb_model_township_level & !missing(vil_model_township_level) & !missing(suburb_model_township_level))
    label variable model_township_level_combined "合并后的示范乡镇级别 (0=非示范乡镇, 1-4=示范乡镇级别, 5=冲突)"
    drop model_township_level vil_model_township_level suburb_model_township_level
    replace model_township_level_combined = 0 if missing(model_township_level_combined)
    rename model_township_level_combined model_township_level
    rename O9M_1 model_twp_econ_dev
    label variable model_twp_econ_dev "TYPE OF MODEL TWP: ECON DEVELOPMENT //示范乡镇的类型 1=经济开发"
    rename O9M_2 model_twp_env_san
    label variable model_twp_env_san "TYPE OF MODEL TWP: ENVI/SANITATION"
    rename O9M_3 model_twp_fam_plan
    label variable model_twp_fam_plan "TYPE OF MODEL TWP: FAMILY PLANNING"
    rename O9M_4 model_twp_admin
    label variable model_twp_admin "TYPE OF MODEL TWP: ADMINISTRITIVE //示范乡镇的类型 4=行政管理"
    rename O9M_5 model_twp_other
    label variable model_twp_other "TYPE OF MODEL TWP: OTHER //示范乡镇的类型 5=其他(注明)"
    replace model_township = 1 if model_twp_econ_dev == 1
    replace model_township = 2 if model_twp_env_san == 1
    replace model_township = 3 if model_twp_fam_plan == 1
    replace model_township = 4 if model_twp_admin == 1
    replace model_township = 5 if model_twp_other == 1
    label variable model_township "示范乡镇类型 (0=否, 非0：1=经济开发，2=环境卫生，3=计划生育，4=行政管理，5=其他)"
    drop model_twp_econ_dev model_twp_env_san model_twp_fam_plan model_twp_admin model_twp_other

  
  * 其他变量
  rename O40 near_open_trade_area
  label variable near_open_trade_area "NEAR OPEN TRADE AREA/CITY(< 2HR BY BUS)? //是否靠近开放城市（bus小于2h）"
  rename O252 park_location
  label variable park_location "CLOSEST PARK/ENTERTNMT CTR: LOCATION //最近的公园/娱乐中心地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类"
  rename O253 park_distance
  label variable park_distance "CLOSEST PARK/ENTERTNMT CTR: DISTANCE(KM) //最近的公园/娱乐中心距离km"
  rename O334 nearest_playground_location
  label variable nearest_playground_location "LOCATION: NEAREST VILL/N'HOOD PLAYGROUND //大多数居民可以去的最近的村/居体育场 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类"
  rename O335 nearest_playground_distance
  label variable nearest_playground_distance "DISTANCE TO NEAREST VILL/N'HOOD PLAYGROUND //最近的村/居体育场距离km"
  rename O254 fewer_bike_to_work
  label variable fewer_bike_to_work "FEWER PEOPLE BIKE TO WORK THAN LST SURVE //你们村居骑自行车上班的人比上次调查时少了？"
  rename O255 stop_biking_reasons
  label variable stop_biking_reasons "WHY PEOPLE STOPPED BIKING TO WORK //停止骑自行车上班的原因"
  rename O255_1 stop_biking_pollution
  label variable stop_biking_pollution "WHY STOP BIKING: POLLUTION //停止骑自行车的原因 1=污染"
  rename O255_2 stop_biking_traffic
  label variable stop_biking_traffic "WHY STOP BIKING: TRAFFIC //停止骑自行车的原因 2=路上车太多、交通危险"
  rename O255_3 stop_biking_fewer_lanes
  label variable stop_biking_fewer_lanes "WHY STOP BIKING: FEWER BIKE LANES //停止骑自行车的原因 3=自行车道少"
  rename O255_3A stop_biking_use_car
  label variable stop_biking_use_car "WHY STOP BIKING: NOW USE CAR/TAXI //停止骑自行车的原因 3A=现在用汽车或出租车"
  rename O255_4 stop_biking_other
  label variable stop_biking_other "WHY STOP BIKING: OTHER REASON //停止骑自行车的其他原因"
  rename O64_1 revenue_housing_subsidy
  label variable revenue_housing_subsidy "SUB/VILL: REVENUES FUND HOUSING SUBSIDY? //企业收入是否用于住房补贴[sub/vill]"
  rename O64_2 revenue_health_insurance
  label variable revenue_health_insurance "SUB/VILL: REVENUES FUND HEALTH INSURNCE? //村居办的企业收入是否用于医疗保险[sub/vill]"
  rename O64_3 revenue_education_subsidy
  label variable revenue_education_subsidy "SUB/VILL: REVENUES FUND EDUCATION SUBS? //村居办的企业收入是否用于教育补贴[sub/vill]"
  rename O64_5 revenue_road_repair
  label variable revenue_road_repair "SUB/VILL: REVENUES FUND ROAD REPAIR? //村居办的企业收入是否用于修路[sub/vill]"
  rename O64_6 revenue_farm_inputs
  label variable revenue_farm_inputs "SUB/VILL: REVENUES FUND FARM INPUTS? //村居办的企业收入是否用于农业投入[sub/vill]"
  rename O16_9 fabric_market_location
  label variable fabric_market_location "FABRIC: LOCATION OF POPULAR FREE MARKET //购买食物与日常用品的自由市场地点"
  rename O17_9 fabric_market_distance
  label variable fabric_market_distance "FABRIC: DISTANCE(KM) TO POPULAR FREE MKT //距离km"
  rename O17A_9 fabric_market_days_open
  label variable fabric_market_days_open "FABRIC: # OF DAYS/WK FREE MARKET OPEN //自由市场每周开放的天数"

  rename O67_1 private_childcare_under3
  label variable private_childcare_under3 "PRIVATE CHILDCARE (AGE<3Y): IN COMMUNITY? //社区内有无私立托儿所"
  rename O67_2 private_childcare_3to6
  label variable private_childcare_3to6 "PRIVATE CHILDCARE (AGE 3-6Y): IN COMMUNITY? //社区内有无私立托幼机构"
  rename O68_1 private_childcare_under3_dis
  label variable private_childcare_under3_dis "PRIVATE CHILDCARE (AGE<3Y): DISTANCE(KM) //私立托儿所距离"
  rename O68_2 private_childcare_3to6_dis
  label variable private_childcare_3to6_dis "PRIVATE CHILDCARE (AGE 3-6Y): DISTANCE(KM) //私立托幼机构距离"
  rename O69_1 private_childcare_under3_fee
  label variable private_childcare_under3_fee "PRIVATE CHILDCARE (AGE<3Y): FEE/MONTH //私立托儿所月费"
  rename O69_2 private_childcare_3to6_fee
  label variable private_childcare_3to6_fee "PRIVATE CHILDCARE (AGE 3-6Y): FEE/MONTH //私立托幼机构月费"
  rename O70_1 public_childcare_under3
  label variable public_childcare_under3 "PUBLIC CHILDCARE (AGE<3Y): IN VIL? //村居有无公立托儿所"
  rename O70_2 public_childcare_3to6
  label variable public_childcare_3to6 "PUBLIC CHILDCARE (AGE 3-6Y): IN VIL? //村居有无公立托幼机构"
  rename O71_1 public_childcare_under3_dis
  label variable public_childcare_under3_dis "PUBLIC CHILDCARE (AGE<3Y): DISTANCE(KM) //公立托儿所距离"
  rename O71_2 public_childcare_3to6_dis
  label variable public_childcare_3to6_dis "PUBLIC CHILDCARE (AGE 3-6Y): DISTANCE(KM) //公立托幼机构距离"
  rename O72_1 public_childcare_under3_fee
  label variable public_childcare_under3_fee "PUBLIC CHILDCARE (AGE<3Y): FEE/MONTH //公立托儿所月费"
  rename O72_2 public_childcare_3to6_fee
  label variable public_childcare_3to6_fee "PUBLIC CHILDCARE (AGE 3-6Y): FEE/MONTH //公立托幼机构月费"

  rename O67A_1 private_childcare_under3_2
  label variable private_childcare_under3_2 "PRIVATE CHILDCARE (AGE<3Y):IN COMMUNITY? //社区有无私立托儿所"
  rename O67A_2 private_childcare_3to6_2
  label variable private_childcare_3to6_2 "PRIVATE CHILDCARE(AGE 3-6Y):IN COMMUNTY? //社区有无私立托幼机构"
  rename O68A_1 private_childcare_under3_dis_2
  label variable private_childcare_under3_dis_2 "PRIVATE CHILDCARE (AGE<3Y): DISTANCE(KM)//私立托儿所距离"
  rename O68A_2 private_childcare_3to6_dis_2
  label variable private_childcare_3to6_dis_2 "PRIVATE CHILDCARE (AGE 3-6Y): DISTANCE(KM) //私立托幼机构距离"
  rename O69A_1 private_childcare_under3_fee_2
  label variable private_childcare_under3_fee_2 "PRIVATE CHILDCARE (AGE<3Y): FEE/MONTH //私立托儿所月费"
  rename O69A_2 private_childcare_3to6_fee_2
  label variable private_childcare_3to6_fee_2 "PRIVATE CHILDCARE (AGE 3-6Y): FEE/MONTH //私立托幼机构月费"
  rename O79 public_primary_school
  label variable public_primary_school "PUBLIC PRIMARY SCHOOL: IN VILLAGE?"
  rename O80 public_primary_school_dis
  label variable public_primary_school_dis "PUBLIC PRIMARY SCHOOL: DISTANCE(KM)"
  rename O81 public_lower_middle_school
  label variable public_lower_middle_school "PUBLIC LOWER-MIDDLE SCHOOL: IN VILLAGE?"
  rename O82 public_lower_middle_school_dis
  label variable public_lower_middle_school_dis "PUBLIC LOWER-MIDDLE SCHOOL: DISTANCE(KM)"
  rename O83 public_upper_middle_school
  label variable public_upper_middle_school "PUBLIC UPPER-MIDDLE SCHOOL: IN VILLAGE?"
  rename O84 public_upper_middle_school_dis
  label variable public_upper_middle_school_dis "PUBLIC UPPER-MIDDLE SCHOOL: DISTANCE(KM)"
  rename O85 vocational_school
  label variable vocational_school "VOCATIONAL SCHOOL: IN VILLAGE?"
  rename O86 vocational_school_distance
  label variable vocational_school_distance "VOCATIONAL SCHOOL: DISTANCE(KM)"

save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/3m07comin_merge.dta", replace

//for 4m16comtv,wave=2009,2011,2015,drop all
//for 5m16hlth1   wave=1989,1991,1993,1997,2000,2004,2006,2009
use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/5m16hlth1_副本.dta", clear
  keep Q1 Q7_1 Q8_1 Q7_2 Q8_2  Q9 Q12   Q23   Q7_12 Q8_12 Q7_11 Q8_11 Q7_7 Q8_7 commid wave
      drop if wave==1989
      rename Q1 health_facility_num
      label variable health_facility_num "HEALTH FACILITY NUMBER //卫生设施数量"
      rename Q7_1 full_time_western_doctors
      label variable full_time_western_doctors "FULL TIME WESTERN DOCTORS //全职西医医生数量"
      rename Q8_1 adjunct_western_doctors
      label variable adjunct_western_doctors "ADJUNCT WESTERN DOCTORS //兼职西医医生数量"
      rename Q7_2 full_time_traditional_doctors
      label variable full_time_traditional_doctors "FULL TIME TRADITIONAL DOCTORS //全职中医医生数量"
      rename Q8_2 adjunct_traditional_doctors
      label variable adjunct_traditional_doctors "ADJUNCT TRADITIONAL DOCTORS //兼职中医医生数量"
      rename Q9 gov_paid_staff_percentage
      label variable gov_paid_staff_percentage "PERCENTAGE OF STAFF SALARIES PAID BY GOV //工资由政府支付的员工比例"
      rename Q12 total_patient_beds
      label variable total_patient_beds "TOTAL PATIENT BEDS //病床总数"
      rename Q23 facility_opendays_perweek
      label variable facility_opendays_perweek "DAYS FACILITY OPEN PER WEEK //设施每周开放的天数"
      rename Q7_12 full_time_rural_doctors
      label variable full_time_rural_doctors "FULL TIME RURAL DOCTORS //全职农村医生数量"
      rename Q8_12 adjunct_rural_doctors
      label variable adjunct_rural_doctors "ADJUNCT RURAL DOCTORS //兼职农村医生数量"
      rename Q7_11 full_time_dentists
      label variable full_time_dentists "FULL TIME DENTISTS //全职牙医数量"
      rename Q8_11 adjunct_dentists
      label variable adjunct_dentists "ADJUNCT DENTISTS //兼职牙医数量"
       rename Q7_7 full_time_nurses
      label variable full_time_nurses "FULL TIME NURSES //全职护士数量"
      rename Q8_7 adjunct_nurses
      label variable adjunct_nurses "ADJUNCT NURSES //兼职护士数量"
      label variable commid "COMMUNITY ID //2006ver"
      label variable wave "SURVEY YEAR"
save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/5m16hlth1_merge.dta", replace

// for 6m16hlth2, wave=2011,2015, sample 是别的2倍
use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/6m16hlth2_副本.dta", clear
  keep commid wave hlthfac O19 O20 O21 O21A O21B O21C O21D O22
      drop if wave==1989
      rename hlthfac facility_num
      label variable facility_num "FACILITY NUMBER //健康服务设施数量"
      rename O19 facility_type
      label variable facility_type "FACILITY TYPE //设施类型 1=村诊所 2=私人诊所 3=单位诊所 4=其他诊所 5-乡计生服务机构 6=乡医院 7=县妇幼保健院 8=县医院 9=市妇幼保健院 10=市医院 11=职工医院 12=其他医院 13=药店 15=其他"
      rename O20 facility_location
      label variable facility_location "FACILITY LOCATION //设施地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类"
      rename O21 facility_distance
      label variable facility_distance "FACILITY DISTANCE(KM) //设施距离km"
      rename O21A facility_business_hours
      label variable facility_business_hours "FACILITY BUSINESS HOURS (HOURS/WEEK) //设施每周营业时间"
      rename O21B facility_doctors_num
      label variable facility_doctors_num "FACILITY # OF DOCTORS //设施医生数量"  // 这些数据 看看用其他变量填补进去
      rename O21C facility_beds_num
      label variable facility_beds_num "FACILITY # OF HOSPITAL BEDS //设施病床数量"
      rename O21D facility_registration_fee
      label variable facility_registration_fee "FACILITY REGISTRATION FEE (YUAN) //设施挂号费"
      rename O22 facility_most_used
      label variable facility_most_used "MOST OFTEN USED? //2004年以来（调查年10年前）最常用的设施是否被取代？ 1=是 2=否"
      label variable commid "COMMUNITY ID //2006ver"
      label variable wave "SURVEY YEAR"
save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/6m16hlth2_merge.dta", replace

****数据合并
 *检查重复情况
  foreach file in 1m07comfm 2m16comfp 3m07comin 5m16hlth1 6m16hlth2 {
      use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/`file'_merge.dta", clear
      duplicates report commid wave
  }
  use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/5m16hlth1_merge.dta", clear
    collapse (mean) health_facility_num full_time_western_doctors adjunct_western_doctors full_time_traditional_doctors adjunct_traditional_doctors gov_paid_staff_percentage total_patient_beds facility_opendays_perweek full_time_rural_doctors adjunct_rural_doctors full_time_dentists adjunct_dentists full_time_nurses adjunct_nurses, by(commid wave)
    save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/5m16hlth1_merge.dta", replace
  use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/6m16hlth2_merge.dta", clear
    collapse (mean) facility_num facility_type facility_location facility_distance facility_business_hours facility_doctors_num facility_beds_num facility_registration_fee facility_most_used, by(commid wave)
    save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/6m16hlth2_merge.dta", replace
  
  * 加载第一个数据文件
  use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/1m07comfm_merge.dta", clear
  * 定义需要合并的文件列表
  local files 2m16comfp 3m07comin 5m16hlth1 6m16hlth2
  * 初始化计数器
  local merge_counter 1
  * 循环合并其他文件
  foreach file in `files' {
      * 合并数据
      merge 1:1 commid wave using "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/$temp/`file'_merge.dta"
      * 重命名 _merge 变量
      rename _merge _merge`merge_counter'
      * 增加计数器
      local merge_counter = `merge_counter' + 1
  }
      label variable health_facility_num "HEALTH FACILITY NUMBER //卫生设施数量"
      label variable full_time_western_doctors "FULL TIME WESTERN DOCTORS //全职西医医生数量"
      label variable adjunct_western_doctors "ADJUNCT WESTERN DOCTORS //兼职西医医生数量"
      label variable full_time_traditional_doctors "FULL TIME TRADITIONAL DOCTORS //全职中医医生数量"
      label variable adjunct_traditional_doctors "ADJUNCT TRADITIONAL DOCTORS //兼职中医医生数量"
      label variable gov_paid_staff_percentage "PERCENTAGE OF STAFF SALARIES PAID BY GOV //工资由政府支付的员工比例"
      label variable total_patient_beds "TOTAL PATIENT BEDS //病床总数"
      label variable facility_opendays_perweek "DAYS FACILITY OPEN PER WEEK //设施每周开放的天数"
      label variable full_time_rural_doctors "FULL TIME RURAL DOCTORS //全职农村医生数量"
      label variable adjunct_rural_doctors "ADJUNCT RURAL DOCTORS //兼职农村医生数量"
      label variable full_time_dentists "FULL TIME DENTISTS //全职牙医数量"
      label variable adjunct_dentists "ADJUNCT DENTISTS //兼职牙医数量"
      label variable full_time_nurses "FULL TIME NURSES //全职护士数量"
      label variable adjunct_nurses "ADJUNCT NURSES //兼职护士数量"
      label variable facility_num "FACILITY NUMBER //健康服务设施数量"
      label variable facility_type "FACILITY TYPE //设施类型 1=村诊所 2=私人诊所 3=单位诊所 4=其他诊所 5-乡计生服务机构 6=乡医院 7=县妇幼保健院 8=县医院 9=市妇幼保健院 10=市医院 11=职工医院 12=其他医院 13=药店 15=其他"
      label variable facility_location "FACILITY LOCATION //设施地点 1=在本村/居 2=在本市另一居 3=在另一个村/镇/县 9=从不购买/没有此类"
      label variable facility_distance "FACILITY DISTANCE(KM) //设施距离km"
      label variable facility_business_hours "FACILITY BUSINESS HOURS (HOURS/WEEK) //设施每周营业时间"
      label variable facility_doctors_num "FACILITY # OF DOCTORS //设施医生数量"  // 这些数据 看看用其他变量填补进去
      label variable facility_beds_num "FACILITY # OF HOSPITAL BEDS //设施病床数量"
      label variable facility_registration_fee "FACILITY REGISTRATION FEE (YUAN) //设施挂号费"
      label variable facility_most_used "MOST OFTEN USED? //2004年以来（调查年10年前）最常用的设施是否被取代？ 1=是 2=否"
save "/Users/zingli/learngit/chnscomm/chnscomm_mergeraw.dta", replace
save "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/chnscomm_mergeraw.dta", replace

//todo 重构建，面板！！分析！！


**交通有关问题趋势预观察
    use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/3m07comin_副本.dta", clear
    keep O23 commid wave T1 T2 T3 T4
    drop if wave==1989
    * 计算硬化路的比例
    gen is_hard_road = (O23==3)
    drop if T2==1
    * 计算每年硬化路的比例
    collapse (mean) is_hard_road, by(wave)
    * 绘制硬化路比例随年份变化的图形
    twoway (line is_hard_road wave), title("硬化路比例随年份变化")
    //1997低谷，然后开始爬升，到2006顶峰

    gen is_hard_road = (O23==2 | O23==3)
    drop if T2==1
    //1997低估，然后开始上升，到2006达到顶峰，后面平稳，even下降（质量）

    gen is_hard_road = (O23==3)
    drop if T2==2
    //00-05有微微下降

    gen is_hard_road = (O23==3)
      drop if T2==2
    drop if T4==3|T4==4|T4==7|T4==8 //suburb208
    //00-05有微微下降
    gen is_hard_road = (O23==3)
    drop if T2==2
    drop if T4==1|T4==2|T4==5|T4==6 

  gen is_hard_road = (O23==3)
  drop if T2==1
  drop if T4==1|T4==5  //931vil
  //一个明显的逐步递增，但在2009年左右开始反复
  gen is_hard_road = (O23==3|O23==2)
  drop if T2==1
  drop if T4==1|T4==5
  //同样明显，只是2009下降幅度小


    gen is_hard_road = (O23==3)
    drop if T2==1
    keep if T4==1|T4==5 //town307

    gen is_hard_road = (O23==3|O23==2)
    drop if T2==1
    keep if T4==1|T4==5 
    //都一直处在高位，除了1997年突然下降

    use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/3m07comin_副本.dta", clear
    drop if wave==1989
    keep O23 O255_3A O26 O33 commid wave T1 T2 T3 T4

    gen fewerbikefordrive = (O255_3A==1)
    drop if T2==1
    drop if T4==1|T4==5
    collapse (mean) fewerbikefordrive, by(wave)
    * 绘制硬化路比例随年份变化的图形
    twoway (line fewerbikefordrive wave), title("比例随年份变化")
    //00之前无数据，上升后，06下降，09回升？

    //sub是04后就下降了——城市环保？

    gen telserv = (O26==1)
    collapse (mean) telserv, by(wave)
    * 绘制硬化路比例随年份变化的图形
    twoway (line telserv wave), title("比例随年份变化")//2000年已经顶峰

    gen busserv = (O33==1)
    collapse (mean) busserv, by(wave)
    * 绘制硬化路比例随年份变化的图形
    twoway (line busserv wave), title("比例随年份变化")
    //00后一直下上波动



foreach file in 1m07comfm 2m16comfp 3m07comin 4m16comtv 5m16hlth1 6m16hlth2 {
    use "/Users/zingli/Downloads/公路数据/chns社区数据1989-2015/CHNS_1989-20152015社区数据（stata格式）/`file'_副本.dta", clear
    
    // 示例：筛选交通基础设施相关变量
    keep commid wave road* highway* transport* T1-T4 O23
    
    // 重命名变量
     rename road* road_*
     rename highway* highway_*
     rename transport* transport_*
    
    // 保存处理后的数据
    save "`file'_cleaned.dta", replace
}


egen miss_han_percent = total(missing(han_percent)), by()
 egen miss_local_cadres_fam_planning = total(missing(local_cadres_fam_planning)), by()

// 4. 面板数据清洗,对-9/9等也处理为缺失值
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
