#!/bin/sh
#
# vpasksl.sh -- makes the sk and sl-files
#
# Modified: Einar March 2009 to act as a part of a batch file, running the PAX all in one sweep
# Modified: Einar February 2013 to change data location from u1/data to u2/data

#echo "vpasksl.sh is running now! "

teg=`cat $HOME/.species`
ar=`cat $HOME/.year`
if [ ! -d $HOME/$teg ]
then
        mkdir $HOME/$teg
fi
cd $HOME/$teg
if [ ! -d data ]
then
        mkdir data
fi
cd data

kfile=/u2/data/$teg/$teg'k'$ar.pre
lfile=/u2/data/$teg/$teg'l'$ar.pre
nfile=/u2/data/$teg/$teg'n'$ar.pre
#sfile=/u2/data/stodvar/s$ar.pre
sfile=/net/hafkaldi/export/home/haf/einarhj/01/data/SfileDoctored.pre
#echo "Trying $kfile, $nfile, $sfile"

if [ ! -f $kfile ]
then
        echo $kfile does not exist.
        echo "There are no more files to try - giving up" >> LOGFILE
	exit
fi

# stodvar
#echo "Er að gera stodvarskrá"
project record_id ar dag man reit smrt vf < $sfile |\
	sorttable  > stod
# Lengdir
#echo "Er ad gera lengdarskra"
project record_id lnr lfj < $nfile |\
	sorttable > t
jointable -a1 t stod |\
	project lnr dag man ar reit smrt vf lfj |\
	select 'lnr > 0' |\
	sorttable -n > $teg'sl'$ar.pre
project lnr < $teg'sl'$ar.pre |\
	sorttable -n > l
plokk l < $lfile > $teg'l'$ar.pre
# Kvarnir
#echo "Er ad gera kvarnaskra"
project record_id knr kfj < $nfile |\
	sorttable > t
jointable -a1 t stod |\
	project knr dag man ar reit smrt vf kfj |\
	select 'knr > 0' |\
	sorttable -n > $teg'sk'$ar.pre
project knr < $teg'sk'$ar.pre |\
	sorttable -n > k
plokk k < $kfile > $teg'k'$ar.pre
#echo "DONE!"
