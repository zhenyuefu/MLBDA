<results>{
    for $l in distinct-values(//last)
        for $f in distinct-values(//author[last=$l]/first)
        return <result>
        <author>
            <last>{$l}</last>
            <first>{$f}</first>
        </author>
        {//book[author[last=$l]/first=$f]/title}
    </result>
}
</results>
(:author contient des elements en double:)