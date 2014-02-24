
teg=`cat $HOME/.species`
#cd $HOME/$teg
cd ldist

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
cd ..

