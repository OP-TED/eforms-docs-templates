<#list codelists?filter(cli -> !cli.codeList.official) as codeListInfo>
=== `${codeListInfo.codeList.id}`
[horizontal]
<#if codeListInfo.codeList.description?trim?has_content!false>
Description:: ${codeListInfo.codeList.description}
</#if>
<#if codeListInfo.tailored?has_content!false>
Tailored by:: ${codeListInfo.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codeListInfo.codeList.parentId?has_content!false>
Subset of:: <<_${codeListInfo.codeList.parentId?replace("-", "_")},`${codeListInfo.codeList.parentId}`>>
</#if> 
<#if codeListInfo.codeList.type?has_content!false>
Structure:: ${codeListInfo.codeList.type}
</#if> 
<#if codeListInfo.codeList.sourceCanonicalUri?trim?has_content!false>
URI:: ${codeListInfo.codeList.sourceCanonicalUri}
</#if> 
<#if codeListInfo.codeList.sourceVersion?has_content!false>
Version:: ${codeListInfo.codeList.sourceVersion}
</#if>
<#if codeListInfo.businessTerms?has_content!false>
Used in:: ${codeListInfo.businessTerms?map(bt -> "`" + bt.id + "` _" + bt.description + "_")?join(", ")}
</#if>
<#if codeListInfo.codes?has_content!false>
Codes:: ${codeListInfo.codes?map(c -> "`" + c.value + "`")?join(", ")}
</#if>

'''

</#list>