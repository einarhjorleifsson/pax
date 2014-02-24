#!/bin/sh
#
# vpasksl.sh -- makes the sk and sl-files
#
# Modified: Einar March 2009 to act as a part of a batch file, running the PAX all in one sweep
# Modified: Einar February 2013 to change data location from u1/data to u2/data
# Modified: Einar February 2014 to run as a part of an R-package on linux

#echo "vpasksl.sh is running now! "

teg=`cat $HOME/.species`
ar=`cat $HOME/.year`
# Deleted below - work in the current directory
#if [ ! -d $HOME/$teg ]
#then
#        mkdir $HOME/$teg
#fi
#cd $HOME/$teg
if [ ! -d data ]
then
        mkdir data
fi
cd data

kfile=/net/hafkaldi/export/u2/data/$teg/$teg'k'$ar.pre
lfile=/net/hafkaldi/export/u2/data/$teg/$teg'l'$ar.pre
nfile=/net/hafkaldi/export/u2/data/$teg/$teg'n'$ar.pre
sfile=/net/hafkaldi/export/u2/data/stodvar/s$ar.pre
# Last years stuff: some doctoring done needs double checking
#sfile=/net/hafkaldi/export/home/haf/einarhj/01/data/SfileDoctored.pre
echo "Trying $kfile, $nfile, $sfile"

if [ ! -f $kfile ]
then
        echo $kfile does not exist.
        echo "There are no more files to try - giving up" >> LOGFILE
	exit
fi

# stodvar
preproject record_id ar dag man reit smrt vf < $sfile |\
	/usr/local/bin/sorttable  > stod
# Lengdir
preproject record_id lnr lfj < $nfile |\
	/usr/local/bin/sorttable > t
jointable -a1 t stod |\
	preproject lnr dag man ar reit smrt vf lfj |\
	/usr/local/bin/select 'lnr > 0' |\
	/usr/local/bin/sorttable -n > $teg'sl'$ar.pre
preproject lnr < $teg'sl'$ar.pre |\
	/usr/local/bin/sorttable -n > l
plokk l < $lfile > $teg'l'$ar.pre
# Kvarnir
preproject record_id knr kfj < $nfile |\
	/usr/local/bin/sorttable > t
jointable -a1 t stod |\
	preproject knr dag man ar reit smrt vf kfj |\
	/usr/local/bin/select 'knr > 0' |\
	/usr/local/bin/sorttable -n > $teg'sk'$ar.pre
preproject knr < $teg'sk'$ar.pre |\
	/usr/local/bin/sorttable -n > k
plokk k < $kfile > $teg'k'$ar.pre
