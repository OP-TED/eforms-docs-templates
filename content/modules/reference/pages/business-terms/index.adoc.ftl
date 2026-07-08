= Business Terms
:icons: font

<#macro btlist terms>
[cols="1,4,1,1", role="fixed-layout"]
|===
h| Identifier h| Description h| Data Type h| Details
<#list terms?sort_by("sortOrder") as term>
h| `${term.id}` | ${term.description!""} | `${term.type!"-"}` a| xref:business-terms/${term.id}.adoc[See fields]
</#list>
|===
</#macro>

<#macro bglist groups level>
<#if groups?has_content>
<#list groups as group>
[#${group.id}]
<#list 0..<level as i>=</#list> `${group.id}`: ${group.description!""}
<@btlist terms=group.terms />
<#if group.childGroups?has_content>
<#assign next=level+1 />
<@bglist groups=group.childGroups?sort_by("sortOrder") level=next />
</#if>
</#list>
</#if>
</#macro>

The following Business Terms are included in version {page-component-version} of eForms SDK.

// We display Business Terms grouped by Business Group
<@bglist groups=business_terms.groups?sort_by("id") level=2 />

// At the end we add an additional group with business terms that do not have a business group
<#if business_terms.ungroupedTerms?has_content>
== `Other`
// The Business Terms without Business Group
<@btlist terms=business_terms.ungroupedTerms />
</#if>
