<#list codelists as codeListInfo>
=== `${codeListInfo.codeList.id}`
[horizontal]
<#if codeListInfo.codeList.description?trim?has_content!false>
Description:: ${codeListInfo.codeList.description}
</#if>
<#if codeListInfo.codeList.parentId?has_content!false>
Subset of:: <<_${codeListInfo.codeList.parentId?replace("-", "_")},`${codeListInfo.codeList.parentId}`>>
</#if> 
<#if codeListInfo.tailored?has_content!false>
Tailored by:: ${codeListInfo.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codeListInfo.codeList.sourceVersion?has_content!false>
Version:: ${codeListInfo.codeList.sourceVersion}
</#if>

xref:code-lists/${codeListInfo.codeList.id}.adoc[See details]

'''

</#list>
