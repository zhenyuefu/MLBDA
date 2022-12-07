<results>{
    for $r in //restaurant
    where $r/@etoile =2
    return <restaurant nom="{$r/@nom}" >
    {for $m in $r/menu
    return <menu nom="{$m/@nom}" />}
    </restaurant>
    }</results>
