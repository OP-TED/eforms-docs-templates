<#list codelists as codeListInfo>
=== `${codeListInfo.codeList.id}`
<#if codeListInfo.codeList.description?trim?has_content!false>
${codeListInfo.codeList.description}
</#if>
[horizontal]
<#if codeListInfo.codeList.parentId?has_content!false>
Subset of:: <<_${codeListInfo.codeList.parentId?replace("-", "_")},`${codeListInfo.codeList.parentId}`>>
</#if> 
<#if codeListInfo.tailored?has_content!false>
Tailored by:: ${codeListInfo.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codeListInfo.codeList.sourceVersion?has_content!false>
Version:: ${codeListInfo.codeList.sourceVersion}
</#if>

See xref:code-lists/${codeListInfo.codeList.id}.adoc[details & codes]

'''

</#list>
