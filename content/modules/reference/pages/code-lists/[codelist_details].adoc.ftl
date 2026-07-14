= `${codelist_details.codeList.id}` codelist
:navtitle: Codelists

<#if codelist_details.codeList.description?trim?has_content!false>
${codelist_details.codeList.description}
</#if>
[horizontal]
<#if codelist_details.codeList.sourceVersion?has_content!false>
Version:: ${codelist_details.codeList.sourceVersion}
</#if>
<#if codelist_details.codeList.sourceCanonicalUri!?trim?has_content!false>
URI:: ${codelist_details.codeList.sourceCanonicalUri}
</#if> 
<#if codelist_details.codeList.parentId?has_content!false>
Subset of:: xref:code-lists/${codelist_details.codeList.parentId}.adoc[`${codelist_details.codeList.parentId}`]
</#if> 
<#if codelist_details.tailored?has_content!false>
Tailored by:: ${codelist_details.tailored?map(tcl -> "xref:code-lists/" + tcl.id + ".adoc[`" + tcl.id + "`]")?join(", ")}
</#if>
<#if codelist_details.codeList.type?has_content!false>
Structure:: ${codelist_details.codeList.type}
</#if>
<#if (codelist_details.codeList.official!false) && codelist_details.codeList.sourceLongNameListId?has_content!false>
EU Vocabularies:: https://op.europa.eu/en/web/eu-vocabularies/concept-scheme/-/resource?uri=${codelist_details.codeList.sourceLongNameListId}[View on EU Vocabularies^]
</#if>
<#if codelist_details.businessTerms?has_content!false>
Used in:: ${codelist_details.businessTerms?map(bt -> "xref:business-terms/" + bt.id + ".adoc[`" + bt.id + "`] " + bt.description)?join(", ")}
</#if>
<#if codelist_details.codes?has_content!false>

== Codes
[horizontal]
  <#list codelist_details.codes as codelist>
  `${codelist.value}`::: ${codelist.description}
  </#list>
</#if>
