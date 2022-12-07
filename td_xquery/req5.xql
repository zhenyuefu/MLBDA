(:<results>{:)
(:    for $r in //restaurant:)
(:    for $m in $r/menu:)
(:    for $v in //ville:)
(:    where $r/@ville=$v/@nom and $m/@prix=$v/plusBeauMonument/@tarif:)
(:    return <result>:)
(:    <restaurant nom="{$r/@nom}"/>:)
(:    <tarif prix="{$m/@prix}"/>:)
(:    </result>:)
(:}</results>:)

<results>
    for $r in //restaurant
    for $v in //ville
    for $p in distinct-values($r/menu/@prix)
    where $r/@ville=$v/@nom and $p=$v/plusBeauMonument/@tarif
    return <result>
    <restaurant nom="{$r/@nom}"/>
    <tarif prix="{$p}"/>
    </result>
</results>


(:<results>{:)
(:    for $r in //restaurant:)
(:    for $v in //ville:)
(:    where $r/@ville=$v/@nom and some $m in $r/menu satisfies $m/@prix=$v/plusBeauMonument/@tarif:)
(:    return <result>:)
(:    <restaurant nom="{$r/@nom}"/>:)
(:    <tarif prix="{$m/@prix}"/>:)
(:    </result>:)
(:    }:)
(:</results>:)