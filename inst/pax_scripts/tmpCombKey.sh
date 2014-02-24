:
# Combine all the keys into one

#PATH=$PATH:/home/haf/einarhj/01/batch

teg=`cat $HOME/.species`
cd $HOME/$teg
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
#echo $list1
llist=$list1
# Get the head for the key files, needs to be  globalize
head -2 v1s1t1.key > tmp
# Sum all age-length keys into one large file
for i in $llist
do
   if test `wc -l < $i` != 2
    then
     #echo $i
     project le aldur count kt0 kt1 ktcount < $i | tail +3  >> tmp 
    else
     echo " "
    fi
done
# Make an output file for combined age-length keys
   sorttable < tmp |\
   subtotal by le aldur on count kt0 kt1 ktcount |\
   sorttable -n  > key.all
rm tmp
##### End of setting all the age length keys into one file ####
## May not need the stuff here   
   sorttable < key.all |\
   select 'le > 95' |\
   sorttable -n  > key.95cm
  
   sorttable < key.all |\
   select 'le > 110' |\
   sorttable -n  > key.110cm
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
  head -2 key.all > $i.tmp
  project le aldur count kt0 kt1 ktcount < $i |\
  select 'le < 110' | tail +3 >> $i.tmp

  project le aldur count kt0 kt1 ktcount < key.110cm |\
  tail +3 >> $i.tmp
  echo "               Done >110 cm replacement for file: $i.tmp" >> $HOME/$teg/LOGFILE
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
      head -2 key.all > $i.tmp
      project le aldur count kt0 kt1 ktcount < $i |\
      select 'le < 95' | tail +3 >> $i.tmp
      project le aldur count kt0 kt1 ktcount < key.95cm |\
      tail +3 >> $i.tmp
      echo "               Done > 95 cm replacement for file: $i.tmp" >> $HOME/$teg/LOGFILE
    else
     echo " "
    fi
done

###### Finally renames the files`
cd $HOME/$teg/keys

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


teg=`cat $HOME/.species`
cd $HOME/$teg/batch
