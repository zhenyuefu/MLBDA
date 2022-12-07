<results>{
    for $m in document("guide.xml")//menu
    return <menu nom="{$m/@nom}"/>
}
</results>