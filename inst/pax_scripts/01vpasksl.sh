#!/bin/sh
#
# vpasksl.sh -- makes the sk and sl-files
#
# Modified: Einar March 2009 to act as a part of a batch file, running the PAX all in one sweep
# Modified: Einar February 2013 to change data location from u1/data to u2/data
# Modified: Einar February 2014 to run as a part of an R-package on linux

teg=`cat .species`
ar=`cat .year`
#paxpath=`cat .pax_path`
paxbin=`cat .pax_bin`


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
echo "Trying $kfile, $nfile, $sfile"  >> ../LOGFILE

if [ ! -f $kfile ]
then
        echo $kfile does not exist.
        echo "There are no more files to try - giving up" >> LOGFILE
	exit
fi

# Stodvar
$paxbin/preproject record_id ar dag man reit smrt vf < $sfile |\
	$paxbin/sorttable  > stod

# Lengdir
$paxbin/preproject record_id lnr lfj < $nfile |\
	$paxbin/sorttable > t
$paxbin/jointable -a1 t stod |\
	$paxbin/preproject lnr dag man ar reit smrt vf lfj |\
	$paxbin/select 'lnr > 0' |\
	$paxbin/sorttable -n > $teg'sl'$ar.pre
$paxbin/preproject lnr < $teg'sl'$ar.pre |\
	$paxbin/sorttable -n > l
$paxbin/plokk l < $lfile > $teg'l'$ar.pre

# Kvarnir
$paxbin/preproject record_id knr kfj < $nfile |\
	$paxbin/sorttable > t
$paxbin/jointable -a1 t stod |\
	$paxbin/preproject knr dag man ar reit smrt vf kfj |\
	$paxbin/select 'knr > 0' |\
	$paxbin/sorttable -n > $teg'sk'$ar.pre
$paxbin/preproject knr < $teg'sk'$ar.pre |\
	$paxbin/sorttable -n > k
$paxbin/plokk k < $kfile > $teg'k'$ar.pre
