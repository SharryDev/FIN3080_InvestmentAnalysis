* Clear existing data and logs
clear all
capture log close

* Set working directory
cd "/Users/sharry/Desktop/FIN3080"

* Import combined balance sheet data
import excel "FS_Combas.xlsx", firstrow
drop if _n == 1 | _n == 2

* Rename variables for total assets and total liabilities
rename A001000000 ttas 
rename A002000000 ttlblt

* Extract year and month from the date variable
gen year = substr(Accper, 1, 4)
gen month = substr(Accper, 6, 7)
replace month = substr(month, 1, 2)

* Remove data for January
drop if month == "01"

* Convert year and month to numeric
destring year, replace
destring month, replace

* Drop data with report type "B"
drop if Typrep == "B"

* Create a new date variable in quarterly format
gen date_yq = ""
replace date_yq = string(year) + "-01" if month == 3
replace date_yq = string(year) + "-02" if month == 6
replace date_yq = string(year) + "-03" if month == 9
replace date_yq = string(year) + "-04" if month == 12

* Convert the new date variable to quarterly format
gen date_yq_new = quarterly(date_yq, "YQ")
format date_yq_new %tq

* Drop the old date variable
drop date_yq

* Rename the new date variable
rename date_yq_new date_yq

* Save the processed balance sheet data
save "processed_data_AE.dta", replace

* Merge balance sheet data with stock data
merge 1:1 Stkcd date_yq using processed_data

* Convert rdexp and ttas to numeric
destring rdexp, replace
destring ttas, replace

* Calculate R&D to Asset ratio
gen RDAratio = rdexp/ttas

* Drop the _merge variable from previous merges
drop _merge

* Merge with company profile data
merge m:1 Stkcd using processed_data_profile

* Create an index variable within each stock code and date
bysort Stkcd Trdmnt: gen index = _n

* Display statistics for R&D to Asset ratio
tabstat RDAratio, stat(n mean median p25 p75 sd)

* Drop specific observations
drop if _n == 233831 | _n == 233832

* Convert Markettype to numeric
destring Markettype, replace

* Save the final processed data
save "processed_data_AE.dta", replace

* Analyze Main board data
clear all
use processed_data_AE if inlist(Markettype, 1, 4, 64)

* Display statistics for R&D to Asset ratio on Main board
tabstat RDAratio, stat(n mean median p25 p75 sd)

* Analyze GEM board data
clear all
use processed_data_AE if inlist(Markettype, 16, 32)

* Display statistics for R&D to Asset ratio on GEM board
tabstat RDAratio, stat(n mean median p25 p75 sd)

