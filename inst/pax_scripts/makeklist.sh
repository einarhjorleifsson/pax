:
if [ ! -f $HOME/.species ]
then
	echo "Must select species first" 1>&2
	sleep 10
	xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 200x70+300+100 -borderwidth 3 -bordercolor black
	exit 1
fi
teg=`cat $HOME/.species`

if [ ! -d $HOME/$teg ]
then
	mkdir $HOME/$teg
fi
cd $HOME/$teg

if [ ! -d keys ]
then
	cp -r /usr/local/reikn/src/Stofnmat/setup/$teg/keys keys
fi
cd keys
for i in v?
do
for j in s?
do
for k in t?
do
list="$list $i$j$k"
done
done
done
echo $list
cd

