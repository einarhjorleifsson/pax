:
paxpath=`cat .pax_path`
paxbin=`cat .pax_bin`
PATH=$PATH:$paxpath
teg=`cat .species`
ar=`cat .year`

cd keys
##### Set all the age length keys into one file, key.all #####
# Get the list of all .key files
for i in v?
do
for j in s?
do
for k in t?
do
list1="$list1 $i$j$k.key"
done
done
done
echo $list1
llist=$list1
# Get the head for the key files, needs to be  globalize
head -n +2 v1s1t1.key > tmp
# Sum all age-length keys into one large file
for i in $llist
do
   if test `wc -l < $i` != 2
    then
     echo $i
     $paxbin/preproject le aldur count kt0 kt1 ktcount < $i | tail -n +3  >> tmp 
    else
     echo " "
    fi
done
# Make an output file for combined age-length keys
   $paxbin/sorttable < tmp |\
   $paxbin/subtotal by le aldur on count kt0 kt1 ktcount |\
   $paxbin/sorttable -n  > key.all
rm tmp
##### End of setting all the age length keys into one file ####
## May not need the stuff here   
   $paxbin/sorttable < key.all |\
   $paxbin/select 'le > 95' |\
   $paxbin/sorttable -n  > key.95cm
  
   $paxbin/sorttable < key.all |\
   $paxbin/select 'le > 110' |\
   $paxbin/sorttable -n  > key.110cm
## May not need the stuff above

### Replace 110 cm fish keys in each cell with the combined key
##     Do this only for v2s1t1 & v2s2t1
#        Get the names of the files
for i in v2
do
for j in s?
do
for k in t1
do
list2="$list2 $i$j$k.key"
done
done
done
#echo "This is for the gill nets: $list2"
llist=$list2
#        Do the replacement
for i in $llist
do
  #echo "Adding 110cm plus to file: $i"
  head -n +2 key.all > $i.tmp
  $paxbin/preproject le aldur count kt0 kt1 ktcount < $i |\
  $paxbin/select 'le < 110' | tail -n +3 >> $i.tmp

  $paxbin/preproject le aldur count kt0 kt1 ktcount < key.110cm |\
  tail -n +3 >> $i.tmp
  echo "               Done >110 cm replacement for file: $i.tmp"
done

### Replace 95 cm fish keys in each cell with the combined key
##     Do this for the remaining .key files
#        Get the names of the files
for i in v?
do
for j in s?
do
for k in t?
do
list3="$list3 $i$j$k.key"
done
done
done

#echo "These are the remaining keys: $list3"
llist=$list3


# Replace 95 cm fish keys with the combined key
for i in $llist
do
   if test `wc -l < $i` != 2
    then
      #echo "Adding 95cm plus to file: $i"
      head -n +2 key.all > $i.tmp
      $paxbin/preproject le aldur count kt0 kt1 ktcount < $i |\
      $paxbin/select 'le < 95' | tail -n +3 >> $i.tmp
      $paxbin/preproject le aldur count kt0 kt1 ktcount < key.95cm |\
      tail -n +3 >> $i.tmp
      echo "               Done > 95 cm replacement for file: $i.tmp" 
    else
     echo " "
    fi
done

###### Finally renames the files`


for i in v?
do
for j in s?
do
for k in t?
do
list4="$list4 $i$j$k.key.tmp"
done
done
done
#echo "These are the files to be renamed: $list4"



for i in $list4
do
 newname=`echo $i | sed 's/.key.tmp/.key/g'`
 #echo $newname
 mv $i $newname
done
echo "Well done!"


