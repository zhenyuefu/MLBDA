for $i in //africa/item
for $a in //closed_auctions/auction[itemref/@item=$i/@id]
return <res>
  {$i/name}
  {$a/price}
</res>