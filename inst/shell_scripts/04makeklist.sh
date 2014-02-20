:
teg=`cat $HOME/.species`
cd $HOME/$teg
if [ ! -d keys ]
then
	cp -r /home/haf/einarhj/src/Setup/keys keys
fi

echo "      copied the setup files for keys directory" >> LOGFILE
echo "             cp -r /home/haf/einarhj/src/Setup/keys keys" >> LOGFILE

#cd keys
#for i in v?
#do
#for j in s?
#do
#for k in t?
#do
#list="$list $i$j$k"
#done
#done
#done
#echo $list
cd

