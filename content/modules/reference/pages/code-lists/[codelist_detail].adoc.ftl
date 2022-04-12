////
We need one page per codelist
The page will contain the same details as the index.adoc
for the codelist it documents. Additionally it will contain 
all the codes in the list together with their descriptions.
////

=== `${codelist_detail.codeList.id}`
[horizontal]
<#if codelist_detail.codeList.description?trim?has_content!false>
Description:: ${codelist_detail.codeList.description}
</#if>
<#if codelist_detail.tailored?has_content!false>
Tailored by:: ${codelist_detail.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codelist_detail.codeList.parentId?has_content!false>
Subset of:: <<_${codelist_detail.codeList.parentId?replace("-", "_")},`${codelist_detail.codeList.parentId}`>>
</#if> 
<#if codelist_detail.codeList.type?has_content!false>
Structure:: ${codelist_detail.codeList.type}
</#if> 
<#if codelist_detail.codeList.sourceCanonicalUri?trim?has_content!false>
URI:: ${codelist_detail.codeList.sourceCanonicalUri}
</#if> 
<#if codelist_detail.codeList.sourceVersion?has_content!false>
Version:: ${codelist_detail.codeList.sourceVersion}
</#if>
<#if codelist_detail.businessTerms?has_content!false>
Used in:: ${codelist_detail.businessTerms?map(bt -> "`" + bt.id + "` _" + bt.description + "_")?join(", ")}
</#if>
<#if codelist_detail.codes?has_content!false>
Codes:: ${codelist_detail.codes?map(c -> "`" + c.value + "`")?join(", ")}
</#if>

'''