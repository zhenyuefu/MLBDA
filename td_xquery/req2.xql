<results>{
    for $m in document("guide.xml")//menu
    where $m/@prix <100
    return $m
}
</results>