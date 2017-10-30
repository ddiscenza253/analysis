#!/bin/tcsh -f

# ----- set parameters -----------------------------------------------------------------------------
set emailuser = "sean.jeffas@stonybrook.edu"

set scriptname = "Fun4All_G4_EICDetector_LQ"
set outfileprefix = "G4ePHENIX_Calorimeter_ZeroField_"
set outfilesuffix = "Test_1000"


set inputFile = "/direct/phenix+u/spjeffas/LQGENEP/Test.93event.root"

set nevent = 93
set pbeam = 250
set ebeam = 20

# directory where to get input from (all content copied to dir_submit)
set dir_macros = "/direct/phenix+u/spjeffas/macros/macros/g4simulations"

# where to store the output simulation files
set dir_data_out = "/direct/phenix+u/spjeffas/macros/macros/g4simulations/output"

# where to store log files
set dir_log = "/gpfs/mnt/gpfs02/phenix/scratch/spjeffas/logs"

# where to run the jobs and store temporary output
set dir_submit = "/gpfs/mnt/gpfs02/phenix/scratch/spjeffas/run"

# -----  check if directories exist, create if necessary -------------------------------------------
if ( ! -d $dir_data_out ) then
  echo "Directory ${dir_data_out} (dir_data_out) not found, abort..."
  exit
else
  echo "Directory ${dir_data_out} (dir_data_out) found, continue..."
endif

if ( ! -d $dir_log ) then
  echo "Directory ${dir_log} (dir_log) not found, abort..."
  exit
else
  echo "Directory ${dir_log} (dir_log) found, continue..."
endif

if ( ! -d $dir_submit ) then
  echo "Directory ${dir_submit} (dir_submit) not found, abort..."
  exit
else
  echo "Directory ${dir_submit} (dir_submit) found, continue..."
endif


# -----  prepare for jobs --------------------------------------------------------------------------
#to run for multiple single etas or phis, simply comment out one of the loops (remember the end at the bottom too!) and
#	change the eta_min's to eta_max's


set outfilename = "${outfileprefix}p${pbeam}_e${ebeam}_${nevent}events_${outfilesuffix}"
echo "Run for $outfilename"

						
            
# prepare job script file
set file_job = "run_${outfilename}.sh"

cat >> ${dir_submit}/$file_job << EOF
#!/bin/tcsh

#unsetenv OFFLINE_MAIN
#unsetenv ONLINE_MAIN
#unsetenv ROOTSYS
#source /opt/phenix/bin/phenix_setup.csh pro.online.1

cd ${dir_submit}

cp ${dir_macros}/*.C .
#/afs/rhic.bnl.gov/phenix/software/calibration/data/LuxorLinker.pl

time root -b -q ${scriptname}.C\(\"$nevent\",\"$ebeam\",\"$pbeam\",\"$inputFile\"\)                 

cp ${outfilename}.root ${dir_data_out}

ls -ltrh

EOF

chmod +x ${dir_submit}/$file_job

# prepare condor file
set file_condor = "condor_${outfilename}.job"

if ( -e ${dir_submit}/$file_condor ) then
rm ${dir_submit}/$file_condor
endif

cat >> ${dir_submit}/$file_condor << EOF
Executable      = ${dir_submit}/$file_job
Output          = ${dir_log}/condor_${scriptname}.out
Error           = ${dir_log}/condor_${scriptname}.error
Log             = ${dir_log}/condor_${scriptname}.log
Universe        = vanilla
Priority        = +20
Input           = /dev/null
GetEnv          = True
Initialdir      = ${dir_submit}
+Experiment     = "PHENIX"
+Job_Type       = "cas"
Notification    = Always
Notify_user     = ${emailuser}
Queue

EOF

# -----  submit all jobs to condor -----------------------------------------------------------------
cd $dir_submit

if ( ! -d ${dir_log} ) then
    mkdir ${dir_log}
endif

condor_submit $file_condor

cd -

end
