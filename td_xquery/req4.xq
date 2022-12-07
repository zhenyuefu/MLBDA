<results>{
    for $r in //restaurant
    for $v in //ville
    where $r/@ville = $v/@nom
    return
        <restaurant nom="{$r/@nom}" dept="{$v/@department}" />
}
</results>

(:autre solution:)

<results>{
    for $r in //restaurant
    return <restaurant nom="{$r/@nom}" dept="{//ville[@nom=$r/@ville]/@department}" />
}
</results>