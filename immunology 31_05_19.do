
****HEMATOLOGY DATA
gen timepoint = "."
replace timepoint = "D1" if redcap_event_name == "d45_follow_up_arm_1"
replace timepoint = "D2" if redcap_event_name == "d90_follow_up_arm_1"
replace timepoint = "D3" if redcap_event_name == "d180_follow_up_arm_1"
replace timepoint = "D0" if redcap_event_name == "discharge_arm_1"
replace timepoint = "A0" if redcap_event_name == "participant_enrolm_arm_1"
replace timepoint = "CP" if haembio_timepoint == 10
keep record_id haembio_collection_date haembio_collection_time timepoint

****TRANSFORM FREEZER WORKS

gen a = substr( sub_id,2,1)
drop if globallyuniquesampleid == ""
gen b = substr( sub_id,1,1)
gen c = substr( sub_id,3,2)
gen d = substr( sub_id,2,1)
gen e = substr( sub_id,4,2)
gen record_id = ""
tostring subject_id, replace
replace record_id = subject_id + b + c if a == "-"
replace record_id = subject_id + d + e if a != "-"
replace record_id = "20001100" if sub_id == "100"
destring record_id, replace
drop a b c d e
rename visit_type timepoint
***MERGE HAEMATOLOGY WITH FREEZER WORKS

gen day = substr( received_date,1,2)
gen month = substr( received_date,4,2)
gen year = substr( received_date,7,4)
gen hours = substr( haembio_collection_time, 1,2)
gen minutes = substr( haembio_collection_time, 4,2)
gen p = substr( haembio_collection_time, 5,1)
gen s = "0"
gen j = substr( haembio_collection_time,1,1)
gen x = substr( haembio_collection_time,5,1)
replace hours = s + j if x == ""
gen t = substr( haembio_collection_time,3,2)
replace minutes = t if x == ""
drop s j x t p

****collection date
gen temp_collectdate = day + month + year
gen temp_collectdatetime = temp_collectdate + hours + minutes

gen seconds = "00"                        
destring day month year, replace
destring seconds hours minutes, replace
gen tc = mdyhms( month , day , year , hours , minutes , seconds )
format tc %td
format %tcMon_DD,_CCYY_HH:MM:SS tc
format %tcMon_dd,_CCYY_HH:MM tc


gen collectiondate = mdy(month, day, year)
format collectiondate %td

***date and time processed
gen fhourslater = tc + tc(4:00)
format %13.0f fhourslater
format %15.0f fhourslater
format fhourslater %td
format %tcMon_dd,_CCYY_HH:MM fhourslater
gen hhr = hh( fhourslater)
gen mmr = mm( fhourslater)
tostring mmr, replace
gen t = substr(mmr,2,1)
gen l = "0"
replace mmr = l + mmr if t == ""
tostring hhr, replace
drop t l
gen temp_receivedate = temp_collectdate
gen temp_receivedatetime = temp_collectdate + hhr + mmr

***barcode
rename specimen_type sampletype
replace sampletype = "PBMC" if sampletype == "PBMC - Blue-Black Top"
replace sampletype = "HEPARIN" if sampletype == "PLASMA - BlueBlack Top"
replace sampletype = "WB" if sampletype == "CL075_CELLS"
replace sampletype = "WB" if sampletype == "CL075_SUP"
replace sampletype = "WB" if sampletype == "LPS_CELLS"
replace sampletype = "WB" if sampletype == "LPS_SUP"
replace sampletype = "WB" if sampletype == "Pam3Cys_Cells"
replace sampletype = "WB" if sampletype == "Pam3Cys_SUP"
replace sampletype = "WB" if sampletype == "RPMI1_CELLS"
replace sampletype = "WB" if sampletype == "RPMI1_SUP"
replace sampletype = "WB" if sampletype == "RPMI2_CELLS"
replace sampletype = "WB" if sampletype == "RPMI2_SUP"
replace sampletype = "WB" if sampletype == "SEB1_CELLS"
replace sampletype = "WB" if sampletype == "SEB1_SUP"
replace sampletype = "WB" if sampletype == "SEB2_CELLS"
replace sampletype = "WB" if sampletype == "SEB2_SUP"

