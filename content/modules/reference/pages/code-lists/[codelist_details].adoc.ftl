////
We need one page per codelist
The page will contain the same details as the index.adoc
for the codelist it documents. Additionally it will contain 
all the codes in the list together with their descriptions.
////

=== `${codelist_details.codeList.id}`
[horizontal]
<#if codelist_details.codeList.description?trim?has_content!false>
Description:: ${codelist_details.codeList.description}
</#if>
<#if codelist_details.codeList.parentId?has_content!false>
Subset of:: <<_${codelist_details.codeList.parentId?replace("-", "_")},`${codelist_details.codeList.parentId}`>>
</#if> 
<#if codelist_details.tailored?has_content!false>
Tailored by:: ${codelist_details.tailored?map(tcl -> "<<_" + tcl.id?replace("-", "_") + ",`" + tcl.id + "`>>")?join(", ")}
</#if>
<#if codelist_details.codeList.type?has_content!false>
Structure:: ${codelist_details.codeList.type}
</#if> 
<#if codelist_details.codeList.sourceCanonicalUri?trim?has_content!false>
URI:: ${codelist_details.codeList.sourceCanonicalUri}
</#if> 
<#if codelist_details.codeList.sourceVersion?has_content!false>
Version:: ${codelist_details.codeList.sourceVersion}
</#if>
<#if codelist_details.businessTerms?has_content!false>
Used in:: ${codelist_details.businessTerms?map(bt -> "`" + bt.id + "` _" + bt.description + "_")?join(", ")}
</#if>
<#if codelist_details.codes?has_content!false>
Codes::
+
[horizontal]
  <#list codelist_details.codes as codelist>
  `${codelist.value}`::: ${codelist.description}
  </#list>
</#if>
