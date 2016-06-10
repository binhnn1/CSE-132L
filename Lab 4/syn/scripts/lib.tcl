#==============================================================================
#                      D E S I G N    P A R A M E T E R S
#==============================================================================
#
#
#
set PROJECT_NAME                "MIPS"
set TOP                         "mips"
set FILES                       "files_mips"
set clock_period                2.0

#==============================================================================
##                  D I R E C T O R Y   S T R U C T U R E
##==============================================================================
#
set synopsys_path                       [getenv "SYNOPSYS"]
set DESIGN                              $env(design)
set SOURCE                              "${DESIGN}"
set SCRIPTS                             "${PROJECT_NAME}/scripts"
set DBDIR                               "${PROJECT_NAME}/db"
set NETLIST                             "${PROJECT_NAME}/netlist"
set LOG                                 "${PROJECT_NAME}/log"
set REPORTS                             "${PROJECT_NAME}/reports"



if { ![file exists $NETLIST] || ![file isdirectory $NETLIST] } {
        file mkdir $NETLIST;
}

if { ![file exists $REPORTS] || ![file isdirectory $REPORTS] } {
        file mkdir $REPORTS;
}

if { ![file exists $LOG] || ![file isdirectory $LOG] } {
        file mkdir $LOG;
}

if { ![file exists $DBDIR] || ![file isdirectory $DBDIR] } {
        file mkdir $DBDIR;
}


#==============================================================================
##                       S E T U P    L I B R A R I E S
##==============================================================================
#
set LVT_TSMCHOME "/users/ugrad2/2012/spring/pooriam/libraries/"

set TECH_LIB_PATH_LVT_1P05_N40  "$LVT_TSMCHOME/saed32lvt_tt1p05vn40c.db"
set TECH_LIB_PATH  $TECH_LIB_PATH_LVT_1P05_N40;  
set MEM_LIB_LVT_1P05_N40    "saed32sram_tt1p05vn40c"
set MEM_LIB $MEM_LIB_LVT_1P05_N40;  
set DRIVE_CELL BUFFD12BWP12TLVT; 
set WC_OP_CONDS WCZ0D81COM;


set search_path [list . [format "%s%s"  $synopsys_path "/libraries/syn"] \
                        [format "%s%s"  $synopsys_path "/packages"] \
                        [format "%s%s"  $synopsys_path "/packages/IEEE"] \
                                                        ${LVT_TSMCHOME}         \
                                                        ${DESIGN}         \
/ecelib/linware/synopsys15/dc/packages/IEEE/src/ \
                                                ]

set search_path "$search_path ${SOURCE} ${DBDIR} ./"

set link_library   "* $TECH_LIB_PATH $MEM_LIB_LVT_1P05_N40"
set target_library   "$TECH_LIB_PATH "
set symbol_library   "generic.sdb "

set WIRELOAD_MODEL "tcForQA"

set_app_var synthetic_library dw_foundation.sldb
set_app_var link_library "* $link_library $target_library $synthetic_library"

