<#list codelists?filter(cl -> cl.parent_id?has_content!false) as codelist>
=== `${codelist.id}`
[horizontal]
<#if codelist.description?trim?has_content!false>
Description:: ${codelist.description}
</#if>
<#if codelist.tailored?has_content!false>
Tailored by:: ${codelist.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codelist.parent_id?has_content!false>
Subset of:: <<_${codelist.parent_id?replace("-", "_")},`${codelist.parent_id}`>>
</#if> 
<#if codelist.type?has_content!false>
Structure:: ${codelist.type}
</#if> 
<#if codelist.source_canonical_uri?trim?has_content!false>
URI:: ${codelist.source_canonical_uri}
</#if> 
<#if codelist.source_version?has_content!false>
Version:: ${codelist.source_version}
</#if>
<#if codelist.business_terms?has_content!false>
Used in:: ${codelist.business_terms?map(bt -> "`" + bt.id + "` _" + bt.description + "_")?join(", ")}
</#if>
<#if codelist.codes?has_content!false>
Codes:: ${codelist.codes?map(c -> "`" + c.value + "`")?join(", ")}
</#if>

'''

</#list>
