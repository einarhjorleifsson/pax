:

teg=`cat $HOME/.species`

cd $HOME/$teg

cd ldist

for i in v?
do
list="$list $i"
done
echo $list
cd
