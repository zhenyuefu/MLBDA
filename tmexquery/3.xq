<results>{
for $o in //open_auctions/auction[position()<4]
return <result id="{$o/@id}">
  <first>{$o/bidder[1]/increase/text()}</first>
  <last>{$o/bidder[last()]/increase/text()}</last>
</result>
}
</results>