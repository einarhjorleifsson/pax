:
# The batch script for "the official" 2008 catch in numbers calculation for 
# iCod done in march 2009. Note that these are run on sun machines, not on
# local Linux.
# The numered script were copied from
# /usr(/...
# to
# /home/haf/einarhj/01/batch/
# Various comments and X11 window prompts were removed from these scripts
# but NO ALTERATIONS were  done to the official code
# Note that the setup files for cod, like definitions for s1 and s2
# were copied from
# /usr
# to
# /home/haf/einarhj/src/Setup
# Alterations were done to those setup files, in particular to the gear files (v?)
# to reflect the ever increasing number of gear codes.
# Non-standard featurese, that are year specific such as "borrowing" of length or
# age-length codes from one fleet to another are setup indside this batch sript
# Einar Hjörleifsson, March 2009




teg=`cat $HOME/.species`
ar=`cat $HOME/.year`
cd $HOME/$teg

# Generate a log file
echo "A log file" > $HOME/$teg/LOGFILE
echo " Operating on year $ar" >>  $HOME/$teg/LOGFILE
echo " Operating on species $teg" >>  $HOME/$teg/LOGFILE
echo " " >>  $HOME/$teg/LOGFILE
# First clean out any directories

# Use the next stuff with care
# OUTCOMMENTED
#rm -r agelen avelewt data keys ldist catch_no
# ADDED
rm -r agelen avelewt keys ldist catch_no
cd batch
echo "Copying scripts and setupfiles" >> $HOME/$teg/LOGFILE
00copyScripts.sh
echo "RUNNING 01vpasksl.sh - reading prelude files into /data" >> $HOME/$teg/LOGFILE
01vpasksl.sh

echo "RUNNING 02vpasksl.sh - setting up default file in /ldist" >> $HOME/$teg/LOGFILE
02makelslist.sh

echo "RUNNING 03ldist_5cm.sh - calculating length distribution in /ldist" >> $HOME/$teg/LOGFILE
03ldist_5cm.sh

echo "          #### Non standard features for cn in $ar - Borrowing length keys ####" >>  $HOME/$teg/LOGFILE
  #echo "Borrow length distribtuions" >> $HOME/$teg/LOGFILE
  teg=`cat $HOME/.species`
  cd $HOME/$teg/ldist
  mv v3s1t1.len v3s1t1.len.original
  cp v1s1t1.len v3s1t1.len
  echo "           cp v1s1t1.len v3s1t1.len" >> $HOME/$teg/LOGFILE
  mv v3s2t1.len v3s2t1.len.original
  cp v1s2t1.len v3s2t1.len
  echo "           cp v1s2t1.len v3s2t1.len" >> $HOME/$teg/LOGFILE
echo "          #### End non standard features                                    ####" >>  $HOME/$teg/LOGFILE
cd $HOME/$teg/batch

echo "RUNNING 04makeklist.sh - setting up default file in /keys"  >> $HOME/$teg/LOGFILE
04makeklist.sh

echo "RUNNING 05agematkey_5cm.sh - calculating age-length key in /keys" >> $HOME/$teg/LOGFILE
05agematkey_5cm.kt.sh

 echo "          #### Non standard features for cn 2008 - Borrowing age-length keys ####" >>  $HOME/$teg/LOGFILE
  echo "            1. Make a copy of the original files, name them #.key.original" >>  $HOME/$teg/LOGFILE
     teg=`cat $HOME/.species`
     cd $HOME/$teg/keys
       for i in *.key
       do
       cp $i $i.original
       done
   
   echo "            2. Use "common" age-length keys for older fish" >>  $HOME/$teg/LOGFILE 
     echo "             Start the large length falsify - tmpCombKey.sh" >> $HOME/$teg/LOGFILE
       teg=`cat $HOME/.species`
       cd $HOME/$teg/batch
       tmpCombKey.sh

   echo "             3. Borrow age-length keys" >>  $HOME/$teg/LOGFILE
    teg=`cat $HOME/.species`
    cd $HOME/$teg/keys
     cp v6s1t2.key v2s1t2.key 
     echo "                cp v6s1t2.key v2s1t2.key" >> $HOME/$teg/LOGFILE
     cp v6s1t2.key v2s1t2.ke
     echo "                cp v6s1t2.key v2s1t2.key" >> $HOME/$teg/LOGFILE   
     cp v6s2t2.key v2s2t2.key 
     echo "                cp v6s2t2.key v2s2t2.key" >> $HOME/$teg/LOGFILE    
     cp v1s1t1.key v3s1t1.key 
     echo "                cp v1s1t1.key v3s1t1.key" >> $HOME/$teg/LOGFILE    
     cp v1s1t2.key v3s1t2.key 
     echo "                cp v1s1t2.key v3s1t2.key" >> $HOME/$teg/LOGFILE    
     cp v1s2t1.key v3s2t1.key 
     echo "                cp v1s2t1.key v3s2t1.key" >> $HOME/$teg/LOGFILE    
     cp v1s2t2.key v3s2t2.key 
     echo "                cp v1s2t2.key v3s2t2.key" >> $HOME/$teg/LOGFILE    
     cp v6s2t1.key v5s2t1.key 
     echo "                cp v6s2t1.key v5s2t1.key" >> $HOME/$teg/LOGFILE     
     cp v6s2t2.key v5s2t2.key
     echo "                cp v6s2t2.key v5s2t2.key" >> $HOME/$teg/LOGFILE
 cd $HOME/$teg/batch
echo "          #### End non standard features                                    ####" >>  $HOME/$teg/LOGFILE

echo "RUNNING 06agelen.kt.sh - calculating xxx" >> $HOME/$teg/LOGFILE
06agelen.kt.sh
echo "RUNNING 07avalewt.kt.sh - calculating average length and weight at age in /awelwt" >> $HOME/$teg/LOGFILE
07avelewt.kt.sh
#echo "Making the par directory"
#echo 'source("LandingsByVST.R")' | R --save
echo "RUNNING  08catchnum.kt.sh" >> $HOME/$teg/LOGFILE
08catchnum.kt.sh
echo "DONE!"
