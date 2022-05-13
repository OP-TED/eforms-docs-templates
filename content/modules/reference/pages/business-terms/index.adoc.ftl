= Business Terms

The following Business Terms are included in version X.X.X of eForms SDK.

// We display Business Terms grouped by Business Group
<#if business_terms.groups?has_content>
<#list business_terms.groups as group>
== `${group.id}`
[horizontal]
<#if group.description?has_content!false>
Group Description:: ${group.description}
</#if>
<#if group.childGroupIds?has_content>
Groups:: ${group.childGroupIds?map(g -> "<<" + g + ">>")?join(", ")}
</#if>

<#list group.terms as term>
=== `${term.id}`
[horizontal]
<#if term.description?has_content!false>
Description:: ${term.description}
</#if>
<#if term.type?has_content!false>
Type:: ${term.type}
</#if>

xref:business-terms/${term.id}.adoc[See details]

'''

</#list>
</#list>
</#if>

// At the end we add an additional group with business terms that do not have a business group
<#if business_terms.ungroupedTerms?has_content>
== `Other`
// The Business Terms without Business Group
<#list business_terms.ungroupedTerms as term>
=== `${term.id}`
[horizontal]
<#if term.description?has_content!false>
Description:: ${term.description}
</#if>
<#if term.type?has_content!false>
Type:: ${term.type}
</#if>

xref:business-terms/${term.id}.adoc[See details]

'''

</#list>
</#if>
