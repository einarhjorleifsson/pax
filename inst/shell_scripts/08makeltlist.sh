:
teg=`cat $HOME/.species`
cd $HOME/$teg
cd ldist
for i in t?
do
list="$list $i"
done
echo $list
cd
