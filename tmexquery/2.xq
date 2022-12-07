<results>{
for $o in //open_auctions/auction[position()<4]
return <result id="{$o/@id}">
  {$o/initial}
</result>
}
</results>