gen code = "20-001-"
tostring record_id, replace
gen id = substr(record_id,6,3)
gen hyphen = "-"
gen barcode = code + sampletype + hyphen + timepoint + hyphen + id
drop code hyphen id

***date frozen for DNA and WHOLE BLOOD ASSAYS
gen processdate = collectiondate + 1
format processdate %td
gen newday = day(processdate)
gen newmonth = month(processdate)
gen newyear = year(processdate)
tostring newday, replace
tostring newmonth, replace
tostring newyear, replace
gen p = substr(newday,2,1)
gen q = "0"
replace newday = q + newday if p == ""
gen r = substr(newmonth,2,1)
gen s = "0"
replace newmonth = s + newmonth if r == ""
drop p q r s
gen temp_datefrozen = newday + newmonth + newyear
gen timefrozen = "0800"
gen temp_datefrozentime1 = newday + newmonth + newyear + timefrozen

*****PLASMA AND PBMC SAMPLES FROZEN TIME
***date and time processed :same day for pbmc and plasma 8 hours after collection
gen eighthourslater = tc + tc(8:00)
format %13.0f eighthourslater
format %15.0f eighthourslater
format eighthourslater %td
format %tcMon_dd,_CCYY_HH:MM eighthourslater
gen hhf = hh( eighthourslater)
gen mmf = mm( eighthourslater)
tostring mmf, replace
tostring hhf, replace
gen t = substr(mmf,2,1)
gen k = substr(hhf,2,1)
gen l = "0"
replace mmf = l + mmf if t == ""
replace hhf = l + hhf if k == ""
tostring hhf, replace
drop t l k
gen temp_datefrozentime2 = temp_collectdate + hhf + mmf

gen temp_datefrozentime = "."
replace temp_datefrozentime = temp_datefrozentime1 if sampletype == "DNA" | sampletype == "WB"
replace temp_datefrozentime = temp_datefrozentime2 if sampletype == "PBMC" | sampletype == "HEPARIN"
order record_id temp_collectdatetime temp_receivedatetime temp_datefrozentime spec_value1 spec_desc1 timepoint barcode

replace spec_desc1 = "millions of cells" if sampletype == "PBMC"
replace spec_desc1 = "ml" if sampletype == "HEPARIN"
replace spec_desc1 = "ml" if sampletype == "DNA"
replace spec_desc1 = "ml" if sampletype == "WB"


replace spec_value1 = "0.5" if sampletype == "HEPARIN"
replace spec_value1 = "0.25" if sampletype == "DNA"
replace spec_value1 = "1.5" if sampletype == "WB"

*****
sort haembio_collection_date
duplicates drop record_id timepoint sampletype, force
save "C:\Users\PROBOOK G3\Desktop\kidms immunology 14_08_19.dta", replace

preserve
use "C:\Users\PROBOOK G3\Desktop\kidms immunology 14_08_19.dta"
keep if sampletype == "DNA"
save "C:\Users\PROBOOK G3\Desktop\kidms DNA.dta"
restore
preserve
use "C:\Users\PROBOOK G3\Desktop\kidms immunology 14_08_19.dta"
keep if sampletype == "PBMC"
save "C:\Users\PROBOOK G3\Desktop\kidms PBMC.dta"
restore
preserve
use "C:\Users\PROBOOK G3\Desktop\kidms immunology 14_08_19.dta"
keep if sampletype == "HEPARIN"
save "C:\Users\PROBOOK G3\Desktop\kidms HEPARIN.dta"
restore
preserve
use "C:\Users\PROBOOK G3\Desktop\kidms immunology 14_08_19.dta"
keep if sampletype == "WB"
save "C:\Users\PROBOOK G3\Desktop\kidms WB.dta"
restore


