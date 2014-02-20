:
teg=`cat $HOME/.species`
#cd $HOME/$teg
if [ ! -d ldist ]
then
	cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/ldist ldist
fi
#echo "  copied the setup files for ldist directory:" >> $HOME/$teg/LOGFILE
#echo "         cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/ldist ldist" >> $HOME/$teg/LOGFILE
